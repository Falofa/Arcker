Arcker.Fol = {}
Arcker.Fol.Vars = {}
Arcker.Fol.UserVars = {}

function Arcker.Fol.Find( s, o )
	local v = {}
	if Arcker.Fol.Vars[s] then
		v = Arcker.Fol.Vars[s]
	end
	if Arcker.Fol.UserVars[s] then
		v = Arcker.Fol.UserVars[s]
	end
	//
	if o then
		o = string.lower( o )
		if string.lower( v.type or '' ) == o or string.lower( v.type_ or '' ) == o then
			return v
		end
	else
		return v
	end
	return false
end

local function LoadVars( t )
	t['find'] = {
		type	= 'f',
		type_	= 'Function',
		args	= 's',
		run		= function( s )
			return getPly( s ) or false
		end
	}
	t['echo'] =  {
		type	= 'f',
		type_	= 'Function',
		args	= '*',
		run		= function( ... )
			print( ... )
		end
	}
	return t
end
Arcker.Fol.Vars = LoadVars( Arcker.Fol.Vars )

Arcker.Fol.Err = function( s )
	ErrorNoHalt( s .. '\n' )
	return {
		type	= 'err',
		type_	= 'Error',
		value	= s,
	}
end
Arcker.Fol.Process = function( s, spt )
	print( s .. ' ' .. tostring( spt ) )
	if spt == 'n' then
		s = string.lower( s )
		local n = string.sub( s, 3 )
		if string.sub( s, 1, 2 ) == '0x' then
			/*
			
				Hexadecimal
				Format: 0xffff
			
			*/
			if #string.match( n, "[0-9a-f]+" ) == #n then
				return {
					type	= 'n',
					type_	= 'Number',
					base	= 16,
					value	= tonumber( n, 16 ),
				}
			else
				return Arcker.Fol.Err( 'Value is not number' )
			end
		else
			if #string.match( s, "[0-9]+" ) == #s then
				/*
					Number
					Format: 3643
				*/
				return {
					type	= 'n',
					type_	= 'Number',
					base	= 10,
					value	= tonumber( s ),
				}
			else
				return Arcker.Fol.Err( 'Value is not number' )
			end
		end
	end
	if spt == 's' then
		/*
			String
			Format: 'Hello World!'
			        "Hello World!"
		*/
		return {
			type	= 's',
			type_	= 'String',
			value	= s,
		}
	end
	if spt == 'f' then
		/*
			Function
			Format: foo( bar )
		*/
		local enn	= string.find( s, '(', 1, true ) - 1
		local obj	= Arcker.Fol.Find( string.sub( s, 1, enn ), 'function' )
		if not obj then 
			return Arcker.Fol.Err( 'Tried calling a nil function' )
		end
		local st	= string.find( s, '(', 1, true ) + 1
		local en	= string.find( s, ')', 1, true )
		
		local f = true
		while f do
			en_	= string.find( s, ')', en + 1, true )
			if en_ ~= nil then
				en = en_
			else
				f = false
			end
		end
		en = en - 1
		
		local args	= st < en and string.sub( s, st, en ) or ''
		local arg_	= Arcker.Fol.Read( args )
		
		local gvnag	= ''
		for k, v in ipairs( arg_ ) do
			gvnag = gvnag .. ( v.type and v.type or 'X' )
		end
		if gvnag == obj.args or obj.args == "*" then
			return {
				type	= "Ran Function",
				type_	= "rf",
				func	= obj,
				args	= arg_,
				name	= string.sub( s, 1, enn ),
			}
		end
		return Arcker.Fol.Err( 'Processor error while parsing function' )
	end
	if not spt then
	end
	return Arcker.Fol.Err( 'Error in processor.' )
end
Arcker.Fol.Read = function( s )
	if type( s ) ~= 'string' then return Arcker.Fol.Err( 'Input is not a string!' ) end
	local instructions = {}
	local curinst = {}
	local fir = true
	local cur = ''
	
	local cnt = 0
	local spt = false
	local stf = false
	local scp = false
	for k, v in ipairs( string.Split( s, '' ) ) do
		if fir then
			cur = ''
			cnt = 0
			if string.find( v, '[a-zA-Z]' ) ~= nil then
				cur = cur .. v
			end
			if string.find( v, '[0-9]' ) ~= nil then
				spt = 'n'
				cur = cur .. v
			end
			if string.find( v, '[\'"]' ) ~= nil then
				spt = 's'
				stf = v
			end
			if v ~= " " then
				fir = false
			end
		else
			local mark_end = false
			if spt == false and v == '(' then
				spt = 'f'
			end
			if spt == 'n' then
				if string.find( v, '[0-9a-fA-FxX]' ) ~= nil then
					cur = cur .. v
				end
			elseif spt == 's' then
				if v ~= stf then
					cur = cur .. v
				else
					mark_end = true
				end
			elseif spt == 'f' then
				if string.find( v, '[\'"]' ) then 
					scp = not scp 
				end
				if v ~= ',' then
					cur = cur .. v
				end
				if v == '(' and not scp then
					cnt = cnt + 1
				end
				if v == ')' and not scp then
					cnt = cnt - 1
					if cnt == 0 then
						mark_end = true
					end
				end
			else
				if string.find( v, '[a-zA-Z0-9]' ) ~= nil then
					cur = cur .. v
				end
			end
			if ( ( v == ' ' or #s == k )  and spt ~= 'f') or mark_end then
				if #cur > 0 and #cur > #( string.match( cur, '[ +]' ) or '' ) then
					table.insert( instructions, Arcker.Fol.Process( cur, spt ) )
					cur = ''
					spt = false
					stf = false
					fir = true
				end
			end
		end
	end
	return instructions
end
