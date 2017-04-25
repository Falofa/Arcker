local Permavars = function( Arcker )
	Arcker.vars = Arcker.vars or { }
	local pvars = { }
	function pvars:Check( )
		local content = file.Read( "arcker/vars.dat", "DATA" )
		local json = util.JSONToTable( content or "" )
		if not ( file.Exists( "arcker/vars.dat", "DATA" ) and json ) then
			file.Write( "arcker/vars.dat", util.TableToJSON( { } ) )
		end
	end
	function pvars:Load( )
		self:Check( )
		local content = file.Read( "arcker/vars.dat", "DATA" )
		local json = util.JSONToTable( content ) or { }
		for k, v in pairs( json ) do
			Arcker.vars[ k ] = v
		end
	end
	function pvars:Write( )
		self:Check( )
		local json = util.TableToJSON( Arcker.vars or { }, true )
		file.Write( "arcker/vars.dat", json )
	end
	timer.Create( 'PermaVarsAutoSave', 60, 0, function( )
		pvars:Write( )
	end )
	hook.Add( 'ShutDown', 'PermaVarsShutdownSave', function( )
		pvars:Write( )
	end )
	pvars:Load( )
end
hook.Add( 'ArckerPreload', 'arcker.permavars', Permavars )