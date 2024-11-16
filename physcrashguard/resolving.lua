--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Resolver

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods: Entity, PhysObj
--
local ENTITY = FindMetaTable( 'Entity' )

local GetColor4Part = ENTITY.GetColor4Part
local SetColor4Part = ENTITY.SetColor4Part

local GetRenderMode = ENTITY.GetRenderMode
local SetRenderMode = ENTITY.SetRenderMode

local GetCollisionGroup = ENTITY.GetCollisionGroup
local SetCollisionGroup = ENTITY.SetCollisionGroup

local SetDrawShadow = ENTITY.DrawShadow

local Remove = ENTITY.Remove


local VPhysicsEnableMotion = FindMetaTable( 'PhysObj' ).EnableMotion

--
-- Enums
--
local RENDERMODE_TRANSCOLOR = RENDERMODE_TRANSCOLOR
local COLLISION_GROUP_WORLD = COLLISION_GROUP_WORLD


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Deletion mode
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local DELETE_ON_RESOLVE = CreateConVar( 'physcrashguard_delete', '0', FCVAR_ARCHIVE, 'Experimental. Should we delete problematic entities? Won\'t apply to ragdolls.' ):GetBool()

cvars.AddChangeCallback( 'physcrashguard_delete', function( _, _, new )

	DELETE_ON_RESOLVE = tobool( new )

end, 'CacheValue' )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Resolve
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function physcrashguard.Resolve( pPhysObj, pEntity, pEntity_t )

	if ( DELETE_ON_RESOLVE ) then

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

		local Parts_t = pEntity_t.m_PhysHang.m_tParts

		if ( not Parts_t[pPhysPart] ) then

			VPhysicsEnableMotion( pPhysPart, false )

			local index = Parts_t[0]
			index = index + 1

			Parts_t[index] = pPhysPart
			Parts_t[pPhysPart] = true

			Parts_t[0] = index

		end

		return

	end

	local r, g, b, a = GetColor4Part( pRagdoll )

	pEntity_t.m_PhysHang = {

		m_colLast = { r; g; b; a };
		m_iLastRenderMode = GetRenderMode( pRagdoll );
		m_iLastCollisionGroup = GetCollisionGroup( pRagdoll );

		m_tParts = {

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
