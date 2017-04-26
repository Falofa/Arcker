AddCSLuaFile( )
Arcker = Arcker or { }
Arcker.Version = '0.1 ALPHA'
Arcker.Name = 'Arcker'
if SERVER then
	util.AddNetworkString( 'arcker files' )
	local Debug = CreateConVar( 'arcker_debug', 0, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, 'Debug mode for arcker')
	function Arcker.Debug(...)
		if Debug:GetBool() then
			local Stack = string.split( debug.traceback(), '\n\t' ) // Getting stack trace. 'addons/arcker/lua/autorun/arcker.lua:0: in main chunk'
			local Sub = { string.find( Stack[#Stack], '[0-9]+:' ) } // Finds second colon. 'addons/arcker/lua/autorun/arcker.lua:0'
			print('[Arcker] at ' .. string.sub( Stack[#Stack], 0, Sub[2]-1 ) ) // Prints from where the function call was made
			local Args = {...}
			if #Args == 1 and type(Args[1]) == 'table' then
				PrintTable( Args[1] )
			else
				print( ... )
			end
		end
	end
	local sv = 1 		// Server Side
	local cs = 2		// Client Side
	local sh = sv + cs	// Shared
	local Files = {
		{ 'net', sh },
		{ 'core', sh },
	}
	Arcker.ServerFiles = {}
	Arcker.ClientFiles = {}
	for k, v in ipairs( Files ) do
		if v[2] ~= 0 and type(v) == 'table' then
			local Filename = 'arcker/' .. v[1] .. '.lua'
			local Client = bit.band( v[2], cs )
			local Server = bit.band( v[2], sv )
			if Server then
				table.insert( Arcker.ServerFiles, Filename )
				include( Filename )
			end
			if Client then
				table.insert( Arcker.ClientFiles, Filename )
				AddCSLuaFile( Filename )
			end
		end
	end
	
	function Arcker.CsInclude( ply )
		if ply then
			net.Start( 'arcker files' )
			net.WriteTable( Arcker.ClientFiles )
			net.Send( ply )
		elseif #player.GetHumans() then
			net.Start( 'arcker files' )
			net.WriteTable( Arcker.ClientFiles )
			net.Broadcast( )
		end
	end
	
	hook.Add( 'PlayerAuthed', Arcker.CsInclude )
	hook.Add( 'PlayerInitialSpawn', Arcker.CsInclude )
	
	
end

if CLIENT then
	Arcker.ClientFiles = {}
	net.Receive( 'arcker files', function( L )
		Arcker.ClientFiles = net.ReadTable()
		for k, v in ipairs( Arcker.ClientFiles ) do
			include( v )
		end
	end	)
end