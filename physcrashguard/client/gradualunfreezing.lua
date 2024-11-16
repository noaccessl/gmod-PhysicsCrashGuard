--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Display the process of unfreezing objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Unfreezing enums
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local UNFREEZE_START = 0
local UNFREEZE_ABORT = 1
local UNFREEZE_PROGRESS = 2
local UNFREEZE_DONE = 3

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Store unfreezing data
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
physcrashguard.Unfreezing = physcrashguard.Unfreezing or {

	Status = 0;
	Entities = {}

}

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Simple interface for managing unfreezing status & entities
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local IUnfreezingQueue = {}
do

	IUnfreezingQueue.__index = IUnfreezingQueue
	IUnfreezingQueue.__tostring = function( self ) return Format( 'IUnfreezingQueue: %p', self ) end

	-- Get the status
	function IUnfreezingQueue:GetStatus() return physcrashguard.Unfreezing.Status end

	-- Get all entities
	function IUnfreezingQueue:GetAll() return physcrashguard.Unfreezing.Entities end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		SetStatus
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:SetStatus( iStatus )

		physcrashguard.Unfreezing.Status = iStatus

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		UpdateStatus
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:UpdateStatus( text, flFraction )

		if ( text == nil ) then
			notification.Kill( 'unfreezing' )
		else
			notification.AddProgress( 'unfreezing', text, flFraction )
		end

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Start
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Start()

		self:Clear()
		self:SetStatus( UNFREEZE_START )

		self:UpdateStatus( Format( language.GetPhrase( 'hint.unfrozeX' ), 0 ) .. '...', 0 )

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Abort
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Abort()

		self:SetStatus( UNFREEZE_ABORT )

		timer.Simple( 1, function()

			if ( self:GetStatus() == UNFREEZE_ABORT ) then
				self:Clear()
			end

		end )

		self:UpdateStatus( Format( language.GetPhrase( 'hint.unfrozeX' ), 0 ) .. '...', 0 )
		self:UpdateStatus( nil )

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		PropelForward
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:PropelForward( flFraction, pEntity )

		self:SetStatus( UNFREEZE_PROGRESS )
		local iUnfrozeObjects = self:Add( pEntity )

		self:UpdateStatus( Format( language.GetPhrase( 'hint.unfrozeX' ), iUnfrozeObjects ) .. '...', flFraction )

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Finish
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Finish( iUnfrozeObjects )

		self:SetStatus( UNFREEZE_DONE )
		self:Clear()

		self:UpdateStatus( Format( language.GetPhrase( 'hint.unfrozeX' ), iUnfrozeObjects ) .. '.', 1 )
		self:UpdateStatus( nil )

		if ( GAMEMODE.UnfrozeObjects ) then
			GAMEMODE:UnfrozeObjects( iUnfrozeObjects )
		end

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Add
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Add( pEntity )

		return table.insert( physcrashguard.Unfreezing.Entities, pEntity )

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Clear
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Clear()

		table.Empty( physcrashguard.Unfreezing.Entities )

	end

end

physcrashguard.UnfreezingQueue = physcrashguard.UnfreezingQueue or newproxy( true )
debug.setmetatable( physcrashguard.UnfreezingQueue, IUnfreezingQueue )


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Display the process
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local COLOR_UNFREEZING = Color( 76, 255, 255 )
local COLOR_ABORT = Color( 255 - COLOR_UNFREEZING.r, 255 - COLOR_UNFREEZING.g, 255 - COLOR_UNFREEZING.b ) -- Let's have inverted color

local COLOR_DISPLAY = COLOR_UNFREEZING

hook.Add( 'PreDrawHalos', 'PhysicsCrashGuard_GradualUnfreezing', function()

	local UnfreezingEntities = physcrashguard.UnfreezingQueue:GetAll()

	if ( #UnfreezingEntities == 0 ) then
		return
	end

	local iStatus = physcrashguard.UnfreezingQueue:GetStatus()

	if ( iStatus == UNFREEZE_ABORT ) then
		COLOR_DISPLAY = COLOR_ABORT
	else
		COLOR_DISPLAY = COLOR_UNFREEZING
	end

	halo.Add( UnfreezingEntities, COLOR_DISPLAY, 2, 2, 1, true, true )

end )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Network
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
net.Receive( 'physcrashguard.Unfreeze', function()

	local iType = net.ReadUInt( 2 )

	if ( iType == UNFREEZE_START ) then

		physcrashguard.UnfreezingQueue:Start()

	elseif ( iType == UNFREEZE_ABORT ) then

		physcrashguard.UnfreezingQueue:Abort()

	elseif ( iType == UNFREEZE_PROGRESS ) then

		local flFraction = net.ReadFloat()
		local pEntity = net.ReadEntity()

		physcrashguard.UnfreezingQueue:PropelForward( flFraction, pEntity )

	elseif ( iType == UNFREEZE_DONE ) then

		local iUnfrozeObjects = net.ReadUInt( 12 )
		physcrashguard.UnfreezingQueue:Finish( iUnfrozeObjects )

	end

	--
	-- Update colors
	--
	local cl_weaponcolor = GetConVar( 'cl_weaponcolor' )

	if ( cl_weaponcolor ) then
		COLOR_UNFREEZING = Vector( cl_weaponcolor:GetString() ):ToColor()
	else
		COLOR_UNFREEZING = Color( 76, 255, 255 )
	end

	COLOR_ABORT = Color( 255 - COLOR_UNFREEZING.r, 255 - COLOR_UNFREEZING.g, 255 - COLOR_UNFREEZING.b )

end )
