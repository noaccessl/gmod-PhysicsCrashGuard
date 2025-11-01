--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Resolvers

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
--
local CEntity = FindMetaTable( 'Entity' )

local GetColor4Part = CEntity.GetColor4Part
local SetColor4Part = CEntity.SetColor4Part

local GetRenderMode = CEntity.GetRenderMode
local SetRenderMode = CEntity.SetRenderMode

local GetCollisionGroup = CEntity.GetCollisionGroup
local SetCollisionGroup = CEntity.SetCollisionGroup

local SetDrawShadow = CEntity.DrawShadow

local Remove = CEntity.Remove

--
-- Enums
--
local RENDERMODE_TRANSCOLOR = RENDERMODE_TRANSCOLOR
local COLLISION_GROUP_WORLD = COLLISION_GROUP_WORLD


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Parameter
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_bDeleteOnResolve

--
-- ConVar Setting
--
do

	local physcrashguard_delete = CreateConVar(

		'physcrashguard_delete',
		'0',

		FCVAR_ARCHIVE,

		'Experimental. Should entities to resolve be deleted? Won\'t apply to ragdolls.',
		0, 1

	)

	g_bDeleteOnResolve = physcrashguard_delete:GetBool()

	cvars.AddChangeCallback( 'physcrashguard_delete', function( _, _, value )

		g_bDeleteOnResolve = tobool( value )

	end, 'Main' )

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	ResolveSimple
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function PhysCrashGuard.ResolveSimple( pPhysObj, pEntity, entity_t )

	if ( g_bDeleteOnResolve ) then

		Remove( pEntity )
		return

	end

	if ( entity_t.m_tPhysHangDetails ) then
		return
	end

	local r, g, b, a = GetColor4Part( pEntity )

	entity_t.m_tPhysHangDetails = {

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
function PhysCrashGuard.ResolveRagdoll( pPhysPart, pRagdoll, entity_t )

	local tPhysHangDetails = entity_t.m_tPhysHangDetails

	if ( tPhysHangDetails ) then

		local ptPhysParts = tPhysHangDetails.tPhysParts

		if ( not ptPhysParts[pPhysPart] ) then

			pPhysPart:EnableMotion( false )

			local i = ptPhysParts[0] + 1
			ptPhysParts[i] = pPhysPart
			ptPhysParts[pPhysPart] = true
			ptPhysParts[0] = i

		end

		return

	end

	local r, g, b, a = GetColor4Part( pRagdoll )

	entity_t.m_tPhysHangDetails = {

		colEntityLast = { r; g; b; a };
		iEntityLastRenderMode = GetRenderMode( pRagdoll );
		iEntityLastCollisionGroup = GetCollisionGroup( pRagdoll );

		tPhysParts = {

			[0] = 1;

			[1] = pPhysPart;
			[pPhysPart] = true

		}

	}

	pPhysPart:EnableMotion( false )

	SetDrawShadow( pRagdoll, false )

	SetRenderMode( pRagdoll, RENDERMODE_TRANSCOLOR )
	SetColor4Part( pRagdoll, r, g, b, 180 )

	SetCollisionGroup( pRagdoll, COLLISION_GROUP_WORLD )

end
