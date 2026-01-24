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
-- Common Hot Functions
--
local GetEntityTable = CEntity.GetTable
local IsEntityValid = CEntity.IsValid

local ipairs = ipairs
local CurTime = CurTime

--
-- Libraries
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
	fast_isentity
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local fast_isentity; do

	local getmetatable = getmetatable
	local g_pEntityMetaTable = FindMetaTable( 'Entity' )
	function fast_isentity( any ) return getmetatable( any ) == g_pEntityMetaTable end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized constraint.HasConstraints
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function Fast_HasConstraints( pEntity )

	if ( not fast_isentity( pEntity ) ) then
		return false
	end

	local entity_t = GetEntityTable( pEntity )
	local ptConstraints = entity_t.Constraints

	if ( not ptConstraints ) then
		return false
	end

	local bHas = false

	for i, pConstraint in ipairs( ptConstraints ) do

		if ( not IsEntityValid( pConstraint ) ) then
			ptConstraints[i] = nil
		else
			bHas = true
		end

	end

	return bHas

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized and simplified constraint.GetTable
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function Fast_GetConstraintsData( pEntity )

	if ( not Fast_HasConstraints( pEntity ) ) then
		return false
	end

	local constraintsdata, i = {}, 0

	for _, pConstraint in ipairs( GetEntityTable( pEntity ).Constraints ) do

		local constraint_t = GetEntityTable( pConstraint )

		i = i + 1
		constraintsdata[i] = constraint_t

	end

	return constraintsdata

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized and altered constraint.GetAllConstrainedEntities
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local IsWorld = CEntity.IsWorld

local function GetAllConstrainedSequential( pEntity, output, map )

	output = output or { [0] = 0 }
	map = map or {}

	if ( not IsEntityValid( pEntity ) ) then
		return
	end

	if ( map[pEntity] ) then
		return
	end

	local i = output[0] + 1
	output[i] = pEntity
	map[pEntity] = true
	output[0] = i

	local ret = Fast_GetConstraintsData( pEntity )

	if ( ret ~= false ) then

		local tConstraintsData = ret

		for _, constraint_t in ipairs( tConstraintsData ) do

			local pConstrained1 = constraint_t.Ent1

			if ( not IsWorld( pConstrained1 ) ) then
				GetAllConstrainedSequential( pConstrained1, output, map )
			end

			local pConstrained2 = constraint_t.Ent2

			if ( not IsWorld( pConstrained2 ) ) then
				GetAllConstrainedSequential( pConstrained2, output, map )
			end

		end

	end

	return output

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Collects objects to be unfreezed
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local IsNonUnfreezable = CEntity.GetUnFreezable
local GetPhysicsObjectCount = CEntity.GetPhysicsObjectCount
local GetPhysicsObjectNum = CEntity.GetPhysicsObjectNum
local GamemodeCall = gamemode.Call

local function CollectUnfreezables( pPlayer, pLookupEntity )

	local unfreezables = { [0] = 0 }

	for _, pEntity in ipairs( GetAllConstrainedSequential( pLookupEntity ) ) do

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
local GetEyeTrace = CPlayer.GetEyeTrace

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

		m_iNextTime = CurTime() + DELAY_NEXTUNFREEZE;
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
local HasPlayerReleasedKey = CPlayer.KeyReleased

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

	local flCurTime = CurTime()

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

		PhysCrashGuard.TryToRestore( pEntity )

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
