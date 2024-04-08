--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Entity
--
local ENTITY			= FindMetaTable( 'Entity' )

local GetColor4Part		= ENTITY.GetColor4Part
local SetColor4Part		= ENTITY.SetColor4Part

local SetRenderMode		= ENTITY.SetRenderMode

local GetCollisionGroup	= ENTITY.GetCollisionGroup
local SetCollisionGroup = ENTITY.SetCollisionGroup

local SetEnableShadows	= ENTITY.DrawShadow

--
-- PhysObj
--
local EnableMotion = FindMetaTable( 'PhysObj' ).EnableMotion

--
-- Enums
--
local RENDERMODE_TRANSCOLOR = RENDERMODE_TRANSCOLOR
local COLLISION_GROUP_WORLD = COLLISION_GROUP_WORLD


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Resolve
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function physcrashguard.Resolve( pObj, ent, ent_t )

	ent_t.m_bPhysHang = true

	EnableMotion( pObj, false )
	SetEnableShadows( ent, false )

	local r, g, b, a = GetColor4Part( ent )

	ent_t.m_LastColor = { r, g, b, a }
	ent_t.m_LastCollisionGroup = GetCollisionGroup( ent )

	SetRenderMode( ent, RENDERMODE_TRANSCOLOR )
	SetColor4Part( ent, r, g, b, 180 )

	SetCollisionGroup( ent, COLLISION_GROUP_WORLD )

end
