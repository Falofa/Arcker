AddCSLuaFile( )
/*///
	
	Developed by:
	Falofa (http://steamcommunity.com/id/falofa)
	Pukki (http://steamcommunity.com/id/Plurily)

    ============== GLOBAL VARIABLES ==============
/*///

Arcker = Arcker or { }
Arcker.Version = '0.1 ALPHA'
Arcker.Name = 'Arcker'

function Arcker:GetName()
	return ("[" .. self.Name .. ' v' .. string.Replace(self.Version, " ALPHA", "") .. "]")
end

Arcker.Color = setmetatable( 
{
	['def'] = 		{Color( 186, 186, 186 ), "Default"},
	['chat_def'] =	{Color( 180, 150, 168 ), "Chat default"},
	['white'] = 	{Color( 255, 255, 255 ), "White"},
	['def'] = 		{Color( 200, 200, 200 ), "Grey"},
	['Lips'] = 		{Color( 164,   8,   2 ), "Red"},
	['Magenta'] =	{Color( 82,    0,  57 ), "Purple"},
	['Freeze'] = 	{Color( 186, 228, 229 ), "Blue"},
	['Pool'] = 		{Color(  52, 190, 218 ), "Blue"},
	['Frog'] = 		{Color( 195, 255, 104 ), "Green"},
	['Green tea'] = {Color( 202, 232, 162 ), "Green"},
	['Alert'] = 	{Color( 127, 255,  36 ), "Green"},
	['Glow'] = 		{Color( 255,  82,   0 ), "Orange"},
	['Default'] = 	{Color(150, 150, 150), "Grey"},
	['Purpose'] = 	{Color(114, 19, 178), "Purple"},
	['Heart'] = 	{Color(178, 19, 19), "Red"},
	['Mustard'] = 	{Color(175, 175, 19), "Yellow"},
	['Lettuce'] = 	{Color(136, 175, 19), "Green"},
	['Rose'] = 		{Color(175, 19, 123), "Pink"},
	['Error'] = 	{Color(255, 35, 35), "Red"},
	['Happy'] = 	{Color(224, 203, 237), "Light pink"},
	['Ice'] = 		{Color(160, 245, 255), "Blue"},
	['Freeze'] =	{Color(0, 228, 255), "Blue"},
	['Sky'] = 		{Color(0, 42, 255), "Blue"},
	['Granted'] = 	{Color(59, 255, 0), "Green"}
},
{
	__call = function(t, s, mod)
		if t[s] then
			if mod == true then
				return t[s]
			else
				if mod then
					local ex = string.Explode(" ", tostring(t[s][1]))
					local m = 0
					local ret = {}
					for k, v in pairs(ex) do
						if ex[#ex] == v then
							break
						end
						v = tonumber(v)
						m = m <= v and v or m
					end
					table.insert(ret, 1, {tostring(m)})
					table.RemoveByValue(ex, tostring(m))
					local c = 0
					for _, x in pairs(ex) do
						c = c + 1
						if ret[1][1] == x then
							table.insert(ret[1], x)
							table.remove(ex, c)
							table.insert(ex, 1, nil)
						end
					end
					local n = tonumber(string.sub(mod, 2, #mod))
					local fin = {}
					local c1 = 0
					for k, v in pairs(ret[1]) do
						c1 = c1 + 1
						if string.Left(mod, 1) == "-" then
							ret[1][c1] = v - n
							if ret[1][c1] < 0 then ret[1][c1] = 0 end
						elseif string.Left(mod, 1) == "+" then
							ret[1][c1] = v + n
							if ret[1][c1] > 255 then ret[1][c1] = 255 end
						end
						table.insert(fin, ret[1][c1])
					end
					local c2 = 0
					for k, v in pairs(ex) do
						c2 = c2 + 1
						if string.Left(mod, 1) == "-" then
							ex[c2] = v - math.floor(n/2)
							if ex[c2] < 0 then ex[c2] = 0 end
						elseif string.Left(mod, 1) == "+" then
							ex[c2] = v + math.floor(n/2)
							if ex[c2] > 255 then ex[c2] = 255 end
						end
						table.insert(fin, ex[c2])
					end
					return Color(fin[1], fin[2], fin[3], 255)
				end
			end
			return t[s][1]
		else
			return t['Default'][1]
		end
	end
})

if SERVER then
	/*///
		============== SERVERSIDE VARIABLES ==============
	/*///
	util.AddNetworkString( 'arcker files' )
	include( 'Arcker/core/util.lua' )
	
	function Arcker:Boot()
		self:Debug( 'BOOTING' )
		self.Files = {}
		self.ClientFiles = {}
		
		local function GetFiles() // Saving on memory
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
			return all
		end

		for _, fl in pairs(GetFiles()) do
			local C = {
				Name = fl
			}
			local read = string.lower( file.Read(fl, "LUA") )
			if string.find(read, "\n?//[%s]*server[%s]*\n?") then 
				C['sv'] = true 
				C['type'] = 'serverside' 
			end
			if string.find(read, "\n?//[%s]*client[%s]*\n?") then 
				C['cs'] = true 
				C['type'] = 'clientside' 
			end
			if string.find(read, "\n?//[%s]*shared[%s]*\n?") then //
				C['sv'] = true
				C['cs'] = true 
				C['type'] = 'shared' 
			end
			
			if not ( C['sv'] or C['cs'] ) then
				// File missing metatags
				self:PrintA( 'File missing metatags: ', fl )
			end
			
			C.Sequence = tonumber( string.match( read, "\n?//[%s]*sequence%([%s]*([0-9]+)[%s]*%)[%s]*\n?", 1 ) or '0' ) or 0
			table.insert( self.Files, C )
		end
		
		table.sort( self.Files, function( a, b ) return a.Sequence > b.Sequence end )
		
		local function FormatPrint(var)
			local w = string.lower( var )
			local r = {"_sv","_cl","_sh",".lua","aura/"}
			for k, v in ipairs( r ) do
				 w = string.Replace( w, v, '' )
			end
			w = string.Replace( w, '/', '.' )
			return w
		end

		local function IncludeAll()
			for k, v in ipairs(self.Files) do
				if v.sv then 
					include(v.Name)
				end
				if v.cs then
					AddCSLuaFile(v.Name)
					table.insert(self.ClientFiles, v.Name)
				end
				if v.sv or v.cs then
					self:Debug( string.format( "Initialized %s file: %s", v.type, FormatPrint(v.Name) ) )
				end
			end
		end

		IncludeAll()

		function self.CsInclude( ply )
			if ply then
				net.Start( 'arcker files' )
				net.WriteTable( self.ClientFiles )
				net.Send( ply )
			elseif #player.GetHumans() then
				net.Start( 'arcker files' )
				net.WriteTable( self.ClientFiles )
				net.Broadcast( )
			end
		end
	end

	Arcker:Boot()
	
	hook.Add( 'PlayerAuthed', 'arcker authed include', Arcker.CsInclude )
	hook.Add( 'PlayerInitialSpawn', 'arcker spawn include', Arcker.CsInclude )
	
end

if CLIENT then
	/*///
		============== CLIENTSIDE VARIABLES ==============
	/*///
	Arcker.ClientFiles = {}
	net.Receive( 'arcker files', function( L )
		Arcker.ClientFiles = net.ReadTable()
		for k, v in ipairs( Arcker.ClientFiles ) do
			include( v )
		end
	end	)
end