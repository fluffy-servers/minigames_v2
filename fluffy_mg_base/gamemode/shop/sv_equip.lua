-- Equip a cosmetic item
-- This broadcasts the cosmetic to all players
function SHOP:EquipCosmetic(ITEM, ply)
    ITEM = SHOP:StripVanillaItem(ITEM)
    net.Start('SHOP_BroadcastEquip')
        net.WriteTable(ITEM)
        net.WriteEntity(ply)
        net.WriteBool(true)
    net.Broadcast()
    
    return true
end

-- Unequip a cosmetic item
-- This broadcasts the cosmetic to all players
function SHOP:UnequipCosmetic(ITEM, ply)
    ITEM = SHOP:StripVanillaItem(ITEM)
    net.Start('SHOP_BroadcastEquip')
        net.WriteTable(ITEM)
        net.WriteEntity(ply)
        net.WriteBool(false)
    net.Broadcast()
end