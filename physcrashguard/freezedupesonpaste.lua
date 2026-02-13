--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	A submodule responsible for freezing dupes upon their creation

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Configurational ConVar
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local physcrashguard_freezedupesonpaste = CreateConVar(
	'physcrashguard_freezedupesonpaste', '1',
	FCVAR_ARCHIVE + FCVAR_REPLICATED,
	'Should dupes be freezed on paste?',
	0, 1
)

if ( CLIENT ) then

	physcrashguard_freezedupesonpaste = nil

	-- Return. Only the convar is needed for clientside settings.
	return

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Parameter
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_bFreezeDupesOnPaste = physcrashguard_freezedupesonpaste:GetBool()

cvars.AddChangeCallback( 'physcrashguard_freezedupesonpaste', function( _, _, value )

	g_bFreezeDupesOnPaste = tobool( value )

end, 'PhysCrashGuard' )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Catch & freeze just pasted dupes
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local CEntity = FindMetaTable( 'Entity' )
local GetPhysicsObjectCount = CEntity.GetPhysicsObjectCount
local GetPhysicsObjectNum = CEntity.GetPhysicsObjectNum

local function FreezeEntities( pArrayOfEntities )

	for _, pEntity in ipairs( pArrayOfEntities ) do

		for num = 0, GetPhysicsObjectCount( pEntity ) - 1 do

			local pPhysObj = GetPhysicsObjectNum( pEntity, num )

			if ( pPhysObj:IsValid() ) then

				pPhysObj:EnableMotion( false )
				pPhysObj:Sleep()

			end

		end

	end

end

--
-- Integrate; through GM:CanCreateUndo
--
hook.Add( 'CanCreateUndo', 'PhysCrashGuard_FreezeDupesOnPaste', function( _, ptUndo )

	if ( ptUndo.Name == 'Duplicator' and g_bFreezeDupesOnPaste ) then
		FreezeEntities( ptUndo.Entities )
	end

end )
