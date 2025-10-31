--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Gradual Unfreezing Subsystem

	Inspired by the PUOT addon (https://steamcommunity.com/sharedfiles/filedetails/?id=3288286594).
	For compatibility, this subsystem won't be active with that addon enabled.

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



local DELAY_NEXTUNFREEZE = 0.03

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metatables
--
local CEntity = FindMetaTable( 'Entity' )
local CPlayer = FindMetaTable( 'Player' )

--
-- Metamethods
--
local IsEntityValid = CEntity.IsValid

local GetEntityTable = CEntity.GetTable

local IsNonUnfreezable = CEntity.GetUnFreezable

local GetPhysicsObjectCount = CEntity.GetPhysicsObjectCount
local GetPhysicsObjectNum = CEntity.GetPhysicsObjectNum

local GetEyeTrace = CPlayer.GetEyeTrace
local HasPlayerReleasedKey = CPlayer.KeyReleased

--
-- Functions
--
local ipairs = ipairs
local GetCurTime = CurTime

local GetAllConstrainedSequentially = PhysCrashGuard.GetAllConstrainedSequentially
local TryToRestore = PhysCrashGuard.TryToRestore

local GamemodeCall = gamemode.Call

--
-- Globals
--
local net = net

--
-- Network
--
util.AddNetworkString( 'physcrashguard_gradualunfreezing' )


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Unfreezing Message Types Enums
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local UNFREEZE_START = 0
local UNFREEZE_ABORT = 1
local UNFREEZE_PROGRESS = 2
local UNFREEZE_DONE = 3

local MAX_UNFREEZE_BITS = 2


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Collects objects to be unfreezed
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function CollectUnfreezables( pPlayer, pLookupEntity )

	local unfreezables = { [0] = 0 }

	for _, pEntity in ipairs( GetAllConstrainedSequentially( pLookupEntity ) ) do

		if ( IsNonUnfreezable( pEntity ) ) then
			continue
		end

		local bInHang = GetEntityTable( pEntity ).m_tPhysHangDetails ~= nil

		for num = 0, GetPhysicsObjectCount( pEntity ) - 1 do

			local pPhysObj = GetPhysicsObjectNum( pEntity, num )

			if ( not bInHang and pPhysObj:IsMoveable() ) then
				continue
			end

			if ( not GamemodeCall( 'CanPlayerUnfreeze', pPlayer, pEntity, pPhysObj ) ) then
				continue
			end

			local i = unfreezables[0] + 1
			unfreezables[i] = pPhysObj
			unfreezables[0] = i

		end

	end

	return unfreezables

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Starts gradual unfreezing for the player
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function PhysCrashGuard.StartGradualUnfreezing( pPlayer )

	-- Compatibility: Physgun Unfreeze Over Time
	if ( _G.puot ) then
		return
	end

	local traceAim = GetEyeTrace( pPlayer )
	local pEntityTarget = traceAim.Entity

	if ( not ( traceAim.HitNonWorld and IsEntityValid( pEntityTarget ) ) ) then
		return
	end

	local player_t = GetEntityTable( pPlayer )

	local tPhysObjs = CollectUnfreezables( pPlayer, pEntityTarget )

	if ( tPhysObjs[0] == 0 ) then
		return
	end

	-- Give the state
	player_t.m_stateUnfreezing = {

		m_tPhysObjs = tPhysObjs;

		m_iNextTime = GetCurTime() + DELAY_NEXTUNFREEZE;
		m_iCurrent = 1

	}

	-- Notify
	net.Start( 'physcrashguard_gradualunfreezing' )

		net.WriteUInt( UNFREEZE_START, MAX_UNFREEZE_BITS )

	net.Send( pPlayer )

	return false

end

--
-- Integrate
--
hook.Add( 'OnPhysgunReload', 'PhysCrashGuard_GradualUnfreezing', function( _, pPlayer )

	local ret = PhysCrashGuard.StartGradualUnfreezing( pPlayer )

	if ( ret ~= nil ) then
		return ret
	end

end )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Processes gradual unfreezing for the player
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function PhysCrashGuard.ProcessGradualUnfreezing( pPlayer )

	-- Compatibility: Physgun Unfreeze Over Time
	if ( _G.puot ) then
		return
	end

	local player_t = GetEntityTable( pPlayer )
	local pStateUnfreezing = player_t.m_stateUnfreezing

	if ( not pStateUnfreezing ) then
		return
	end

	local flCurTime = GetCurTime()

	local tPhysObjs = pStateUnfreezing.m_tPhysObjs

	--
	-- Process Abortion
	--
	if ( HasPlayerReleasedKey( pPlayer, IN_RELOAD ) ) then

		--
		-- Freeze the objects back again
		--
		for _, pPhysObj in ipairs( tPhysObjs ) do

			if ( pPhysObj:IsValid() and pPhysObj:IsMoveable() ) then

				pPhysObj:EnableMotion( false )
				pPhysObj:Sleep()

			end

		end

		-- Remove the state
		player_t.m_stateUnfreezing = nil

		-- Notify
		net.Start( 'physcrashguard_gradualunfreezing' )

			net.WriteUInt( UNFREEZE_ABORT, MAX_UNFREEZE_BITS )

		net.Send( pPlayer )

		return

	end

	local iTotal = tPhysObjs[0]
	local iCurrent = pStateUnfreezing.m_iCurrent

	--
	-- Unfreezing Finish
	--
	if ( iCurrent > iTotal ) then

		-- Remove the state
		player_t.m_stateUnfreezing = nil

		-- Notify
		net.Start( 'physcrashguard_gradualunfreezing' )

			net.WriteUInt( UNFREEZE_DONE, MAX_UNFREEZE_BITS )
			net.WriteUInt( iTotal, MAX_EDICT_BITS )

		net.Send( pPlayer )

		return

	end

	--
	-- Gradual Unfreezing
	--
	local iNextTime = pStateUnfreezing.m_iNextTime

	if ( iNextTime < flCurTime ) then

		local pPhysObj = tPhysObjs[iCurrent]

		--
		-- Terminate the process if in midstream some object has been removed
		--
		if ( not pPhysObj:IsValid() ) then

			-- Remove the state
			player_t.m_stateUnfreezing = nil

			-- Notify
			net.Start( 'physcrashguard_gradualunfreezing' )

				net.WriteUInt( UNFREEZE_ABORT, MAX_UNFREEZE_BITS )

			net.Send( pPlayer )

			return

		end

		--
		-- Make progress
		--
		local pEntity = pPhysObj:GetEntity()

		TryToRestore( pEntity )

		pPhysObj:EnableMotion( true )
		pPhysObj:Wake()

		pStateUnfreezing.m_iCurrent = iCurrent + 1
		pStateUnfreezing.m_iNextTime = flCurTime + DELAY_NEXTUNFREEZE

		-- Notify
		net.Start( 'physcrashguard_gradualunfreezing' )

			net.WriteUInt( UNFREEZE_PROGRESS, MAX_UNFREEZE_BITS )
			net.WriteFloat( iCurrent / iTotal )
			net.WriteEntity( pEntity )

		net.Send( pPlayer )

	end

end

--
-- Integrate
--
hook.Add( 'PlayerPostThink', 'PhysCrashGuard_GradualUnfreezing', function( pPlayer )

	PhysCrashGuard.ProcessGradualUnfreezing( pPlayer )

end )
