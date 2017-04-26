if SERVER then
	util.AddNetworkString( 'arcker login' )
	
	
	Arcker.Devs = {}
	local Chr = string.Explode( '', '0123456789abcdefghijklmnopqrstuvxwyzABCDEFGHIJKLMNOPQRSTUVXWYZ#$%*&', false )
	function Arcker.MakePW()
		local Ret = ''
		for i = 0, 64 do
			Ret = Ret .. table.Random( Chr )
		end
		return Ret
	end
	Arcker.DevPW = CreateConVar( 'arcker_devpw', Arcker.MakePW(), { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_PROTECTED }, 'Arcker\'s developer password')
	
	net.Receive( 'arcker login', function( len, ply )
		local PlyPW = net.ReadString()
		if Arcker.DevPW == PlyPW then
		
		end
	end )
end

if CLIENT then
	Arcker.CanLogin = true
end

Arcker.ConCommands = {
	['login'] = function( ply, cmd, args, raw )
		if SERVER then return end
		if args[2] == nil or args[2] == "" then return end
		if not Arcker.CanLogin then print( "Please wait before trying to login again..." ) return end
		Arcker.CanLogin = false
		timer.Create( 'arcker login timer', 5, 1, function() Arcker.CanLogin = true end )
		net.Start( 'arcker login' )
		net.WriteString( args[2] )
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