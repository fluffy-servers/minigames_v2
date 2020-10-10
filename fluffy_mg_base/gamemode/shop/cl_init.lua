include("cl_inventory.lua")
include("cl_render.lua")
include("cl_images.lua")
include("vgui/ShopMirror.lua")
include("vgui/ShopItemPanel.lua")

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

-- Colors used in the inventory interface
-- Easy to reskin
SHOP.Color1 = Color(245, 246, 250)
SHOP.Color2 = Color(220, 221, 225)
SHOP.Color3 = Color(0, 168, 255)
SHOP.Color4 = Color(0, 151, 230)

-- Handle equips broadcast from the server
net.Receive("SHOP_BroadcastEquip", function()
    local ITEM = net.ReadTable()
    ITEM = SHOP:ParseVanillaItem(ITEM)
    local ply = net.ReadEntity()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local state = net.ReadBool()

    if ITEM.Type == "Hat" then
        -- See cl_render
        -- Passes off to cosmetic rendering engine
        if state then
            SHOP:EquipCosmetic(ITEM, ply)
        else
            SHOP:UnequipCosmetic(ITEM, ply)
        end
    elseif ITEM.Type == "Tracer" then
        if state then
            ply.TracerEffect = ITEM.Effect
        else
            ply.TracerEffect = nil
        end
    end
end)

-- Announce unboxes
net.Receive("SHOP_AnnounceUnbox", function()
    local name = net.ReadString()
    local prize = net.ReadString()
    local joiner = net.ReadString()
    local color = net.ReadTable()
    color = Color(color.r, color.g, color.b)
    chat.AddText(Color(241, 196, 15), name, Color(255, 255, 255), " ", joiner, " ", color, prize)
end)