if SERVER then
	local overwrite = type( Arcker ) ~= 'nil'
	Arcker = Arcker or { }
	Arcker.Valid = true
	Arcker.Files = Arcker.Files or { }

	Arcker.Debug = { }
	Arcker.Debug.Color 		= Color( 255, 255, 255 )
	Arcker.Debug.ErrColor 	= Color( 240, 30 , 0   )
	function Arcker.Debug:Add( err, ... )
		local t = { ( err and self.ErrColor or self.Color ), ... }
		for i = 1, #t do
			if type( t[i] ) == "Player" then
				t[ i ] = t[ i ]:Nick() .. ' (' .. t[ i ]:SteamID() .. ')'
			end
		end
		MsgC( Arcker:LogName(), ' ' )
		for k, v in ipairs( t ) do MsgC( v ) end // I would like to use unpack for this, but for some reason it doesnt seem to work with MsgC...
		MsgC( '\n' )
	end

	function Arcker:Require( s )
		local b = Arcker.Files[ s ] or false
		local _type = false
		if not b then
			if file.Exists( b, "LUA" ) then
				b = s
			end
			_type = 'sv'
		else
			_type = b.type
			b = b.file
		end
		if b then
			if _type == 'sv' or _type == 'sh' then
				return include( b ) or false
			else
				return false
			end
		else
			return false
		end
	end

	function Arcker:ReloadEvents()
		Arcker.RegisteredEvents = { }
		Arcker.Events = {
			OnEndLoad 		= true,
			OnEndBaseLoad 	= true,
		}
		for k, v in pairs( Arcker.Events ) do
			Arcker.RegisteredEvents[ k ] = { }
		end
		function Arcker:RunEvent( s )
			if Arcker.Events[s] then
				Arcker.Debug:Add( false, "Event ran: " .. s .. "." )
				for k, func in pairs( Arcker.RegisteredEvents[s] ) do
					local success, err = pcall( func )
					if not success and err then
						Arcker.Debug:Add( true, "'" .. func .. "' registered as event [[" .. s .. "]] returned an error!\nMore information:\n" .. err )
					end
				end
				return true
			else
				Arcker.Debug:Add( true, "Invalid event ran: " .. s .. "." )
				return false
			end
		end
		function Arcker:AddEvent( s, f )
			if Arcker.Events[s] then
				table.insert( Arcker.RegisteredEvents[s], f )
				return true
			else
				return false
			end
		end
	end
	
	function Arcker:Boot( p )
		Arcker:ReloadEvents()
		MsgC( "-=[[ Arcker Booting ]]=-\n" )
		if not p then
			Arcker.Name = "Arcker"
			Arcker.Version = "v2.1"
			function Arcker:GetName()
				return table.concat( { Arcker.Name, Arcker.Version }, " " )
			end
			function Arcker:LogName()
				return table.concat( { '( ', Arcker.Name, ' )' } )
			end
			Arcker.__tostring = Arcker.GetName
			if not file.Exists( "arcker/", "DATA" ) then file.CreateDir( "arcker" ) end
			
			Arcker.ToSend = { }
		end
		function Arcker:LoadAll()
			Arcker.Subfiles = { }
			local dir = {
				'arcker/core',
				'arcker/util',
				'arcker/vgui'
			}
			local Files = {
				sh = { },
				sv = { },
				cs = { },
			}
			local function FileToPrint( s )
				local w = string.Replace( s, 'arcker/', '' )
				w = string.Replace( w, '.lua', '' )
				w = string.Replace( w, '_cl', '' )
				w = string.Replace( w, '_sv', '' )
				w = string.Replace( w, '_sh', '' )
				w = string.Replace( w, '/', '.' )
				return w
			end
			for k, v in ipairs( dir ) do
				local files = file.Find( v .. '/*.lua', "LUA" )
				for _, i in ipairs( files ) do
					if (not p) or (p and string.find( i, p ) ~= nil) then
						local s = v .. '/' .. i
						local p = string.Replace( s, 'arcker/', '' ) // its kind of redundant to keep repeating 'arcker/whatever.lua'
						local l = { cs = false, sv = false }
						l.cs = string.find( s, '.-_cl%.lua' ) ~= nil or string.find( s, '.-_sh%.lua' ) ~= nil
						l.sv = string.find( s, '.-_cl%.lua' ) == nil
						
						local _type = false
						if not l.sv and     l.cs then table.insert( Files.cs, s ) _type = 'cs' end
						if     l.sv and not l.cs then table.insert( Files.sv, s ) _type = 'sv' end
						if     l.sv and     l.cs then table.insert( Files.sh, s ) _type = 'sh' end
						Arcker.Files[ FileToPrint( s ) ] = { file = s, type = _type }
					end
				end
			end
			/*
				INCLUDE FUNCTIONS
			*/
			util.AddNetworkString( 'arckerinclude' )
			function Arcker:SendCs( ply, t )
				local t = t or Arcker.ToSend
				net.Start( 'arckerinclude' )
				net.WriteTable( t )
				if ply then
					net.Send( ply )
					Arcker.Debug:Add( false, 'Sent ', ply, ' file list to include!' )
				else
					net.Broadcast()
					local i = #player.GetHumans()
					if i ~= 0 then
						Arcker.Debug:Add( false, 'Broadcasting file list to ' .. i .. ' player' .. ( i == 1 and '' or 's' ) .. '!' )
					end
				end
			end
			function Arcker:IncludeSv( s, echo )
				if echo or echo == nil then
					Arcker.Debug:Add( false, 'Server file init: ', FileToPrint( s ) )
				end
				include( s )
			end
			function Arcker:IncludeCs( s, echo )
				if echo or echo == nil then
					Arcker.Debug:Add( false, 'Client file init: ', FileToPrint( s ) )
				end
				AddCSLuaFile( s )
				table.insert( Arcker.ToSend, s )
			end
			function Arcker:IncludeSh( s, echo )
				if echo or echo == nil then
					Arcker.Debug:Add( false, 'Shared file init: ', FileToPrint( s ) )
				end
				Arcker:IncludeSv( s, false )
				Arcker:IncludeCs( s, false )
			end
			/*
				Including all files
			*/
			for k, s in SortedPairsByValue( Files.sv ) do
				Arcker:IncludeSv( s )
			end
			for k, s in SortedPairsByValue( Files.sh ) do
				Arcker:IncludeSh( s )
			end
			for k, s in SortedPairsByValue( Files.cs ) do
				Arcker:IncludeCs( s )
			end
			Arcker:SendCs( nil )
			hook.Add( 'PlayerAuthed', 'arcker.cl', function( ply )
				Arcker:SendCs( ply )
			end )
		end
		Arcker:LoadAll()
		Arcker:RunEvent( 'OnEndLoad' )
	end
	Arcker:Boot()
	Arcker:Load()
end
if CLIENT then
	Arcker = Arcker or {}
	net.Receive( 'arckerinclude', function()
		local t = net.ReadTable() or false
		if not t then RunConsoleCommand( [[ disconnect ]] ) end
		/*
			Any failure to execute the demanded files will result in
			an instantaneous disconnection.
		*/
		for k, v in ipairs( t ) do 
			include( v )
		end
		Arcker:Load()
	end )
end