// Shared
// Sequence(6000)
Arcker.Perm = {}

local PermFile = Arcker.File( 'arcker/perms.dat' )
local Perms = PermFile:ReadTable()

function Arcker.Perm:Register( p )
	if type( p ) == 'table' then
		for k, v in ipairs( p ) do
			Perms[ v ] = 1
		end
	else
		Perms[ p ] = 1
	end
	PermFile:WriteTable( Perms )
end

function Arcker.Perm:GetAll() return Perms end

local function UniquePerms( t )
	local temp = {}
	local ret = {}
	for k, v in pairs( t ) do
		temp[v] = true
	end
	for k, v in pairs( temp ) do
		table.insert( ret, k )
	end
	return ret
end

function Arcker.Perm:HasPermission( ply, perm )
	pb = string.Split( perm, '.' ) // Permission break down
	local id = ply
	if IsEntity( ply ) and ply:IsPlayer() then
		id = Arcker:SimpleID( ply )
	end
	
	local gp = UniquePerms( table.concat( Arcker.PlayerRanks[ id ].perm, Arcker.GetRank( Arcker.PlayerRanks[ id ].name ) ) )
	// local gp = { 'player.kick', 'player.ban', chat.asay, 'foo.*' } // Sample
	
	for k, v in ipairs( gp ) do
		local tp = string.Split( v, '.' ) // Player Permission
		if v == perm then return true end // Exact permission, no need to check any further
		for i = 1, math.min( #tp, #pb ) do
			local ct = tp[i] // Current Player Permission
			local cp = pb[i] // Current Objective Permission
			
			if ct == '*' then return true end
			if ct ~= cp then break end
		end
	end
	return false
end