GlobalColor = Color( 255, 255, 255, 255 )
if SERVER then
	Arcker.ChatColor = GlobalColor
end
function rcol() 
	return Arcker and Arcker.ChatColor or GlobalColor 
end

if SERVER then
	util.AddNetworkString( 'chatprint' )
	function PrintSafe( t )
		/*
			Parses the arguments so its easier to call the PLAYER:Print( ... )
			( some random crashes have been reported after printing some values i.e. vectors )
		*/
		local result = {} // Default chat color
		for k, v in ipairs( t ) do
			if type( v ) == "table" then
				if v.r then // In case the table is a color
					table.insert( result, v )
				elseif v.x then // In case the table is a vector
					table.insert( result, tostring( v ) )
				else // Otherwise
					for _, i in ipairs( PrintSafe( v ) ) do
						table.insert( result, i )
					end
				end
			else
				if v then // Making sure we're not passing nil as an element
					table.insert( result, v )
				end
			end
		end
		return result
	end
	local PLAYER = FindMetaTable( 'Player' )
	function PLAYER:Print( ... )
		if #{ ... } == 0 then return false end
		local tab = PrintSafe({ rcol(), ... })
		net.Start( 'chatprint' )
		 net.WriteTable( tab )
		net.Send( self )
	end
	function PrintA( ... )
		if #{ ... } == 0 then return false end
		local tab = PrintSafe({ rcol(), ... })
		net.Start( 'chatprint' )
		 net.WriteTable( tab )
		net.Broadcast()
	end
	function PLAYER:Aprint( ... )
		if #{ ... } == 0 then return false end
		local tab = PrintSafe({ Color(255,255,100),"[Arcker] ",rcol(), ... })
		net.Start( 'chatprint' )
		 net.WriteTable( tab )
		net.Send( self )
	end
	function chatP( ply )
		return { 
			Arcker.Ranks[ ply:Team() ].Color,
			ply:Nick(),
			rcol()
		}
	end
end
if CLIENT then
	net.Receive( 'chatprint',function()
		local args = net.ReadTable()
		chat.AddText( unpack( args ) )
	end )
	
	hook.Add("OnPlayerChat", "arcker.chat",function( ply, txt, tem, dead )
		local str = {}
		if ply and IsValid( ply ) then
			if Ranks[ ply:Team() ].Tag then
				for k, v in ipairs( Ranks[ ply:Team() ].Tag ) do
					table.insert( str, v )
				end
				table.insert( str, " " )
				table.insert( str, rcol() )
			end
			local rank_col = Ranks[ ply:Team() ].Color or Color( 150, 200, 0, 255 )
			table.insert( str, rank_col )
			local nick = ply:Nick()
			table.insert( str, nick )
			table.insert( str, Color( 255, 255, 255, 255 ) )
			table.insert( str, ': ' )
		else
			table.insert( str, Color( 150, 150, 150, 255 ) )
			table.insert( str, "Console" )
			table.insert( str, Color( 255, 255, 255, 255 ) )
			table.insert( str, ': ' )
		end
		if txt then
			local abc = 'abcdefghijklmnopqrstuvxwyz'
			local text = txt
			if string.find( abc, txt[1], 1, true ) ~= nil then
				// Making sure players always use upper case on the start of their message
				text = string.upper( txt[1] ) .. ( string.sub( txt, 2 ) or '' )
			end
			table.insert( str, text )
		end
		
		chat.AddText( unpack( str ) )
		return true
	end )
end