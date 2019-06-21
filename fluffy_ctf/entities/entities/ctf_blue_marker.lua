AddCSLuaFile()
ENT.Base = "base_point"
ENT.Type = "point"
if CLIENT then
    ENT.DefendIcon = Material('icon16/shield.png', 'noclamp smooth')
    ENT.AttackIcon = Material('icon16/bomb.png', 'noclamp smooth')
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:Draw()
    if not LocalPlayer():Alive() or LocalPlayer().Spectating then return end
    
    local center = self:GetPos()
    local p = center:ToScreen()
    local size = 24

    if LocalPlayer():Team() == TEAM_BLUE then
        surface.SetMaterial(self.AttackIcon)
        draw.SimpleTextOutlined('Capture!', 'DermaDefault', p.x, p.y + size, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
    elseif LocalPlayer():Team() == TEAM_RED then
        surface.SetMaterial(self.DefendIcon)
        draw.SimpleTextOutlined('Defend!', 'DermaDefault', p.x, p.y + size, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
    else
        return
    end
    
    -- Draw the icon
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRect(p.x - size/2, p.y - size/2, size, size)
end