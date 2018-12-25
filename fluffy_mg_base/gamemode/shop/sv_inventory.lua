SHOP.PlayerInventories = {}

hook.Add('PlayerInitialSpawn', 'LoadShopInventory', function(ply)
    -- to do
    SHOP.PlayerInventories[ply] = {}
end)

hook.Add('PlayerDisconnected', 'ShopDisconnect', function(ply)
    -- save inventory here
    
    SHOP.PlayerInventories[ply] = nil
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