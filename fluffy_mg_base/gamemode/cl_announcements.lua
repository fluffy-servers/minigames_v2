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
    mat:Scale( Vector(scale, scale) )
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