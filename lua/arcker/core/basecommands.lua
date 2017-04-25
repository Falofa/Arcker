function Arcker:LoadBaseCommands()
	Arcker:AddCommand( "plugin", {
		desc = "",
		help = "",
		rank = "owner",
		args = {"SS","S"},
		dorun = function(t,ply)
			local actions = { 
				["enable"]	= "SS", 
				["disable"]	= "SS", 
				["reload"]	= "SS",
				["list"]	= "S",
				["update"]	= "S",
			}
			local action = string.lower( t.args[1] )
			if actions[ action ] ~= t.typ then
				if actions[ action ] ~= nil then
					ply:Print( "Wrong arguments for action." )
					return
				end
				ply:Print( "No such action." )
				return
			end
			if not actions[ action ] then
				ply:Print( "No such action." )
				return
			end
			
			if t.typ == "S" then
				if action == "list" then
					ply:Print( Color( 255, 100, 100 ), "Plugin listing: " )
					--ply:Print( Color( 100, 255, 100 ), "[id] | [enabled]" )
					for k, v in ipairs( Arcker.Plugins ) do
						ply:Print( Color( 100, 255, 100 ), v.Id .. " > " ..
							(Arcker:CheckPlugin( v ) and "Enabled" or "Disabled") )
					end
				end
				if action == "update" then
					ply:Print( Color( 100, 255, 100 ), "Updating all!" )
					self:LoadPlugins()
				end
			end
			
			local obj = nil
			if t.typ == "SS" then
				local arg = string.lower( t.args[2] )
				for k, v in pairs( self.Plugins ) do
					local nm = string.lower( v.Name )
					local id = string.lower( v.Id )
					if string.len( arg ) > 1 then
						if string.find( nm , arg, 1, true ) ~= nil or
						   string.find( id , arg, 1, true ) ~= nil then
							obj = v
						end
					end
				end
			end
			if obj then
				if action == "reload" then
					ply:Print( "Requesting a plugin reload. id: " .. obj.Id )
					local m = Arcker:PluginLoad( obj._info.Folder, true, false, 
						"Plugin reload request by: '" .. ply:Nick() .. "'." )
					ply:Print( "Received message: '", m, "'." )
					Arcker:Log( "[PLUGIN] ", plytolog(ply) , " reloaded '", obj.Id, "'" )
				end
				local PluginColor = Color( 255,255,255 )
				local PluginIdColor = Color( 255,255,100 )
				local EnableColor = Color( 100, 255, 100 )
				local DisableColor = Color( 255, 100, 100 )
				if action == "disable" then
					if not Arcker:CheckPlugin( obj ) then
						ply:Print( "Already ",DisableColor,"disabled",rcol(),": ", PluginColor, obj.Name, rcol(), " [", PluginIdColor, obj.Id, rcol(), "]" )
						return
					end
					Arcker:PluginEnable( obj, false )
					pcall( obj.Unload, Arcker )
					print( "Plugin disabling called by: " .. ply:Nick() .. ". id: " .. obj.Id .. "." )
					ply:Print( "Plugin ",DisableColor,"disabled",rcol(),": ", PluginColor, obj.Name, rcol(), " [", PluginIdColor, obj.Id, rcol(), "]" )
					Arcker:Log( "[PLUGIN] ", plytolog(ply) , " disabled '", obj.Id, "'" )
				end
				if action == "enable" then
					if Arcker:CheckPlugin( obj ) then
						ply:Print( "Already ",EnableColor,"enabled",rcol(),": ", PluginColor, obj.Name, rcol(), " [", PluginIdColor, obj.Id, rcol(), "]" )
						return
					end
					Arcker:PluginEnable( obj, true )
					local m = Arcker:PluginLoad( obj._info.Folder, true, false, 
						"Plugin enabling request by: '" .. ply:Nick() .. "'." )
					ply:Print( "Plugin ",EnableColor,"enabled",rcol(),": ", PluginColor, obj.Name, rcol(), " [", PluginIdColor, obj.Id, rcol(), "]" )
					Arcker:Log( "[PLUGIN] ", plytolog(ply), " enabled '", obj.Id, "'" )
				end
			elseif t.typ == "SS" then
				ply:Print( "No such plugin." )
			end
		end
	})
	function findCommand( args )
		local obj = nil
		for k, v in ipairs( Arcker.Commands ) do
			local names = string.Split( string.Replace( v.name, ' ', '' ), '/' )
			for __, name in ipairs( names ) do
				if name == args then
					obj = v
				end
			end
		end
		return obj
	end
	
	Arcker:AddCommand( "debug", {
		desc = "",
		help = "",
		rank = "owner",
		args = { "SS" },
		dorun = function(t,ply)
			local base = string.lower( t.args[1] )
			local args = string.lower( t.args[2] )
			if base == "command" then
				local obj = findCommand( args )
				if obj then
					ply:Print( 'Name: ', obj.name )
					ply:Print( 'Rank: ', obj.rank )
					ply:Print( 'Args: ', table.concat( obj.args, ', ' ) )
					--ply:Print(  )
				else
					ply:Print( 'Nothing found.' )
				end
			elseif base == 'help' then
				ply:Print( 'Valid commands: command' )
			else
				ply:Print( 'Invalid command, use /debug help' )
			end
		end
	})
	
	Arcker:AddCommand( "version", {
		desc = "",
		help = "",
		rank = "guest",
		args = { "" },
		dorun = function(t,ply)
			ply:Print( Color( 255, 100, 100 ), '[ ', Color( 255, 200, 100 ), Arcker:GetName(), Color( 255, 100, 100 ), ' ]' )
			ply:Print( Color( 255, 200, 100 ), 'Authors: ', Color( 20, 200, 250 ), 'Falofa', Color( 255, 200, 100 ), ' and ', Color( 255, 120, 220 ), 'Pukki' )
		end
	})
	
	Arcker:AddCommand( "sudo", {
		desc = "",
		help = "",
		rank = "admin",
		args = { "ES" },
		dorun = function(t,ply)
			local tar = t.args[1]
			local tex = t.args[2]
			hook.Run( 'PlayerSay', tar, '/' .. tex )
			return ''
		end
	})
	
	Arcker:AddCommand( "say", {
		desc = "",
		help = "",
		rank = "admin",
		args = { "ES" },
		dorun = function(t,ply)
			local tar = t.args[1]
			local tex = t.args[2]
			tar:Say( tex )
			return ''
		end
	})
end