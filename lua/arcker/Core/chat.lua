// Shared
// Sequence( 3000 )

if SERVER then

	local META = FindMetaTable( "Player" )

	function META:ArckerPrint( ... )
		local t = {...}
		local ret = {}
		function Add( ... ) table.insert( ret, ... ) end
		local id = Arcker:SimpleID( self )
		local rank = Arcker:GetRank( Arcker.PlayerRanks[id].rank )
		-- Color parsing:
			if IsColor( t[1] ) then
				Add( t[1] )
			elseif t[1] == 1 then
				Add( Arcker:Color( 'Glow' ) )
			elseif t[1] == 2.1 then
				Add( Arcker:Color( 'Lips' ))
			elseif t[1] == 2.2 then
				Add( Arcker:Color( 'Alert' ) )
			else
				Add( PrintColor )
			end
			table.remove( t, 1 ) -- Make sure we remove the color for next parsing
		-- Parsing:
		for k, v in pairs( t ) do
			local spc = t[#t] != v and " " or ""
			if type( v ) == "table" then
				table.insert( ret, v )
			elseif type( v ) == "Vector" then
				table.insert( ret, tostring( v ) .. spc )
			elseif type( v ) == "Player" then
				local war = PrintWarColor
				local err = PrintErrColor
				local gran = PrintGrantedColor
				local function lastcolor(  )
					local last
					for k, v in pairs( ret ) do
						if IsColor( v ) then
							last = v
						end
					end
					if last then return true, last else return false end
				end
				local bol, last = lastcolor(  )
				if t[#t] != v then
					table.insert( ret, rank.color )
					table.insert( ret, v:Nick(  ) .. spc )
					local col = t[1] == 1 and war or t[1] == 2.1 and err or t[1] == 2.2 and gran or bol and last or PrintColor
					table.insert( ret, col )
				else
					table.insert( ret, rank.color )
					table.insert( ret, v:Nick(  ) )
				end
			else
				table.insert( ret, v .. spc )
			end
		end
		-- Sending to player:
		net.Start( 'arcker print' )
		net.WriteTable( ret )
		net.Send( self )
	end
end

if CLIENT then
	hook.Add( "OnPlayerChat", "Arcker.ChatBoxMods", function( ply, str, team, ded )
		local tab = {}
		local function Add( ... ) table.insert( tab, ... ) end
		local id = Arcker:SimpleID( ply )
		local rank = Arcker:GetRank( Arcker.PlayerRanks[id].rank ) or nil
		print( rank )
		if ply and IsValid( ply ) then
			if rank then
				Add( rank.color or defaultcolor )
				for k, v in ipairs( rank.tag ) do
					Add( v )
				end
				Add( ' ' )
				Add( ply:GetName( ) .. ': ')
				Add( Color( 255, 255, 255 ) )
				Add( str )
			else
				Add( Color(  150, 150, 150, 200  ) )
				Add( ply:GetName( ) .. ': ')
				Add( Color( 255, 255, 255) )
				Add( str )
			end
		else
			table.insert( str, Color( 150, 150, 150 ) )
			table.insert( str, "Console"  )
			table.insert( str, Color( 255, 255, 255 ) )
			table.insert( str, ': ' )
		end

		chat.AddText( unpack( tab ) )
	end )
end