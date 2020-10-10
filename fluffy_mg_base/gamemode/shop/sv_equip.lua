-- Equip a cosmetic item
-- This broadcasts the cosmetic to all players
function SHOP:EquipCosmetic(ITEM, ply)
    ITEM = SHOP:StripVanillaItem(ITEM)
    net.Start("SHOP_BroadcastEquip")
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
    net.Start("SHOP_BroadcastEquip")
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
    SHOP:RemoveTrail(ply)
end

-- Remove a trail - without permamently unequipping it
function SHOP:RemoveTrail(ply)
    if ply.TrailEntity then
        SafeRemoveEntity(ply.TrailEntity)
    end
end

-- Wear a trail
function SHOP:WearTrail(ply, force)
    if ply.EquippedTrail then
        local ITEM = ply.EquippedTrail
        if not GAMEMODE:DoCosmeticsCheck(ply, ITEM) and not force then return end
        ply.TrailEntity = util.SpriteTrail(ply, 0, ITEM.Color or color_white, false, 20, 2, 2.5, 0.1, ITEM.Material)
    end
end

-- Equip a tracer
function SHOP:EquipTracer(ITEM, ply)
    ply:SetNWString("ShopTracerEffect", ITEM.Effect)

    return true
end

-- Unequip a tracer
function SHOP:UnequipTracer(ply)
    ply:SetNWString("ShopTracerEffect", nil)
end

-- Add equipped trails on player spawn
hook.Add("PlayerSpawn", "AddEquippedTrail", function(ply)
    SHOP:WearTrail(ply)
end)

-- Remove trails on player death
hook.Add("DoPlayerDeath", "RemoveEquippedTrail", function(ply)
    SHOP:RemoveTrail(ply)
end)

-- Serverside tracer effect
hook.Add("EntityFireBullets", "ShopTracerEffects", function(ent, data)
    if not ent:IsPlayer() then return end
    local effect = ent:GetNWString("ShopTracerEffect")
    if not effect or effect == "" then return end

    if not GAMEMODE:DoCosmeticsCheck(ent, {
        Type = "Tracer"
    }) then
        return
    end

    data.Tracer = 1
    data.TracerName = effect

    return true
end)