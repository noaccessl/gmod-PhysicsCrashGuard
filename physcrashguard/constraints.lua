--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Adjustments

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: A workaround for sliders. Limits distance between the two objects via rope.

	Note:
		Sliders will crash the game if:
		1. Two connected objects are too far away.
		2. They are bitching much, which is a consequence from the first point.

		Perhaps, that is crazy physics correlated, like some collision calculation fault/limitation.
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local MAX_DISTANCE = 4096 + 2048 + 512

hook.Add( 'OnEntityCreated', 'PhysCrashGuard_SlidersWorkaround', function( pEntity )

	if ( pEntity:GetClass() == 'phys_slideconstraint' ) then

		local pConstrained1 = pEntity.Ent1
		if ( not IsValid( pConstrained1 ) ) then return end

		local pConstrained2 = pEntity.Ent2
		if ( not IsValid( pConstrained2 ) ) then return end

		local vecPos1 = pConstrained1:GetPos()
		local vecPos2 = pConstrained2:GetPos()

		local flCurrentDist = vecPos1:Distance( vecPos2 )
		flCurrentDist = math.min( flCurrentDist, MAX_DISTANCE )

		local vecLimitedPos = vecPos2
		vecLimitedPos:Sub( vecPos1 )
		vecLimitedPos:Normalize()
		vecLimitedPos:Mul( flCurrentDist )
		vecLimitedPos:Add( vecPos1 )

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
