
--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Some settings to Spawn Menu
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local command

local function fnSetupSettings( pPage )

	command = 'physcrashguard_hangthreshold'
	pPage:AddControl( 'Slider', {

		Label = 'Hang threshold';
		Command = command;
		Type = 'Float';
		Min = 4;
		Max = 200

	} )
	pPage:ControlHelp( GetConVar( command ):GetHelpText() )

	command = 'physcrashguard_delete'
	pPage:AddControl( 'CheckBox', { Label = 'Delete on resolve'; Command = command } )
	pPage:ControlHelp( GetConVar( command ):GetHelpText() )

	command = 'physcrashguard_freezedupesonpaste'
	pPage:AddControl( 'CheckBox', { Label = 'Freeze dupes on paste'; Command = command } )
	pPage:ControlHelp( GetConVar( command ):GetHelpText() )

	command = nil

end

hook.Add( 'PopulateToolMenu', 'PhysCrashGuard_Settings', function()

	spawnmenu.AddToolMenuOption(
		'Utilities',
		'Admin',
		'PhysCrashGuard',
		'Physics Crash Guard',
		'',
		'',
		fnSetupSettings
	)

end )
