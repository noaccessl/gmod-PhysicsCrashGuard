--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Restoring
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function Restore( ent, ent_t, pObj )

	ent_t.m_bPhysHang = nil

	pObj:EnableMotion( true )
	pObj:Wake()

	ent:DrawShadow( true )

	ent:SetColor4Part( unpack( ent_t.m_LastColor ) )
	ent:SetCollisionGroup( ent_t.m_LastCollisionGroup )

	ent_t.m_LastColor = nil
	ent_t.m_LastCollisionGroup = nil

end

function physcrashguard.TryToRestore( ent )

	local pObj = ent:GetPhysicsObject()
	local ent_t = ent:GetTable()

	if ent_t.m_bPhysHang and not pObj:IsPenetrating() then
		Restore( ent, ent_t, pObj )
	end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Try to restore
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
hook.Add( 'OnPhysgunPickup', 'physcrashguard.TryToRestore', function( _, ent )

	physcrashguard.TryToRestore( ent )

end )

hook.Add( 'GravGunOnPickedUp', 'physcrashguard.TryToRestore', function( _, ent )

	physcrashguard.TryToRestore( ent )

end )

hook.Add( 'GravGunPunt', 'physcrashguard.TryToRestore', function( _, ent )

	physcrashguard.TryToRestore( ent )

end )
