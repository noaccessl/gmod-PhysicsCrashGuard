
--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Add some settings to the Spawn Menu
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function SetupSettings( Page )

	Page:AddControl( 'Slider', {

		Label = 'Hang detection (ms)';
		Command = 'physcrashguard_hangdetection';
		Type = 'Float';
		Min = 1;
		Max = 100

	} )
	Page:ControlHelp( 'What delay in physics simulation will be considered as a physics hang' )

	Page:AddControl( 'CheckBox', { Label = 'Delete on resolve'; Command = 'physcrashguard_delete' } )
	Page:ControlHelp( 'Experimental. Should entities to resolve be deleted? Won\'t apply to ragdolls.' )

	Page:AddControl( 'CheckBox', { Label = 'Freeze dupes on paste'; Command = 'physcrashguard_freezedupesonpaste' } )
	Page:ControlHelp( 'Should dupes be freezed on paste?' )

end

hook.Add( 'PopulateToolMenu', 'PhysicsCrashGuard_Settings', function()

	spawnmenu.AddToolMenuOption(

		'Utilities',
		'Admin',
		'PhysicsCrashGuard',
		'Physics Crash Guard',
		'',
		'',
		SetupSettings

	)

end )
