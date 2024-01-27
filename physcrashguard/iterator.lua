--[[---------------------------------------------------------------------------
	Prepare
---------------------------------------------------------------------------]]
local iter = ipairs( {} )

--[[---------------------------------------------------------------------------
	Iterator for physics objects
---------------------------------------------------------------------------]]
local Cache = nil

function physcrashguard.Iterator()

	if Cache == nil then

		Cache = {}

		for num, ent in ipairs( ents.GetAll() ) do

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
