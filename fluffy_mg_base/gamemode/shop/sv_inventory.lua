SHOP.PlayerInventories = SHOP.PlayerInventories or {}
SHOP.PlayerEquipped = SHOP.PlayerEquipped or {}

local test_inventory = {
    {VanillaID = 'boogleballoon'},
    {VanillaID = 'coolcrate', Name='Coolest Crate', Type='crate', Rarity=3},
}

function SHOP:DefaultInventory()
    return test_inventory
end

function SHOP:NetworkEquipped(ply)
    net.Start('SHOP_NetworkEquipped')
        net.WriteTable(SHOP.PlayerEquipped[ply])
    net.Send(ply)
end

function SHOP:NetworkInventory(ply)
    net.Start('SHOP_NetworkInventory')
        net.WriteTable(SHOP.PlayerInventories[ply])
    net.Send(ply)
end

hook.Add('PlayerInitialSpawn', 'LoadShopInventory', function(ply)
    -- to do
    SHOP.PlayerInventories[ply] = test_inventory
end)

hook.Add('PlayerDisconnected', 'ShopDisconnect', function(ply)
    -- save inventory here
    
    SHOP.PlayerInventories[ply] = nil
end)

net.Receive('SHOP_NetworkInventory', function(len, ply)
    -- stop this from being lagged out
    if ply.LastVerification then
        if ply.LastVerification + 5 > CurTime() then return end
    end
    ply.LastVerification = CurTime()
    
    local check = net.ReadString()
    if not SHOP.PlayerInventories[ply] then 
        SHOP.PlayerInventories[ply] = SHOP:DefaultInventory()
    end
    
    if check != SHOP:HashTable(SHOP.PlayerInventories[ply]) then
        SHOP:NetworkInventory(ply)
    end
end)

net.Receive('SHOP_RequestItemAction', function(len, ply)
    if not SHOP.PlayerInventories[ply] then return end
    local action = net.ReadString()
    local key = net.ReadInt(16)
    
    if action == 'EQUIP' then
        -- Handle equipping/unequipping of items
        if not SHOP.PlayerEquipped[ply] then SHOP.PlayerEquipped[ply] = {} end
        if SHOP.PlayerEquipped[ply][key] then
            -- Unequip the item
            local ITEM = SHOP.PlayerInventories[ply][key]
            ITEM = SHOP:ParseVanillaItem(ITEM)
        
            if ITEM.Type == 'Hat' then
                SHOP:UnequipCosmetic(ITEM, ply)
            elseif ITEM.Type == 'Tracer' then
                SHOP:UnequipTracer(ITEM, ply)
            elseif ITEM.Type == 'Trail' then
                SHOP:UnequipTrail(ITEM, ply)
            end
            
            SHOP.PlayerEquipped[ply][key] = nil
            SHOP:NetworkEquipped(ply)
        else
            -- Equip the item
            local ITEM = SHOP.PlayerInventories[ply][key]
            ITEM = SHOP:ParseVanillaItem(ITEM)
        
            local equipped = false
            if ITEM.Type == 'Hat' then
                equipped = SHOP:EquipCosmetic(ITEM, ply)
            elseif ITEM.Type == 'Tracer' then
                equipped = SHOP:EquipTracer(ITEM, ply)
            elseif ITEM.Type == 'Trail' then
                equipped = SHOP:EquipTrail(ITEM, ply)
            end
    
            if equipped then
                SHOP.PlayerEquipped[ply][key] = true
                SHOP:NetworkEquipped(ply)
            end
        end
    end
end)