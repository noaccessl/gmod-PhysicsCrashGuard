--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Resolver

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
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

--
-- Enums
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
function PhysicsCrashGuard.Resolve( pPhysObj, pEntity, entity_t )

	if ( g_bDeleteOnResolve ) then

		Remove( pEntity )
		return

	end

	if ( entity_t.m_PhysHang ) then
		return
	end

	local r, g, b, a = GetColor4Part( pEntity )

	entity_t.m_PhysHang = {

		colEntityLast = { r; g; b; a };
		iEntityLastRenderMode = GetRenderMode( pEntity );
		iEntityLastCollisionGroup = GetCollisionGroup( pEntity )

	}

	pPhysObj:EnableMotion( false )

	SetDrawShadow( pEntity, false )

	SetRenderMode( pEntity, RENDERMODE_TRANSCOLOR )
	SetColor4Part( pEntity, r, g, b, 180 )

	SetCollisionGroup( pEntity, COLLISION_GROUP_WORLD )

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	ResolveRagdoll
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function PhysicsCrashGuard.ResolveRagdoll( pPhysPart, pRagdoll, entity_t )

	if ( entity_t.m_PhysHang ) then

		local physparts = entity_t.m_PhysHang.m_PhysParts

		if ( not physparts[pPhysPart] ) then

			pPhysPart:EnableMotion( false )

			local index = physparts[0] + 1

			physparts[index] = pPhysPart
			physparts[pPhysPart] = true

			physparts[0] = index

		end

		return

	end

	local r, g, b, a = GetColor4Part( pRagdoll )

	entity_t.m_PhysHang = {

		colEntityLast = { r; g; b; a };
		iEntityLastRenderMode = GetRenderMode( pRagdoll );
		iEntityLastCollisionGroup = GetCollisionGroup( pRagdoll );

		m_PhysParts = {

			[0] = 1;

			[pPhysPart] = true;
			[1] = pPhysPart

		}

	}

	pPhysPart:EnableMotion( false )

	SetDrawShadow( pRagdoll, false )

	SetRenderMode( pRagdoll, RENDERMODE_TRANSCOLOR )
	SetColor4Part( pRagdoll, r, g, b, 180 )

	SetCollisionGroup( pRagdoll, COLLISION_GROUP_WORLD )

end
