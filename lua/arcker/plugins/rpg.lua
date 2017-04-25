local Plugin = {}
Plugin.Name 	= "Rpg"
Plugin.Id		= "rpg"
Plugin.Author 	= "Falofa"


Plugin.Load = function( Arcker )
	Arcker:AddCommand( "rpg", {
		desc = "",
		help = "",
		rank = "admin",
		args = {""},
		dorun = function(t,ply)
			ply:Print( "It's RPG time!" )
			local tar = t.args[1]
			ply:Give( 'weapon_rpg' )
			ply:SelectWeapon( 'weapon_rpg' )
			timer.Create( Arcker:Pname( 'rpg', tar ), 0.3, 10, function()
				local rpg = ents.Create( 'rpg_missile' )
				rpg:SetPos( ply:GetShootPos() + ply:EyeAngles():Forward() * 60 )
				rpg:SetAngles( ply:EyeAngles() )
				rpg:Spawn()
				rpg:SetOwner( ply )
			end )
		end
	})
end
Plugin.Unload = function( Arcker )
	Arcker:UnregisterCommand( 'rpg' )
end

return Plugin