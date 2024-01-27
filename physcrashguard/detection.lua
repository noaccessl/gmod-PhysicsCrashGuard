--[[---------------------------------------------------------------------------
	Prepare
---------------------------------------------------------------------------]]
--
-- Entity
--
local GetTable		= FindMetaTable( 'Entity' ).GetTable

--
-- PhysObj
--
local PHYSOBJ		= FindMetaTable( 'PhysObj' )

local GetEntity		= PHYSOBJ.GetEntity
local IsPenetrating	= PHYSOBJ.IsPenetrating

--
-- Globals
--
local IsThereHang	= physcrashguard.IsThereHang
local Iterator		= physcrashguard.Iterator
local Resolve		= physcrashguard.Resolve


--[[---------------------------------------------------------------------------
	Detect Hang
---------------------------------------------------------------------------]]
timer.Create( 'physcrashguard.DetectHang', 0, 0, function()

	if IsThereHang() then

		for num, pObj in Iterator() do

			local ent = GetEntity( pObj )
			local ent_t = GetTable( ent )

			if not ent_t.m_bPhysHang and IsPenetrating( pObj ) then
				Resolve( pObj, ent, ent_t )
			end

		end

	end

end )

hook.Add( 'CanPlayerUnfreeze', 'physguard.DetectHang', function( pl, ent, pObj )

	Resolve( pObj, ent, GetTable( ent ) )

	timer.Simple( 0, function()

		pObj:EnableMotion( false )
		pObj:Sleep()

	end )

end )
