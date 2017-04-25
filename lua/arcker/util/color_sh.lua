function isColor( col, sc )
	if not col then return false end
	if string.lower( type( col ) ) ~= 'table' and
	   string.lower( type( col ) ) ~= 'number' and
	   string.lower( type( col ) ) ~= 'string' then return false end
	if type( col ) == 'table' then
		if col.r and col.g and col.b then return true end
	end
	if sc ~= true and type( col ) == 'number' then
		if isColor( HSVToColor( col ), true ) then return true end
	end
	if type( col ) == 'string' then
		if #string.match( col, '#[0-9a-fa-F]+' ) == 7 then return true end
	end
	return false
end
/////////////////////////////////////////////

ColorLib = {}
ColorLib.Rgb = {}
ColorLib.Hex = {}
ColorLib.Hsv = {}

// RGB
function ColorLib.Rgb.ToHex( c )
	if not isColor( c ) then return '#000' end
	return '#' .. bit.tohex( c.r, 2 ) .. bit.tohex( c.g, 2 ) .. bit.tohex( c.b, 2 )
end
function ColorLib.Rgb.ToHsv( c )
	if not isColor( c ) then return ColorToHSV( Color( 0, 0, 0 ) ) end
	return ColorToHSV( c )
end

// HEX
function ColorLib.Hex.ToRgb( c )
	local digits = string.match( c, '[0-9a-fa-F]+' ) or ''
	local types = { [6]=true, [3]=true, [4]=true, [8]=true }
	if not types[ #digits ] then return Color(0 ,0, 0) end
	local c1 = 0
	local c2 = 0
	local c3 = 0
	local a = 255
	if #digits == 6 or #digits == 8 then
		c1 = tonumber( string.sub( digits, 1, 2 ), 16 )
		c2 = tonumber( string.sub( digits, 3, 4 ), 16 )
		c3 = tonumber( string.sub( digits, 5, 6 ), 16 )
		a =  tonumber( string.sub( digits, 7, 8 ), 16 ) or 255
	end
	if #digits == 3 or #digits == 4 then
		c1 = tonumber( string.sub( digits, 1, 1 ) * ( 255/16 ), 16 )
		c2 = tonumber( string.sub( digits, 2, 2 ) * ( 255/16 ), 16 )
		c3 = tonumber( string.sub( digits, 3, 3 ) * ( 255/16 ), 16 )
		a =  tonumber( string.sub( digits, 4, 4 ) * ( 255/16 ), 16 ) or 255
	end
	return Color( c1, c2, c3 )
end
function ColorLib.Hex.ToHsv( c )
	return ColorToHSV( ColorLib.Hex.ToRgb( c ) )
end

// HSV
function ColorLib.Hsv.ToRgb( h, s, v )
	if not isColor( h ) then return Color( 0, 0, 0 ) end
	return HSVToColor( h, s, v )
end
function ColorLib.Hsv.ToHex( h, s, v )
	if not isColor( h ) then return ColorToHSV( Color( 0, 0, 0 ) ) end
	return ColorLib.Rgb.ToHex( HSVToColor( h, s, v ) )
end

/////////////////////////////////////////////

function rgb( ... )
	return Color( ... )
end

Arcker.Color = {}
setmetatable(Arcker.Color,{
	__index = function(tbl,key)
		if type(key) == "string" then
			if #key == 4 then
				return tbl["#"..key[2].."F"..key[3].."F"..key[4].."F".."FF"]
			elseif #key == 7 then
				return tbl[key.."FF"]
			elseif #key == 9 then
				rawset( tbl, key, ColorLib.Hex.ToRgb(key) )
				return rawget(tbl,key)
			end
		end

		return Color(math.random(0,255),math.random(0,255),math.random(0,255))
	end
})

Arcker.Color.Cyan 		= Arcker.Color["#00bcd4"]
Arcker.Color.Teal 		= Arcker.Color["#009688"]
Arcker.Color.Green 		= Arcker.Color["#259b24"]
Arcker.Color.LightGreen	= Arcker.Color["#8bc34a"]
Arcker.Color.LightBlue 	= Arcker.Color["#03a9f4"]
Arcker.Color.Cyan 		= Arcker.Color["#00bcd4"]
Arcker.Color.Teal 		= Arcker.Color["#009688"]
Arcker.Color.Green 		= Arcker.Color["#259b24"]
Arcker.Color.LightGreen	= Arcker.Color["#8bc34a"]
Arcker.Color.Lime 		= Arcker.Color["#cddc39"]
Arcker.Color.Yellow 	= Arcker.Color["#ffeb3b"]
Arcker.Color.Amber 		= Arcker.Color["#ffc107"]
Arcker.Color.Orange 	= Arcker.Color["#ff9800"]
Arcker.Color.DeepOrange	= Arcker.Color["#ff5722"]
Arcker.Color.Brown 	 	= Arcker.Color["#795548"]
Arcker.Color.Grey 	 	= Arcker.Color["#9e9e9e"]
Arcker.Color.BlueGrey 	= Arcker.Color["#607d8b"]
Arcker.Color.Invisible  = Arcker.Color["#00000000"]
Arcker.Color.Black 		= Arcker.Color["#000000"]
Arcker.Color.White 		= Arcker.Color["#FFFFFF"]
Arcker.Color.Red 		= Arcker.Color["#e51c23"]
Arcker.Color.Pink 		= Arcker.Color["#e91e63"]
Arcker.Color.Purple 	= Arcker.Color["#9c27b0"]
Arcker.Color.DeepPurple = Arcker.Color["#673ab7"]
Arcker.Color.Indigo 	= Arcker.Color["#e351b5"]
Arcker.Color.Blue 		= Arcker.Color["#5677fc"]
Arcker.Color.LightBlue 	= Arcker.Color["#03a9f4"]