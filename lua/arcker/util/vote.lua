Arcker:AddEvent( 'OnEndLoad', function()
	Arcker.ActiveVote = Arcker.ActiveVote or { active = false }
	Arcker.VoteDelay = 0
	hook.Add( 'PlayerSpawn', Arcker:UniqueName( 'Vote', 'Spawn' ), function( ply )
		if ply:GetVar( 'VoteDelay' ) == nil then
			ply:SetVar( 'VoteDelay', CurTime() )
		end
	end )

	util.AddNetworkString( 'votecreate' )
	util.AddNetworkString( 'voteclose' )
	util.AddNetworkString( 'myvoteoption' )



	function Arcker:CreateVote( s, time, options, preferred, callback )
		if not Arcker.ActiveVote.active then
			Arcker.VoteDelay = CurTime() + time + 60
			net.Start( 'votecreate' )
			 net.WriteString( s )
			 net.WriteDouble( time )
			 net.WriteTable( options )
			net.Broadcast()
			Arcker.ActiveVote = {
				Func		= callback,
				Preffered	= preferred,
				Votes 		= {},
				VoteCount 	= {},
				All 		= 0,
				active 		= true,
				text 		= s,
				time 		= time,
				opti 		= options
			}
			for k, v in ipairs( options ) do
				Arcker.ActiveVote.VoteCount[ v ] = 0
			end
			timer.Create( self:UniqueName( "vote", s ), time, 1, function()
				Arcker:CloseVote( false )
			end	)
			return true
		else
			return false
		end
	end

	function Arcker:CloseVote( early )
		if Arcker.ActiveVote.active then
			Arcker.ActiveVote.active = false
			net.Start( 'voteclose' )
			net.Broadcast()
			
			local cnt = Arcker.ActiveVote.All
			local won = { n = 'nil', c = 0 }
			local first = true
			local End = false
			for k, v in SortedPairsByValue( Arcker.ActiveVote.VoteCount, true ) do
				if not End then
					if first then
						won = { n = k, c = v }
						first = false
					else
						if v == won.c then
							if k == Arcker.ActiveVote.Preffered then
								won = { n = k, c = v }
								End = true
							end
						else
							End = true
						end
					end
				end
			end
			if cnt ~= 0 then
				PrintA( "Vote ended, results:" )
				for k, v in pairs( Arcker.ActiveVote.VoteCount ) do
					if v ~= 0 then
						PrintA( ' ' .. k .. ' - ' .. math.abs( ( v / cnt ) * 100 ) .. "%" )
					end
				end
			else
				PrintA( "Vote ended, no votes." )
			end
			local _temp = Arcker.ActiveVote.VoteCount
			local __temp = Arcker.ActiveVote.Votes
			Arcker.ActiveVote.Func( won.n, _temp, __temp )
			
			return true
		else
			return false
		end
	end

	local function updateVoteCount()
		local countp = #player.GetAll() - #player.GetBots()
		if Arcker.ActiveVote.All >= countp then
			timer.Remove( Arcker:UniqueName( "vote", s ) )
			Arcker:CloseVote( true )
		end
	end
	net.Receive( 'myvoteoption', function( len, ply )
		local s = net.ReadString( )
		if not Arcker.ActiveVote.Votes[ ply:SteamID() ] then
			Arcker.ActiveVote.VoteCount[ s ] = Arcker.ActiveVote.VoteCount[ s ] + 1
			Arcker.ActiveVote.All = Arcker.ActiveVote.All + 1
			updateVoteCount()
		end
		Arcker.ActiveVote.Votes[ ply:SteamID() ] = s
	end )
end)