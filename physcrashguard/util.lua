--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Utilities

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Shared Functions
--
local getmetatable = getmetatable


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Init
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
physcrashguard.util = physcrashguard.util or {}

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized entity-check
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_EntityMeta = FindMetaTable( 'Entity' )

function physcrashguard.util.IsEntity( any )

	return getmetatable( any ) == g_EntityMeta

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized vehicle-check
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_VehicleMeta = FindMetaTable( 'Vehicle' )

function physcrashguard.util.IsVehicle( any )

	return getmetatable( any ) == g_VehicleMeta

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized player-check
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_PlayerMeta = FindMetaTable( 'Player' )

function physcrashguard.util.IsPlayer( any )

	return getmetatable( any ) == g_PlayerMeta

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized npc-check
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_NPCMeta = FindMetaTable( 'NPC' )

function physcrashguard.util.IsNPC( any )

	return getmetatable( any ) == g_NPCMeta

end
