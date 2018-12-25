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

-- Equip a trail
function SHOP:EquipTrail(ITEM, ply)
    ply.EquippedTrail = ITEM
    SHOP:WearTrail(ply)
    return true
end

-- Unequip a trail
function SHOP:UnequipTrail(ply)
    ply.EquippedTrail = nil
    if ply.TrailEntity then
        SafeRemoveEntity(ply.TrailEntity)
    end
end

-- Wear a trail
function SHOP:WearTrail(ply)
    if ply.EquippedTrail then
        local ITEM = ply.EquippedTrail
        ply.TrailEntity = util.SpriteTrail(ply, 0, ITEM.Color or color_white, false, 20, 2, 2.5, 0.1, ITEM.Material)
    end
end

-- Add equipped trails on player spawn
hook.Add('PlayerSpawn', 'AddEquippedTrail', function(ply)
    SHOP:WearTrail(ply)
end)

-- Remove trails on player death
hook.Add('DoPlayerDeath', 'RemoveEquippedTrail', function(ply)
    if ply.TrailEntity then
        SafeRemoveEntity(ply.TrailEntity)
    end
end)