AddCSLuaFile()
ENT.Base = "base_point"
ENT.Type = "point"
if CLIENT then
    ENT.Icon = Material('icon16/flag_blue.png')
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:Draw()
    if not LocalPlayer():Alive() or LocalPlayer().Spectating then return end
    
    local center = self:GetPos()
    local p = center:ToScreen()
    
    surface.SetDrawColor(color_white)
    surface.SetMaterial(self.Icon)
    surface.DrawTexturedRect(p.x - 8, p.y - 8, 16, 16)
    
    if LocalPlayer():Team() == TEAM_BLUE then
        draw.SimpleTextOutlined('Capture here!', 'DermaDefault', p.x, p.y + 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
    end
end