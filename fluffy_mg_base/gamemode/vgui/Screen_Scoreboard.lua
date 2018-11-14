local PANEL = {}

function PANEL:Init()
    local w = self:GetParent():GetWide()
    local h = self:GetParent():GetTall()
    
    self:SetSize(w/3, h)
end

function PANEL:Paint(w, h)

end
vgui.Register("Screen_Scoreboard", PANEL, "Panel")