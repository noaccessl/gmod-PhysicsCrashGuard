--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Adjustments to some constraints in the game

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
--
local EntityMeta = FindMetaTable( 'Entity' )

local GetEntityTable    = EntityMeta.GetTable
local IsEntityValid     = EntityMeta.IsValid
local IsWorld           = EntityMeta.IsWorld

--
-- Functions
--
local subsequent = ipairs( {} )
local next = pairs( {} )

--
-- Globals
--
local PhysicsCrashGuard = PhysicsCrashGuard


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Fixes sliders by limiting the distance between two connected objects using rope

	Note:
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

			if ( not IsValid( Ent1 ) ) then
				return
			end

			local Ent2 = pEntity.Ent2

			if ( not IsValid( Ent2 ) ) then
				return
			end

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
function PhysicsCrashGuard.util.HasConstraints( pEntity )

	if ( not PhysicsCrashGuard.util.IsEntity( pEntity ) ) then
		return false
	end

	local entity_t = GetEntityTable( pEntity )
	local tConstraints = entity_t.Constraints

	if ( not tConstraints ) then
		return false
	end

	local bHas = false

	for index, pConstraint in next, tConstraints do

		if ( not IsEntityValid( pConstraint ) ) then
			tConstraints[index] = nil
		else
			bHas = true
		end

	end

	return bHas

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized (and reduced) constraint.GetTable
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local HasConstraints = PhysicsCrashGuard.util.HasConstraints

function PhysicsCrashGuard.util.GetConstraintsData( pEntity )

	if ( not HasConstraints( pEntity ) ) then
		return false
	end

	local constraintsdata = { [0] = 0 }

	for _, pConstraint in next, GetEntityTable( pEntity ).Constraints do

		local constraint_t = GetEntityTable( pConstraint )

		local index = constraintsdata[0] + 1
		constraintsdata[index] = constraint_t
		constraintsdata[0] = index

	end

	constraintsdata[0] = nil
	return constraintsdata

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Optimized constraint.GetAllConstrainedEntities
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local GetConstraintsData = PhysicsCrashGuard.util.GetConstraintsData

local function GetAllConstrainedEntitiesSequentially( pEntity, output, map )

	output = output or { [0] = 0 }
	map = map or {}

	if ( not IsEntityValid( pEntity ) ) then
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

		local constraintsdata = ret

		for _, constraint_t in subsequent, constraintsdata, 0 do

			for i = 1, 2 do

				local pConstrained = constraint_t[ 'Ent' .. i ]

				if ( not IsWorld( pConstrained ) ) then
					GetAllConstrainedEntitiesSequentially( pConstrained, output, map )
				end

			end

		end

	end

	return output

end

PhysicsCrashGuard.util.GetAllConstrainedEntitiesSequentially = GetAllConstrainedEntitiesSequentially
