local function genloghtml( s )
	local base = [[
<!DOCTYPE html>
<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Log-%s</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
</head>
<body style="background:#34495e;">
<div class="container" style="background:#ecf0f1; box-shadow: 5px 5px 10px #222;">
<center><h1>Log-%s</h1></center>
<div class="col-md-12">
<br>
<!--insert-->
<br>
</div>
</div>
</body></html>
	]]
	return string.format( base, s, s )
end
local function inserthtml( fil, t )
	local s = "<p>" .. table.concat( t, '' ) .. "</p>"
	local data = string.Split( file.Read( fil, 'DATA' ), '\n' )
	local insertPoint = 0
	for k, v in ipairs( data ) do
		if string.find( v, '<!--insert-->', 1, true ) ~= nil then
			insertPoint = k
		end
	end
	table.insert( data, insertPoint, s )
	file.Write( fil, table.concat( data, '\n' ) )
end
function plytolog( ply )
	if not ply or not IsValid(ply) then return "nil" end
	return string.format( '<span style="color:%s; background:#000"><b>' .. ply:Nick() .. '</b></span>' .. " <small>(" .. ply:SteamID() .. ")</small>", ColorLib.Rgb.ToHex( team.GetColor( ply:Team() ) ) )
end
Arcker.LogCol = Arcker.LogCol or false
function Arcker:LogColorOnce( col )
	if not isColor( col ) then return false end
	Arcker.LogCol = col
end
function Arcker:Log( ... )
	local t = { ... }
	local col = 2
	if string.find( t[1], '%[.-%] ?' ) ~= nil then
		t[1] = '<span style="color:#8e44ad"><b>' .. t[1] .. '</b></span>'
	else
		col = 1
	end
	if Arcker.LogCol and isColor( Arcker.LogCol ) then
		table.insert( t, 2, '<span style="color:#' .. ColorLib.Rgb.ToHex( Arcker.LogCol ) .. '">' )
		table.insert( t, '</span>')
		Arcker.LogCol = false
	end
	if Arcker.LogCol and not isColor( Arcker.LogCol ) then
		Arcker.LogCol = false
	end
	local folder = "arcker/logs"
	local date = string.Split( util.DateStamp(), " " )[1]
	local stamp = "log-" .. date .. ".dat"
	if not file.Exists( folder, "DATA" ) then file.CreateDir( folder ) end
	if not file.Exists( folder .. "/" .. stamp, "DATA"  ) then file.Write( folder .. "/" .. stamp, genloghtml( date ) ) end
	
	local time = string.Replace( string.Split( util.DateStamp(), " " )[2], "-", ":" )
	
	inserthtml( folder .. "/" .. stamp , t )
	-- "( " .. time .. " ) " .. s .. "\n"
end

hook.Add( "Initialize", "arcker.log.initialize", function()
	Arcker:Log( "Gamemode initializing..." )
end )
hook.Add( "ShutDown", "arcker.log.shutdown", function()
	Arcker:Log( "Lua environment is shuting down" )
end )