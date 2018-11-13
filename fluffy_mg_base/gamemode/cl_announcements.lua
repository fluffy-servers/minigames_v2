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