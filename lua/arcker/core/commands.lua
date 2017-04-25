getLvl = function(ply)
	if not ply then return -1 end
	if not IsValid( ply ) then return -1 end
	return Arcker.Ranks[ ply:Team() ] and Arcker.Ranks[ ply:Team() ].Level or 0
end

separateArgs = function( s )
	local result = {}
	local cur = ""
	local curs = nil
	local ste = false
	local sca = true
	local escape = {
		["\\"] = true
	}
	local schars = {
		['"'] = true,
		["'"] = true
	}
	for _, v in ipairs( string.Split( s, "" ) ) do
		if sca then
			cur = cur .. v
			sca = false
			if _ == string.len( s ) then
				table.insert( result, cur )
				cur = ""
			end
		else
			if escape[v] then
				sca = true
				if _ == string.len( s ) then
					table.insert( result, cur )
					cur = ""
				end
			else
				if schars[ v ] and ( curs == v or not curs ) then
					ste = not ste
					if ste then
						if string.len( cur ) ~= 0 then
							table.insert( result, cur )
						end
						cur = ""
						curs = v
					else
						curs = nil
						table.insert( result, cur )
						cur = ""
					end
				end
				if not ste then
					if not schars[ v ] then
						if v == " " then
							if string.len( cur ) ~= 0 then
								table.insert( result, cur )
							end
							cur = ""
						else
							cur = cur .. v
						end
						if _ == string.len( s ) then
							table.insert( result, cur )
							cur = ""
						end
					end
				else
					if v ~= curs then
						cur = cur .. v
						if _ == string.len( s ) then
							table.insert( result, cur )
							cur = ""
						end
					end
				end
			end
		end
	end
	return result
end

getPly = function( s, ply )
	s = string.lower( s )
	if s == "^" then return ply end
	for _, v in pairs( player.GetAll() ) do
		if
			string.find( string.lower( v:Nick() ), s, 1, true ) ~= nil or
			s == v:EntIndex() or
			s == v:SteamID()  or
			s == v:SteamID64()
		then
		   return v
		end
	end
	return false
end

local argtypes = {}
argtypes.E = function( s, ply, typ )
	local tar = getPly( s, ply )
	if not tar then return {err="invalid target."} end
	if typ == "*" then return tar end
	if not ply then return tar end
	if getLvl( ply ) >= Arcker:Rank( "owner" ) then return tar end
	if getLvl( tar ) <= getLvl( ply ) then 
		return tar
	else
		return {err="you can't target " .. tar:Nick() .. "."}
	end
	return {err="unknown error."}
end
argtypes.S = function( s )
	return tostring( s )
end
argtypes.N = function( s )
	local num = tonumber( s )
	if num then
		return num
	else
		return {err="invalid number."}
	end
end
argtypes.B = function( s )
	return tobool( s ) or false
end
argtypes.T = function(s,ply)
	local mult = {
		Y = 525600,
		M = 43800,
		W = 10080,
		D = 1440,
		H = 60,
	}
	local st = {
		Y = { "Year", "Years" },
		M = { "Month", "Months"},
		W = { "Week", "Weeks"},
		D = { "Day", "Days"},
		H = { "Hour", "Hours"},
		m = { "Minute", "Minutes" }
	}
	local str = string.upper(s)
	local tim = string.sub(str,string.len(str))
	if mult[tim] ~= nil then
		local num = tonumber(string.sub(str,1,string.len(str)-1))
		if num then
			converted = num * mult[tim]
			if num ~= 1 then
				return { converted, num.." "..st[tim][2] }
			else
				return { converted, num.." "..st[tim][1] }
			end
		else
			return {err="invalid time."}
		end
	else
		local num = tonumber(str)
		if num then
			if num ~= 1 then
				return { num, num.." "..st.m[2] }
			else
				return { num, num.." "..st.m[1] }
			end
		else
			return {err="invalid time."}
		end
	end
end

getArgs = function( t, args, ply, typ )
	local malformed_err = "malformed argument table."
	local invalid_input = "invalid input table."
	if type(args) ~= "table" then return {err=malformed_err} end
	if type(t) ~= "table" then return {err=invalid_input} end
	for _, v in pairs( args ) do if type( v ) ~= "string" then return {err=malformed_err} end end
	for _, v in pairs( t ) do if type( v ) ~= "string" then return {err=invalid_input} end end
	local errors = {}
	local results = {}
	local accepted = nil
	
	for _, v in ipairs( args ) do
	local i = 1
		if string.len( v ) == table.Count( t ) then
			if string.len( v ) == 0 then
				return { w = true, args = {}, typ = "" }
			end
			local contin = true
			local cur = {}
			for __, k in ipairs( string.Split( v, "" ) ) do
				if contin then
					if argtypes[ k ] then
						local args = argtypes[ k ]( t[ i ], ply, typ )
						if type( args ) == "table" and args.err then
							table.insert( errors, args.err )
							contin = false
						end
						table.insert( cur, args )
					else
						table.insert( errors, malformed_err )
						contin = false
					end
				end
				i = i + 1
			end
			if contin then
				accepted = true
				table.insert( results, { cur, v } )
			end
		end
	end
	
	/*
	--[[ DEBUG ]]--
	
	do
		return results, errors
	end
	*/
	
	if table.Count( results ) ~= 0 then
		local res = results[1]
		return { w = true, args = res[1], typ = res[2] }
	else
		if table.Count( errors ) ~= 0 then
			return { w = false, err = errors[1] }
		else
			return { w = false, err = "generic error." }
		end
	end
	return {}
end

local argstr = function(comma,s)
	local result = ""
	local argss = {
		E = "Entity",
		S = "String",
		N = "Number",
		B = "Bool",
		T = "Time"
	}
	for _, v in pairs( s ) do
		result = result .. "\t/" .. comma .. " "
		for __, k in ipairs( string.Split( v, "" ) ) do
			result = result .. "[" .. ( argss[ k ] or k ) .. "] "
		end
		result = result .. "\n"
	end
	return result
end

function Arcker:LoadCommandSystem()
	self.Commands = {}
	function self:UnregisterCommand( s )
		local tore = nil
		s = string.lower( s )
		for k, v in ipairs( self.Commands ) do
			local names = string.Split( string.Replace( v.name, ' ', '' ), '|' )
			for __, name in ipairs( names ) do
				if name == s then
					tore = k
				end
			end
		end
		local r = table.remove( self.Commands, tore )
		return r and true or false
	end
	function self:AddCommand( s, t )
		if type( t ) ~= "table" then return nil end
		local name = string.lower( s )
		local dorun = t.dorun
		local raw = t.raw
		local args = t.args
		local rank = t.rank
		local typ = t.typ
		if string.len( t.help ) == 0 then t.help = nil end
		if string.len( t.desc ) == 0 then t.desc = nil end
		local help = { 
			help = t.help or t.desc or "No help attached.",
			desc = t.desc or "No description", 
		}
		
		if not name then return false end
		if string.len( name ) == 0 then return end
		if string.find( name, " ", 1, true ) ~= nil then 
			name = string.Replace( name, ' ', '' )
		end
		
		local index = table.Count( self.Commands ) + 1
		for k, v in pairs( self.Commands ) do
			/*
				Overwriting old version of commands.
			*/
			local names = string.Split( string.Replace( v.name, ' ', '' ), '|' )
			for __, nam_e in ipairs( names ) do
				if nam_e == name then
					index = k
				end
			end
		end
		self.Commands[index] =
		{
			name = name,
			func = dorun,
			args = args,
			rank = rank,
			help = help,
			raw = raw,
			typ = typ
		}
	end
	hook.Add("PlayerSay",Arcker:Pname( 'commands' ),function( ply, text, team )
		local workd = false
		local run = false
		local comchar = {
			["!"] = true,
			["/"] = true
		}
		local ret = nil
		if string.len( text ) <= 1 then return end
		if comchar[ text[1] ] then
			local args = separateArgs( string.sub( text, 2) )
			if not args then return end
			for k, v in ipairs( Arcker.Commands ) do
				if not run then
					local names = string.Split( string.Replace( v.name, ' ', '' ), '/' )
					for __, name in ipairs( names ) do
						if name == string.lower( args[1] ) then
							workd = true
							local comma = args[1]
							table.remove( args, 1 )
							if v.raw then
								if name ~= 'last' then
									ply:SetVar( 'last', text )
								end
								if getLvl( ply ) >= Arcker:Rank( v.rank ) then
									ret = v.func( { 
										args	= string.sub( text, #name + 3 ),
										typ		= "RAW",
										name	= name,
									}, ply )
								else
									ply:Print( "You can't use this command!" )
								end
							else
								local args_t = getArgs( args, v.args, ply, v.typ or "" )
								if args_t.w then
									if getLvl( ply ) >= Arcker:Rank( v.rank ) then
										if name ~= 'last' then
											ply:SetVar( 'last', text )
										end
										ret = v.func( { 
											args	= args_t.args,
											typ		= args_t.typ,
											raw		= string.sub( text, string.len( text ) + 3 ),
											name	= name,
										}, ply )
										run = true
									else
										ply:Print( "You can't use this command!" )
									end
								else
									ply:Print("An error ocourred: \n\t"..args_t.err)
									ply:Print("Syntax: \n"..argstr(name,v.args))
									run = true
								end
							end
						end
					end
				end
			end
			if workd then
				if text[1] == "/" then
					return ""
				end
			end
			if ret then
				return tostring( ret )
			end
		end
	end)
end