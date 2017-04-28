// Client
// Sequence(7000)

function Arcker:PrintTable( t )
	print( util.TableToJSON( t, true ) )
end

function Arcker:Ply( info )
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Name()), string.lower(tostring(info))) ~= nil then
			return v
		end
	end
end

function Arcker:SimpleID( p ) // Either player or SteamID string
	local id = ( IsEntity( p ) and p:IsPlayer() ) and p:SteamID() or tostring( p )
	local x, y, z = string.match( string.Replace( id, 'STEAM_', '' ), '([0-9]+):([0-9]+):([0-9]+)' )
	local w = x + bit.lshift(y, 4)
	return string.upper( string.format( '%s-%s', bit.tohex( w, 2 ), string.TrimLeft( bit.tohex( z, 20 ), '0' ) ) )
end

function Arcker:SteamID( s )
	local w, z = string.match( s, '([0-9A-Fa-f]+)%-([0-9A-Fa-f]+)' )
	w = tonumber( w, 16 )
	z = tonumber( z, 16 )
	local x = bit.band( w, 0x0F )
	local y = bit.rshift( w, 4 )
	return string.format( 'STEAM_%s:%s:%s', x, y, z )
end

if SERVER then
	
	local Debug = CreateConVar( 'arcker_debug', 0, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, 'Debug mode for arcker')
	/*
	
		"arcker_debug" def: 0
		0: Disabled
		1: Simple
		2: With traceback
	
	*/
	function Arcker:Debug( ... )
		if Debug:GetInt() then
			if Debug:GetInt() == 2 then
				local Stack = string.split( debug.traceback(), '\n\t' ) // Getting stack trace. 'addons/arcker/lua/autorun/arcker.lua:0: in main chunk'
				local Sub = { string.find( Stack[#Stack], '[0-9]+:' ) } // Finds second colon. 'addons/arcker/lua/autorun/arcker.lua:0'
				print('[Arcker] at ' .. string.Replace( string.sub( Stack[#Stack], 0, Sub[2]-1 ), 'addons/arcker/lua/', '' ) ) // Prints from where the function call was made
			else
				Msg( '[Arcker] ' ) // No line breaks so the next print is on the same line
			end
			local Args = {...}
			if #Args == 1 and type(Args[1]) == 'table' then
				self:PrintTable( Args[1] )
			else
				print( ... )
			end
		end
	end
	
	function Arcker:Error( s )
		local Stack = string.split( debug.traceback(), '\n\t' ) // Copied from Arcker:Debug()
		local Sub = { string.find( Stack[#Stack], '[0-9]+:' ) }
		print('[Arcker] Exception at ' .. string.Replace( string.sub( Stack[#Stack], 0, Sub[2]-1 ), 'addons/arcker/lua/', '' ) )
		print( string.format( 'Message: %s.', s ) )
	end
	
	function Arcker:PrintA( ... )
		local Text = ""
		for k, v in pairs( { ... } ) do
			if type(v) == "Player" then
				Text = Text .. v:Nick() .. "(" .. v:SteamID() .. ")"
			elseif type(v) == "table" then
				Text = Text .. util.TableToJSON( v, true )
			else
				Text = Text .. tostring( v )
			end
		end

		Msg( Arcker:GetName(), ' ', Text, '\n' )
	end
	
end