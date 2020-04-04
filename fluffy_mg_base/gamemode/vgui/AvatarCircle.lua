--[[
    VGUI element to create a circular avatar
    This element can be pretty easily extended for a range of shapes
    Replace the drawStencil() function with whatever shape you need to draw
--]]

PANEL = {}
PANEL.NumSides = 16
PANEL.PolyOffset = 0
PANEL.DrawLevel = false

-- This panel uses the standard AvatarImage display
-- This is then rendered when required + a stencil for varying shapes
function PANEL:Init()
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:SetPaintedManually(true)
end

-- Resize the avatar when required
function PANEL:PerformLayout()
    self.Avatar:SetSize(self:GetWide(), self:GetTall())
end

-- Set the player of our avatar image when required
function PANEL:SetPlayer(player, size)
    self.Player = player
    self.Avatar:SetPlayer(player, size)
end

-- Set the number of sides to render this avatar with
function PANEL:SetNumSides(num, off)
    self.NumSides = num
    self.PolyOffset = off or 0
end

-- Set whether this panel should draw the player level
function PANEL:DrawLevel(bool)
    self.DrawLevel = bool
end

-- This function is taken straight from the wiki
-- https://wiki.facepunch.com/gmod/surface.DrawPoly
local function drawCircle(x, y, radius, seg, offset)
    local offset = offset or 0
	local cir = {}

	table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
	for i = 0, seg do
		local a = offset + math.rad((i / seg) * -360)
		table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	end

	local a = offset + math.rad(0) -- This is needed for non absolute segment counts
	table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})

	surface.DrawPoly(cir)
end

function PANEL:DrawStencil(w, h)
    drawCircle(w/2, h/2, w/2, self.NumSides, self.PolyOffset)
end

-- Big scary stencil code goes in here
function PANEL:Paint(w, h)
    render.ClearStencil()
    render.SetStencilEnable(true)
 
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
 
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)
	
    -- Draw the mask in white
	surface.SetDrawColor(color_white)
	draw.NoTexture()
    self:DrawStencil(w, h)
 
    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(1)
 
    -- Draw the avatar, masked to the stencil shape
    self.Avatar:PaintManual()
 
    render.SetStencilEnable(false)
    render.ClearStencil()
end

-- Register this so we can reuse it later
vgui.Register('AvatarCircle', PANEL)