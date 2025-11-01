--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	A submodule responsible for freezing dupes upon their creation

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
--
local CEntity = FindMetaTable( 'Entity' )

local GetPhysicsObjectCount = CEntity.GetPhysicsObjectCount
local GetPhysicsObjectNum = CEntity.GetPhysicsObjectNum

--
-- Functions
--
local ipairs = ipairs


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Parameter
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_bFreezeDupesOnPaste

--
-- ConVar Setting
--
do

	local physcrashguard_freezedupesonpaste = CreateConVar(

		'physcrashguard_freezedupesonpaste',
		'1',

		FCVAR_ARCHIVE,

		'Should dupes be freezed on paste?',
		0, 1

	)

	g_bFreezeDupesOnPaste = physcrashguard_freezedupesonpaste:GetBool()

	cvars.AddChangeCallback( 'physcrashguard_freezedupesonpaste', function( _, _, value )

		g_bFreezeDupesOnPaste = tobool( value )

	end, 'Main' )

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Catch & freeze just pasted dupes
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
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

	if ( ptUndo.Name ~= 'Duplicator' ) then
		return
	end

	if ( g_bFreezeDupesOnPaste ) then
		FreezeEntities( ptUndo.Entities )
	end

end )
