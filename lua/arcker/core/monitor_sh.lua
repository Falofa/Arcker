Arcker.Monitor = Arcker.Monitor or {}
if SERVER then
	util.AddNetworkString('dohint')
	local PLAYER = FindMetaTable('Player')
	function PLAYER:Hint( s, t, tim )
		net.Start( 'dohint' )
		 net.WriteString( s )
		 net.WriteString( tostring( t ) )
		 net.WriteString( tostring( tim  ) )
		net.Send( self )
		return true
	end
end
if CLIENT then
	net.Receive( 'dohint', function( len )
		local str = net.ReadString( )
		local typ = tonumber( net.ReadString( ) ) or NOTIFY_HINT
		local tim = tonumber( net.ReadString( ) ) or 5
		snd = {
			[ NOTIFY_HINT ]		= 'buttons/button14.wav',
			[ NOTIFY_ERROR ]	= 'buttons/button10.wav',
		}
		if str and typ and tim then
			notification.AddLegacy( str, typ, tim )
			if snd[ typ ] then
				surface.PlaySound(snd[ typ ])
			end
		else
			error( 'Internal net error.' )
		end
	end )
	hook.Add( 'PlayerNoClip', 'arcker.cs.noclip', function( ply, des )
		return ply:GetNWBool( 'can-noclip' ) or false
	end)
	Arcker.Monitor.HintDelay = CurTime()
	Arcker.Monitor.HintedM1 = false
	Arcker.Monitor.HintedM2 = false
	function Arcker.Monitor:Hint( )
		if CurTime() > self.HintDelay then
			self.HintDelay = CurTime() + 5
			notification.AddLegacy( "You can't use that weapon on spawn!", NOTIFY_ERROR, 5 )
			surface.PlaySound( "buttons/button10.wav" )
		end
	end
	local function inrange(val, min, max)
		return val <= max and val >= min
	end
	local function onSpawn(pos)
		if not pos then return false end
		local max = Arcker:GetSpawn().Max
		local min = Arcker:GetSpawn().Min
		return (inrange( pos.x, min.x, max.x ) and inrange( pos.y, min.y, max.y ) and inrange( pos.z, min.z, max.z ))
	end
	function MonitorCommands( ply, cmd )
		local weps = {
			['weapon_physgun']	= true,
			['gmod_camera']		= true,
			['gmod_tool']		= true,
		}
		if onSpawn( ply:GetPos() ) then
			if not ply then return false end
			if not ply:GetActiveWeapon() then return false end
			if not IsValid( ply:GetActiveWeapon() ) then return false end
			if bit.band( cmd:GetButtons(), IN_ATTACK ) == IN_ATTACK then
				if not weps[ ply:GetActiveWeapon():GetClass() ] then
					if ply:IsAdmin() or ply:IsSuperAdmin() then
						return true
					else
						cmd:SetButtons( cmd:GetButtons() - IN_ATTACK )
						if not Arcker.Monitor.HintedM1 then
							Arcker.Monitor:Hint( )
						end
						Arcker.Monitor.HintedM1 = true
					end
				end
			else
				Arcker.Monitor.HintedM1 = false
			end
			if bit.band( cmd:GetButtons(), IN_ATTACK2 ) == IN_ATTACK2 then
				if not weps[ ply:GetActiveWeapon():GetClass() ] then
					if ply:IsAdmin() or ply:IsSuperAdmin() then
						return true
					else
						cmd:SetButtons( cmd:GetButtons() - IN_ATTACK2 )
						if not Arcker.Monitor.HintedM2 then
							Arcker.Monitor:Hint( )
						end
						Arcker.Monitor.HintedM2 = true
					end
				end
			else
				Arcker.Monitor.HintedM2 = false
			end
		end
	end
	hook.Add( 'StartCommand', Arcker:Pname( 'monitor' ), MonitorCommands )
end