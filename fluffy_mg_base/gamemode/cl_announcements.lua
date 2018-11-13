--[[
    Clientside announcements library
    Contains some local functions for drawing fancy text
    Announcements here are triggered on the server and then displayed here for information
    Currently contains the following announcement types:
        - Countdown
--]]

-- Draw text that can be scaled
-- Useful for cool animations without creating lost of different font sizes
local function drawScaledText(x, y, text, font, color, scale)
    -- Setup the matrix
	local mat = Matrix()
	mat:Translate( Vector(x, y) )
	mat:Scale( Vector(scale, scale) )
	mat:Translate( -Vector(x, y) )
    
    -- Get the size of the text
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(text)
    
    -- Push matrices and draw the text
    render.PushFilterMag( TEXFILTER.ANISOTROPIC )
    render.PushFilterMin( TEXFILTER.ANISOTROPIC )
    cam.PushModelMatrix(mat)
        draw.SimpleText(text, font, x - tw/2, y - th/2, color)
    cam.PopModelMatrix()
    render.PopFilterMag()
    render.PopFilterMin()
end

-- Draw text that can be rotated
local function drawRotatedText(x, y, text, font, color, ang)
    -- Get the size of the text
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(text)
    
    -- Setup the matrix
    local mat = Matrix()
    mat:Translate( Vector(x, y) )
    mat:SetAngles( Angle(0, ang, 0) )
    mat:Translate( -Vector(x, y) )
    
    -- Push matrices and draw the text
    render.PushFilterMag( TEXFILTER.ANISOTROPIC )
    render.PushFilterMin( TEXFILTER.ANISOTROPIC )
    cam.PushModelMatrix(mat)
        draw.SimpleText(text, font, x - tw/2, y - th/2, color)
    cam.PopModelMatrix()
    render.PopFilterMag()
    render.PopFilterMin()
end

-- Draw text that is a combination of the above two functions
local function drawRotatedScaledText(x, y, text, font, color, ang, scale)
    -- Get the size of the text
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(text)
    
    -- Setup the matrix
    local mat = Matrix()
    mat:Translate( Vector(x, y) )
    mat:SetAngles( Angle(0, ang, 0) )
    mat:Scale( Vector(scale, scale) )
    mat:Translate( -Vector(x, y) )
    
    -- Push matrices and draw the text
    render.PushFilterMag( TEXFILTER.ANISOTROPIC )
    render.PushFilterMin( TEXFILTER.ANISOTROPIC )
    cam.PushModelMatrix(mat)
        draw.SimpleText(text, font, x - tw/2, y - th/2, color)
    cam.PopModelMatrix()
    render.PopFilterMag()
    render.PopFilterMin()
end

-- Create a countdown announcement
-- Counts down in the middle of the screen before displaying the endtext
function GM:CountdownAnnouncement(length, endtext, endsound, ticksound)
    local test = vgui.Create("DPanel")
    test:SetSize(ScrW(), ScrH())
    test:Center()
    test:NoClipping(true)
    local lasttick = CurTime()
    local number = length
    local finished = false
    
    if ticksound then surface.PlaySound(ticksound) end
    
    function test:GetCountdownInfo()
        if finished then return 1, endtext end
        local timeleft = lasttick - CurTime()+1
        if timeleft < 0 then
            timeleft = 1
            lasttick = CurTime()
            number = number - 1
            if number < 1 then
                finished = true
                if endsound then surface.PlaySound(endsound) end
                timer.Simple(1, function() self:Remove() end)
            else
                if ticksound then surface.PlaySound(ticksound) end
            end
        end
        return timeleft, number
    end
    
    function test:Paint(w, h)
        local s, num = self:GetCountdownInfo()
        local x = w/2
        local y = h/2
        drawScaledText(x+2, y+2, tostring(num), "FS_64", GAMEMODE.FColShadow, s + 0.25)
        drawScaledText(x, y, tostring(num), "FS_64", GAMEMODE.FCol1, s + 0.25)
    end
end

-- Net handler to parse announcements
net.Receive('MinigamesAnnouncement', function()
    local tbl = net.ReadTable()
    if not tbl.type then return end
    if tbl.type == 'countdown' then
        local length = tbl.length or 5
        local endtext = tbl.endtext or ""
        GAMEMODE:CountdownAnnouncement(length, endtext, tbl.endsound, tbl.ticksound)
    end
end)