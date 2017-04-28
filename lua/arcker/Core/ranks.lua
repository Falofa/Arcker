// Shared
// Sequence(3000)

/*///
		Heres how it works:
	The server's Arcker.PlayerRanks contains ALL player ranks
	The client's only gets updated when they first spawn, this will give them the ranks of all online players
	and also when another player spawns, so they always have all the ranks.
	
/*///

Arcker.Ranks = {}
Arcker.PlayerRanks = {}

function Arcker.GetRank( s )
	s = string.lower(s)
	for k, v in ipairs( Arcker.Ranks ) do
		if v.name == s then 
			return v 
		end
	end
end

if SERVER then
	util.AddNetworkString( 'arcker set rank' )
	util.AddNetworkString( 'arcker set playerrank' )
	util.AddNetworkString( 'arcker update playerrank' )
	util.AddNetworkString( 'arcker clear playerrank' )
	
	Arcker.CSRanks = {}
	Arcker.RankFile = Arcker.File( 'Arcker/ranks.dat' )
	Arcker.PlayerRanksFile = Arcker.File( 'Arcker/player_ranks.dat' )
	Arcker.DefaultRank = Arcker.Config:Get( 'default_rank', 'user' )
	
	local ModelPlayerRank = {
		name = '',
		id = '',
		rank = Arcker.DefaultRank,
		perm = {}
	}
	

	local DefaultRanks = {
		{
			name = 'user',
			display = 'User',
			color = Color( 244, 238, 66 ), // Yellow
			tag = {'[User]'},
			perm = {},
			inherits = ''
		},
		{
			name = 'mod',
			display = 'Moderator',
			color = Color( 3, 209, 55 ), // Green
			tag = {'[Mod]'},
			perm = {},
			inherits = 'user'
		},
		{
			name = 'operator',
			display = 'Operator',
			color = Color( 3, 209, 55 ), // Green
			tag = {'[Operator]'},
			perm = {},
			inherits = 'mod'
		},
		{
			name = 'admin',
			display = 'Admin',
			color = Color( 3, 209, 55 ), // Green
			tag = {'[Admin]'},
			perm = {},
			inherits = 'operator'
		},
		{
			name = 'superadmin',
			display = 'Super Admin',
			color = Color( 4, 82, 209 ), // Blue
			tag = {'[SUPERADMIN]'},
			perm = {},
			inherits = 'admin'
		},
		{
			name = 'owner',
			display = 'Owner',
			color = Color( 209, 2, 2 ), // Yellow
			tag = {'[OWNER]'},
			perm = {'*'},
			inherits = 'superamin'
		},
	}
	
	// 	RANK FUNCTIONS
	
	function Arcker:LoadRanks( ) 
		self.PlayerRanks = self.PlayerRanksFile:ReadTable( ) 
		self.Ranks = self.RankFile:ReadTable( ) 
	end
	
	function Arcker:SaveRanks( ) 
		self.PlayerRanksFile:WriteTable( self.PlayerRanks ) 
		self.RankFile:WriteTable( self.Ranks ) 
	end
	
	function Arcker:RankUpdate( ply, data )
		local id = self:SimpleID( ply )
		local mod = self.Ranks[ id ] 
		
		for k, v in pairs( data ) do
			mod[ k ] = v
		end
		
		self.Ranks[ id ] = mod
		self.CSRanks[ id ] = mod
		
		self:SaveRanks( ) // Always has most updated version on file
	end
	
	function Arcker:CheckRank( ply )
		//if 
		local id = Arcker:SimpleID( ply )
		if self.Ranks[ id ] then return end
		local Rank = ModelPlayerRank
		Rank['name'] = ply:GetName()
		Rank['id'] = id
		self.Ranks[ id ] = Rank
	end
	
	function Arcker:UpdateCSRanks( )
		self.CSRanks = {}
		for k, v in ipairs( player.GetAll( ) ) do
			local id = self:SimpleID( v )
			self.CSRanks[ id ] = self.Ranks[ id ]
		end
	end
	
	function Arcker:BroadcastRanks( )
		net.Start( 'arcker set playerrank' )
		net.WriteTable( self.CSRanks )
		net.Broadcast( )
	end
	
	// RANK HOOKS
	
	hook.Add( 'PlayerInitialSpawn', '', function( ply )
		local id = Arcker:SimpleID( ply )
		Arcker.CSRanks[ id ] = Arcker.PlayerRanks[ id ]
		
		local plys = player.GetAll( )
		table.RemoveByValue( plys, ply )
		
		net.Start( 'arcker set playerrank' )
		net.WriteTable( Arcker.CSRanks )
		net.Send( ply )
		
		net.Start( 'arcker update playerrank' )
		net.WriteTable( Arcker.PlayerRanks[ id ] )
		net.Send( plys )
	end )
	
	hook.Add( 'PlayerDisconnected', function( ply )
		net.Start( 'arcker clear rank' )
		net.Write( Arcker:SimpleID( ply ) )
		net.Broadcast( )
	end )
	
	hook.Add( 'Initialize', 'arcker init ranks', function( ) Arcker:LoadRanks( ) end  )
	
	Arcker:LoadRanks( )
	Arcker:UpdateCSRanks( )
end

if CLIENT then
	net.Receive( 'arcker set rank', function( )
		Arcker.Ranks = net.ReadTable()
	end )

	net.Receive( 'arcker set playerrank', function( )
		Arcker.PlayerRanks = net.ReadTable( )
	end )
	net.Receive( 'arcker update playerrank', function( )
		local ply = player.GetAll( )[ net.ReadInt( 16 ) ]
		local t = net.ReadTable( )
		Arcker.PlayerRanks[ Arcker:SimpleID( ply ) ] = t
	end )
	net.Receive( 'arcker clear playerrank', function( )
		Arcker.PlayerRanks[ net.ReadString( ) ] = nil
	end )
end