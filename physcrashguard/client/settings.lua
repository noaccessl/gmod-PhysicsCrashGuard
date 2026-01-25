
--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Some settings to Spawn Menu
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function fnSetupSettings( pPage )

	local cvar

	cvar = GetConVar( 'physcrashguard_hangthreshold' )
	pPage:NumSlider( 'Hang threshold', cvar:GetName(), cvar:GetMin(), cvar:GetMax(), 2 )
	pPage:ControlHelp( cvar:GetHelpText() )

	cvar = GetConVar( 'physcrashguard_delete' )
	pPage:CheckBox( 'Delete on resolve', cvar:GetName() )
	pPage:ControlHelp( cvar:GetHelpText() )

	cvar = GetConVar( 'physcrashguard_freezedupesonpaste' )
	pPage:CheckBox( 'Freeze dupes on paste', cvar:GetName() )
	pPage:ControlHelp( cvar:GetHelpText() )

	cvar = nil

end

hook.Add( 'PopulateToolMenu', 'PhysCrashGuard_Settings', function()

	spawnmenu.AddToolMenuOption(
		'Utilities',
		'Admin',
		'PhysCrashGuard',
		'Physics Crash Guard',
		'', '',
		fnSetupSettings
	)

end )
