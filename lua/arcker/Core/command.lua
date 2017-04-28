// Shared
// Sequence(4000)

local BaseCommand = {
	Name = '',
	Perm = 'default'
}

local Command = {

}
local CommandMeta = {
	__call = function( self, s )
		
	end
}
CommandMeta.__index = CommandMeta
Arcker.Command = setmetatable( Command, CommandMeta )