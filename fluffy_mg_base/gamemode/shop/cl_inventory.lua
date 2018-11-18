function SHOP.OpenInventory()
    if IsValid(SHOP.InventoryPanel) then return end
    if not SHOP.InventoryTable then
        -- Request the table from the server
    end
    
    local sw = math.floor(ScrW()/256) - 1
    local margin = ScrW() - sw*256
    
    local xx = sw*256
    local yy = ScrH() - margin
    
    local frame = vgui.Create('DFrame')
    frame:SetSize(xx, yy)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:SetTitle('')
    
    function frame:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(53, 59, 72))
    end
    
    local mirror = vgui.Create('ShopMirror', frame)
    mirror:SetPos(0, 0)
    mirror:SetCamera(24, 24)
    mirror:SetAngle(180)
    mirror:TransitionCamera(60, 24, 0, 1)
    mirror:SetSize(320, yy)
    mirror:SetModel( LocalPlayer():GetModel() )
    
    local tabs = vgui.Create('DScrollPanel', frame)
    tabs:SetSize(128, yy)
    tabs:SetPos(320, 0)
    tabs:GetVBar():SetVisible(false)
    function tabs:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 54, 64))
    end
    
    local scroll = vgui.Create('DScrollPanel', frame)
    scroll:SetSize(xx - 448, yy)
    scroll:SetPos(448, 24)
    
    local display = vgui.Create('DIconLayout', scroll)
    display:Dock(FILL)
    display:SetSpaceX(4)
    display:SetSpaceY(4)
end