AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "microgames_disc"
ENT.Radius = 32
ENT.Icon = Material('icon16/flag_green.png', 'noclamp')

if CLIENT then
    ENT.Circle = Material("sprites/sent_ball")

    function ENT:Draw()
        local radius = self:GetNWInt("Radius", self.Radius)
        local point = self:GetNWInt("RacePoint", 0)
        render.SetMaterial(self.Circle)
        render.DrawQuadEasy(self:GetPos() + Vector(0, 0, 1), self:GetUp(), radius*2, radius*2, self:GetColor())

        -- Stick a big number on the circle
        cam.Start3D2D(self:GetPos() + Vector(0, 0, 1), Angle(0, 0, 00), 1/4)
            draw.SimpleTextOutlined(point, 'FS_128', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        cam.End3D2D()

        if not LocalPlayer():Alive() or LocalPlayer().Spectating then return end
        local center = self:GetPos() + Vector(0, 0, 32)
        local p = center:ToScreen()
        local size = 24

        if (point - 1) == LocalPlayer():GetMScore() then
            cam.Start2D()
                -- Mark this race point
                draw.NoTexture()
                surface.SetMaterial(self.Icon)
                surface.SetDrawColor(color_white)
                surface.DrawTexturedRect(p.x - size/2, p.y - size/2, size, size)

                local text = 'Go here!'
                draw.SimpleTextOutlined(text, 'FS_24', p.x, p.y + size + 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
                draw.SimpleTextOutlined('#' .. point, 'FS_20', p.x, p.y + size + 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))

            cam.End2D()
        end
    end
end