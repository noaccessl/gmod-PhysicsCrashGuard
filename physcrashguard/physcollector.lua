--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Collector for almost all non-static physics objects that may potentially collide

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
--
local CEntity = FindMetaTable( 'Entity' )

local GetClass = CEntity.GetClass

local IsWorld = CEntity.IsWorld

local GetPhysicsObjectCount = CEntity.GetPhysicsObjectCount
local GetPhysicsObjectNum = CEntity.GetPhysicsObjectNum

--
-- Functions
--
local UTIL_EntitiesIterator = ents.Iterator

local substrof = string.sub


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	fast_isplayer; fast_isnpc
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local fast_isplayer
local fast_isnpc

do

	local getmetatable = getmetatable

	local g_pPlayerMetaTable = FindMetaTable( 'Player' )
	function fast_isplayer( any ) return getmetatable( any ) == g_pPlayerMetaTable end

	local g_pNPCMetaTable = FindMetaTable( 'NPC' )
	function fast_isnpc( any ) return getmetatable( any ) == g_pNPCMetaTable end

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Collector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local INPUT_SKIP = {

	prop_door_rotating = true;
	prop_dynamic = true

}

function PhysCrashGuard.PhysCollector()

	local array, i = {}, 0

	for _, pEntity in UTIL_EntitiesIterator() do

		if ( fast_isplayer( pEntity )
			or fast_isnpc( pEntity ) ) then
			continue
		end

		local classname = GetClass( pEntity )

		if ( INPUT_SKIP[classname]
			or substrof( classname, 1, 5 ) == 'func_'
			or IsWorld( pEntity ) ) then
			continue
		end

		for num = 0, GetPhysicsObjectCount( pEntity ) - 1 do

			local pPhysObj = GetPhysicsObjectNum( pEntity, num )

			if ( pPhysObj:IsValid() ) then

				i = i + 1
				array[i] = pPhysObj

			end

		end

	end

	return array

end
