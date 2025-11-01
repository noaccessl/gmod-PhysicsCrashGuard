--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Display of the process of unfreezing objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Unfreezing Message Types Enums
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local UNFREEZE_START = 0
local UNFREEZE_ABORT = 1
local UNFREEZE_PROGRESS = 2
local UNFREEZE_DONE = 3

local MAX_UNFREEZE_BITS = 2


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Unfreezing data
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
PhysCrashGuard.m_tUnfreezingDetails = PhysCrashGuard.m_tUnfreezingDetails or {

	Status = 0;
	Entities = {}

}

local g_pUnfreezingQueue

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Simple interface for managing unfreezing status & entities
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local IUnfreezingQueue = {}
do

	IUnfreezingQueue.__index = IUnfreezingQueue
	IUnfreezingQueue.__tostring = function( self ) return Format( 'IUnfreezingQueue: %p', self ) end


	-- Get the status
	function IUnfreezingQueue:GetStatus() return PhysCrashGuard.m_tUnfreezingDetails.Status end

	-- Get all entities
	function IUnfreezingQueue:GetAll() return PhysCrashGuard.m_tUnfreezingDetails.Entities end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		SetStatus
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:SetStatus( iStatus )

		PhysCrashGuard.m_tUnfreezingDetails.Status = iStatus

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Notify
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Notify( text, flFraction )

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

		self:Notify( Format( language.GetPhrase( 'hint.unfrozeX' ), 0 ) .. '...', 0 )

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

		self:Notify( Format( language.GetPhrase( 'hint.unfrozeX' ), 0 ) .. '...', 0 )
		self:Notify( nil )

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Progress
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Progress( flFraction, pEntity )

		self:SetStatus( UNFREEZE_PROGRESS )
		local iUnfrozeObjects = self:Add( pEntity )

		self:Notify( Format( language.GetPhrase( 'hint.unfrozeX' ), iUnfrozeObjects ) .. '...', flFraction )

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Finish
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Finish( iUnfrozeObjects )

		self:SetStatus( UNFREEZE_DONE )
		self:Clear()

		self:Notify( Format( language.GetPhrase( 'hint.unfrozeX' ), iUnfrozeObjects ) .. '.', 1 )
		self:Notify( nil )

		if ( GAMEMODE.UnfrozeObjects ) then
			GAMEMODE:UnfrozeObjects( iUnfrozeObjects )
		end

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Add
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Add( pEntity )

		return table.insert( PhysCrashGuard.m_tUnfreezingDetails.Entities, pEntity )

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Clear
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function IUnfreezingQueue:Clear()

		table.Empty( PhysCrashGuard.m_tUnfreezingDetails.Entities )

	end

end

--
-- Create
--
if ( not PhysCrashGuard.m_pUnfreezingQueue ) then

	PhysCrashGuard.m_pUnfreezingQueue = newproxy()
	debug.setmetatable( PhysCrashGuard.m_pUnfreezingQueue, IUnfreezingQueue )

end

g_pUnfreezingQueue = PhysCrashGuard.m_pUnfreezingQueue


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Display the process
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_colUnfreezing = Color( 76, 255, 255 )
local g_colAbort = Color( 255 - g_colUnfreezing.r, 255 - g_colUnfreezing.g, 255 - g_colUnfreezing.b )
-- Let's have inverted color

local g_colDisplaying = g_colUnfreezing

hook.Add( 'PreDrawHalos', 'PhysCrashGuard_GradualUnfreezing', function()

	local tUnfreezingEntities = g_pUnfreezingQueue:GetAll()

	if ( #tUnfreezingEntities == 0 ) then
		return
	end

	local iStatus = g_pUnfreezingQueue:GetStatus()

	if ( iStatus == UNFREEZE_ABORT ) then
		g_colDisplaying = g_colAbort
	else
		g_colDisplaying = g_colUnfreezing
	end

	halo.Add( tUnfreezingEntities, g_colDisplaying, 2, 2, 1, true, true )

end )


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Network
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
net.Receive( 'physcrashguard_gradualunfreezing', function()

	-- Update colors
	do

		local cl_weaponcolor = GetConVar( 'cl_weaponcolor' )

		if ( cl_weaponcolor ) then
			g_colUnfreezing = Vector( cl_weaponcolor:GetString() ):ToColor()
		else
			g_colUnfreezing = Color( 76, 255, 255 )
		end

		g_colAbort = Color( 255 - g_colUnfreezing.r, 255 - g_colUnfreezing.g, 255 - g_colUnfreezing.b )

	end

	local iType = net.ReadUInt( MAX_UNFREEZE_BITS )

	if ( iType == UNFREEZE_START ) then

		g_pUnfreezingQueue:Start()
		return

	end

	if ( iType == UNFREEZE_ABORT ) then

		g_pUnfreezingQueue:Abort()
		return

	end

	if ( iType == UNFREEZE_PROGRESS ) then

		g_pUnfreezingQueue:Progress( net.ReadFloat(), net.ReadEntity() )
		return

	end

	if ( iType == UNFREEZE_DONE ) then

		g_pUnfreezingQueue:Finish( net.ReadUInt( MAX_EDICT_BITS ) )
		return

	end

end )
