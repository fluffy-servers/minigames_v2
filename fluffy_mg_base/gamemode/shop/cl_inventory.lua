-- Positions are stored:
-- height, distance, angle

local default_cam = Vector(56, 24, 0)
local shop_categories = {
    {'Backwear', Vector(48, 24, 180), 'back'},
    {'Glasses', Vector(64, 16, 0), 'eyes'},
    {'Headgear', Vector(64, 24, 0), 'hat'},
    
    {'Crates', default_cam, 'crate'},
    {'Paint', default_cam, 'paint'},
    {'Tracers', default_cam, 'tracer'},
    {'Trails', default_cam, 'trail'},
}

local test_inventory = {
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol', Type='crate', Rarity=3},
    {Name = 'lol trail', Type='trail', Rarity=4, Material='trails/lol'},
    {Name = 'lol trail g', Type='trail', Rarity=2, Material='trails/lol', Color=Color(0, 255, 100)},
    {Name = 'i\'m already', Type='tracer'},
}

function SHOP.PopulateInventory(category)
    if not IsValid(SHOP.InventoryPanel) then return end
    local display = SHOP.InventoryPanel.display
    display:Clear()
    
    for key,ITEM in pairs(test_inventory) do
        print(ITEM.Name)
        if category then
            if not ITEM.Type then continue end
            if ITEM.Type != category then continue end
        end
        
        local panel = display:Add('ShopItemPanel')
        panel.key = key
        panel.ITEM = ITEM
        panel:Ready()
    end
end

function SHOP.OpenInventory()
    if IsValid(SHOP.InventoryPanel) then return end
    if not SHOP.InventoryTable then
        -- Request the table from the server
    end
    
    -- Scaling stuff
    local sw = math.floor(ScrW()/256) - 1
    local margin = ScrW() - sw*256
    local xx = sw*256
    local yy = ScrH() - margin
    
    -- Create the frame
    local frame = vgui.Create('DFrame')
    frame:SetSize(xx, yy)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:SetTitle('')
    
    function frame:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(53, 59, 72))
    end
    
    -- Create the mirror -> see vgui/ShopMirror.lua
    local mirror = vgui.Create('ShopMirror', frame)
    mirror:SetPos(0, 0)
    mirror:SetCamera(default_cam.x, default_cam.y)
    mirror:SetAngle(default_cam.z)
    mirror:SetSize(320, yy)
    
    -- Scrollable category list
    local tabs = vgui.Create('DScrollPanel', frame)
    tabs:SetSize(128, yy)
    tabs:SetPos(320, 0)
    tabs:GetVBar():SetVisible(false)
    function tabs:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 54, 64))
    end
    
    -- Create buttons for all shop categories
    for k, cat in pairs(shop_categories) do
        local cat_button = vgui.Create('DButton', tabs)
        cat_button:SetSize(128, 48)
        cat_button:SetFont('FS_B32')
        cat_button:SetText(cat[1])
        cat_button:SetTextColor(color_white)
        cat_button:Dock(TOP)
        function cat_button:Paint(w, h)
            local c = Color(47, 54, 64)
            if self.Selected or self:IsHovered() then
                c = Color(37, 44, 54)
            end
            draw.RoundedBox(0, 0, 0, w, h, c)
        end
        
        function cat_button:DoClick()
            -- Deselect & reset camera
            if self.Selected then
                self.Selected = false
                mirror:TransitionCamera(default_cam.x, default_cam.y, default_cam.z, 0.5)
                SHOP.PopulateInventory()
                SHOP.InventoryPanel.Category = nil
                return
            end
            
            -- Toggle selection state of all other buttons
            local buttons = tabs:GetChild(0):GetChildren()
            for k,v in pairs(buttons) do
                v.Selected = (v == self)
            end
            
            -- Apply camera transitions if relevant
            if cat[2] then
                mirror:TransitionCamera(cat[2].x, cat[2].y, cat[2].z, 0.5)
            end
            
            -- Repopulate
            SHOP.InventoryPanel.Category = cat[1]
            SHOP.PopulateInventory(cat[3])
        end
    end
    
    -- Create the scrollable inventory display
    local scroll = vgui.Create('DScrollPanel', frame)
    scroll:SetSize(xx - 448, yy - 24)
    scroll:SetPos(448, 24)
    
    -- Sizing for the display
    local test = (xx - 448) / (128+8)
    test = math.floor(test)*(128+8)-8
    local border = (xx-448-test)/2
    
    local display = vgui.Create('DIconLayout', scroll)
    display:SetSize(xx - 448 - border*2, yy)
    display:SetPos(border, 0)
    display:SetSpaceX(8)
    display:SetSpaceY(8)
    display:SetBorder(0)
    display:Layout()
    
    SHOP.InventoryPanel = frame
    SHOP.InventoryPanel.display = display
    SHOP.PopulateInventory()
end

-- Concommand to open the shop
concommand.Add('minigames_shop', function()
    SHOP.OpenInventory()
end)

-- Request functions for server interfacing
function SHOP.RequestUnbox()

end

function SHOP.RequestEquip()

end