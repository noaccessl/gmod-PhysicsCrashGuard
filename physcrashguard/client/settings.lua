
--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Some settings to Spawn Menu
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function fnSetupSettings( pPage )

	local g_bIsDedicated = game.IsDedicated()
	local bControlsEnabled = not g_bIsDedicated

	local cvar

	cvar = GetConVar( 'physcrashguard_hangthreshold' )
	if ( cvar ) then

		pPage:NumSlider( 'Hang threshold', cvar:GetName(), cvar:GetMin(), cvar:GetMax(), 2 )
			:SetEnabled( bControlsEnabled )
		pPage:ControlHelp( cvar:GetHelpText() )

	end

	cvar = GetConVar( 'physcrashguard_delete' )
	if ( cvar ) then

		pPage:CheckBox( 'Delete on resolve', cvar:GetName() )
			:SetEnabled( bControlsEnabled )
		pPage:ControlHelp( cvar:GetHelpText() )

	end

	cvar = GetConVar( 'physcrashguard_freezedupesonpaste' )
	if ( cvar ) then

		pPage:CheckBox( 'Freeze dupes on paste', cvar:GetName() )
			:SetEnabled( bControlsEnabled )
		pPage:ControlHelp( cvar:GetHelpText() )

	end

	cvar = nil

	if ( g_bIsDedicated ) then
		pPage:Help( 'This is a dedicated server, which means you can change these ConVars (`find physcrashguard_`) only via the server console.' )
			:SetColor( Color( 255, 76, 76 ) )
	end

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
