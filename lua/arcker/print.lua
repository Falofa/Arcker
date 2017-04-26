// Print type enum
Arcker.PRINTCHAT = 0
Arcker.PRINTCONSOLE = 1
Arcker.PRINTF = 2

if SERVER then
	util.AddNetworkString( 'arcker print' )
	function Arcker.Print( ply, typ, ... )
		if ply == nil then ply = player.GetAll() end
		if ( type( ply ) == 'table' ) or ( IsEntity( ply ) and ply:IsPlayer() ) then
			net.Start( 'arcker print' )
			net.WriteTable( { ... } )
			net.WriteInt( typ or 0 )
			net.Send( ply )
			return true
		end
		return false
	end
end
	
if CLIENT then
	net.Receive( 'arcker print', function()
		local Text = net.ReadTable()
		local Type = net.ReadInt()
		if Type == Arcker.PRINTCHAT then chat.AddText( unpack( Text ) ) end
		if Type == Arcker.PRINTCONSOLE then print( unpack( Text ) ) end
		if Type == Arcker.PRINTF then print( string.format( unpack( Text ) ) ) end
	end )
end