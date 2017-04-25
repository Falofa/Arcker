if SERVER then
	Arcker.Ranks = {}
	function Arcker:Rank( s )
		local str = string.lower( s )
		for k, v in pairs( Arcker.Ranks ) do
			if v.Id == s then
				return v.Level
			end
		end
		return 0
	end
end
if CLIENT then
	Ranks = {}
	function RankLvl( s )
		local str = string.lower( s )
		for k, v in pairs( Ranks ) do
			if v.Id == s then
				return v.Level
			end
		end
		return 0
	end
end
local Rid = 1


function AddRank( t )
    /*
		
		Id
		Name
		Color
		Tag ( Prefix )
		Tree ( Hierarchy i.e. 'User' )
	
	*/
	
	local id 	= t.id
	local pname = t.pname
	local color = t.color
	local tag 	= t.tag
	local lvl 	= t.lvl
	local group = t.group
	
	if SERVER then
		Arcker.Ranks[Rid] = {
			Rid 	= Rid,
			Id 		= id,
			Name 	= pname,
			Color 	= color,
			Group 	= group,
			Tag 	= tag,
			Level 	= lvl
		}
	end
	if CLIENT then
		Ranks[Rid] = {
			Rid 	= Rid,
			Id 		= id,
			Name 	= pname,
			Color 	= color,
			Group 	= group,
			Tag 	= tag,
			Level 	= lvl
		}
	end
	Rid = Rid + 1
end

AddRank({
	id 		= "spectator",
	pname 	= "Spectator",
	group 	= "user",
	color 	= Color( 52, 73, 94 ),
	tag 	= nil,
	lvl		= 0
})
AddRank({
	id 		= "user",
	pname 	= "User",
	group 	= "user",
	color 	= Color( 255, 255, 51 ),
	tag 	= nil,
	lvl		= 1
})
AddRank({
	id 		= "helper",
	pname 	= "Helper",
	group 	= "user",
	color 	= Color( 241, 196, 15 ),
	tag 	= nil,
	lvl		= 2
})
AddRank({
	id 		= "mod",
	pname 	= "Moderator",
	group 	= "user",
	color 	= Color( 46, 204, 113 ),
	tag 	= { Color( 39 , 174, 96 ), "[ Mod ]" },
	tag 	= nil,
	lvl		= 20
})
AddRank({
	id 		= "admin",
	pname 	= "Admin",
	group 	= "admin",
	color 	= Color( 52, 152, 215 ),
	tag 	= { Color( 41, 128, 185 ), "[ Admin ]" },
	lvl		= 75
})
AddRank({
	id 		= "owner",
	pname 	= "Owner",
	group 	= "superadmin",
	color 	= Color( 231, 76, 60 ),
	tag 	= { Color( 192, 57, 43 ), "[ Owner ]" },
	lvl		= 100
})


function LoadRanks()
	if SERVER then
		for _, v in pairs( Arcker.Ranks ) do
			team.SetUp( _, v.Name, v.Color, true )
		end
	else
		for _, v in pairs( Ranks ) do
			team.SetUp( _, v.Name, v.Color, true )
		end
	end
end

if SERVER then
	local getRank_f = function( id )
		if not file.Exists( "arcker/ranks.dat", "DATA" ) then file.Write( "arcker/ranks.dat", "" ) end
		local DATA = file.Read( "arcker/ranks.dat", "DATA" )
		for k, v in ipairs( string.Split( DATA, "\n" ) ) do
			local sid, rnk = unpack( string.Split( v, "\t" ) )
			if sid and rnk then
				if sid == id then
					return rnk
				end
			end
		end
	end
	local setRank_f = function( ply, rank )
		if not file.Exists( "arcker/ranks.dat", "DATA" ) then file.Write( "arcker/ranks.dat", "" ) end
		local DATA = file.Read( "arcker/ranks.dat", "DATA" )
		local data = {}
		for k, v in ipairs( string.Split( DATA, "\n" ) ) do
			local sid, rnk, nam = unpack( string.Split( v, "\t" ) )
			if sid and rnk then
				data[sid] = { lvl = Arcker:Rank(rnk), rank = rnk, name = nam or "" }
			end
		end
		if not rank then
			data[ply:SteamID()] = nil
		else
			data[ply:SteamID()] = { lvl = Arcker:Rank(rank), rank = rank, name = string.Replace( ply:Nick(), "\t", "" ) }
		end
		
		local dat = ""
		for k, v in SortedPairsByMemberValue( data, 'lvl', true ) do
			dat = dat .. k .. "\t" .. v['rank'] .. "\t" .. v['name'] .. "\n"
		end
		file.Write( "arcker/ranks.dat", dat )
	end
	Arcker.DefRank = "user"
	local PLAYER = FindMetaTable( 'Player' )
	function PLAYER:Rank()
		if not self then return end
		local rank = Arcker.Ranks[self:Team()]
		return rank.Id, rank.Level
	end
	function PLAYER:SetPos_B( vec )
		if not self then return end
		if not vec then return end
		local pos = self:GetPos()
		local ang = self:EyeAngles()
		self:SetVar( 'back', { pos = pos, ang = ang } )
		self:SetPos( vec )
	end
	function PLAYER:SetRank( id )
		for _, v in pairs( Arcker.Ranks ) do
			if id == v.Id then
				self:SetTeam( v.Rid )
				self:SetUserGroup( v.Group )
				if v.Id ~= Arcker.DefRank then
					setRank_f( self, v.Id )
				else
					setRank_f( self, nil )
				end
			end
		end
	end
	local function updateRank( ply )
		local val = getRank_f( ply:SteamID() )
		if val then
			ply:SetRank( val )
		else
			ply:SetRank( Arcker.DefRank )
		end
	end
	hook.Add("PlayerSpawn",Arcker:Pname( 'rankupdate' ),function( ply )
		if ply:GetVar( 'forceupdaterank', true ) then
			updateRank( ply )
			ply:SetVar( 'forceupdaterank', false )
		end
	end)
end
LoadRanks()
