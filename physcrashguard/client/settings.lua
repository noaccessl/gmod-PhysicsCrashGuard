
--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Some settings to Spawn Menu
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function fnSetupSettings( pPage )

	pPage:AddControl( 'Slider', {

		Label = 'Hang threshold';
		Command = 'physcrashguard_hangthreshold';
		Type = 'Float';
		Min = 4;
		Max = 200

	} )
	pPage:ControlHelp( 'Threshold for counting last physics simulation duration as physics hang, in ms.' )

	pPage:AddControl( 'CheckBox', { Label = 'Delete on resolve'; Command = 'physcrashguard_delete' } )
	pPage:ControlHelp( 'Experimental. Should entities to resolve be deleted? Won\'t apply to ragdolls.' )

	pPage:AddControl( 'CheckBox', { Label = 'Freeze dupes on paste'; Command = 'physcrashguard_freezedupesonpaste' } )
	pPage:ControlHelp( 'Should dupes be freezed on paste?' )

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
