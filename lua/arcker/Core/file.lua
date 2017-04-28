// Shared
// Sequence(6500)

local ValidFormats = {
	".txt", 
	".jpg", 
	".png", 
	".vtf",
	".dat"
}

local FileMeta = {
	WriteTable = function ( self, t )
		return file.Write( self.Name, util.TableToJSON( t ) )
	end,
	ReadTable = function( self )
		return util.JSONToTable( file.Read( self.Name ) ) or {}
	end
}
FileMeta.__index = FileMeta

Arcker.File = setmetatable( {}, {
	__call = function( self, s )
		if not table.HasValue( ValidFormats, string.lower( string.sub( s, -4 ) ) ) then return Arcker:Error( 'Invalid filetype' ) end
		if not file.Exists( s, 'DATA' ) then
			local a = string.Split( s, '/' )
			table.remove( a, #a )
			local b = ''
			for k, v in ipairs( a ) do
				b = v .. '/'
				if not file.Exists( b, 'DATA' ) then file.CreateDir( b ) end
			end
			file.Write( s, '' )
		end
		return setmetatable( { Name = s }, FileMeta )
	end
})

function Arcker.File:WriteTable( s, t )
	return file.Write( s, util.TableToJSON( t ) )
end

function Arcker.File:ReadTable( s )
	return util.JSONToTable( file.Read( s ) ) or {}
end

function Arcker.File:IsJSON( s )
	return util.JSONToTable( file.Read( s ) ) == nil
end