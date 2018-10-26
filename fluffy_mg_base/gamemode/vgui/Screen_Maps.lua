local PANEL = {}

function PANEL:Init()
    local w = self:GetParent():GetWide()
    local h = self:GetParent():GetTall()
    
    self:SetSize(w/3, h)
    
    w = w/3
    
    local n = 3
    local margin = 32
    local padding = 24
    local panel_w = (w - margin*2 - (n-1)*padding ) / n
    local panel_h = (h/2) - 32
    
    for j = 1,2 do
        local yy = 16
        if j == 2 then yy = h - panel_w - 16 end
        
        for i = 1,3 do
            local map = vgui.Create("MapVotePanel", self)
            map:SetSize(panel_w, panel_h)
            map:SetPos(margin + (panel_w+padding)*(i-1), yy)
            map:AddChildren()
            map:SetIndex(1)
        end
    end
end

function PANEL:Paint(w, h)

end

vgui.Register("Screen_Maps", PANEL, "Panel")