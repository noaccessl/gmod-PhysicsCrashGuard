--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Adjustments & Utility

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
--
local CEntity = FindMetaTable( 'Entity' )

local GetEntityTable = CEntity.GetTable
local IsEntityValid = CEntity.IsValid
local IsWorld = CEntity.IsWorld

--
-- Functions
--
local ipairs = ipairs


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Fixes sliders by limiting the distance between two connected objects using rope

	Note:
		Sliders will crash the game if:
		1. Two connected objects are too far away.
		2. They are bitching too much. (Consequence from the first point.)
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local MAX_DISTANCE = 6656

hook.Add( 'OnEntityCreated', 'PhysCrashGuard_FixSliders', function( pEntity )

	timer.Simple( 0, function()

		if ( not pEntity:IsValid() ) then
			return
		end

		if ( pEntity:GetClass() == 'phys_slideconstraint' ) then

			local pConstrained1 = pEntity.Ent1

			if ( not IsValid( pConstrained1 ) ) then
				return
			end

			local pConstrained2 = pEntity.Ent2

			if ( not IsValid( pConstrained2 ) ) then
				return
			end

			local vecPos1 = pConstrained1:GetPos()
			local vecPos2 = pConstrained2:GetPos()

			local flCurrentDist = vecPos1:Distance( vecPos2 )
			flCurrentDist = math.min( flCurrentDist, MAX_DISTANCE )

			local vecDir = ( vecPos2 - vecPos1 ):Angle():Forward()
			local vecLimitedPos = vecPos1 + vecDir * flCurrentDist

			pConstrained2:SetPos( vecLimitedPos )

			local flAddLength = MAX_DISTANCE - flCurrentDist

			constraint.Rope(

				pConstrained1,
				pConstrained2,
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
local function GetAllConstrainedSequentially( pEntity, output, map )

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
				GetAllConstrainedSequentially( pConstrained1, output, map )
			end

			local pConstrained2 = constraint_t.Ent2

			if ( not IsWorld( pConstrained2 ) ) then
				GetAllConstrainedSequentially( pConstrained2, output, map )
			end

		end

	end

	return output

end

PhysCrashGuard.GetAllConstrainedSequentially = GetAllConstrainedSequentially
