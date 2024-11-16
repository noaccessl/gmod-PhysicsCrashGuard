--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Adjustments to some constraints in the game

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metatables
--
local ENTITY = FindMetaTable( 'Entity' )

--
-- Metamethods: Entity
--
local GetEntityTable	= ENTITY.GetTable
local IsValidEntity		= ENTITY.IsValid
local IsWorld			= ENTITY.IsWorld

--
-- Globals, Utilities
--
local subsequent	= ipairs( {} )
local next			= pairs( {} )


local fast_isentity do

	local getmetatable	= getmetatable
	local ENTITY		= ENTITY

	function fast_isentity( any )

		return getmetatable( any ) == ENTITY

	end

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Fix for sliders by limiting the distance between two connected objects using rope

	Note #1:
		Sliders will crash the game if:
		1. Two connected objects are too far away.
		2. They are bitching too much. (Consequence from the first point.)
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local MAX_DISTANCE = 6656

hook.Add( 'OnEntityCreated', 'PhysicsCrashGuard_FixSliders', function( pEntity )

	timer.Simple( 0, function()

		if ( not pEntity:IsValid() ) then
			return
		end

		if ( pEntity:GetClass() == 'phys_slideconstraint' ) then

			local Ent1 = pEntity.Ent1
			local Ent2 = pEntity.Ent2

			local vecPos1 = Ent1:GetPos()
			local vecPos2 = Ent2:GetPos()

			local flCurrentDist = vecPos1:Distance( vecPos2 )
			flCurrentDist = math.min( flCurrentDist, MAX_DISTANCE )

			local vecDir = ( vecPos2 - vecPos1 ):Angle():Forward()
			local vecLimitedPos = vecPos1 + vecDir * flCurrentDist

			Ent2:SetPos( vecLimitedPos )

			local flAddLength = MAX_DISTANCE - flCurrentDist

			constraint.Rope(

				Ent1,
				Ent2,
				0, -- Bone 1
				0, -- Bone 2
				vector_origin, -- Local pos 1
				vector_origin, -- Local pos 2
				flCurrentDist, -- Length
				flAddLength, -- Additional length
				0, -- Force limit
				0 -- Width

			)

		end

	end )

end )


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized constraint.HasConstraints
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function physcrashguard.HasConstraints( pEntity )

	if ( not fast_isentity( pEntity ) ) then
		return false
	end

	local pEntity_t = GetEntityTable( pEntity )
	local Constraints_t = pEntity_t.Constraints

	if ( not Constraints_t ) then
		return false
	end

	local bHas = false

	for index, pConstraint in next, Constraints_t do

		if ( not IsValidEntity( pConstraint ) ) then
			Constraints_t[index] = nil
		else
			bHas = true
		end

	end

	return bHas

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized (and reduced) constraint.GetTable
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local HasConstraints = physcrashguard.HasConstraints

function physcrashguard.GetConstraintsData( pEntity )

	if ( not HasConstraints( pEntity ) ) then
		return false
	end

	local ConstraintsData_t = { [0] = 0 }

	for _, pConstraint in next, GetEntityTable( pEntity ).Constraints do

		local pConstraint_t = GetEntityTable( pConstraint )

		local index = ConstraintsData_t[0]
		index = index + 1

		ConstraintsData_t[index] = pConstraint_t
		ConstraintsData_t[0] = index

	end

	ConstraintsData_t[0] = nil
	return ConstraintsData_t

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized constraint.GetAllConstrainedEntities
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local GetConstraintsData = physcrashguard.GetConstraintsData

local function GetAllConstrainedEntitiesSequentially( pEntity, output, map )

	output = output or { [0] = 0 }
	map = map or {}

	if ( not IsValidEntity( pEntity ) ) then
		return
	end

	if ( map[pEntity] ) then
		return
	end

	local index = output[0]
	index = index + 1

	output[index] = pEntity
	map[pEntity] = true

	output[0] = index

	local ret = GetConstraintsData( pEntity )

	if ( ret ~= false ) then

		local ConstraintsData_t = ret

		for _, pConstraint_t in subsequent, ConstraintsData_t, 0 do

			for i = 1, 2 do

				local pConstrained = pConstraint_t[ 'Ent' .. i ]

				if ( not IsWorld( pConstrained ) ) then
					GetAllConstrainedEntitiesSequentially( pConstrained, output, map )
				end

			end

		end

	end

	return output

end

physcrashguard.GetAllConstrainedEntitiesSequentially = GetAllConstrainedEntitiesSequentially
