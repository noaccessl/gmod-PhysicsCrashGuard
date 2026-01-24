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

local GetCollisionGroup = CEntity.GetCollisionGroup
local GetRenderMode = CEntity.GetRenderMode
local GetColor4Part = CEntity.GetColor4Part

local SetCollisionGroup = CEntity.SetCollisionGroup
local SetRenderMode = CEntity.SetRenderMode
local SetColor4Part = CEntity.SetColor4Part
local DrawShadow = CEntity.DrawShadow

local Remove = CEntity.Remove

--
-- Enums
--
local COLLISION_GROUP_WORLD = COLLISION_GROUP_WORLD
local RENDERMODE_TRANSCOLOR = RENDERMODE_TRANSCOLOR


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Parameter
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_bDeleteOnResolve

-- Configurational ConVar
do

	local physcrashguard_delete = CreateConVar(
		'physcrashguard_delete', '0',
		FCVAR_ARCHIVE,
		'Experimental. Should entities to resolve be deleted? Won\'t apply to ragdolls.',
		0, 1
	)

	g_bDeleteOnResolve = physcrashguard_delete:GetBool()

	cvars.AddChangeCallback( 'physcrashguard_delete', function( _, _, value )

		g_bDeleteOnResolve = tobool( value )

	end, 'PhysCrashGuard' )

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

	pPhysObj:EnableMotion( false )

	local r, g, b, a = GetColor4Part( pEntity )

	entity_t.m_tPhysHangDetails = {

		iLastEntityCollisionGroup = GetCollisionGroup( pEntity );

		iLastEntityRenderMode = GetRenderMode( pEntity );
		tLastEntityColor = { r; g; b; a }

	}

	SetCollisionGroup( pEntity, COLLISION_GROUP_WORLD )

	SetRenderMode( pEntity, RENDERMODE_TRANSCOLOR )
	SetColor4Part( pEntity, r, g, b, 180 )

	DrawShadow( pEntity, false )

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

	pPhysPart:EnableMotion( false )

	local r, g, b, a = GetColor4Part( pRagdoll )

	entity_t.m_tPhysHangDetails = {

		iLastEntityCollisionGroup = GetCollisionGroup( pRagdoll );

		iLastEntityRenderMode = GetRenderMode( pRagdoll );
		tLastEntityColor = { r; g; b; a };

		tPhysParts = {

			[0] = 1;

			[1] = pPhysPart;
			[pPhysPart] = true

		}

	}

	SetCollisionGroup( pRagdoll, COLLISION_GROUP_WORLD )

	SetRenderMode( pRagdoll, RENDERMODE_TRANSCOLOR )
	SetColor4Part( pRagdoll, r, g, b, 180 )

	DrawShadow( pRagdoll, false )

end
