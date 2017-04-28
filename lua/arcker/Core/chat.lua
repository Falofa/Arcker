// Shared
// Sequence( 3000 )

if SERVER then
	local PrintColor =    Color( 186, 186, 186 )
	local PrintWarColor = Color( 235, 123,  89 )
	local PrintErrColor = Color( 200, 0,     0 )
	local PrintGrantedColor = Color( 0, 200, 0 )
	local META = FindMetaTable( "Player" )
	local Tag = "Arcker.PlayerPrint"

	util.AddNetworkString( Tag )
	function META:Print( ... )
		local t = {...}
		local ret = {}
		local id = Arcker:SimpleID( self )
		local rank = Arcker:GetRank( Arcker.PlayerRanks[id].rank )
		-- Color parsing:
			if IsColor( t[1] ) then
				table.insert( ret, t[1] )
			elseif t[1] == 1 then
				table.insert( ret, PrintWarColor )
			elseif t[1] == 2.1 then
				table.insert( ret, PrintErrColor )
			elseif t[1] == 2.2 then
				table.insert( ret, PrintGrantedColor )
			else
				table.insert( ret, PrintColor )
				table.insert( t, 1, "del" )
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
		net.Start( Tag )
		net.WriteTable( ret )
		net.Send( self )
	end
end

if CLIENT then
	net.Receive( "Arcker.PlayerPrint", function(  )
		local t = net.ReadTable(  )
		timer.Simple( 0.01, function(  )
			chat.AddText(  unpack(  t  )  )
		end )
	end )

	local defaultcolor = Color( 180, 150, 168 )
	hook.Add( "OnPlayerChat", "Arcker.ChatBoxMods", function( ply, str, team, ded )
		local tab = {}
		local id = Arcker:SimpleID( ply )
		local rank = Arcker:GetRank( Arcker.PlayerRanks[id].rank ) or nil
		print( rank )
		if ply and IsValid( ply ) then
			if rank then
				table.insert( tab, rank.color or defaultcolor )
				table.insert( tab, rank.tag[1]..' ' ) -- !
				table.insert( tab, ply:Nick(  )..': ')
				table.insert( tab, Color( 255, 255, 255) )
				table.insert( tab, str )
			else
				table.insert( tab, Color(  150, 150, 150, 200  ) )
				table.insert( tab, ply:Nick(  )..': ')
				table.insert( tab, Color( 255, 255, 255) )
				table.insert( tab, str )
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