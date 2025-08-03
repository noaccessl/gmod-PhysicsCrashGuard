--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	A submodule responsible for freezing dupes on creation

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods: Entity; PhysObj
--
local EntityMeta = FindMetaTable( 'Entity' )

local IsRagdoll             = EntityMeta.IsRagdoll
local GetPhysicsObject      = EntityMeta.GetPhysicsObject
local GetPhysicsObjectCount = EntityMeta.GetPhysicsObjectCount
local GetPhysicsObjectNum   = EntityMeta.GetPhysicsObjectNum

--
-- Functions
--
local subsequent = ipairs( {} )


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	A setting
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local physcrashguard_freezedupesonpaste = CreateConVar(

	'physcrashguard_freezedupesonpaste',
	'1',

	FCVAR_ARCHIVE,

	'Should dupes be freezed on paste?',
	0, 1

)

local g_bFreezeDupesOnPaste = physcrashguard_freezedupesonpaste:GetBool()

cvars.AddChangeCallback( 'physcrashguard_hangdetection', function( _, _, value )

	g_bFreezeDupesOnPaste = tobool( value )

end, 'Main' )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Catch & freeze just pasted dupes
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function FreezeEntities( listEntities )

	for _, pEntity in subsequent, listEntities, 0 do

		if ( IsRagdoll( pEntity ) ) then

			for numObj = 0, GetPhysicsObjectCount( pEntity ) - 1 do

				local pPhysObj = GetPhysicsObjectNum( pEntity, numObj )

				if ( pPhysObj:IsValid() ) then

					pPhysObj:EnableMotion( false )
					pPhysObj:Sleep()

				end

			end

		else

			local pPhysObj = GetPhysicsObject( pEntity )

			if ( pPhysObj:IsValid() ) then

				pPhysObj:EnableMotion( false )
				pPhysObj:Sleep()

			end

		end

	end

end

hook.Add( 'CanCreateUndo', 'PhysicsCrashGuard_FreezeDupesOnPaste', function( pl, tblUndo )

	if ( tblUndo.Name ~= 'Duplicator' ) then
		return
	end

	if ( g_bFreezeDupesOnPaste ) then
		FreezeEntities( tblUndo.Entities )
	end

end )
