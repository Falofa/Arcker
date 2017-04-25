
function Arcker:GenSeed( s, l )
	s = s .. 'f000413b8255b58ee3019d38a3f26ec28d4f6012dd1514ba4b24baea6ba2d450a68f7bed1558fa7cc0c9c4c9ec4fcaad901a69ccd3064443c96ad30a29bdadf457f0a842cbc6'
	local i = 0x3AB6FBC7434B
	local r = ""
	l = math.ceil( math.min( l/2, 1024/2 ) ) + 2
	for k = 1, l do
		i = bit.bxor( i, string.byte( s[ ( k % #s ) + 1 ] ) )
		i = i * 27 + bit.bxor( i, 0xFB353 )
		i = i % 256
		r = r .. bit.tohex( i, 2 )
	end
	return r
end

function Arcker:Hash( s, l, d ) 
	l = l or 16
	local typ = type( s )
	if type( s ) ~= 'string' then
		s = tostring( s )
	end
	s = s .. typ
	
	typ = type( d )
	if type( d ) ~= 'string' then
		d = tostring( d )
	end
	d = d .. typ .. Arcker:GenSeed( d .. s, l )
	
	local seed = string.Split( Arcker:GenSeed( s .. d .. typ, l ), "" )
	for k = 1, table.Count( seed ) do
		local last = string.byte( (seed[(k-1)%table.Count( seed )] or "a") ) or 35
		local inpt = string.byte( s[ k % string.len(s) ] or "a" ) or 12
		seed[k] = string.char( string.byte( seed[k] ) + bit.rshift( string.byte( seed[k] ), inpt * 6 + last * 5 ) )
	end
	s = s .. table.concat( seed, "" )
	local hash = {}
	local i = 1
	local len = l or 16
	local len_ = math.Clamp( len, 4, table.Count( seed ) )
	len = math.ceil( math.Clamp( len, 8, table.Count( seed ) ) / 2 ) * 2
	for k = 1, len / 2 do
		hash[k] = string.byte( seed[k] )
	end
	local last = 0
	for k, v in ipairs( string.Split( s, "" ) ) do
		local Byte = string.byte( v ) + ( len_ % 31 )
		Byte = Byte + ( last % 3 )
		Byte = Byte + ( ( string.byte( d[ k % string.len( d ) ] ) or 17 ) * ( ( last % 5 ) + 1 ) )
		Byte = Byte - hash[ ( i + 1 ) % table.Count( hash ) + 1 ]
		Byte = Byte + k + ( len_ % 11 )
		local hex = bit.tohex( ( Byte + string.byte( v ) + 37 ) % 256, 2 )
		Byte = Byte + string.byte( hex[1] ) + string.byte( hex[2] )
		Byte = Byte + k * 37 + ( ( last * 5 ) % 234 )
		
		local cur = hash[i]
		cur = bit.bxor( cur, Byte )
		hash[i] = cur
		i = ( i % ( len / 2 ) ) + 1
		last = Byte
	end
	local hash_s = ""
	for k = 1, len / 2 do
		hash_s = hash_s .. bit.tohex( ( hash[k] % 256 ), 2)
	end
	return string.sub( hash_s, 1, len_ )
end

function Arcker:RandomString( l, a )
	local alp = ""
	if type( a ) == "string" then
		alp = a																			// Manual alphabet
	else
		a = ( type( a ) == "number" and a or 0 )
		local al = {
			[0] = "0123456789abcdefghijklmnopqrstuvxwyzZBCDEFGHIJKLMNOPQRSTUVXWYZ",		// Alphanumeric
			[1] = "abcdefghijklmnopqrstuvxwyzZBCDEFGHIJKLMNOPQRSTUVXWYZ",				// Alphabet
			[2] = "01"				,													// Binary
			[3] = "0123456789",															// Decimal
			[4] = "0123456789abcdef",													// Hexadecimal
			[5] = "0123456789abcdefghijklmnopqrstuvxwyz"	,							// Base36
			[6] = "0123456789abcdefghijklmnopqrstuvxwyzZBCDEFGHIJKLMNOPQRSTUVXWYZ+/",	// Base64
		}
		alp = al[a] or al[0]
	end
	local len = l or 8
	local s = ""
	if string.len( alp ) ~= 0 then
		for i=1, l do
			s = s .. alp[ math.random( string.len( alp ) ) ]
		end
		return s
	end
	return ""
end

function Arcker:RandomColor( )
	return HSVToColor( math.random( 360 ), 1, 1 )
end

function Arcker:Pname( ... )
	local t = { ... }
	for i = 1, #t do
		if type( t[i] ) == 'Player' then
			t[i] = bit.tohex( t[i]:SteamID64() )
		end
	end
	return 'arcker.' .. table.concat( t, '.' )
end

function Arcker:UniqueName( a, b )
	/*
		Generates a quick random id for a timer/hook
	*/
	if b then
		if IsEntity( b ) and b:IsPlayer() then b = b:SteamID() .. b:SteamID64() end
		return string.Replace( string.lower( a ), ' ', '.' ) .. '.' .. self:Hash( b, 8, a .. b ) 
	else
		return string.Replace( string.lower( a ), ' ', '.' ) .. '.' .. self:RandomString( 8, 4 )
	end
end

function Arcker:Rot( s, n )
	if type( s ) ~= 'string' then return "" end
	if not s or #s == 0 then return "" end
	if not n then n = 13 end
	if type( n ) ~= 'number' then return "" end
	n = n - 1 // ( the script is made to work with counting from 0, so this is a needed step )
	
	local re = {}
	local alp = "abcdefghijklmnopqrstuvxwyz"
	
	for k = 1, #alp do
		re[alp[ k ]] = alp[ ( k + n ) % #alp + 1 ]
		re[string.upper( alp[ k ] )] = string.upper( re[alp[ k ]] )
	end
	
	local result = ""
	for k, v in ipairs( string.Split( s, "" ) ) do
		local a_ = re[ v ] or v
		result = result .. a_
	end
	return result
end

--[[-------------------------------------------------------------------------

	Unique Keys

---------------------------------------------------------------------------]]

IP_UNIQUE_KEY = ''
SERVER_UNIQUE_KEY = ''

function genIpKey()
	IP_UNIQUE_KEY = ''
	string.gsub( game.GetIPAddress(), '([0-9]-)[%.:]', function(v) 
		IP_UNIQUE_KEY = IP_UNIQUE_KEY .. Arcker:Hash( v, 6 )
	end )
end
function genSvKey( force )
	local str = 'arcker/server_unique_key.txt'
	if not force then
		if file.Exists( str, 'DATA' ) then
			SERVER_UNIQUE_KEY = file.Read( str, 'DATA' )
			if #SERVER_UNIQUE_KEY ~= 24 then
				genSvKey( true )
			end
			return false
		end
	end
	local k = Arcker:RandomString( 24, 4 )
	file.Write( str, k )
	SERVER_UNIQUE_KEY = k
	return true
end

genIpKey( )
genSvKey( false )

--[[-------------------------------------------------------------------------

	Arcker Strong Cryptography

---------------------------------------------------------------------------]]
local Jkz = {}
local Mutate = function( s, k, t )
	local p = t and ( s + string.byte( k ) ) or ( s - string.byte( k ) )
	return p % 256
end
local Code = function( s, k )
	function nextChar( i )
		return k[ ( ( i - 1 ) % #k ) + 1 ]
	end

	local tbl = {}
	for _, v in ipairs( string.Split( s, '' ) ) do
		local c = nextChar( _ )
		local int = string.byte( v )
		table.insert( tbl, bit.tohex( Mutate( int, c, true ), 2 ) )
	end
	return table.concat( tbl, '' )
end
local Decode = function( s, k )
	function nextChar( i )
		return k[ ( ( i - 1 ) % #k ) + 1 ]
	end

	local g = {}
	string.gsub( s, '..', function( v ) table.insert( g, tonumber( v, 16 ) ) end )

	local tbl = {}
	for _, v in ipairs( g ) do
		local c = nextChar( _ )
		local int = v
		table.insert( tbl, string.char( Mutate( int, c, false ) ) )
	end
	return table.concat( tbl, '' )
end
Jkz.Encode = function( s, key )
	key = Arcker:Hash( key )
	local r = Code( s, Arcker:Hash( key, 64 ), true )
	return r
end
Jkz.Decode = function( s, key )
	key = Arcker:Hash( key )
	local r = Decode( s, Arcker:Hash( key, 64 ), false )
	return r
end
--[[-------------------------------------------------------------------------

	Arcker.ASC

---------------------------------------------------------------------------]]
Arcker.ASC = {}
Arcker.ASC.HashLen = 4
Arcker.ASC.Encode = function( str, key )
	local conf = Arcker:Hash( str, Arcker.ASC.HashLen, key )
	local st = Jkz.Encode( str, key )
	return string.upper( conf .. st )
end
Arcker.ASC.Decode = function( str, key, err )
	str = string.lower( str )
	local fir = string.sub( str, 1, Arcker.ASC.HashLen )
	local sec = string.sub( str, 5 )

	local dec = Jkz.Decode( sec, key )
	if fir == Arcker:Hash( dec, Arcker.ASC.HashLen, key ) then
		return dec
	else
		if not err then
			error( 'Wrong key.' )
		else
			return false
		end
	end
end
Arcker.ASC.IsFormat = function( str )
	local fir = string.sub( str, 1, Arcker.ASC.HashLen )
	local sec = string.sub( str, 5 )

	return fir and sec and #fir == Arcker.ASC.HashLen and math.floor( #sec / 2 ) == #sec / 2
end
Arcker.ASC.IsValid = function( str, key )
	str = string.lower( str )
	local fir = string.sub( str, 1, Arcker.ASC.HashLen )
	local sec = string.sub( str, 5 )

	local dec = Jkz.Decode( sec, key )
	if fir == Arcker:Hash( dec, Arcker.ASC.HashLen, key ) then
		return true
	else
		return false
	end
end