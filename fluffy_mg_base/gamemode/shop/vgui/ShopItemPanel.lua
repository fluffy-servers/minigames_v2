local icons = {}
icons["paintable"] = Material("icon16/palette.png")
icons["equipped"] = Material("icon16/tick.png")
icons["locked"] = Material("icon16/lock.png")
local rarity_colors = {}
rarity_colors[1] = Color(52, 152, 219)
rarity_colors[2] = Color(0, 119, 181)
rarity_colors[3] = Color(150, 70, 165)
rarity_colors[4] = Color(200, 65, 50)
rarity_colors[5] = Color(220, 150, 0)
local rarity_names = {}
rarity_names[1] = "Common"
rarity_names[2] = "Uncommon"
rarity_names[3] = "Rare"
rarity_names[4] = "Epic"
rarity_names[5] = "Legendary"
local camera_changes = {}

camera_changes["back"] = function(p)
    p:SetCamPos(Vector(-100, 0, -22))
    p:SetLookAt(Vector(-50, 0, -22))
    p:SetFOV(35)
end

camera_changes["hat"] = function(p)
    p:SetCamPos(Vector(0, 15, -5))
    p:SetLookAt(Vector(-50, 0, -5))
    p:SetFOV(25)
end

camera_changes["face"] = function(p)
    p:SetCamPos(Vector(0, 0, -12))
    p:SetLookAt(Vector(-50, 0, -12))
    p:SetFOV(25)
end

camera_changes["head"] = function(p)
    p:SetCamPos(Vector(0, 15, -12))
    p:SetLookAt(Vector(-50, 0, -12))
    p:SetFOV(25)
end

camera_changes["body"] = function(p)
    p:SetCamPos(Vector(0, 0, -32))
    p:SetLookAt(Vector(-50, 0, -32))
    p:SetFOV(40)
end

local PANEL = {}

function PANEL:Init()
    self:SetSize(128, 128)
    self:SetText("")
end

-- Branch handler -> pass off to the below functions for icon generation
function PANEL:Ready()
    local ITEM = self.ITEM
    if not ITEM then return end -- uh oh

    if IsValid(self.icon) then
        self.icon:Remove()
    end

    -- Parse the item and store
    ITEM = SHOP:ParseVanillaItem(ITEM)
    self.ITEM = ITEM

    -- Decide what function to use
    if ITEM.Type == "Crate" then
        self:CrateIcon(ITEM)
    elseif ITEM.Type == "Paint" then
        self:PaintIcon(ITEM)
    elseif ITEM.Type == "Tracer" then
        self:TracerIcon(ITEM)
    elseif ITEM.Type == "Trail" then
        self:TrailIcon(ITEM)
    else
        self:WearableIcon(ITEM)
    end

    -- Pass click handlers up the chain
    if IsValid(self.icon) then
        function self.icon:DoClick()
            self:GetParent():DoClick()
        end
    end
end

function PANEL:CrateIcon(ITEM)
    self.icon = vgui.Create("DModelPanel", self)
    self.icon:Dock(FILL)
    self.icon:SetModel("models/props_junk/cardboard_box003a.mdl")
    self.icon.Entity:SetAngles(Angle(0, 90, 0))
    self.icon:SetCamPos(Vector(0, 48, 20))
    self.icon:SetFOV(60)
    self.icon:SetLookAt(Vector(0, 0, -10))

    function self.icon:LayoutEntity()
        return
    end
end

function PANEL:PaintIcon(ITEM)
    self.icon = vgui.Create("DModelPanel", self)
    self.icon:Dock(FILL)
    self.icon:SetModel("models/paintcan/paint_can.mdl")
    self.icon:SetCamPos(Vector(0, 32, 24))
    self.icon:SetFOV(60)
    self.icon:SetLookAt(Vector(0, 0, -10))
    self.icon:SetColor(ITEM.Color or color_white)

    function self.icon:LayoutEntity()
        return
    end
end

function PANEL:TracerIcon(ITEM)
    self.icon = vgui.Create("DModelPanel", self)
    self.icon:Dock(FILL)
    self.icon:SetModel("models/weapons/c_357.mdl")
    self.icon.Entity:SetPos(Vector(-22, 0, -5))
    self.icon.Entity:SetAngles(Angle(0, 0, 0))
    self.icon:SetCamPos(Vector(0, 40, 0))
    self.icon:SetFOV(20)
    self.icon:SetLookAt(Vector(0, 0, -10))

    function self.icon:LayoutEntity()
        return
    end
end

function PANEL:TrailIcon(ITEM)
    local off = 24
    self.icon = vgui.Create("DButton", self)
    self.icon:Dock(FILL)
    self.icon:SetText("")
    self.icon.Material = Material(ITEM.Material)
    self.icon.uv = 0

    function self.icon:Paint(w, h)
        -- Set color if paintable
        if ITEM.Color then
            surface.SetDrawColor(ITEM.Color)
        else
            surface.SetDrawColor(color_white)
        end

        -- Draw the trail
        surface.SetMaterial(self.Material)
        surface.DrawTexturedRectUV(off / 2, 0, w - off, h - off, 0, self.uv, 1, self.uv + 1)

        -- Scroll the trail if in the right category
        if IsValid(SHOP.InventoryPanel) and not self:IsHovered() and SHOP.InventoryPanel.Category == "Trails" then
            self.uv = self.uv + FrameTime() * 0.5

            if self.uv > 1 then
                self.uv = 0
            end
        end
    end
end

function PANEL:WearableRender(ITEM, ent, CSModel)
    -- Search for the attachment and calculate the position & angles
    if not ITEM.Attachment then return end
    local attach_id = ent:LookupAttachment(ITEM.Attachment)
    if not attach_id then return end
    local attach = ent:GetAttachment(attach_id)
    if not attach then return end
    local pos = attach.Pos
    local ang = attach.Ang
    if not pos or not ang then return end

    -- Apply any modifications
    if ITEM.Modify then
        -- Scale modification
        if ITEM.Modify.scale then
            CSModel:SetModelScale(ITEM.Modify.scale, 0)
        end

        -- Offset modification
        if ITEM.Modify.offset then
            local offset = ITEM.Modify.offset
            pos = pos + (ang:Forward() * offset.x) + (ang:Right() * offset.y) + (ang:Up() * offset.z)
        end

        -- Rotation modification
        if ITEM.Modify.angle then
            local rotation = ITEM.Modify.angle
            ang:RotateAroundAxis(ang:Right(), rotation.p)
            ang:RotateAroundAxis(ang:Forward(), rotation.r)
            ang:RotateAroundAxis(ang:Up(), rotation.y)
        end
    end

    -- Apply custom colours
    if ITEM.Paintable and ITEM.Color then
        render.SetColorModulation(ITEM.Color.r / 255, ITEM.Color.g / 255, ITEM.Color.b / 255)
    end

    -- Apply override material
    if ITEM.MaterialOverride then
        CSModel:SetMaterial(ITEM.MaterialOverride)
    end

    -- Draw the model!
    CSModel:SetPos(pos)
    CSModel:SetAngles(ang)
    CSModel:DrawModel()

    -- Reset paintable colors
    if ITEM.Paintable and ITEM.Color then
        render.SetColorModulation(1, 1, 1)
    end
end

function PANEL:WearableIcon(ITEM)
    self.icon = vgui.Create("DModelPanel", self)
    self.icon:Dock(FILL)
    local model = LocalPlayer():GetModel()

    if not string.find(model, "models/player/") then
        model = "models/player/Group01/male_07.mdl"
    end

    self.icon:SetModel(model)
    self.icon:SetAnimated(false)
    self.icon.Entity:SetPlaybackRate(0)

    if camera_changes[ITEM.Slot] then
        camera_changes[ITEM.Slot](self.icon)
    else
        self.icon:SetCamPos(Vector(0, 0, -12))
        self.icon:SetLookAt(Vector(-50, 0, -12))
        self.icon:SetFOV(26)
    end

    if ITEM.IconShift then
        self.icon:SetCamPos(self.icon:GetCamPos() + ITEM.IconShift)
        self.icon:SetLookAt(self.icon:GetLookAt() + ITEM.IconShift)
    end

    self.icon.panel = self
    if not IsValid(self.icon.Entity) then return end
    self.icon.Entity:SetPos(Vector(-50, 0, -75))

    function self.icon:LayoutEntity()
        return
    end

    function self.icon.Entity:GetPlayerColor()
        return LocalPlayer():GetPlayerColor()
    end

    if not ITEM.Model then return end
    self.icon.CSModel = ClientsideModel(ITEM.Model, RENDERGROUP_OPAQUE)

    function self.icon:OnRemove()
        SafeRemoveEntity(self.CSModel)
    end

    function self.icon:PostDrawModel(ent)
        self.panel:WearableRender(self.panel.ITEM, ent, self.CSModel)
    end
end

-- Clicking handler to open up the menu
function PANEL:DoClick()
    local ITEM = self.ITEM
    if not ITEM then return end
    local Menu = DermaMenu()

    local rarity_color = rarity_colors[ITEM.Rarity or 1]
    local rarity_box = Menu:AddOption(rarity_names[ITEM.Rarity or 1])
    rarity_box:SetTextColor(color_white)
    rarity_box:SetIcon("icon16/star.png")

    function rarity_box:Paint(w, h) end
    function rarity_box:PaintOver(w, h) end

    function Menu:Paint(w, h)
        derma.SkinHook("Paint", "Menu", self, w, h)
        draw.RoundedBox(0, 1, 1, w - 2, 21, rarity_color)
    end

    -- No other options if this is a 0 key item
    -- Used for imaginary item displays e.g creator, unboxing
    if self.key < 0 then
        Menu:Open()

        return
    end

    if ITEM.Type == "Crate" then
        -- Add unbox button
        Menu:AddOption("Unbox", function()
            SHOP:RequestUnbox(self.key)
        end):SetIcon("icon16/box.png")
    --elseif ITEM.Type == "Paint" then
    else
        -- Add equip button
        local text = "Equip"

        if SHOP.InventoryEquipped and SHOP.InventoryEquipped[self.key] then
            text = "Unequip"
        end

        Menu:AddOption(text, function()
            SHOP:RequestEquip(self.key)
        end):SetIcon("icon16/wrench.png")
    end

    -- Add paint button
    if ITEM.Paintable then
        Menu:AddOption("Select Paint", function()
            SHOP:OpenPaintBox(self.key)
        end):SetIcon("icon16/palette.png")
    end

    -- Add remove / gift buttons
    -- If the item is locked, the player cannot get rid of it
    if not ITEM.Locked then
        Menu:AddOption("Delete", function()
            SHOP:RequestDelete(self.key)
        end):SetIcon("icon16/delete.png")

        -- Generate the gifting submenu
        if #player.GetHumans() > 1 then
            local submenu, parent = Menu:AddSubMenu("Gift to...")
            parent:SetIcon("icon16/package_go.png")

            for k, v in pairs(player.GetHumans()) do
                if not IsValid(v) then continue end
                if v == LocalPlayer() then continue end

                submenu:AddOption(v:Nick(), function()
                    SHOP:RequestGift(self.key, v)
                end)
            end
        end
    end

    Menu:Open()
end

-- Dark background
function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, SHOP.Color2)
end

-- Name bar & relevant icons
function PANEL:PaintOver(w, h)
    local ITEM = self.ITEM
    if not ITEM then return end
    -- Draw the name bar
    local color = rarity_colors[ITEM.Rarity or 1]
    draw.RoundedBoxEx(8, 0, h - 24, w, 24, color, false, false, true, true)
    draw.SimpleText(ITEM.Name or "?", "FS_I16", w / 2, h - (24 / 2) - 1, Color(236, 240, 241), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    -- Draw any icons
    local yy = 2
    surface.SetDrawColor(Color(255, 255, 255))

    if ITEM.Locked then
        surface.SetMaterial(icons["locked"])
        surface.DrawTexturedRect(w - 16, yy, 16, 16)
        yy = yy + 16
    end

    -- Draw tick mark if equipped
    if SHOP.InventoryEquipped and SHOP.InventoryEquipped[self.key] then
        surface.SetMaterial(icons["equipped"])
        surface.DrawTexturedRect(w - 16, yy, 16, 16)
        yy = yy + 16
    end

    -- Draw easel or color if paintable
    if ITEM.Paintable then
        if ITEM.Color then
            surface.SetDrawColor(ITEM.Color)
            surface.DrawRect(w - 18, yy, 16, 16)
            yy = yy + 16
        else
            surface.SetMaterial(icons["paintable"])
            surface.DrawTexturedRect(w - 18, yy, 16, 16)
            yy = yy + 16
        end
    end
end

vgui.Register("ShopItemPanel", PANEL, "DButton")