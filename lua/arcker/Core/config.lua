// Server
// Sequence(6000)

/*///

	This should be used for configurations that need to be recorded but do not require a file of its own

/*///
local ConfigFile = Arcker.File( 'arcker/config.dat' )

local ConfigTable = ConfigFile:ReadTable()
local ConfigMeta = {
	Get = function( self, s, d )
		self.Load()
		if not self[ s ] then
			self:Set( s, d )
		end
		return self[ s ]
	end,
	Set = function( self, s, v )
		self[ s ] = v
		self:Save()
	end,
	Load = function( self )
		ConfigFile:ReadTable( )
	end,
	Save = function( self )
		ConfigFile:WriteTable( self )
	end
}
ConfigMeta.__index = ConfigMeta

Arcker.Config = setmetatable( ConfigTable, ConfigMeta )

