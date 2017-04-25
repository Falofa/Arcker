local Plugin = {}
Plugin.Name 	= "Fun"
Plugin.Id		= "fun"
Plugin.Author 	= "Falofa"


Plugin.Load = function( Arcker )
	Arcker:AddCommand( "slay / kill", {
		desc = "",
		help = "",
		rank = "mod",
		args = {"E"},
		dorun = function(t,ply)
			local tar = t.args[1]
			if tar:Alive() then
				tar:Kill()
				if ply:EntIndex() == tar:EntIndex() then
					ply:Print( "You commit suicide." )
				else
					ply:Print( "Slaying ", chatP( tar ), "." )
					tar:Print( chatP( ply ), " slayed you!" )
				end
				return
			end
			ply:Print( chatP( tar ), " is already dead." )
		end
	})
	Arcker:AddCommand( "revive", {
		desc = "",
		help = "",
		rank = "helper",
		args = {"E", ""},
		dorun = function(t,ply)
			if t.typ == "E" and getLvl( ply ) < Arcker:Rank( 'admin' ) then
				ply:Print( "You can't do that!" )
				return
			end
			local tar = t.args[1] or ply
			if not tar:Alive() then
				local pos = tar:GetPos()
				local ang = tar:EyeAngles()
				tar:Spawn()
				tar:SetPos( pos )
				tar:SetEyeAngles( ang )
				if ply:EntIndex() == tar:EntIndex() then
					ply:Print( "You revive yourself." )
				else
					ply:Print( "Reviving ", chatP( tar ), "." )
					tar:Print( chatP( ply ), " revived you!" )
				end
				return
			end
			ply:Print( chatP( tar ), " is already alive." )
		end
	})
	local gotosound = Sound( 'buttons/button14.wav' )
	function sendPlayer( ply, tar, front )
		local pos = tar:GetPos()
		local ang = tar:EyeAngles()
		local tpang = ang:Forward()
		tpang['yaw'] = 0
		ply:SetPos_B( pos + tpang * ( front and 160 or -160 ) )
		ply:SetEyeAngles( front and (-ang:Forward()):Angle() or ang )
		timer.Simple( 0.25, function()
			if ply:OnGround() then return end
			ply:SetMoveType( MOVETYPE_NOCLIP )
		end )
	end
	Arcker:AddCommand( "goto", {
		desc = "",
		help = "",
		rank = "helper",
		args = {"E"},
		typ = "*",
		dorun = function(t,ply)
			sendPlayer( ply, t.args[1], false )
			ply:EmitSound( gotosound )
		end
	})
	Arcker:AddCommand( "bring", {
		desc = "",
		help = "",
		rank = "mod",
		args = {"E"},
		typ = "*",
		dorun = function(t,ply)
			sendPlayer( t.args[1], ply, true )
			ply:EmitSound( gotosound )
			
			t.args[1]:Print( chatP( ply ) ,' brought you.' )
		end
	})
	Arcker:AddCommand( "hbring", {
		desc = "",
		help = "",
		rank = "admin",
		args = {"E"},
		typ = "*",
		dorun = function(t,ply)
			sendPlayer( t.args[1], ply, true )
			return ''
		end
	})
	
	Arcker:AddCommand( "send", {
		desc = "",
		help = "",
		rank = "mod",
		args = {"EE"},
		typ = "*",
		dorun = function(t,ply)
			local tar1 = t.args[1]
			local tar2 = t.args[2]
			if tar1:SteamID() == tar2:SteamID() then return end
			if tar1:SteamID() == ply:SteamID() then
				ply:Print( "Use: /goto E" )
				return
			elseif tar2:SteamID() == ply:SteamID() then
				ply:Print( "Use: /bring E" )
				return
			end
			
			sendPlayer( tar1, tar2, true )
			tar1:EmitSound( gotosound )
			tar2:EmitSound( gotosound )
			
			tar1:Print( chatP( ply ), " sent you to ", chatP( tar2 ), "." )
			tar2:Print( chatP( ply ), " sent ", chatP( tar2 ), " to you." )
		end
	})
	Arcker:AddCommand( "hsend", {
		desc = "",
		help = "",
		rank = "mod",
		args = {"EE"},
		typ = "*",
		dorun = function(t,ply)
			if tar1:SteamID() == tar2:SteamID() then return end
			if tar1:SteamID() == ply:SteamID() then
				ply:Print( "Use: /goto E" )
				return
			elseif tar2:SteamID() == ply:SteamID() then
				ply:Print( "Use: /hbring E" )
				return
			end
			local tar1 = t.args[1]
			local tar2 = t.args[2]
			sendPlayer( tar1, tar2 )
			return ''
		end
	})
	Arcker:AddCommand( "back", {
		desc = "",
		help = "",
		rank = "helper",
		args = {""},
		dorun = function(t,ply)
			local pos = ply:GetVar( 'back' )
			if pos then
				ply:SetPos_B( pos['pos'] )
				ply:SetEyeAngles( pos['ang'] )
				ply:EmitSound( gotosound )
				ply:Print( 'Teleported back.' )
			else
				ply:Print( 'No place to get back to.' )
				return
			end
		end
	})
	Arcker:AddCommand( "snap", {
		desc = "",
		help = "",
		rank = "user",
		args = { "", "N", "NNN" },
		dorun = function(t,ply)
			if t.typ ~= "NNN" then
				local snap = t.args[1] or 15
			end
			local ent = ply:GetEyeTrace().Entity
			
			if not ( ent and IsValid( ent ) ) then
				ply:Print( 'No entity.' )
				return
			end
			
			local canTouch = false
			if FPP ~= nil then
				canTouch = FPP.plyCanTouchEnt( ply, ent, 'Physgun' )
			else
				canTouch = ent:GetOwner():SteamID() == ply:SteamID()
			end
			canTouch = canTouch or getLvl( ply ) > Arcker:Rank( 'admin' )
			
			if not canTouch then
				ply:Print( 'You can\'t touch this entity!' )
				return
			end
			
			local ang = ent:GetAngles()
			local snap_ang = ang:SnapTo( "p", snap or t.args[1] ):SnapTo( "y", snap or t.args[2] ):SnapTo( "r", snap or t.args[3] )
			ent:SetAngles( snap_ang )
			if t.typ == "NNN" then
				ply:Print( 'Entity angles snapped to ', t.args[1], ", ", t.args[2], ", ", t.args[3], ' degrees.' )
			else
				ply:Print( 'Entity angles snapped to ', snap, ' degrees.' )
			end
		end
	})
	Arcker:AddCommand( "last", {
		desc = "",
		help = "",
		rank = "user",
		args = { "" },
		dorun = function(t,ply)
			local last = ply:GetVar( 'last', false )
			if last then
				--ply:Print( 'Rerunning last command...' )
				hook.Run( 'PlayerSay', ply, last, false)
			else
				ply:Print( 'No last command!' )
			end
		end
	})
	Arcker:AddCommand( "bot", {
		desc = "",
		help = "",
		rank = "owner",
		args = { "", "N" },
		dorun = function(t,ply)
			local count = math.abs( math.Clamp( t.args[1] or 1, 1, 10 ) )
			for k=1, count do
				RunConsoleCommand( 'bot' )
			end
			ply:Print( 'Creating ' .. count .. ' bot(s).' )
		end
	})
	Arcker:AddCommand( "clearbots / kickbots", {
		desc = "",
		help = "",
		rank = "owner",
		args = { "" },
		dorun = function(t,ply)
			for k, v in ipairs( player.GetBots() ) do
				v:Kick()
			end
			ply:Print( "All bots kicked!" )
		end
	})
	Arcker:AddCommand( "noclip", {
		desc = "",
		help = "",
		rank = "mod",
		args = { "E" },
		dorun = function(t,ply)
			local tar = t.args[1]
			if tar:SteamID() == ply:SteamID() then
				ply:Print( 'You already have noclip.' )
			else
				local pl = not tar:GetVar( 'can-noclip', false )
				Arcker:UpdatePlyNoclip( tar )
				tar:SetVar( 'can-noclip', pl )
				if pl then
					ply:Print( 'You ',Color( 100, 255, 100 ),'enabled', rcol(),' noclip for ', chatP( tar ), '!' )
					tar:Print( chatP(ply), ' ',Color( 100, 255, 100 ),'enabled', rcol(),' noclip for you!' )
				else
					ply:Print( 'You ',Color( 255, 100, 100 ),'disabled', rcol(),' noclip for ', chatP( tar ), '!' )
					tar:Print( chatP(ply), ' ',Color( 255, 100, 100 ),'disabled', rcol(),' noclip for you!' )
				end
			end
		end
	})
	
	Arcker:AddCommand( "ammo", {
		desc = "",
		help = "",
		rank = "mod",
		args = {""},
		typ = "",
		dorun = function(t,ply)
			local wep = ply:GetActiveWeapon()
			local fir = wep:GetPrimaryAmmoType()
			local sec = wep:GetSecondaryAmmoType()
			ply:GiveAmmo( 1e5, fir, false )
			ply:GiveAmmo( 1e5, sec, false )
		end
	})
	
	Arcker:AddCommand( "retry", {
		desc = "",
		help = "",
		rank = "user",
		args = {"", "E"},
		typ = "",
		dorun = function(t,ply)
			local tar = t.args[1] or ply
			if tar:SteamID() == ply:SteamID() then
				tar:SendLua( [[ RunConsoleCommand( 'retry' ) ]] )
			else
				if getLvl( ply ) >= Arcker:Rank( "owner" ) then
					tar:SendLua( [[ RunConsoleCommand( 'retry' ) ]] )
				else
					ply:Print( "You can't run this command on ", chatP( tar ), "." )
				end
			end
		end
	})
end

Plugin.Unload = function( Arcker )
	Arcker:UnregisterCommand( 'slay' )
	Arcker:UnregisterCommand( 'revive' )
	Arcker:UnregisterCommand( 'goto' )
	Arcker:UnregisterCommand( 'bring' )
	Arcker:UnregisterCommand( 'hbring' )
	Arcker:UnregisterCommand( 'send' )
	Arcker:UnregisterCommand( 'hsend' )
	Arcker:UnregisterCommand( 'snap' )
	Arcker:UnregisterCommand( 'last' )
	Arcker:UnregisterCommand( 'bot' )
	Arcker:UnregisterCommand( 'clearbots' )
	Arcker:UnregisterCommand( 'noclip' )
	Arcker:UnregisterCommand( 'ammo' )
end

return Plugin