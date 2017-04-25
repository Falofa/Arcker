local Plugin = {}
Plugin.Name 	= "Protection"
Plugin.Id		= "protection"
Plugin.Author 	= "Falofa"


Plugin.Load = function( Arcker )
	local function inrange(val, min, max)
		return val <= max and val >= min
	end
	local function onSpawn(pos)
		if not pos then return false end
		local max = Arcker:GetSpawn().Max
		local min = Arcker:GetSpawn().Min
		return (inrange( pos.x, min.x, max.x ) and inrange( pos.y, min.y, max.y ) and inrange( pos.z, min.z, max.z ))
	end
	hook.Add( 'PlayerShouldTakeDamage', Arcker:Pname( 'damage' ), function( ply, tar )
		local pl = IsValid( ply )
		local pt = IsValid( ply ) and IsValid( tar )
		if pt then
			if ply:SteamID() == tar:SteamID() then return true end
			if tar:GetVar( 'plymode' ) == "abuse" then return true end
		end
		if pl then
			if ply:GetVar( 'force-take-dmg', false ) then return true end
			if onSpawn( ply:GetPos() ) then return false end
			if ply:GetVar( 'plymode' ) == "abuse" then return false end
			if ply:GetVar( 'plymode' ) == "build" then return false end
		end
		if pt then
			if tar:GetVar( 'force-deal-dmg', false ) then return true end
			if onSpawn( tar:GetPos() ) then return false end
			if tar:GetVar( 'plymode' ) == "build"  then return false end
		end
	end )
	local ThrowVel	= {}
	local Holding	= {}
	local PickPlayers = {}
	local br = {}
	for _,i in ipairs( { "", "1", "3" } ) do
		table.insert( br, Sound( 'player/pl_fallpain' .. i .. '.wav' ) )
	end
	hook.Add( 'Think', Arcker:Pname( 'playerpickupthink' ), function()
		local ToRe = {}
		for k, v in pairs( PickPlayers ) do
			if v then
				if not v then 
					table.insert( ToRe, k ) 
				else
					v:SetVelocity( v:GetVelocity() * -0.9 )
					local vl = ThrowVel[ v:EntIndex() ] or Vector( 0, 0, 0 )
					local len = ( vl * Vector( 0, 0, 1 ) ):Length()
					if len > 140 and vl.z < 0 then
						if v:OnGround() then
							local dmg = ( len - 140 ) / 4 + 10
							v:TakeDamage( dmg, Holding[ v:EntIndex() ] )
							ThrowVel[ v:EntIndex() ] = Vector( vl.x, vl.y, 0 )
							v:EmitSound( br[ math.random( #br ) ], 75, 100 - ( 30 - ( math.min( dmg, 60 ) ) ) )
						end
					end
				end
			end
		end
		for k, v in ipairs( ToRe ) do
			PickPlayers[v] = nil
		end
	end )
	hook.Add( 'PhysgunPickup', Arcker:Pname( 'playerpickup' ), function( ply, tar )
		if IsValid( ply ) and IsValid( tar ) then
			if ply:IsPlayer() and tar:IsPlayer() then
				if getLvl( ply ) > Arcker:Rank( 'admin' ) and getLvl( ply ) >= getLvl( tar ) then
					PickPlayers[ tar:EntIndex() ] = tar
					tar:SetMoveType( MOVETYPE_NONE )
					local last = tar:GetPos()
					timer.Create( "Pick"..ply:EntIndex().."-"..tar:EntIndex(), 0.05, 0, function()
						if not ThrowVel[ tar:EntIndex() ] then ThrowVel[ tar:EntIndex() ] = Vector( 0, 0, 0) end
						Holding[ tar:EntIndex() ] = ply
						ThrowVel[ tar:EntIndex() ] = ThrowVel[ tar:EntIndex() ] * 0.4 + ( tar:GetPos() - last )
						last = tar:GetPos()
					end )
					return true
				end
			end
		end
	end )
	hook.Add( 'PlayerButtonDown', Arcker:Pname( 'physgundown' ), function( ply, key )
		if key == MOUSE_RIGHT then
			ply:SetVar( 'MOUSE_RIGHT', true )
		end
	end)
	hook.Add( 'PlayerButtonUp', Arcker:Pname( 'physgunup' ), function( ply, key )
		if key == MOUSE_RIGHT then
			ply:SetVar( 'MOUSE_RIGHT', false )
		end
	end)
	hook.Add( 'PhysgunDrop', Arcker:Pname( 'playerdrop' ), function( ply, tar )
		if IsValid( ply ) and IsValid( tar ) then
			if ply:IsPlayer() and tar:IsPlayer() then
				if not ThrowVel[ tar:EntIndex() ] then ThrowVel[ tar:EntIndex() ] = Vector( 0, 0, 0 ) end
				PickPlayers[ tar:EntIndex() ] = false
				timer.Remove( "Pick"..ply:EntIndex().."-"..tar:EntIndex() )
				if ply:GetVar( 'MOUSE_RIGHT', false ) then
					tar:SetMoveType( MOVETYPE_NOCLIP )
				else
					tar:SetMoveType( MOVETYPE_WALK )
					tar:SetVelocity( ThrowVel[ tar:EntIndex() ] * 2 )
				end
				ThrowVel[ tar:EntIndex() ] = Vector( 0, 0, 0 )
				Holding[ tar:EntIndex() ] = nil
			end
		end
	end )
	function plyCanNoclip( ply, des )
		if ply:GetVar( 'can-noclip', false ) then return true end
		if des == false then return true end
		if getLvl( ply ) >= Arcker:Rank( 'helper' ) then return true end
		return false
	end
	local lastps = {}
	local tmrdel = {}
	hook.Add( 'Think', Arcker:Pname( 'noclipstop' ), function()
		for k, ply in ipairs( player.GetHumans( ) ) do
			if ply:GetNWBool( 'can-noclip' ) ~= plyCanNoclip( ply, true ) then
				ply:SetNWBool( 'can-noclip', plyCanNoclip( ply, true ) )
				if not onSpawn( ply:GetPos( ) ) then
					ply:SetMoveType( MOVETYPE_WALK )
				end
			end
			if ( not plyCanNoclip( ply, true ) ) and ply:GetMoveType() == MOVETYPE_NOCLIP then
				if not onSpawn( ply:GetPos( ) ) then
					ply:SetPos( ( ply:GetPos( ) - lastps[ ply ] ) * -1.1 + ply:GetPos( ) )
					if tmrdel[ ply ] < CurTime() then
						ply:Hint( "you can't exit spawn while nocliping!", NOTIFY_ERROR )
						tmrdel[ ply ] = CurTime( ) + 10
					end
				end
			end
			lastps[ ply ] = ply:GetPos( )
			if not tmrdel[ ply ] then
				tmrdel[ ply ] = CurTime( )
			end
		end
	end )
	hook.Add( 'PlayerNoClip', Arcker:Pname( 'noclip' ), function( ply, des )
		if onSpawn( ply:GetPos() ) then
			return true
		end
		return plyCanNoclip( ply, des )
	end)
	function Arcker:UpdatePlyNoclip( ply )
		local canNoclip = hook.Run( 'PlayerNoClip', ply, true )
		if not canNoclip then
			ply:SetMoveType( MOVETYPE_WALK )
		end
	end
	local BuildColor = Color( 200, 255, 200 )
	local FightColor = Color( 255, 200, 200 )
	local AbuseColor = Color( 200, 255, 255 )
	Arcker:AddCommand( "build", {
		desc = "",
		help = "",
		rank = "guest",
		args = {""},
		dorun = function(t,ply)
			if not ply:GetVar( 'plymode' ) then ply:SetVar( 'plymode', 'fight' ) end
			if ply:GetVar( 'plymode' ) == "build" then
				ply:Print( 'You are already in ', BuildColor, 'build', rcol(), ' mode.' )
				return
			end
			if ply:GetVar( 'modedelay' ) then
				if ply:GetVar( 'modedelay' ) > CurTime() then
					ply:Print( 'Please wait until you change your mode again.' )
					return
				end
			end
			ply:SetVar( 'plymode', "build" )
			ply:SetVar( 'modedelay', CurTime() + 30 )
			PrintA( chatP( ply ), ' is now in ', BuildColor, 'build', rcol(), ' mode!' )
			PrintA( 'Type ', BuildColor, '/build', rcol(), ' to join too!' )
			return ''
		end
	})
	Arcker:AddCommand( "fight", {
		desc = "",
		help = "",
		rank = "guest",
		args = {""},
		dorun = function(t,ply)
			if not ply:GetVar( 'plymode' ) then ply:SetVar( 'plymode', 'fight' ) end
			if not ply:GetVar( 'plymode' ) == "fight" then
				ply:Print( 'You are already in ', FightColor, 'fight', rcol(), ' mode.' )
				return
			end
			if ply:GetVar( 'modedelay' ) then
				if ply:GetVar( 'modedelay' ) > CurTime() then
					ply:Print( 'Please wait until you change your mode again.' )
					return
				end
			end
			ply:SetVar( 'plymode', "fight" )
			ply:SetVar( 'modedelay', CurTime() + 30 )
			PrintA( chatP( ply ), ' is now in ', FightColor, 'fight', rcol(), ' mode!' )
			PrintA( 'Type ', FightColor, '/fight', rcol(), ' to join too!' )
			return ''
		end
	})
	Arcker:AddCommand( "abuse", {
		desc = "",
		help = "",
		rank = "owner",
		args = {""},
		dorun = function(t,ply)
			if not ply:GetVar( 'plymode' ) then ply:SetVar( 'plymode', 'fight' ) end
			if not ply:GetVar( 'plymode' ) == "abuse" then
				ply:Print( 'You are already in ', AbuseColor, 'abuse', rcol(), ' mode.' )
				return
			end
			if ply:GetVar( 'modedelay' ) then
				if ply:GetVar( 'modedelay' ) > CurTime() then
					ply:Print( 'Please wait until you change your mode again.' )
					return
				end
			end
			ply:SetVar( 'plymode', "abuse" )
			ply:SetVar( 'modedelay', CurTime() + 30 )
			PrintA( chatP( ply ), ' is now in ', AbuseColor, 'abuse', rcol(), ' mode!' )
			return ''
		end
	})
	Arcker:AddCommand( "god / ungod", {
		desc = "",
		help = "",
		rank = "mod",
		args = { "", "E" },
		dorun = function( t, ply )
			print( name )
			local obj = name == 'god' or false
			local tar = t.args[1] or ply
			local slf = t.typ == ""
			
			if obj then
				if not slf then
					ply:Print( 'God enabled for ', chatP( tar ), '.' )
					tar:Print( chatP( ply ) ,' enabled god for you.' )
				else
					ply:Print( 'You enabled god for yourself.' )
				end
				tar:GodEnable()
			else
				if not slf then
					ply:Print( 'God disabled for ', chatP( tar ), '.' )
					tar:Print( chatP( ply ) ,' disabled god for you.' )
				else
					ply:Print( 'You disabled god for yourself.' )
				end
				tar:GodDisable()
			end
		end
	})
	hook.Add( 'PlayerCanPickupItem', Arcker:Pname( 'adminpickup' ), function( ply, ent )
		if getLvl( ply ) >= Arcker:Rank( 'mod' ) then
			return true
		end
	end )
end
Plugin.Unload = function( Arcker )
	hook.Remove( 'PlayerShouldTakeDamage', 	Arcker:Pname( 'damage' ) )
	hook.Remove( 'PhysgunPickup', 			Arcker:Pname( 'playerpickup' ) )
	hook.Remove( 'Think', 					Arcker:Pname( 'playerpickupthink' ) )
	hook.Remove( 'PlayerButtonDown', 		Arcker:Pname( 'physgundown' ) )
	hook.Remove( 'PlayerButtonUp', 			Arcker:Pname( 'physgunup' ) )
	hook.Remove( 'PhysgunDrop', 			Arcker:Pname( 'playerdrop' ) )
	hook.Remove( 'PlayerNoClip', 			Arcker:Pname( 'noclip' ) )
	hook.Remove( 'PlayerCanPickupItem', 	Arcker:Pname( 'adminpickup' ) )
	
	Arcker.UpdatePlyNoclip = function() end
	Arcker:UnregisterCommand( 'build' )
	Arcker:UnregisterCommand( 'fight' )
	Arcker:UnregisterCommand( 'abuse' )
end

return Plugin