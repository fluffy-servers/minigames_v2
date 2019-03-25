include('cl_inventory.lua')
include('cl_render.lua')
include('vgui/ShopMirror.lua')
include('vgui/ShopItemPanel.lua')

SHOP.RarityColors = {}
SHOP.RarityColors[1] = Color(52, 152, 219)
SHOP.RarityColors[2] = Color(0, 119, 181)
SHOP.RarityColors[3] = Color(150, 70, 165)
SHOP.RarityColors[4] = Color(200, 65, 50)
SHOP.RarityColors[5] = Color(220, 150, 0)

SHOP.RarityNames = {}
SHOP.RarityNames[1] = "Common"
SHOP.RarityNames[2] = "Uncommon"
SHOP.RarityNames[3] = "Rare"
SHOP.RarityNames[4] = "Epic"
SHOP.RarityNames[5] = "Legendary"

-- Fonts used in the inventory interface
surface.CreateFont('FS_I16', {
    font = 'Roboto',
    size = 16,
})

surface.CreateFont('FS_I24', {
    font = 'Coolvetica',
    size = 24,
    weight = 800,
})

surface.CreateFont('FS_I48', {
    font = 'Roboto',
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
net.Receive('SHOP_BroadcastEquip', function()
    local ITEM = net.ReadTable()
    ITEM = SHOP:ParseVanillaItem(ITEM)
    
    local ply = net.ReadEntity()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local state = net.ReadBool()
    
    if ITEM.Type == 'Hat' then
        -- See cl_render
        -- Passes off to cosmetic rendering engine
        if state then
            SHOP:EquipCosmetic(ITEM, ply)
        else
            SHOP:UnequipCosmetic(ITEM, ply)
        end
    elseif ITEM.Type == 'Tracer' then
        if state then
            ply.TracerEffect = ITEM.Effect
        else
            ply.TracerEffect = nil
        end
    end
end)