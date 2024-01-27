--[[---------------------------------------------------------------------------
	Fix for sliders

	Sliders will crash the game if:
	1. Two connected objects are too far away.
	2. They are bitching too much. (Consequence from the first point.)
---------------------------------------------------------------------------]]
local MAX_DISTANCE = 6656

hook.Add( 'OnEntityCreated', 'physcrashguard.FixSliders', function( ent )

	timer.Simple( 0, function()

		if ent:IsValid() and ent:GetClass() == 'phys_slideconstraint' then

			local Ent1 = ent.Ent1
			local Ent2 = ent.Ent2

			local flDist = Ent1:GetPos():Distance( Ent2:GetPos() )
			flDist = math.min( flDist, MAX_DISTANCE )

			local vecLimited = Ent1:GetPos() + ( Ent2:GetPos() - Ent1:GetPos() ):Angle():Forward() * flDist

			Ent2:SetPos( vecLimited )

			constraint.Rope( Ent1, Ent2, 0, 0, vector_origin, vector_origin, flDist, MAX_DISTANCE - flDist, 0, 0 )

		end

	end )

end )
