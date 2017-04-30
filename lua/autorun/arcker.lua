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
	return ("[" .. self.Name .. ' v' .. self.Version .. "]")
end

Arcker.Color = setmetatable( 
{
	[''] = 			Color( 186, 186, 186 ), // Default
	['war'] =		Color( 235, 123,  89 ),
	['err'] =		Color( 200,   0,   0 ),
	['sublime'] =	Color( 110, 150, 152 ),
	['chat_def'] =	Color( 180, 150, 168 ),
	['granted'] =	Color(   0, 200,   0 ),
	['white'] = 	Color( 255, 255, 255 ),
},
{
	__call = function(self, s)
		if not s then s = "" end
		return self[s] or self['']
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