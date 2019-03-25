SHOP.PlayerInventories = SHOP.PlayerInventories or {}
SHOP.PlayerEquipped = SHOP.PlayerEquipped or {}

local test_inventory = {
    {VanillaID = 'coolcrate', Name='Coolest Crate', Type='Crate', Rarity=3},
    {VanillaID = 'testtrail', Name='Hilarious', Rarity=2, Type='Trail', Paintable=true, Material='trails/lol.vmt'},
    {VanillaID = 'bewaredog'},
    {VanillaID = 'gmanonhead'},
    {VanillaID = 'camera'},
	SHOP.PaintList['blueberry'],
}

-- Function to generate a default inventory
-- This should return a table
function SHOP:DefaultInventory()
    return test_inventory
end

-- Load a player's inventory
function SHOP:LoadInventory(ply, callback)
    SHOP.PlayerInventories[ply] = SHOP:DefaultInventory()
    
    local inventory = SHOP.PlayerInventories[ply]
    callback(inventory)
end

-- Transmit the equipped table to the clients
-- This makes sure the server & client about what items are equipped
function SHOP:NetworkEquipped(ply)
    net.Start('SHOP_NetworkEquipped')
        net.WriteTable(SHOP.PlayerEquipped[ply])
    net.Send(ply)
end

-- Network the entire inventory to the client
-- Only use this when needed
function SHOP:NetworkInventory(ply)
    net.Start('SHOP_NetworkInventory')
        net.WriteTable(SHOP.PlayerInventories[ply])
    net.Send(ply)
end

-- Add an item to the inventory
function SHOP:AddItem(ITEM, ply)
    if type(ITEM) != 'table' then
        ITEM = {VanillaID = ITEM}
    end
    if not SHOP.VanillaItems[ITEM.VanillaID] then return end
    
    if not SHOP.PlayerInventories[ply] then return end
    table.insert(SHOP.PlayerInventories[ply], ITEM)
    
    -- Network change to the client
    net.Start('SHOP_InventoryChange')
        net.WriteString('ADD')
        net.WriteTable(ITEM)
    net.Send(ply)
end

-- Remove an item from the inventory
function SHOP:RemoveItem(key, ply)
    if not SHOP.PlayerInventories[ply] then return end
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
        SHOP:LoadInventory(ply, function() SHOP:NetworkInventory(ply) end)
        return
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
    elseif action == 'PAINT' then
		-- Handle painting of items
		local paintcan = net.ReadInt(16)
	end
end)