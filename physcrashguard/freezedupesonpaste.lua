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

local IsRagdoll				= EntityMeta.IsRagdoll
local GetPhysicsObject		= EntityMeta.GetPhysicsObject
local GetPhysicsObjectCount	= EntityMeta.GetPhysicsObjectCount
local GetPhysicsObjectNum	= EntityMeta.GetPhysicsObjectNum

local PhysObjMeta = FindMetaTable( 'PhysObj' )

local VPhysicsIsValid		= PhysObjMeta.IsValid
local VPhysicsEnableMotion	= PhysObjMeta.EnableMotion
local VPhysicsSleep			= PhysObjMeta.Sleep

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
local function FreezeEntities( listEntites )

	for _, pEntity in subsequent, listEntites, 0 do

		if ( IsRagdoll( pEntity ) ) then

			for numObj = 0, GetPhysicsObjectCount( pEntity ) - 1 do

				local pPhysObj = GetPhysicsObjectNum( pEntity, numObj )

				if ( VPhysicsIsValid( pPhysObj ) ) then

					VPhysicsEnableMotion( pPhysObj, false )
					VPhysicsSleep( pPhysObj )

				end

			end

		else

			local pPhysObj = GetPhysicsObject( pEntity )

			if ( VPhysicsIsValid( pPhysObj ) ) then

				VPhysicsEnableMotion( pPhysObj, false )
				VPhysicsSleep( pPhysObj )

			end

		end

	end

end

hook.Add( 'CanCreateUndo', 'PhysicsCrashGuard_FreezeDupesOnPaste', function( pl, tblUndo )

	if ( tblUndo.Name ~= 'Duplicator' ) then
		return
	end

	if ( not g_bFreezeDupesOnPaste ) then
		return
	end

	FreezeEntities( tblUndo.Entities )

end )
