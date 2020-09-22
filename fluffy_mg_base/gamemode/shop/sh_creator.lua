--[[
    This file is not loaded as part of the gamemode, it is meant to be a seperate addon
    Kept here for git tracking purposes only!
]]
--
if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("ShopItemPanel.lua")
    util.AddNetworkString("ItemCreatorBroadcast")

    net.Receive("ItemCreatorBroadcast", function(len, ply)
        local item = net.ReadTable()
        PrintTable(item)
        net.Start("ItemCreatorBroadcast")
        net.WriteTable(item)
        net.WriteEntity(ply)
        net.Broadcast()
    end)

    return
end

-- Fonts used in the inventory interface
surface.CreateFont("FS_I16", {
    font = "Roboto",
    size = 16,
})

surface.CreateFont("FS_I24", {
    font = "Coolvetica",
    size = 24,
    weight = 800,
})

surface.CreateFont("FS_I48", {
    font = "Roboto",
    size = 48,
    weight = 800,
})

include("ShopItemPanel.lua")
SHOP = SHOP or {}
SHOP.CreatorEntity = nil
SHOP.CreatorFrame = nil
SHOP.CreatorData = {}
-- Colors used in the inventory interface
-- Easy to reskin
SHOP.Color1 = Color(245, 246, 250)
SHOP.Color2 = Color(220, 221, 225)
SHOP.Color3 = Color(0, 168, 255)
SHOP.Color4 = Color(0, 151, 230)

function SHOP:ParseVanillaItem(ITEM)
    return ITEM
end

local function GenerateCode(frame)
    if not SHOP.CreatorData["mdl"] then return end
    if not SHOP.CreatorData["attach"] then return end
    if not SHOP.CreatorData["vanillaid"] then return end

    -- Basic properties
    local code = "ITEM = {}\n"
    code = code .. "ITEM.VanillaID = '" .. SHOP.CreatorData["vanillaid"] .. "'\n"
    code = code .. "ITEM.Name = '" .. SHOP.CreatorData["name"] .. "'\n"
    code = code .. "ITEM.Model = '" .. SHOP.CreatorData["mdl"] .. "'\n"
    code = code .. "ITEM.Attachment = '" .. SHOP.CreatorData["attach"] .. "'\n"

    if SHOP.CreatorData["skin"] and SHOP.CreatorData["skin"] ~= 0 then
        code = code .. "ITEM.Skin = " .. SHOP.CreatorData["skin"] .. "\n"
    end

    if SHOP.CreatorData["bg1"] and SHOP.CreatorData["bg1"] ~= 0 then
        code = code .. "ITEM.Bodygroup = " .. SHOP.CreatorData["bg1"] .. "\n"
    end

    -- Position and angles modifier
    local modify = "ITEM.Modify = {\n"

    if SHOP.CreatorData["scale"] and SHOP.CreatorData["scale"] ~= 1 then
        modify = modify .. "	scale = " .. SHOP.CreatorData["scale"] .. ",\n"
    end

    if SHOP.CreatorData["x"] ~= 0 or SHOP.CreatorData["y"] ~= 0 or SHOP.CreatorData["z"] ~= 0 then
        modify = modify .. "	offset = Vector(" .. SHOP.CreatorData["x"] .. ", " .. SHOP.CreatorData["y"] .. ", " .. SHOP.CreatorData["z"] .. "),\n"
    end

    if SHOP.CreatorData["p"] ~= 0 or SHOP.CreatorData["yaw"] ~= 0 or SHOP.CreatorData["r"] ~= 0 then
        modify = modify .. "	angle = Angle(" .. SHOP.CreatorData["p"] .. ", " .. SHOP.CreatorData["yaw"] .. ", " .. SHOP.CreatorData["r"] .. "),\n"
    end

    code = code .. modify .. "}\n\n"

    -- Color and Material
    if SHOP.CreatorData["cmode"] == "Paintable" then
        code = code .. "ITEM.Paintable = true\n"
    end

    if SHOP.CreatorData["material"] and #SHOP.CreatorData["material"] > 1 then
        code = code .. "ITEM.MaterialOverride = '" .. SHOP.CreatorData["material"] .. "'\n"
    end

    -- Slot and Rarity
    code = code .. "ITEM.Slot = '" .. (SHOP.CreatorData["slot"] or "face") .. "'\n"
    code = code .. "ITEM.Rarity = " .. (SHOP.CreatorData["rarity"] or 1) .. "\n"
    code = code .. "\nSHOP:RegisterHat(ITEM)"
    SetClipboardText(code)
    -- Generate the PNG image
    local x, y = frame:LocalToScreen(86, 24)
    CreatorScreenshotRequested = true
    CreatorScreenshotX = x
    CreatorScreenshotY = y
end

hook.Add("PostRender", "GrabCreatorScreenshot", function()
    if not CreatorScreenshotRequested then return end
    if not CreatorScreenshotX then return end
    if not CreatorScreenshotY then return end
    CreatorScreenshotRequested = nil

    local data = render.Capture({
        format = "png",
        x = CreatorScreenshotX,
        y = CreatorScreenshotY,
        w = 128,
        h = 128,
        alpha = false,
    })

    file.CreateDir("creator")
    local f = file.Open("creator/" .. SHOP.CreatorData["vanillaid"] .. ".png", "wb", "DATA")
    f:Write(data)
    f:Close()
    chat.AddText("Took a picture of the item! Check data/creator/")
    CreatorScreenshotX = nil
    CreatorScreenshotY = nil
end)

local function DataToItem(data)
    local ITEM = {}
    ITEM.VanillaID = data["vanilla_id"] or "novanillaid"
    ITEM.Name = data["name"] or "Unnamed Item"
    ITEM.Model = data["mdl"]
    ITEM.Attachment = data["attach"]

    ITEM.Modify = {
        scale = data["scale"] or 1,
        offset = Vector(data["x"] or 0, data["y"] or 0, data["z"] or 0),
        angle = Angle(data["p"] or 0, data["yaw"] or 0, data["r"] or 0)
    }

    ITEM.Slot = data["slot"] or "face"
    ITEM.Rarity = data["rarity"] or 1
    ITEM.MaterialOverride = data["material"] or nil

    if SHOP.CreatorData["cmode"] == "Paintable (Test)" then
        ITEM.Paintable = true
        ITEM.Color = SHOP.CreatorData["color"]
    end

    return ITEM
end

local function UpdateInfo(frame)
    if SHOP.CreatorEntity then
        SHOP.CreatorEntity:Remove()
        SHOP.CreatorData = {}
    end

    local mdl = frame.Model:GetValue()
    if not mdl or #mdl < 1 then return end
    if not file.Exists(mdl, "GAME") then return end
    SHOP.CreatorData["mdl"] = mdl
    SHOP.CreatorData["attach"] = frame.Attachment:GetValue()
    SHOP.CreatorData["scale"] = math.Round(math.Clamp(frame.Scale:GetValue(), 0, 5), 2)
    SHOP.CreatorData["skin"] = math.Round(math.Clamp(frame.Skin:GetValue(), 0, 8), 0)
    SHOP.CreatorData["bg1"] = math.Round(math.Clamp(frame.BG1:GetValue(), 0, 8), 0)
    SHOP.CreatorData["x"] = math.Round(frame.XOffset:GetValue(), 1)
    SHOP.CreatorData["y"] = math.Round(frame.YOffset:GetValue(), 1)
    SHOP.CreatorData["z"] = math.Round(frame.ZOffset:GetValue(), 1)
    SHOP.CreatorData["p"] = math.Round(frame.Pitch:GetValue())
    SHOP.CreatorData["r"] = math.Round(frame.Roll:GetValue())
    SHOP.CreatorData["yaw"] = math.Round(frame.Yaw:GetValue())
    SHOP.CreatorData["camera_ang"] = frame.Camera:GetValue()
    SHOP.CreatorData["camera_dist"] = frame.Camera2:GetValue()
    SHOP.CreatorData["camera_height"] = frame.Camera3:GetValue()
    SHOP.CreatorData["vanillaid"] = frame.ID:GetValue()
    SHOP.CreatorData["name"] = frame.Name:GetValue()
    SHOP.CreatorData["slot"] = frame.Slot:GetValue()
    SHOP.CreatorData["rarity"] = math.Round(math.Clamp(frame.Rarity:GetValue(), 1, 5))
    SHOP.CreatorData["cmode"] = frame.CMode:GetValue()
    SHOP.CreatorData["color"] = frame.ColorMixer:GetColor()
    SHOP.CreatorData["material"] = frame.Material:GetValue()
    frame.icon.ITEM = DataToItem(SHOP.CreatorData)
    frame.icon:Ready()
    local ent = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
    ent:SetNoDraw(true)
    ent:SetSkin(SHOP.CreatorData["skin"])
    SHOP.CreatorEntity = ent
end

local function CameraTab(frame)
    local panel = vgui.Create("DPanel")

    function panel:Paint()
    end

    local Camera = vgui.Create("DNumSlider", panel)
    Camera:SetPos(24, 32)
    Camera:SetSize(252, 24)
    Camera:SetText("C Ang")
    Camera:SetMin(0)
    Camera:SetMax(360)
    Camera:SetDecimals(0)
    Camera:SetValue(SHOP.CreatorData["camera_ang"] or 0)

    Camera.OnValueChanged = function(self)
        SHOP.CreatorData["camera_ang"] = self:GetValue()
    end

    frame.Camera = Camera
    local Camera2 = vgui.Create("DNumSlider", panel)
    Camera2:SetPos(24, 64)
    Camera2:SetSize(252, 24)
    Camera2:SetText("C Dist")
    Camera2:SetMin(16)
    Camera2:SetMax(128)
    Camera2:SetDecimals(0)
    Camera2:SetValue(SHOP.CreatorData["camera_dist"] or 100)

    Camera2.OnValueChanged = function(self)
        SHOP.CreatorData["camera_dist"] = self:GetValue()
    end

    frame.Camera2 = Camera2
    local Camera3 = vgui.Create("DNumSlider", panel)
    Camera3:SetPos(24, 96)
    Camera3:SetSize(252, 24)
    Camera3:SetText("C Height")
    Camera3:SetMin(16)
    Camera3:SetMax(128)
    Camera3:SetDecimals(0)
    Camera3:SetValue(SHOP.CreatorData["camera_height"] or 64)

    Camera3.OnValueChanged = function(self)
        SHOP.CreatorData["camera_height"] = self:GetValue()
    end

    frame.Camera3 = Camera3
    local CameraReset = vgui.Create("DButton", panel)
    CameraReset:SetPos(100, 144)
    CameraReset:SetSize(100, 32)
    CameraReset:SetText("Reset")

    CameraReset.DoClick = function()
        Camera:SetValue(0)
        Camera2:SetValue(100)
        Camera3:SetValue(64)
    end

    return panel
end

local function BasicTab(frame)
    local panel = vgui.Create("DPanel")

    function panel:Paint()
    end

    local ModelLabel = vgui.Create("DLabel", panel)
    ModelLabel:SetPos(24, 32)
    ModelLabel:SetText("Model Path:")
    local Model = vgui.Create("DTextEntry", panel)
    Model:SetPos(24, 48)
    Model:SetSize(252, 24)
    Model:SetText(SHOP.CreatorData["mdl"] or "")

    Model.OnEnter = function(self)
        frame:UpdateInfo()
    end

    frame.Model = Model
    local AttachmentLabel = vgui.Create("DLabel", panel)
    AttachmentLabel:SetPos(24, 72)
    AttachmentLabel:SetText("Attachment:")
    local Attachments = vgui.Create("DComboBox", panel)
    Attachments:SetPos(24, 96)
    Attachments:SetSize(252, 24)
    Attachments:SetValue(SHOP.CreatorData["attach"] or "eyes")
    Attachments:AddChoice("eyes")
    Attachments:AddChoice("mouth")
    Attachments:AddChoice("chest")
    Attachments:AddChoice("forward")

    function Attachments:OnSelect(index, value)
        frame:UpdateInfo()
    end

    frame.Attachment = Attachments
    local ScaleSlider = vgui.Create("DNumSlider", panel)
    ScaleSlider:SetPos(24, 128)
    ScaleSlider:SetSize(252, 24)
    ScaleSlider:SetText("Scale")
    ScaleSlider:SetMin(0)
    ScaleSlider:SetMax(5)
    ScaleSlider:SetDecimals(2)
    ScaleSlider:SetValue(SHOP.CreatorData["scale"] or 1)

    function ScaleSlider:OnValueChanged()
        frame:UpdateInfo()
    end

    frame.Scale = ScaleSlider
    local XSlider = vgui.Create("DNumSlider", panel)
    XSlider:SetPos(24, 160)
    XSlider:SetSize(252, 24)
    XSlider:SetText("X Offset")
    XSlider:SetMin(-10)
    XSlider:SetMax(10)
    XSlider:SetDecimals(1)
    XSlider:SetValue(SHOP.CreatorData["x"] or 0)

    XSlider.OnValueChanged = function()
        frame:UpdateInfo()
    end

    frame.XOffset = XSlider
    local YSlider = vgui.Create("DNumSlider", panel)
    YSlider:SetPos(24, 192)
    YSlider:SetSize(252, 24)
    YSlider:SetText("Y Offset")
    YSlider:SetMin(-10)
    YSlider:SetMax(10)
    YSlider:SetDecimals(1)
    YSlider:SetValue(SHOP.CreatorData["y"] or 0)

    YSlider.OnValueChanged = function()
        frame:UpdateInfo()
    end

    frame.YOffset = YSlider
    local ZSlider = vgui.Create("DNumSlider", panel)
    ZSlider:SetPos(24, 224)
    ZSlider:SetSize(252, 24)
    ZSlider:SetText("Z Offset")
    ZSlider:SetMin(-20)
    ZSlider:SetMax(20)
    ZSlider:SetDecimals(1)
    ZSlider:SetValue(SHOP.CreatorData["z"] or 0)

    ZSlider.OnValueChanged = function()
        frame:UpdateInfo()
    end

    frame.ZOffset = ZSlider
    local Pitch = vgui.Create("DNumSlider", panel)
    Pitch:SetPos(24, 272)
    Pitch:SetSize(252, 24)
    Pitch:SetText("Pitch")
    Pitch:SetMin(-180)
    Pitch:SetMax(180)
    Pitch:SetDecimals(0)
    Pitch:SetValue(SHOP.CreatorData["p"] or 0)

    Pitch.OnValueChanged = function()
        frame:UpdateInfo()
    end

    frame.Pitch = Pitch
    local Roll = vgui.Create("DNumSlider", panel)
    Roll:SetPos(24, 304)
    Roll:SetSize(252, 24)
    Roll:SetText("Roll")
    Roll:SetMin(-180)
    Roll:SetMax(180)
    Roll:SetDecimals(0)
    Roll:SetValue(SHOP.CreatorData["r"] or 0)

    Roll.OnValueChanged = function()
        frame:UpdateInfo()
    end

    frame.Roll = Roll
    local Yaw = vgui.Create("DNumSlider", panel)
    Yaw:SetPos(24, 336)
    Yaw:SetSize(252, 24)
    Yaw:SetText("Yaw")
    Yaw:SetMin(-180)
    Yaw:SetMax(180)
    Yaw:SetDecimals(0)
    Yaw:SetValue(SHOP.CreatorData["yaw"] or 0)

    Yaw.OnValueChanged = function()
        frame:UpdateInfo()
    end

    frame.Yaw = Yaw
    local Skin = vgui.Create("DNumSlider", panel)
    Skin:SetPos(24, 400)
    Skin:SetSize(252, 24)
    Skin:SetText("Skin")
    Skin:SetMin(0)
    Skin:SetMax(8)
    Skin:SetDecimals(0)
    Skin:SetValue(SHOP.CreatorData["skin"] or 0)

    Skin.OnValueChanged = function()
        frame:UpdateInfo()
    end

    frame.Skin = Skin
    local BG1 = vgui.Create("DNumSlider", panel)
    BG1:SetPos(24, 432)
    BG1:SetSize(252, 24)
    BG1:SetText("Bodygroup1")
    BG1:SetMin(0)
    BG1:SetMax(8)
    BG1:SetDecimals(0)
    BG1:SetValue(SHOP.CreatorData["bg1"] or 0)

    BG1.OnValueChanged = function()
        frame:UpdateInfo()
    end

    frame.BG1 = BG1

    return panel
end

local function PropertiesTab(frame)
    local panel = vgui.Create("DPanel")

    function panel:Paint()
    end

    local IDLabel = vgui.Create("DLabel", panel)
    IDLabel:SetPos(24, 24)
    IDLabel:SetText("Vanilla ID:")
    local ID = vgui.Create("DTextEntry", panel)
    ID:SetPos(24, 48)
    ID:SetSize(252, 24)
    ID:SetText(SHOP.CreatorData["vanillaid"] or "vanillaid")

    ID.OnEnter = function(self)
        frame:UpdateInfo()
    end

    frame.ID = ID
    local NameLabel = vgui.Create("DLabel", panel)
    NameLabel:SetPos(24, 80)
    NameLabel:SetText("Name:")
    local Name = vgui.Create("DTextEntry", panel)
    Name:SetPos(24, 104)
    Name:SetSize(252, 24)
    Name:SetText(SHOP.CreatorData["name"] or "?")

    Name.OnEnter = function(self)
        frame:UpdateInfo()
    end

    frame.Name = Name
    local SlotLabel = vgui.Create("DLabel", panel)
    SlotLabel:SetPos(24, 128)
    SlotLabel:SetText("Slot:")
    local Slots = vgui.Create("DComboBox", panel)
    Slots:SetPos(24, 152)
    Slots:SetSize(252, 24)
    Slots:SetValue(SHOP.CreatorData["slot"] or "face")
    Slots:AddChoice("back")
    Slots:AddChoice("body")
    Slots:AddChoice("face")
    Slots:AddChoice("hat")
    Slots:AddChoice("head")

    function Slots:OnSelect(index, value)
        frame:UpdateInfo()
    end

    frame.Slot = Slots
    local Rarity = vgui.Create("DNumSlider", panel)
    Rarity:SetPos(24, 196)
    Rarity:SetSize(252, 24)
    Rarity:SetText("Rarity")
    Rarity:SetMin(1)
    Rarity:SetMax(5)
    Rarity:SetDecimals(0)
    Rarity:SetValue(SHOP.CreatorData["rarity"] or 0)

    Rarity.OnValueChanged = function()
        frame:UpdateInfo()
    end

    frame.Rarity = Rarity
    local Generate = vgui.Create("DButton", panel)
    Generate:SetPos(100, 256)
    Generate:SetSize(100, 32)
    Generate:SetText("Generate Code")

    Generate.DoClick = function()
        frame:UpdateInfo()
        frame:GenerateCode()
        chat.AddText("Item code copied to clipboard!")
    end

    local Broadcast = vgui.Create("DButton", panel)
    Broadcast:SetPos(100, 296)
    Broadcast:SetSize(100, 32)
    Broadcast:SetText("Broadcast")

    Broadcast.DoClick = function()
        frame:UpdateInfo()
        frame:Broadcast()
        chat.AddText("Other players can now see this model!")
    end

    local Reset = vgui.Create("DButton", panel)
    Reset:SetPos(100, 336)
    Reset:SetSize(100, 32)
    Reset:SetText("Reset")

    Reset.DoClick = function()
        if SHOP.CreatorEntity then
            -- Store camera settings
            local c1 = SHOP.CreatorData["camera_ang"]
            local c2 = SHOP.CreatorData["camera_dist"]
            local c3 = SHOP.CreatorData["camera_height"]
            SHOP.CreatorEntity:Remove()
            SHOP.CreatorEntity = nil
            SHOP.CreatorData = {}
            SHOP.CreatorData["camera_ang"] = c1
            SHOP.CreatorData["camera_dist"] = c2
            SHOP.CreatorData["camera_height"] = c3
            frame:Close()
        end
    end

    return panel
end

local function MaterialTab(frame)
    local panel = vgui.Create("DPanel")

    function panel:Paint()
    end

    local CModeLabel = vgui.Create("DLabel", panel)
    CModeLabel:SetPos(24, 16)
    CModeLabel:SetText("Color Mode:")

    local CModes = vgui.Create("DComboBox", panel)
    CModes:SetPos(24, 32)
    CModes:SetSize(252, 24)
    CModes:SetValue(SHOP.CreatorData["cmode"] or "No Color")
    CModes:AddChoice("No Color")
    CModes:AddChoice("Paintable")

    --CModes:AddChoice("Force Color (WIP)")
    function CModes:OnSelect(index, value)
        frame:UpdateInfo()
    end

    frame.CMode = CModes
    local Mixer = vgui.Create("DColorMixer", panel)
    Mixer:SetPos(24, 64)
    Mixer:SetSize(236, 128)
    Mixer:SetColor(SHOP.CreatorData["color"] or color_white)
    Mixer:SetPalette(false)

    function Mixer:ValueChanged()
        frame:UpdateInfo()
    end

    frame.ColorMixer = Mixer

    local MaterialLabel = vgui.Create("DLabel", panel)
    MaterialLabel:SetPos(24, 224)
    MaterialLabel:SetText("Material:")

    local MaterialPicker = vgui.Create("DTextEntry", panel)
    MaterialPicker:SetPos(24, 256)
    MaterialPicker:SetSize(252, 24)
    MaterialPicker:SetText(SHOP.CreatorData["material"] or "")

    function MaterialPicker:OnEnter()
        frame:UpdateInfo()
    end

    frame.Material = MaterialPicker

    return panel
end

function SHOP.OpenCreatorPanel()
    if IsValid(SHOP.CreatorFrame) then return end
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 720)
    frame:SetPos(ScrW() - 320, 20)
    frame:SetTitle("Item Creator")
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()

    frame.OnClose = function()
        SHOP.CreatorFrame = nil
    end

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(47, 54, 64))
    end

    function frame:UpdateInfo(self)
        UpdateInfo(self)
    end

    function frame:Broadcast(self)
        if not SHOP.CreatorData then return end
        PrintTable(SHOP.CreatorData)
        net.Start("ItemCreatorBroadcast")
        net.WriteTable(SHOP.CreatorData)
        net.SendToServer()
    end

    function frame:GenerateCode(self)
        GenerateCode(self)
    end

    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:DockMargin(0, 128, 0, 0)
    sheet:Dock(FILL)
    sheet:SetPadding(0)
    local icon = vgui.Create("ShopItemPanel", frame)
    icon:SetPos(86, 24)
    icon.ITEM = DataToItem(SHOP.CreatorData)
    icon:Ready()
    frame.icon = icon
    frame.tabBasic = BasicTab(frame)
    frame.tabCamera = CameraTab(frame)
    frame.tabMaterial = MaterialTab(frame)
    frame.tabProperties = PropertiesTab(frame)
    sheet:AddSheet("Basic", frame.tabBasic, "icon16/wrench.png")
    sheet:AddSheet("Camera", frame.tabCamera, "icon16/camera.png")
    sheet:AddSheet("Material", frame.tabMaterial, "icon16/color_wheel.png")
    sheet:AddSheet("Properties", frame.tabProperties, "icon16/tag_blue_edit.png")
    SHOP.CreatorFrame = frame
end

concommand.Add("minigames_item_creator", function()
    SHOP.OpenCreatorPanel()
end)

net.Receive("ItemCreatorBroadcast", function()
    local ITEM = net.ReadTable()
    local ply = net.ReadEntity()
    if ply == LocalPlayer() then return end

    if ply.CreatorItem and IsValid(ply.CreatorItem.entity) then
        SafeRemoveEntity(ply.CreatorItem.entity)
    end

    ply.CreatorItem = ITEM
end)

-- Handles drawing of multiplayer items
hook.Add("PostPlayerDraw", "FS_ItemBroadcast", function(ply)
    if ply == LocalPlayer() then return end
    if not ply.CreatorItem then return end

    if not ply.CreatorItem.entity then
        local mdl = ply.CreatorItem["mdl"]
        local ent = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
        ent:SetNoDraw(true)
        ply.CreatorItem.entity = ent
    end

    local ITEM = ply.CreatorItem
    local ent = ply.CreatorItem.entity
    if not ITEM["attach"] then return end
    local attach_id = ply:LookupAttachment(ITEM["attach"])
    if not attach_id then return end
    local attach = ply:GetAttachment(attach_id)
    if not attach then return end
    local pos = attach.Pos
    local ang = attach.Ang
    ent:SetModelScale(ITEM["scale"])
    pos = pos + (ang:Forward() * ITEM["x"]) + (ang:Right() * ITEM["y"]) + (ang:Up() * ITEM["z"])
    ang:RotateAroundAxis(ang:Right(), ITEM["p"])
    ang:RotateAroundAxis(ang:Forward(), ITEM["r"])
    ang:RotateAroundAxis(ang:Up(), ITEM["yaw"])

    if ITEM["material"] then
        ent:SetMaterial(ITEM["material"])
    end

    if ITEM["cmode"] == "Paintable" then
        local c = ITEM["color"]
        render.SetColorModulation(c.r / 255, c.g / 255, c.b / 255)
    end

    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:DrawModel()

    if ITEM["cmode"] == "Paintable" then
        render.SetColorModulation(1, 1, 1)
    end
end)

-- Handles drawing of own items
hook.Add("PostPlayerDraw", "FS_ItemCreator", function(ply)
    if ply ~= LocalPlayer() then return end
    if not SHOP.CreatorEntity then return end
    if not SHOP.CreatorData["attach"] then return end
    local attach_id = ply:LookupAttachment(SHOP.CreatorData["attach"])
    if not attach_id then return end
    local attach = ply:GetAttachment(attach_id)
    if not attach then return end
    local pos = attach.Pos
    local ang = attach.Ang
    SHOP.CreatorEntity:SetModelScale(SHOP.CreatorData["scale"])
    pos = pos + (ang:Forward() * SHOP.CreatorData["x"]) + (ang:Right() * SHOP.CreatorData["y"]) + (ang:Up() * SHOP.CreatorData["z"])
    ang:RotateAroundAxis(ang:Right(), SHOP.CreatorData["p"])
    ang:RotateAroundAxis(ang:Forward(), SHOP.CreatorData["r"])
    ang:RotateAroundAxis(ang:Up(), SHOP.CreatorData["yaw"])

    if SHOP.CreatorData["material"] then
        SHOP.CreatorEntity:SetMaterial(SHOP.CreatorData["material"])
    end

    if SHOP.CreatorData["cmode"] == "Paintable" then
        local c = SHOP.CreatorData["color"]
        render.SetColorModulation(c.r / 255, c.g / 255, c.b / 255)
    end

    SHOP.CreatorEntity:SetPos(pos)
    SHOP.CreatorEntity:SetAngles(ang)
    SHOP.CreatorEntity:DrawModel()

    if SHOP.CreatorData["cmode"] == "Paintable" then
        render.SetColorModulation(1, 1, 1)
    end
end)

-- Handles the camera when the player is inside the creation frame
hook.Add("CalcView", "CreatorCamera", function(ply, origin, angles, fov)
    if not IsValid(SHOP.CreatorFrame) then return end
    local targetpos = ply:GetPos() + Vector(0, 0, SHOP.CreatorData["camera_height"] or 64)
    local distance = SHOP.CreatorData["camera_dist"] or 100
    local goalangles = Angle(0, (SHOP.CreatorData["camera_ang"] or 0) - 180)
    local goalpos = targetpos + (goalangles:Forward() * -distance)
    -- Smoothly transition the view
    local view = {}
    view.origin = goalpos --origin + (goalpos - origin) * smooth
    view.angles = goalangles --angles + (goalangles - angles) * smooth
    view.drawviewer = true

    return view
end)