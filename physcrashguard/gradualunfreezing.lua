--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Gradual Unfreezing

	Got inspired by this addon https://steamcommunity.com/sharedfiles/filedetails/?id=3288286594
	Credits to the author of the addon.

	Not my intention to replace the addon, but to implement the concept here so that there's no need to install both.
	You can install both, no problem with it.

	For compatibility sake it will not work with that addon.

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


local DELAY = 0.03

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metatables: Entity; PhysObj, Player
--
local EntityMeta = FindMetaTable( 'Entity' )

local IsUnfreezable = EntityMeta.GetUnFreezable

local GetPhysicsObjectCount = EntityMeta.GetPhysicsObjectCount
local GetPhysicsObjectNum = EntityMeta.GetPhysicsObjectNum

local GetEntityTable = EntityMeta.GetTable

local IsValidEntity = EntityMeta.IsValid

local PhysObj = FindMetaTable( 'PhysObj' )

local VPhysicsIsMoveable	= PhysObj.IsMoveable
local VPhysicsIsValid		= PhysObj.IsValid
local VPhysicsEnableMotion	= PhysObj.EnableMotion
local VPhysicsSleep			= PhysObj.Sleep
local VPhysicsWake			= PhysObj.Wake
local VPhysicsGetEntity		= PhysObj.GetEntity

local GetAimTrace = FindMetaTable( 'Player' ).GetEyeTrace
local HasPlayerReleasedKey = FindMetaTable( 'Player' ).KeyReleased

--
-- Functions
--
local subsequent = ipairs( {} )

local GetCurTime = CurTime

local GamemodeCall = gamemode.Call

--
-- Globals, Utilities
--
local net = net


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Unfreezing enums
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local UNFREEZE_START = 0
local UNFREEZE_ABORT = 1
local UNFREEZE_PROGRESS = 2
local UNFREEZE_DONE = 3

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Network
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
util.AddNetworkString( 'physcrashguard.Unfreeze' )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Collect unfreezable objects
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local GetAllConstrainedEntitiesSequentially = physcrashguard.GetAllConstrainedEntitiesSequentially

local function CollectUnfreezable( pl, pLookupEntity )

	local tblUnfreezing = { [0] = 0 }
	local tblConstrainedEntities = GetAllConstrainedEntitiesSequentially( pLookupEntity )

	for _, pEntity in subsequent, tblConstrainedEntities, 0 do

		if ( IsUnfreezable( pEntity ) ) then
			continue
		end

		local numPhysObjs = GetPhysicsObjectCount( pEntity )

		for numObj = 1, numPhysObjs do

			local pPhysObj = GetPhysicsObjectNum( pEntity, numObj - 1 )

			if ( not GetEntityTable( pEntity ).m_PhysHang and VPhysicsIsMoveable( pPhysObj ) ) then
				continue
			end

			if ( not GamemodeCall( 'CanPlayerUnfreeze', pl, pEntity, pPhysObj ) ) then
				continue
			end

			local index = tblUnfreezing[0]
			index = index + 1

			tblUnfreezing[index] = pPhysObj
			tblUnfreezing[0] = index

		end

	end

	return tblUnfreezing

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Start gradual unfreezing
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function physcrashguard.StartGradualUnfreezing( pl )

	-- Compatibility: Physgun Unfreeze Over Time
	if ( _G.puot ) then
		return
	end

	local traceAim = GetAimTrace( pl )
	local pFacingEntity = traceAim.Entity

	if ( traceAim.HitNonWorld and IsValidEntity( pFacingEntity ) ) then

		local pl_t = GetEntityTable( pl )

		local tblPhysObjs = CollectUnfreezable( pl, pFacingEntity )

		if ( tblPhysObjs[0] == 0 ) then
			return
		end

		pl_t.m_Unfreezing = {

			m_tPhysObjs = tblPhysObjs;
			m_iNextTime = GetCurTime() + DELAY;
			m_iCurrent = 1

		}

		net.Start( 'physcrashguard.Unfreeze' )
			net.WriteUInt( UNFREEZE_START, 2 )
		net.Send( pl )

	end

	return false

end


local StartGradualUnfreezing = physcrashguard.StartGradualUnfreezing

hook.Add( 'OnPhysgunReload', 'PhysicsCrashGuard_GradualUnfreezing', function( pPhysGun, pl )

	local ret = StartGradualUnfreezing( pl )

	if ( ret ~= nil ) then
		return ret
	end

end )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Process gradual unfreezing
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local TryToRestore = physcrashguard.TryToRestore

function physcrashguard.ProcessGradualUnfreezing( pl )

	-- Compatibility: Physgun Unfreeze Over Time
	if ( _G.puot ) then
		return
	end

	local pl_t = GetEntityTable( pl )
	local Unfreezing = pl_t.m_Unfreezing

	if ( not Unfreezing ) then
		return
	end

	local flCurTime = GetCurTime()

	local tblPhysObjs = Unfreezing.m_tPhysObjs

	--
	-- Abort the process
	--
	if ( HasPlayerReleasedKey( pl, IN_RELOAD ) ) then

		--
		-- Freeze back the objects
		--
		for i, pPhysObj in subsequent, tblPhysObjs, 0 do

			if ( VPhysicsIsValid( pPhysObj ) and VPhysicsIsMoveable( pPhysObj ) ) then

				VPhysicsEnableMotion( pPhysObj, false )
				VPhysicsSleep( pPhysObj )

			end

		end

		pl_t.m_Unfreezing = nil

		net.Start( 'physcrashguard.Unfreeze' )
			net.WriteUInt( UNFREEZE_ABORT, 2 )
		net.Send( pl )

		return

	end

	local iTotal = tblPhysObjs[0]
	local iCurrent = Unfreezing.m_iCurrent

	--
	-- Stop unfreezing
	--
	if ( iCurrent > iTotal ) then

		pl_t.m_Unfreezing = nil

		net.Start( 'physcrashguard.Unfreeze' )
			net.WriteUInt( UNFREEZE_DONE, 2 )
			net.WriteUInt( iTotal, 12 )
		net.Send( pl )

		return

	end

	--
	-- Gradually unfreeze the objects
	--
	local iNextTime = Unfreezing.m_iNextTime

	if ( iNextTime < flCurTime ) then

		local pPhysObj = tblPhysObjs[iCurrent]

		--
		-- Terminate the process if one of the entities was removed
		--
		if ( not VPhysicsIsValid( pPhysObj ) ) then

			pl_t.m_Unfreezing = nil

			net.Start( 'physcrashguard.Unfreeze' )
				net.WriteUInt( UNFREEZE_ABORT, 2 )
			net.Send( pl )

			return

		end

		local pEntity = VPhysicsGetEntity( pPhysObj )

		if ( GetEntityTable( pEntity ).m_PhysHang ) then
			TryToRestore( pEntity )
		else

			VPhysicsEnableMotion( pPhysObj, true )
			VPhysicsWake( pPhysObj )

		end

		Unfreezing.m_iCurrent = iCurrent + 1
		Unfreezing.m_iNextTime = flCurTime + DELAY

		net.Start( 'physcrashguard.Unfreeze' )
			net.WriteUInt( UNFREEZE_PROGRESS, 2 )
			net.WriteFloat( iCurrent / iTotal )
			net.WriteEntity( pEntity )
		net.Send( pl )

	end

end

--
-- Set in use
--
local ProcessGradualUnfreezing = physcrashguard.ProcessGradualUnfreezing

hook.Add( 'PlayerPostThink', 'PhysicsCrashGuard_GradualUnfreezing', function( pl )

	ProcessGradualUnfreezing( pl )

end )
