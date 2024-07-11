--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local iter = ipairs( {} )

local ITER_PROHIBITED = {

	prop_door_rotating = true;
	prop_dynamic = true

}


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Iterator for physics objects
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local Cache = nil

function physcrashguard.Iterator()

	if Cache == nil then

		Cache = {}

		for num, ent in ipairs( ents.GetAll() ) do

			local strClass = ent:GetClass()

			if ITER_PROHIBITED[ strClass ] or string.sub( strClass, 1, 5 ) == 'func_' then
				continue
			end

			if ent:IsVehicle() or ent:IsPlayer() or ent:IsWorld() or ent:IsNPC() then
				continue
			end

			local pObj = ent:GetPhysicsObject()

			if pObj:IsValid() then
				table.insert( Cache, pObj )
			end

		end

	end

	return iter, Cache, 0

end

local function InvalidateCache()

	Cache = nil

end

hook.Add( 'OnEntityCreated', 'physcrashguard.Iterator', InvalidateCache )
hook.Add( 'EntityRemoved',	 'physcrashguard.Iterator', InvalidateCache )
