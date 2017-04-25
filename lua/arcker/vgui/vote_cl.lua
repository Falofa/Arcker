ArckerVote = ArckerVote or {}
Voted = false

function sendMyOptionOfChoosing( s )
	net.Start( 'myvoteoption' )
	 net.WriteString( s )
	net.SendToServer( )
end
function closeVote()
	local f = ArckerVote.frame.base
	if f and IsValid( f ) then
		f:Close()
	end
end

function createOption( t, f, pos, size )
	local o = vgui.Create( "DButton", f )
	o:SetText( t )
	o:SetFont( "Trebuchet24" )
	o:SetPos( pos.x, pos.y )
	o:SetSize( size.w, size.h )
	o.Paint = function( p, w, h )
		draw.RoundedBoxEx( 5, 0, 0, w, h, Color( 255, 255, 255 ), false, true, true, false )
	end
	o.DoClick = function()
		if not Voted then
			sendMyOptionOfChoosing( t )
			closeVote()
			Voted = true
		end
	end
	o.DoRightClick = o.DoClick
	return o
end
function voteDraw( s, i, o )
	ArckerVote = {
		text = s,
		time = i,
		opti = o
	}
	Voted = false
	
	local size = { x=250, y=150 }
	size.y = size.y + 60 * #o - 5
	
	local baseframe = vgui.Create( "DFrame" )
	baseframe:SetPos( 100, 100 )
	baseframe:SetSize( 300, 200 )
	baseframe:SetTitle( "" )
	baseframe:SetDraggable( true )
	
	local frame = vgui.Create( "DPanel", baseframe )
	ArckerVote.frame = {
		base = baseframe,
		frame = frame,
		options = {}
	}
	local basecolor = Color( 0, 0, 0, 100 )
	baseframe.Paint = function( f, w, h )
		draw.RoundedBoxEx( 5, 0, 0, w, 25, basecolor, true, true, false, false )
	end
	frame.Paint = function( f, w, h )
		draw.RoundedBoxEx( 5, 0, 0, w, h, basecolor, false, false, true, true )
	end
	
	local subframe = vgui.Create( "DPanel", frame )
	subframe:SetPos( 5, 5 )
	subframe:SetSize( 240, 135 )
	subframe.Paint = function( f, w, h )
		draw.RoundedBoxEx( 10, 0, 0, w, h, Color( 255, 255, 255 ), true, false, false, true )
	end
	
	local text = vgui.Create( "DLabel", subframe )
	local margin = 5
	text:SetText( s )
	text:SetColor( Color( 44, 62, 80 ) )
	text:SetFont( "Trebuchet24" )
	text:SetSize( 240-margin*2, 135-margin*2 )
	text:Center()
	text:SetWrap( true )
	text:SetContentAlignment( 5 )
	
	baseframe:SetPos( 5, ScrH()/4 - size.y/2 )
	baseframe:SetSize( size.x, size.y + 30 )
	frame:SetPos( 0, 25 )
	frame:SetSize( size.x, size.y )
	for k, v in ipairs( o ) do
		table.insert( ArckerVote.frame.options, 
			createOption( v, frame, 
			{ x = 5, y = 150 + ( (k-1) * 60 ) },
			{ w = 250-10, h = 50 }
		) )
	end
	//baseframe:MakePopup()
end
net.Receive( 'votecreate', function()
	local s = net.ReadString()
	local i = net.ReadDouble()
	local o = net.ReadTable()
	voteDraw( s, i, o )
end )
net.Receive( 'voteclose', function()
	if ArckerVote.base and IsValid( ArckerVote.base ) then
		ArckerVote.base:Close()
		ArckerVote.base = nil
	end
end )