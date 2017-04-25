if SERVER then
	util.AddNetworkString( 'manualchatcommand' )
	net.Receive( 'manualchatcommand', function( len, ply )
		local comma = net.ReadString( 'command' )
		hook.Run( 'PlayerSay', ply, comma, false)
	end )
	return nil
end
local commands = {
	['kick']	= { RankLvl( 'mod' ), false },
	['ban']		= { RankLvl( 'admin' ), false },
	['setrank']	= { RankLvl( 'owner' ), false },
	['slay']	= { RankLvl( 'mod' ), false },
	['revive']	= { RankLvl( 'helper' ), false },
	['goto']	= { RankLvl( 'helper' ), true },
	['bring']	= { RankLvl( 'mod' ), true },
}

function canUseCommandOn( ply, tar, c )
	if not commands[c] then return false end
	local plylvl = Ranks[ ply:Team() ].Level
	local tarlvl = Ranks[ tar:Team() ].Level
	if not commands[c][2] then
		if plylvl < tarlvl then return false end
	end
	return plylvl >= ( commands[c][1] or 20 )
end