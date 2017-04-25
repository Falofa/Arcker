if SERVER then
	function Arcker:LoadPlugins()
		self.Plugins = self.Plugins or {}
		local ids = table.Count( self.Plugins ) + 1
		
		function self:CheckPlugin( p, e )
			if not p then return end
			if not p._info.Valid then return end
			if not file.Exists( "arcker/plugins.dat", "DATA" ) then
				file.Write( "arcker/plugins.dat", "" )
			end
			local DATA = file.Read( "arcker/plugins.dat", "DATA" )
			local plugs = {}
			for k, v in ipairs( string.Split( DATA, "\n" ) ) do
				local pl, vl = unpack( string.Split( v, "\t" ) )
				if pl and vl then
					plugs[pl] = util.tobool( vl )
				end
			end
			if e ~= nil then
				plugs[p.Id] = e
			elseif plugs[p.Id] == nil then
				plugs[p.Id] = true // New plugin
			end
			local dat = ""
			for k, v in pairs( plugs ) do
				dat = dat .. k .. "\t" .. tostring( v ) .. "\n"
			end
			file.Write( "arcker/plugins.dat", dat )
			return plugs[p.Id]
		end
		
		function self:PluginEnable( p, enable )
			if p then
				local newstate = self:CheckPlugin( p, enable )
				return true, newstate
			else
				return false, nil
			end
		end
		
		function self:PluginLoad( p, slog, f, customlog )
			local Message = "Generic error"
			if not file.Exists( p, "LUA" ) then return "File not found" end
			
			local Plugin = include( p )
			if not Plugin then return "Plugin is nil" end
			if type( Plugin ) ~= 'table' then return "Plugin is invalid" end
			Plugin._info = {}
			Plugin._info.Folder = p
			Plugin._info.Valid = true
			Plugin._info.Enabled = self:CheckPlugin( Plugin )
			local rep = nil
			for k, v in ipairs( self.Plugins ) do
				if v._info.Folder == Plugin._info.Folder then
					// If this exact plugin is already loaded then its gonna replace the older version
					pcall( v.Unload ) // Unloading older version...
					rep = k // Setting where the new plugin should be put in
				end
			end
			Plugin._info.Id = rep or ids
			self.Plugins[rep or ids] = Plugin
			if not rep then
				ids = ids + 1
			end
			local log = nil
			if Plugin._info.Enabled then
				if Plugin.Load then
					local name = Plugin and ( Plugin.Name or "" ) or ""
					log = "Preloaded: ".. name
					local en = self:CheckPlugin( Plugin )
					
					local succ, err = pcall( Plugin.Load, self )
					if succ then
						log = log .. "... Loaded!"
						Message = ( rep and not f ) and
							"Plugin reloaded with success" or
							"Plugin loaded with success"
					else
						/*
						
							Simple loading error dumping
						
						*/
						local fil = "arcker/dump/pl_" .. string.lower( name ) .. "_dump.txt"
						local dump = {}
						local tbl = {}
						for k, v in pairs( Plugin ) do
							if type( v ) ~= "function" then 
								tbl[k] = v
							else
								tbl[k] = tostring( v )
							end
						end
						table.insert( dump, "loaded at: " .. util.DateStamp() )
						table.insert( dump, util.TableToJSON( tbl, true ) )
						if err then
							table.insert( dump, "error:" )
							table.insert( dump, err )
						end
						if err and err_sh then
							table.insert( dump, '\n' )
						end
						if err_sh then
							table.insert( dump, "shared error:" )
							table.insert( dump, err_sh )
						end
						table.insert( dump, "\n<eof>" )
						
						if not file.Exists( "arcker/", "DATA" ) then file.CreateDir( "arcker" ) end
						if not file.Exists( "arcker/dump/", "DATA" ) then file.CreateDir( "arcker/dump" ) end
						file.Write( fil, table.concat( dump, "\n" ) )
						
						log = log .. "... Failed! ( log saved in: data/" .. fil .. " )"
						Message = "Plugin failed"
						Plugin._info.Valid = false
					end
				else
					log = log .. "... No loading point."
					Message = "Plugin has no loading point"
					Plugin._info.Valid = false
				end
			else
				log = "Refusing to load " .. Plugin.Id .. ". reason: Disabled."
			end
			if customlog then print( tostring( customlog ) ) end
			if slog then print( log or "Error loading plugin" ) end
			return Message
		end
		
		local folder = "arcker/plugins"
		local files = file.Find( "arcker/plugins/*.lua", "LUA" )
		timer.Create( Arcker:Pname( 'plugins' ),0.5,1,function()
			print("Loading plugins...")
			for _, v in pairs( files ) do
				Arcker:PluginLoad( folder .. "/" .. v, true, true )
			end
		end)
	end
end