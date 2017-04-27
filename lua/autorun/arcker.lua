AddCSLuaFile( )
Arcker = Arcker or { }
Arcker.Version = '0.1 ALPHA'
Arcker.Name = 'Arcker'
if SERVER then
	util.AddNetworkString( 'arcker files' )
	local Debug = CreateConVar( 'arcker_debug', 0, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, 'Debug mode for arcker')
	function Arcker.Debug(...)
		if Debug:GetBool() then
			local Stack = string.split( debug.traceback(), '\n\t' ) // Getting stack trace. 'addons/arcker/lua/autorun/arcker.lua:0: in main chunk'
			local Sub = { string.find( Stack[#Stack], '[0-9]+:' ) } // Finds second colon. 'addons/arcker/lua/autorun/arcker.lua:0'
			print('[Arcker] at ' .. string.sub( Stack[#Stack], 0, Sub[2]-1 ) ) // Prints from where the function call was made
			local Args = {...}
			if #Args == 1 and type(Args[1]) == 'table' then
				PrintTable( Args[1] )
			else
				print( ... )
			end
		end
	end

	Arcker.Print = {}
	Arcker.Color =    Color(186, 186, 186)
	Arcker.WarColor = Color(235, 123,  89)
	Arcker.ErrColor = Color(200, 0,     0)
	Arcker.SublimeColor = Color(110, 150, 152)

	function Arcker:GetName()
		return ("[" .. self.Name .. ' v' .. self.Version .. "]")
	end

	function Arcker:PrintA(n, ...)
		local t = { ... }
		local ret = ""
		if n != 1 or n != 2 then
			t = {n}
		end
		for k, v in pairs(t) do
			if type(v) == "Player" then
				ret = ret .. v:Nick() .. "(" .. v:SteamID() .. ")"
			elseif type(v) == "table" then
				ret = ret .. tostring(v)
			else
				ret = ret .. v
			end
			ret = ret .. " "
		end


		if n == 1 then
			MsgC(Arcker.Color, Arcker:GetName())
			MsgC(" ")
			MsgC(Arcker.ErrColor, ret .. "\n")
		elseif n == 2 then
			MsgC(Arcker.ErrColor, "[ARCKER ERROR]")
			MsgC(" ")
			MsgC(Arcker.ErrColor, ret .. "\n")
		else
			MsgC(Arcker.Color, Arcker:GetName())
			MsgC(" ")
			MsgC(Arcker.Color, ret .. "\n")
		end
	end

	function Arcker:Boot()
		local NotLoad = {
			//
		}
		local Files = {
			sv = {},
			cl = {},
			sh = {}
		}
		local all = {}
		local fil, fol = file.Find("arcker/*", "LUA")
		for z, x in pairs(fol) do
			for _, v in pairs(file.Find("arcker/" .. x .. "/*.lua", "LUA")) do
				for k, source in pairs(file.Find("arcker/*.lua", "LUA")) do
					table.insert(all, "arcker/" .. source)
				end
				table.insert(all, "arcker/" .. x .. "/" .. v)
			end
		end

		for k, v in pairs(NotLoad) do
			for _, al in pairs(all) do
				if v == al then
					table.RemoveByValue(all, al)
				end
			end
		end

		for _, fl in pairs(all) do
			local read = file.Read(fl, "LUA")
			if string.find(read, "// Server") then
				table.insert(Files.sv, fl)
			elseif string.find(read, "// Client") then
				table.insert(Files.cl, fl)
			elseif string.find(read, "// Shared") then
				table.insert(Files.sh, fl)
			else
				if string.find(read, "CLIENT") and string.find(read, "SERVER") then
					table.insert(Files.sh, fl)
				elseif string.find(read, "CLIENT") then
					table.insert(Files.cl, fl)
				elseif string.find(read, "SERVER") then
					table.insert(Files.sv, fl)
				else
					table.insert(Files.sh, fl)
				end
			end
		end
		
		local function FormatPrint(var)
			local w = string.Replace(var, "_sv", "")
			w = string.Replace(w, "_cl", "")
			w = string.Replace(w, "_sh", "")
			w = string.Replace(w, ".lua", "")
			w = string.Replace(w, "aura/", "")
			w = string.Replace(w, "/", ".")
			return w
		end

		local function IncludeAll()
			for k, v in pairs(Files.sv) do
				include(v)
				Arcker:PrintA("Server file initialized: " .. FormatPrint(v))
			end
			for k, v in pairs(Files.cl) do
				AddCSLuaFile(v)
				table.insert(Arcker.ClientFiles, v)
				Arcker:PrintA("Client file initialized: " .. FormatPrint(v))
			end
			for k, v in pairs(Files.sh) do
				include(v)
				AddCSLuaFile(v)
				table.insert(Arcker.ClientFiles, v)
				Arcker:PrintA("Shared file initialized: " .. FormatPrint(v))
			end
		end

		IncludeAll()

		function Arcker.CsInclude( ply )
			if ply then
				net.Start( 'arcker files' )
				net.WriteTable( Arcker.ClientFiles )
				net.Send( ply )
			elseif #player.GetHumans() then
				net.Start( 'arcker files' )
				net.WriteTable( Arcker.ClientFiles )
				net.Broadcast( )
			end
		end
	end

	Arcker:Boot()
	
	hook.Add( 'PlayerAuthed', Arcker.CsInclude )
	hook.Add( 'PlayerInitialSpawn', Arcker.CsInclude )
	
end

if CLIENT then
	Arcker.ClientFiles = {}
	net.Receive( 'arcker files', function( L )
		Arcker.ClientFiles = net.ReadTable()
		for k, v in ipairs( Arcker.ClientFiles ) do
			include( v )
		end
	end	)
end