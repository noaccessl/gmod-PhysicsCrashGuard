--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Iterator for all non-static physics objects that may potentially collide

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods: Entity, PhysObj
--
local ENTITY = FindMetaTable( 'Entity' )

local GetClass = ENTITY.GetClass

local IsVehicle = ENTITY.IsVehicle
local IsPlayer	= ENTITY.IsPlayer
local IsWorld	= ENTITY.IsWorld
local IsNPC		= ENTITY.IsNPC

local GetPhysicsObjectCount = ENTITY.GetPhysicsObjectCount
local GetPhysicsObjectNum	= ENTITY.GetPhysicsObjectNum


local VPhysicsIsValid = FindMetaTable( 'PhysObj' ).IsValid

--
-- Globals
--
local EntitiesIterator = ents.Iterator

local substrof	= string.sub
local tinsert	= table.insert


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

function physcrashguard.Iterator()

	if ( PhysCache == nil ) then

		PhysCache = {}

		for _, pEntity in EntitiesIterator() do

			local strClass = GetClass( pEntity )

			if ( PHYSCACHE_SKIP[strClass] or substrof( strClass, 1, 5 ) == 'func_' ) then
				continue
			end

			if ( IsVehicle( pEntity ) or IsPlayer( pEntity ) or IsWorld( pEntity ) or IsNPC( pEntity ) ) then
				continue
			end

			local numPhysObjs = GetPhysicsObjectCount( pEntity )

			for numObj = 1, numPhysObjs do

				local pPhysObj = GetPhysicsObjectNum( pEntity, numObj - 1 )

				if ( VPhysicsIsValid( pPhysObj ) ) then
					tinsert( PhysCache, pPhysObj )
				end

			end

		end

	end

	return subsequent, PhysCache, 0

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Set the cache up for update
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function physcrashguard.InvalidatePhysCache()

	PhysCache = nil

end


local InvalidatePhysCache = physcrashguard.InvalidatePhysCache

hook.Add( 'OnEntityCreated', 'PhysicsCrashGuard_Iterator', function()

	InvalidatePhysCache()

end )

hook.Add( 'EntityRemoved', 'PhysicsCrashGuard_Iterator', function( pEntity, bFullUpdate )

	if ( bFullUpdate ) then
		return
	end

	InvalidatePhysCache()

end )
