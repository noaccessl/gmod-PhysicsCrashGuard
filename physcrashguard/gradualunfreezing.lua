--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Gradual Unfreezing

	Got inspired by this addon https://steamcommunity.com/sharedfiles/filedetails/?id=3288286594
	Credits to the author of the addon.

	Not my intention to replace the addon, but to implement the concept here so that there's no need to install both.
	You can install both, no problem with it.

	For compatibility sake it will not work with that addon.

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


local DELAY_NEXTUNFREEZE = 0.03

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metatables
--
local EntityMeta = FindMetaTable( 'Entity' )

local IsUnfreezable = EntityMeta.GetUnFreezable

local GetPhysicsObjectCount = EntityMeta.GetPhysicsObjectCount
local GetPhysicsObjectNum = EntityMeta.GetPhysicsObjectNum

local GetEntityTable = EntityMeta.GetTable

local IsValidEntity = EntityMeta.IsValid

local PlayerMeta = FindMetaTable( 'Player' )

local GetAimTrace = PlayerMeta.GetEyeTrace
local HasPlayerReleasedKey = PlayerMeta.KeyReleased

--
-- Functions
--
local subsequent = ipairs( {} )

local GetCurTime = CurTime

local GamemodeCall = gamemode.Call

--
-- Globals
--
local PhysicsCrashGuard = PhysicsCrashGuard
local net = net

--
-- Network
--
util.AddNetworkString( 'physcrashguard_gradualunfreezing' )


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Unfreezing enums
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local UNFREEZE_START = 0
local UNFREEZE_ABORT = 1
local UNFREEZE_PROGRESS = 2
local UNFREEZE_DONE = 3

local MAX_UNFREEZE_BITS = 2


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Collects unfreezable objects
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function CollectUnfreezable( pl, pLookupEntity )

	local tblUnfreezing = { [0] = 0 }
	local tblConstrainedEntities = PhysicsCrashGuard.util.GetAllConstrainedEntitiesSequentially( pLookupEntity )

	for _, pEntity in subsequent, tblConstrainedEntities, 0 do

		if ( IsUnfreezable( pEntity ) ) then
			continue
		end

		local numPhysObjs = GetPhysicsObjectCount( pEntity )

		for numObj = 1, numPhysObjs do

			local pPhysObj = GetPhysicsObjectNum( pEntity, numObj - 1 )

			if ( not GetEntityTable( pEntity ).m_PhysHang and pPhysObj:IsMoveable() ) then
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
	Purpose: Starts gradual unfreezing
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function PhysicsCrashGuard.StartGradualUnfreezing( pl )

	-- Compatibility: Physgun Unfreeze Over Time
	if ( _G.puot ) then
		return
	end

	local traceAim = GetAimTrace( pl )
	local pFacingEntity = traceAim.Entity

	if ( not ( traceAim.HitNonWorld and IsValidEntity( pFacingEntity ) ) ) then
		return
	end

	local player_t = GetEntityTable( pl )

	local tblPhysObjs = CollectUnfreezable( pl, pFacingEntity )

	if ( tblPhysObjs[0] == 0 ) then
		return
	end

	-- Give the status
	player_t.m_Unfreezing = {

		m_tPhysObjs = tblPhysObjs;
		m_iNextTime = GetCurTime() + DELAY_NEXTUNFREEZE;
		m_iCurrent = 1

	}

	-- Notify
	net.Start( 'physcrashguard_gradualunfreezing' )

		net.WriteUInt( UNFREEZE_START, MAX_UNFREEZE_BITS )

	net.Send( pl )

	return false

end

--
-- Set in use
--
hook.Add( 'OnPhysgunReload', 'PhysicsCrashGuard_GradualUnfreezing', function( pPhysGun, pl )

	local ret = PhysicsCrashGuard.StartGradualUnfreezing( pl )

	if ( ret ~= nil ) then
		return ret
	end

end )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Processes gradual unfreezing
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function PhysicsCrashGuard.ProcessGradualUnfreezing( pl )

	-- Compatibility: Physgun Unfreeze Over Time
	if ( _G.puot ) then
		return
	end

	local player_t = GetEntityTable( pl )
	local tUnfreezing = player_t.m_Unfreezing

	if ( not tUnfreezing ) then
		return
	end

	local flCurTime = GetCurTime()

	local tblPhysObjs = tUnfreezing.m_tPhysObjs

	--
	-- Abort the process
	--
	if ( HasPlayerReleasedKey( pl, IN_RELOAD ) ) then

		--
		-- Freeze back the objects
		--
		for i, pPhysObj in subsequent, tblPhysObjs, 0 do

			if ( pPhysObj:IsValid() and pPhysObj:IsMoveable() ) then

				pPhysObj:EnableMotion( false )
				pPhysObj:Sleep()

			end

		end

		-- Remove the status
		player_t.m_Unfreezing = nil

		-- Notify
		net.Start( 'physcrashguard_gradualunfreezing' )

			net.WriteUInt( UNFREEZE_ABORT, MAX_UNFREEZE_BITS )

		net.Send( pl )

		return

	end

	local iTotal = tblPhysObjs[0]
	local iCurrent = tUnfreezing.m_iCurrent

	--
	-- On unfreezing done
	--
	if ( iCurrent > iTotal ) then

		-- Remove the status
		player_t.m_Unfreezing = nil

		-- Notify
		net.Start( 'physcrashguard_gradualunfreezing' )

			net.WriteUInt( UNFREEZE_DONE, MAX_UNFREEZE_BITS )
			net.WriteUInt( iTotal, MAX_EDICT_BITS )

		net.Send( pl )

		return

	end

	--
	-- Gradually unfreeze the objects
	--
	local iNextTime = tUnfreezing.m_iNextTime

	if ( iNextTime < flCurTime ) then

		local pPhysObj = tblPhysObjs[iCurrent]

		--
		-- Terminate the process if during it some entity/physobj has been removed
		--
		if ( not pPhysObj:IsValid() ) then

			-- Remove the status
			player_t.m_Unfreezing = nil

			-- Notify
			net.Start( 'physcrashguard_gradualunfreezing' )

				net.WriteUInt( UNFREEZE_ABORT, MAX_UNFREEZE_BITS )

			net.Send( pl )

			return

		end

		--
		-- Make progress
		--
		local pEntity = pPhysObj:GetEntity()

		if ( GetEntityTable( pEntity ).m_PhysHang ) then

			PhysicsCrashGuard.TryToRestore( pEntity )

		else

			pPhysObj:EnableMotion( true )
			pPhysObj:Wake()

		end

		tUnfreezing.m_iCurrent = iCurrent + 1
		tUnfreezing.m_iNextTime = flCurTime + DELAY_NEXTUNFREEZE

		-- Notify
		net.Start( 'physcrashguard_gradualunfreezing' )

			net.WriteUInt( UNFREEZE_PROGRESS, MAX_UNFREEZE_BITS )
			net.WriteFloat( iCurrent / iTotal )
			net.WriteEntity( pEntity )

		net.Send( pl )

	end

end

--
-- Set in use
--
hook.Add( 'PlayerPostThink', 'PhysicsCrashGuard_GradualUnfreezing', function( pl )

	PhysicsCrashGuard.ProcessGradualUnfreezing( pl )

end )
