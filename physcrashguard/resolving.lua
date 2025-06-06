--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Resolver

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods: Entity; PhysObj
--
local EntityMeta = FindMetaTable( 'Entity' )

local GetColor4Part = EntityMeta.GetColor4Part
local SetColor4Part = EntityMeta.SetColor4Part

local GetRenderMode = EntityMeta.GetRenderMode
local SetRenderMode = EntityMeta.SetRenderMode

local GetCollisionGroup = EntityMeta.GetCollisionGroup
local SetCollisionGroup = EntityMeta.SetCollisionGroup

local SetDrawShadow = EntityMeta.DrawShadow

local Remove = EntityMeta.Remove

local VPhysicsEnableMotion = FindMetaTable( 'PhysObj' ).EnableMotion

--
-- Globals
--
local RENDERMODE_TRANSCOLOR = RENDERMODE_TRANSCOLOR
local COLLISION_GROUP_WORLD = COLLISION_GROUP_WORLD


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Deletion mode
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local physcrashguard_delete = CreateConVar(

	'physcrashguard_delete',
	'0',

	FCVAR_ARCHIVE,

	'Experimental. Should entities to resolve be deleted? Won\'t apply to ragdolls.',
	0, 1

)

local g_bDeleteOnResolve = physcrashguard_delete:GetBool()

cvars.AddChangeCallback( 'physcrashguard_delete', function( _, _, value )

	g_bDeleteOnResolve = tobool( value )

end, 'Main' )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Resolve
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function physcrashguard.Resolve( pPhysObj, pEntity, pEntity_t )

	if ( g_bDeleteOnResolve ) then

		Remove( pEntity )
		return

	end

	if ( pEntity_t.m_PhysHang ) then
		return
	end

	local r, g, b, a = GetColor4Part( pEntity )

	pEntity_t.m_PhysHang = {

		m_colLast = { r; g; b; a };
		m_iLastRenderMode = GetRenderMode( pEntity );
		m_iLastCollisionGroup = GetCollisionGroup( pEntity )

	}

	VPhysicsEnableMotion( pPhysObj, false )

	SetDrawShadow( pEntity, false )

	SetRenderMode( pEntity, RENDERMODE_TRANSCOLOR )
	SetColor4Part( pEntity, r, g, b, 180 )

	SetCollisionGroup( pEntity, COLLISION_GROUP_WORLD )

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	ResolveRagdoll
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function physcrashguard.ResolveRagdoll( pPhysPart, pRagdoll, pEntity_t )

	if ( pEntity_t.m_PhysHang ) then

		local physparts = pEntity_t.m_PhysHang.m_PhysParts

		if ( not physparts[pPhysPart] ) then

			VPhysicsEnableMotion( pPhysPart, false )

			local index = physparts[0] + 1

			physparts[index] = pPhysPart
			physparts[pPhysPart] = true

			physparts[0] = index

		end

		return

	end

	local r, g, b, a = GetColor4Part( pRagdoll )

	pEntity_t.m_PhysHang = {

		m_colLast = { r; g; b; a };
		m_iLastRenderMode = GetRenderMode( pRagdoll );
		m_iLastCollisionGroup = GetCollisionGroup( pRagdoll );

		m_PhysParts = {

			[0] = 1;

			[pPhysPart] = true;
			[1] = pPhysPart

		}

	}

	VPhysicsEnableMotion( pPhysPart, false )

	SetDrawShadow( pRagdoll, false )

	SetRenderMode( pRagdoll, RENDERMODE_TRANSCOLOR )
	SetColor4Part( pRagdoll, r, g, b, 180 )

	SetCollisionGroup( pRagdoll, COLLISION_GROUP_WORLD )

end
