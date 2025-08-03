--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Iterator for all non-static physics objects that may potentially collide

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
--
local EntityMeta = FindMetaTable( 'Entity' )

local GetClass = EntityMeta.GetClass

local IsWorld = EntityMeta.IsWorld

local GetPhysicsObjectCount = EntityMeta.GetPhysicsObjectCount
local GetPhysicsObjectNum = EntityMeta.GetPhysicsObjectNum

--
-- Functions
--
local UTIL_EntitiesIterator = ents.Iterator

local substrof = string.sub
local tableinsert = table.insert

--
-- Globals
--
local PhysicsCrashGuard = PhysicsCrashGuard


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Cache for physics objects
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local PhysCache = {}

local PHYSCACHE_SKIP = {

	prop_door_rotating = true;
	prop_dynamic = true

}

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Iterator for physics objects
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local subsequent = ipairs( {} )

function PhysicsCrashGuard.Iterator()

	if ( PhysCache == nil ) then

		PhysCache = {}

		for _, pEntity in UTIL_EntitiesIterator() do

			local classname = GetClass( pEntity )

			if ( PHYSCACHE_SKIP[classname] or substrof( classname, 1, 5 ) == 'func_' ) then
				continue
			end

			if ( PhysicsCrashGuard.util.IsPlayer( pEntity ) or PhysicsCrashGuard.util.IsNPC( pEntity ) or PhysicsCrashGuard.util.IsVehicle( pEntity ) or IsWorld( pEntity ) ) then
				continue
			end

			local numPhysObjs = GetPhysicsObjectCount( pEntity )

			for numObj = 1, numPhysObjs do

				local pPhysObj = GetPhysicsObjectNum( pEntity, numObj - 1 )

				if ( pPhysObj:IsValid() ) then
					tableinsert( PhysCache, pPhysObj )
				end

			end

		end

	end

	return subsequent, PhysCache, 0

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Sets the cache up for update
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function PhysicsCrashGuard.InvalidatePhysCache()

	PhysCache = nil

end

--
-- Set in use
--
hook.Add( 'OnEntityCreated', 'PhysicsCrashGuard_Iterator', function( pEntity )

	timer.Simple( 0, function()

		if ( EntityMeta.IsValid( pEntity ) ) then
			PhysicsCrashGuard.InvalidatePhysCache()
		end

	end )

end )

hook.Add( 'EntityRemoved', 'PhysicsCrashGuard_Iterator', function( pEntity, bFullUpdate )

	if ( bFullUpdate ) then
		return
	end

	PhysicsCrashGuard.InvalidatePhysCache()

end )
