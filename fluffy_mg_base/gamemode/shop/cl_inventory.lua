-- Positions are stored:
-- height, distance, angle
local default_cam = Vector(56, 24, 0)

local shop_categories = {
    {"Backwear", Vector(48, 24, 180), "back"},
    {"Glasses", Vector(64, 16, 0), "eyes"},
    {"Headgear", Vector(64, 24, 0), "face"},
    {"Crates", default_cam, "Crate"},
    {"Paint", default_cam, "Paint"},
    {"Tracers", default_cam, "Tracer"},
    {"Trails", default_cam, "Trail"},
}

SHOP.InventoryTable = SHOP.InventoryTable or {}
SHOP.InventoryEquipped = SHOP.InventoryEquipped or {}

function SHOP:VerifyInventory()
    net.Start("SHOP_NetworkInventory")
    net.WriteString(SHOP:HashTable(SHOP.InventoryTable))
    net.SendToServer()
end

net.Receive("SHOP_NetworkInventory", function()
    SHOP.InventoryTable = net.ReadTable()
    print("Updated local inventory with copy from server")

    if IsValid(SHOP.InventoryPanel) then
        SHOP:PopulateInventory()
    end
end)

net.Receive("SHOP_NetworkEquipped", function()
    SHOP.InventoryEquipped = net.ReadTable()
end)

function SHOP:PopulateInventory(category)
    if not IsValid(SHOP.InventoryPanel) then return end
    local display = SHOP.InventoryPanel.display
    display:Clear()
    if not SHOP.InventoryTable then return end

    for key, ITEM in pairs(SHOP.InventoryTable) do
        ITEM = SHOP:ParseVanillaItem(ITEM)

        if category then
            if category == "Equipped" then
                if not SHOP.InventoryEquipped[key] then continue end
            else
                if not ITEM.Type then continue end
                if (ITEM.Type ~= category) and (ITEM.Slot ~= category) then continue end
            end
        end

        local panel = display:Add("ShopItemPanel")
        panel.key = key
        panel.ITEM = ITEM
        panel:Ready()
    end
end

function SHOP:PopulateEquipped()
    if not IsValid(SHOP.InventoryPanel) then return end
    local display = SHOP.InventoryPanel.display
    display:Clear()
end

-- Populate the settings panel if appropiate to do so
function SHOP:PopulateSettings()
    if not IsValid(SHOP.InventoryPanel) then return end
    local display = SHOP.InventoryPanel.display
    display:Clear()
end

-- Main function for opening up the inventory
-- Large and painful :(
function SHOP:OpenInventory(display)
    if not IsValid(display) then return end
    SHOP:VerifyInventory()

    -- Create the mirror -> see vgui/ShopMirror.lua
    local mirror = vgui.Create("ShopMirror", display)
    mirror:SetWide(320)
    mirror:Dock(LEFT)
    mirror:SetCamera(default_cam.x, default_cam.y)
    mirror:SetAngle(default_cam.z)

    -- Scrollable category list
    local tabs = vgui.Create("DScrollPanel", display)
    tabs:SetWide(128)
    tabs:Dock(LEFT)
    tabs:GetVBar():SetVisible(false)

    function tabs:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, SHOP.Color3)
    end

    local button_height = 40

    -- Create buttons for all shop categories
    for k, cat in pairs(shop_categories) do
        local cat_button = vgui.Create("DButton", tabs)
        cat_button:SetSize(128, button_height)
        cat_button:SetFont("FS_B32")
        cat_button:SetText(cat[1])
        cat_button:SetTextColor(color_white)
        cat_button:Dock(TOP)

        function cat_button:Paint(w, h)
            local c = SHOP.Color3

            if self.Selected or self:IsHovered() then
                c = SHOP.Color4
            end

            draw.RoundedBox(0, 0, 0, w, h, c)
        end

        function cat_button:DoClick()
            -- Deselect & reset camera
            if self.Selected then
                self.Selected = false
                mirror:TransitionCamera(default_cam.x, default_cam.y, default_cam.z, 0.5)
                SHOP:PopulateInventory()
                SHOP.InventoryPanel.Category = nil

                return
            end

            -- Toggle selection state of all other buttons
            local buttons = tabs:GetChild(0):GetChildren()

            for _, v in pairs(buttons) do
                v.Selected = (v == self)
            end

            -- Apply camera transitions if relevant
            if cat[2] then
                mirror:TransitionCamera(cat[2].x, cat[2].y, cat[2].z, 0.5)
            end

            -- Repopulate
            SHOP.InventoryPanel.Category = cat[1]
            SHOP:PopulateInventory(cat[3])
        end
    end

    -- Create the equipped button
    local equipped_button = vgui.Create("DButton", tabs)
    equipped_button:SetSize(128, button_height)
    equipped_button:SetFont("FS_B32")
    equipped_button:SetTextColor(color_white)
    equipped_button:SetText("Equipped")
    equipped_button:Dock(TOP)

    function equipped_button:Paint(w, h)
        local c = SHOP.Color3

        if self.Selected or self:IsHovered() then
            c = SHOP.Color4
        end

        draw.RoundedBox(0, 0, 0, w, h, c)
    end

    function equipped_button:DoClick()
        mirror:TransitionCamera(default_cam.x, default_cam.y, default_cam.z, 0.5)

        if self.Selected then
            SHOP.InventoryPanel.Category = nil
            self.Selected = false
            SHOP:PopulateInventory()

            return
        end

        local buttons = tabs:GetChild(0):GetChildren()

        for k, v in pairs(buttons) do
            v.Selected = (v == self)
        end

        SHOP.InventoryPanel.Category = "Equipped"
        SHOP:PopulateInventory("Equipped")
    end

    -- Create the settings button
    local settings_button = vgui.Create("DButton", tabs)
    settings_button:SetSize(128, button_height)
    settings_button:SetFont("FS_B32")
    settings_button:SetTextColor(color_white)
    settings_button:SetText("Settings")
    settings_button:Dock(TOP)

    function settings_button:Paint(w, h)
        local c = SHOP.Color3

        if self.Selected or self:IsHovered() then
            c = SHOP.Color4
        end

        draw.RoundedBox(0, 0, 0, w, h, c)
    end

    function settings_button:DoClick()
        mirror:TransitionCamera(default_cam.x, default_cam.y, default_cam.z, 0.5)

        if self.Selected then
            SHOP.InventoryPanel.Category = nil
            self.Selected = false
            SHOP:PopulateInventory()

            return
        end

        local buttons = tabs:GetChild(0):GetChildren()

        for k, v in pairs(buttons) do
            v.Selected = (v == self)
        end

        SHOP.InventoryPanel.Category = "Settings"
        SHOP.PopulateSettings()
    end

    -- Create the scrollable inventory display
    local scroll = vgui.Create("DScrollPanel", display)
    scroll:Dock(FILL)
    local icons_display = vgui.Create("DIconLayout", scroll)
    icons_display:Dock(FILL)
    icons_display:SetSpaceX(8)
    icons_display:SetSpaceY(8)
    icons_display:DockMargin(8, 8, 8, 8)
    icons_display:DockPadding(8, 8, 8, 8)
    icons_display:Layout()
    SHOP.InventoryPanel = display
    SHOP.InventoryPanel.display = icons_display
    SHOP:PopulateInventory()
end

-- Open up the paint selection frame
function SHOP:OpenPaintBox(topaint)
    if not IsValid(SHOP.InventoryPanel) then return end
    SHOP.InventoryPanel:SetMouseInputEnabled(false)
    local frame = vgui.Create("DFrame")
    -- Scaling stuff
    local sw = math.floor(ScrW() / 256) - 1
    local margin = ScrW() - sw * 256
    local xx = sw * 256 - 32
    local yy = ScrH() - margin - 32
    frame:SetSize(xx, yy)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:SetTitle("")

    function frame:OnClose()
        SHOP.InventoryPanel:SetMouseInputEnabled(true)
    end

    function frame:Paint(w, h)
        DisableClipping(true)
        local bs = 4
        draw.RoundedBox(16, -bs, 4, w + (bs * 2), h + (bs * 2), SHOP.Color4)
        draw.RoundedBox(16, -bs, -bs, w + (bs * 2), h + (bs * 2), SHOP.Color3)
        DisableClipping(false)
        draw.RoundedBox(16, 0, 0, w, h, SHOP.Color1)
    end

    -- Create the scrollable inventory display
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetSize(xx, yy - 24)
    scroll:SetPos(0, 24)
    -- Sizing for the display
    local display = vgui.Create("DIconLayout", scroll)
    display:DockMargin(16, 0, 16, 0)
    display:Dock(FILL)
    display:SetPos(32, 0)
    display:SetSpaceX(8)
    display:SetSpaceY(8)
    display:SetBorder(0)
    display:Layout()

    -- Populate the list of paints
    for key, ITEM in pairs(SHOP.InventoryTable) do
        if ITEM.Type ~= "Paint" then continue end
        local panel = display:Add("ShopItemPanel")
        panel.key = key
        panel.ITEM = ITEM
        panel:Ready()

        panel.DoClick = function()
            -- Send to the esrver
            SHOP:RequestPaint(topaint, key)
            frame:Close()
        end
    end
end

-- Request functions for server interfacing
-- Golden rule: Never trust the client
-- Anything to do with item interaction goes through the server first
-- Send an equip request to the server
function SHOP:RequestEquip(key)
    net.Start("SHOP_RequestItemAction")
    net.WriteString("EQUIP")
    net.WriteInt(key, 16)
    net.SendToServer()
end

-- Send a paint request to the server
function SHOP:RequestPaint(itemkey, paintkey)
    net.Start("SHOP_RequestItemAction")
    net.WriteString("PAINT")
    net.WriteInt(itemkey, 16)
    net.WriteInt(paintkey, 16)
    net.SendToServer()
end

-- Send an unbox request to the server
function SHOP:RequestUnbox(key)
    net.Start("SHOP_RequestItemAction")
    net.WriteString("UNBOX")
    net.WriteInt(key, 16)
    net.SendToServer()
end

-- Send a delete request to the server
function SHOP:RequestDelete(key)
    net.Start("SHOP_RequestItemAction")
    net.WriteString("DELETE")
    net.WriteInt(key, 16)
    net.SendToServer()
end

-- Send a gift request to the server
function SHOP:RequestGift(key, giftee)
    net.Start("SHOP_RequestItemAction")
    net.WriteString("GIFT")
    net.WriteInt(key, 16)
    net.WriteEntity(giftee)
    net.SendToServer()
end

-- Network handler for changing inventory handling
-- This allows adding items, removing items, and modifying items
net.Receive("SHOP_InventoryChange", function()
    local mode = net.ReadString()

    if mode == "ADD" then
        -- An item has been added
        local ITEM = net.ReadTable()
        table.insert(SHOP.InventoryTable, ITEM)
    elseif mode == "REMOVE" then
        -- An item has been removed
        local key = net.ReadInt(16)
        table.remove(SHOP.InventoryTable, key)
    elseif mode == "MODIFY" then
        -- An item has been modified
        local key = net.ReadInt(16)
        local ITEM = net.ReadTable()
        SHOP.InventoryTable[key] = ITEM
    end

    -- Repopulate the display a short time after recieving the data
    timer.Simple(0.1, function()
        if IsValid(SHOP.InventoryPanel) then
            SHOP:PopulateInventory()
        end
    end)
end)