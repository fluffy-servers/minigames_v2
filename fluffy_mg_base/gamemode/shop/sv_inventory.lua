SHOP.PlayerInventories = SHOP.PlayerInventories or {}

local test_inventory = {
    {VanillaID = 'boogleballoon'},
    {VanillaID = 'coolcrate', Name='Coolest Crate', Type='crate', Rarity=3},
}

function SHOP:DefaultInventory()
    return test_inventory
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
    print(check, SHOP:HashTable(SHOP.PlayerInventories[ply]))
    if check != SHOP:HashTable(SHOP.PlayerInventories[ply]) then
        net.Start('SHOP_NetworkInventory')
        net.WriteTable(SHOP.PlayerInventories[ply])
        net.Send(ply)
    end
end)

net.Receive('SHOP_RequestItemAction', function(len, ply)
    if not SHOP.PlayerInventories[ply] then return end
    local action = net.ReadString()
    local key = net.ReadInt(16)
    
    if action == 'EQUIP' then
        -- Handle equipment of items
        local ITEM = SHOP.PlayerInventories[ply][key]
        ITEM = SHOP:ParseVanillaItem(ITEM)
        
        if ITEM.Type == 'Hat' then
            SHOP:EquipCosmetic(ITEM, ply)
        elseif ITEM.Type == 'Tracer' then
            SHOP:EquipTracer(ITEM, ply)
        elseif ITEM.Type == 'Trail' then
            SHOP:EquipTrail(ITEM, ply)
        end
    end
end)