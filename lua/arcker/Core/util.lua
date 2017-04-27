// Client
// Sequence(7000)

function Arcker:PrintTable( t )
	print( util.TableToJSON( t, true ) )
end

if SERVER then
	
	local Debug = CreateConVar( 'arcker_debug', 0, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, 'Debug mode for arcker')
	function Arcker:Debug( ... )
		if Debug:GetInt() then
			if Debug:GetInt() == 2 then
				local Stack = string.split( debug.traceback(), '\n\t' ) // Getting stack trace. 'addons/arcker/lua/autorun/arcker.lua:0: in main chunk'
				local Sub = { string.find( Stack[#Stack], '[0-9]+:' ) } // Finds second colon. 'addons/arcker/lua/autorun/arcker.lua:0'
				print('[Arcker] at ' .. string.Replace( string.sub( Stack[#Stack], 0, Sub[2]-1 ), 'addons/arcker/lua/', '' ) ) // Prints from where the function call was made
			else
				Msg( '[Arcker] ' ) // No line breaks so the next print is on the same line
			end
			local Args = {...}
			if #Args == 1 and type(Args[1]) == 'table' then
				self:PrintTable( Args[1] )
			else
				print( ... )
			end
		end
	end
	
	function Arcker:PrintA( ... )
		local Text = ""
		for k, v in pairs( { ... } ) do
			if type(v) == "Player" then
				Text = Text .. v:Nick() .. "(" .. v:SteamID() .. ")"
			elseif type(v) == "table" then
				Text = Text .. util.TableToJSON( v, true )
			else
				Text = Text .. tostring( v )
			end
		end

		Msg( Arcker:GetName(), ' ', Text, '\n' )
	end
	
end