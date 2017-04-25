local Plugin = {}
Plugin.Name 	= "Administration"
Plugin.Id		= "administration"
Plugin.Author 	= "Falofa"

Plugin.Load = function( Arcker )
	
	Arcker:AddCommand( "setrank", {
		desc = "",
		help = "",
		rank = "owner",
		args = {"ES"},
		dorun = function(t,ply)
			local tar = t.args[1]
			if tar:SteamID() == ply:SteamID() then
				ply:Print( "You can't change your own rank." )
				return
			end
			local str = string.lower( t.args[2] )
			local exists = false
			local rid = -1
			for k, v in pairs( Arcker.Ranks ) do
				if v.Id == str then
					exists = true
					rid = k
				end
			end
			if exists then
				local a = "aeiou"
				local an = "a"
				if string.find( a, string.lower( Arcker.Ranks[rid].Name[1] ), 1, true ) ~= nil then
					an = "an"
				end
				tar:SetRank( str )
				PrintA( chatP(tar)," is now ", an, " ", Arcker.Ranks[rid].Color, Arcker.Ranks[rid].Name, rcol(), "." )
				Arcker:Log( "[ADMIN] ",plytolog(ply), " set ", plytolog(tar), " rank to: ", Arcker.Ranks[rid].Name )
			else
				ply:Print( "Rank does not exist." )
			end
		end
	})
	Arcker:AddCommand( "decals", {
		desc = "",
		help = "",
		rank = "admin",
		args = {""},
		dorun = function(t,ply)
			BroadcastLua("RunConsoleCommand( 'r_cleardecals' )")
			PrintA(chatP(ply)," cleaned all decals!")
		end
	})
	Arcker:AddCommand( "gibs", {
		desc = "",
		help = "",
		rank = "admin",
		args = {""},
		dorun = function(t,ply)
			BroadcastLua("game.CleanUpMap()")
			PrintA(chatP(ply)," cleaned all clientside props and decals!")
		end
	})
	Arcker:AddCommand( "kick", {
		desc = "",
		help = "",
		rank = "admin",
		args = {"E","ES"},
		dorun = function(t,ply)
			local tar = t.args[1]
			local mes = t.args[2]
			Arcker:Log( "[ADMIN] ", plytolog(ply), " kicked ", plytolog( tar ), " reason: '", ( mes or "no reason" ) ,"'" )
			tar:Kick( mes )
		end
	})
	
	Arcker:AddCommand( "ban", {
		desc = "",
		help = "",
		rank = "admin",
		args = {"E","ET","ES","ETS"},
		dorun = function(t,ply)
			local tar = t.args[1]
			local tim = ( string.find( t.typ, "T" ) ~= nil ) and t.args[2][1] or 0
			local ti_ = ( string.find( t.typ, "T" ) ~= nil ) and t.args[2][2] or "0"
			local str = ""
			if string.find( t.typ, "S" ) ~= nil then
				if t.typ == "ES" then str = t.args[2] end
				if t.typ == "ETS" then str = t.args[3] end
			end
			Arcker:Log( "[ADMIN] ", plytolog(ply), " banned ", plytolog( tar ), " for " .. ti_ .. ", reason: '", ( mes or "no reason" ) ,"'" )
			tar:Ban( tim, true, str )
			if tar:IsBot() then
				tar:Kick()
			end
		end
	})
	function SendError( ply, s )
		if not ply then return end
		if not s then return end
		ply:SendLua( 'print([[' .. s .. ']])' )
	end
	
	Arcker:AddCommand( "l", {
		desc = "",
		help = "",
		rank = "owner",
		raw = true,
		args = {""},
		dorun = function(t,ply)
			local s = t.args
			if #t.args ~= 0 then
				PrintA( chatP(ply), Color( 255, 200, 100), '@', Color( 255, 255, 100), 'server', rcol(), ': ', t.args )
			end
			LuaCode = 'L_R = function() ' .. string.Replace( s, 'print', 'prin_' ) .. ' end'
			local err_ = RunString( LuaCode, nil, false )
			if err_ == nil then
				L_PLY = ply
				prin_ = function( ... ) ply:Print( Color( 255,100,0 ), '[Lua] ', rcol(), ... ) end
				local err = RunString( ' L_R() ' )
				if err ~= nil then
					SendError( ply, err )
					ply:Print( 'An internal error ocourred, read your console!' )
				end
			else
				SendError( ply, err )
				ply:Print( 'An internal error ocourred, read your console!' )
			end
			return ''
		end
	} )
	Arcker:AddCommand( "pw", {
		desc = "",
		help = "",
		rank = "owner",
		raw = true,
		args = {""},
		dorun = function(t,ply)
			RunConsoleCommand( 'sv_password', t.args )
			return ''
		end
	})
	Arcker:AddCommand( "lock", {
		desc = "",
		help = "",
		rank = "owner",
		args = {""},
		dorun = function(t,ply)
			RunConsoleCommand( 'sv_password', Arcker:RandomString( 16, 0 ) )
			PrintA( chatP(ply), ' locked the server!' )
			return ''
		end
	})
	Arcker:AddCommand( "unlock", {
		desc = "",
		help = "",
		rank = "owner",
		args = {""},
		dorun = function(t,ply)
			RunConsoleCommand( 'sv_password', '' )
			PrintA( chatP(ply), ' unlocked the server!' )
			return ''
		end
	})
	Arcker:AddCommand( "drop", {
		desc = "",
		help = "",
		rank = "owner",
		args = {"E"},
		dorun = function(t,ply)
			local tar = t.args[1]
			tar:SendLua( [[ RunConsoleCommand( 'disconnect' ) ]] )
			if IsValid( tar ) and tar then
				ply:Print( "Failed dropping ", chatP( tar ), "." )
			else
				ply:Print( "Dropped ", chatP( tar ), " from server!" )
			end
		end
	})
	Arcker:AddCommand( "votekick", {
		desc = "",
		help = "",
		rank = "user",
		args = {"ES"},
		typ = "*",
		dorun = function(t,ply)
			local minplayers = 4
			if #player.GetAll() - #player.GetBots() < minplayers then
				ply:Print( "Not enough players to create a vote. min: " .. minplayers .. "." )
				return
			end
			local tar = t.args[1]
			if tar:SteamID() == ply:SteamID() then return end
			local reason = t.args[2]
			if #reason < 4 then
				ply:Print( "The reason must be longer than 4 characters." )
				return
			end
			if #reason > 64 then
				ply:Print( "The reason must be smaller than 64 characters." )
				return
			end
			if getLvl( tar ) >= Arcker:Rank( 'admin' ) then
				ply:Print( 'You can\'t votekick admins.' )
				return
			end
			if Arcker.VoteDelay > ply:GetVar( 'VoteDelay' ) then
				if Arcker.VoteDelay >= CurTime() then 
					ply:Print( 'Please wait ', string.NiceTime( math.ceil( Arcker.VoteDelay-CurTime() ) ) ,' to create another vote.' )
					return 
				end
			else
				if ply:GetVar( 'VoteDelay' ) >= CurTime() then 
					ply:Print( 'Please wait ', string.NiceTime( math.ceil( ply:GetVar( 'VoteDelay' )-CurTime() ) ) ,' to create another vote.' )
					return 
				end
			end
			ply:SetVar( 'VoteDelay', CurTime() + 60 * 5 )
			if not Arcker.ActiveVote.active then
				Arcker:CreateVote( 'Kick ' .. tar:Nick() .. '?\nReason: ' .. reason, 35, { "Yes", "No" }, "No", 
					function(s)
						if s == "Yes" then
							PrintA( "Kicking ", tar:Nick(), "..." )
							tar:Kick( reason )
						else
							PrintA( "Player will not be kicked." )
						end
					end
				)
			end
		end
	})
end
Plugin.Unload = function( Arcker )
	Arcker:UnregisterCommand( 'setrank' )
	Arcker:UnregisterCommand( 'decals' )
	Arcker:UnregisterCommand( 'gibs' )
	Arcker:UnregisterCommand( 'kick' )
	Arcker:UnregisterCommand( 'ban' )
	Arcker:UnregisterCommand( 'l' )
	Arcker:UnregisterCommand( 'pw' )
	Arcker:UnregisterCommand( 'lock' )
	Arcker:UnregisterCommand( 'unlock' )
	Arcker:UnregisterCommand( 'votekick' )
end

return Plugin