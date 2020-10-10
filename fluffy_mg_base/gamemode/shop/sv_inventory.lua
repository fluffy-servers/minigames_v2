-- Global shop tables to keep track of player inventories
SHOP.PlayerInventories = SHOP.PlayerInventories or {}
SHOP.PlayerEquipped = SHOP.PlayerEquipped or {}
SHOP.PlayerEquippedSlots = SHOP.PlayerEquippedSlots or {}

-- Default inventory for testing purposes
local test_inventory = {
    {
        VanillaID = "unbox_test"
    },
    {
        VanillaID = "testtrail",
        Name = "Hilarious",
        Rarity = 2,
        Type = "Trail",
        Paintable = true,
        Material = "trails/lol.vmt"
    },
    {
        VanillaID = "testtrail",
        Name = "Hilarious",
        Rarity = 2,
        Type = "Trail",
        Paintable = true,
        Material = "trails/lol.vmt"
    },
    {
        VanillaID = "bewaredog"
    },
    {
        VanillaID = "gmanonhead"
    },
    {
        VanillaID = "camera"
    },
    {
        VanillaID = "tracer_disco"
    },
    SHOP.PaintList["blueberry"], {
        VanillaID = "tracer_lol",
        Locked = true
    }
}

-- Function to generate a default inventory
-- This should return a table
function SHOP:DefaultInventory()
    return test_inventory
end

-- Load a player inventory
function SHOP:LoadInventory(ply, callback)
    SHOP.PlayerInventories[ply] = SHOP:DefaultInventory()
    local inventory = SHOP.PlayerInventories[ply]
    callback(inventory)
end

-- Transmit the equipped table to the clients
-- This makes sure the server & client about what items are equipped
function SHOP:NetworkEquipped(ply)
    if not SHOP.PlayerEquipped[ply] then return end
    net.Start("SHOP_NetworkEquipped")
    net.WriteTable(SHOP.PlayerEquipped[ply])
    net.Send(ply)
end

-- Network the entire inventory to the client
-- Only use this when needed
function SHOP:NetworkInventory(ply)
    net.Start("SHOP_NetworkInventory")
    net.WriteTable(SHOP.PlayerInventories[ply])
    net.Send(ply)
end

-- Add an item to the inventory
function SHOP:AddItem(ITEM, ply)
    if type(ITEM) ~= "table" then
        ITEM = {
            VanillaID = ITEM
        }
    end

    if not SHOP.VanillaItems[ITEM.VanillaID] then return end
    if not SHOP.PlayerInventories[ply] then return end
    local key = table.insert(SHOP.PlayerInventories[ply], ITEM)
    -- Network change to the client
    net.Start("SHOP_InventoryChange")
    net.WriteString("ADD")
    net.WriteTable(ITEM)
    net.Send(ply)

    return key
end

-- Remove an item from the inventory
function SHOP:RemoveItem(key, ply)
    if not SHOP.PlayerInventories[ply] then return end
    if not SHOP.PlayerInventories[ply][key] then return end
    table.remove(SHOP.PlayerInventories[ply], key)
    SHOP:ShiftEquippedTable(ply, key)
    -- Network changes
    net.Start("SHOP_InventoryChange")
    net.WriteString("REMOVE")
    net.WriteInt(key, 16)
    net.Send(ply)
end

function SHOP:EquipItem(key, ply, state)
    -- Handle equipping/unequipping of items
    if not SHOP.PlayerEquipped[ply] then
        SHOP.PlayerEquipped[ply] = {}
    end

    if not SHOP.PlayerEquippedSlots[ply] then
        SHOP.PlayerEquippedSlots[ply] = {}
    end

    -- Determine whether to equip or not
    local equip = false

    if state == nil then
        equip = not SHOP.PlayerEquipped[ply][key]
    else
        equip = state
    end

    if equip then
        -- Equip the item
        local ITEM = SHOP.PlayerInventories[ply][key]
        ITEM = SHOP:ParseVanillaItem(ITEM)
        -- Check the slot is empty
        local slot = ITEM.Slot or ITEM.Type
        if SHOP.PlayerEquippedSlots[ply][slot] then return end
        local equipped = false

        if ITEM.Type == "Hat" then
            equipped = SHOP:EquipCosmetic(ITEM, ply)
        elseif ITEM.Type == "Tracer" then
            equipped = SHOP:EquipTracer(ITEM, ply)
        elseif ITEM.Type == "Trail" then
            equipped = SHOP:EquipTrail(ITEM, ply)
        end

        -- If equip was successful, store the change
        if equipped then
            SHOP.PlayerEquipped[ply][key] = true
            SHOP.PlayerEquippedSlots[ply][slot] = true
            SHOP:NetworkEquipped(ply)
        end
    else
        -- Unequip the item
        local ITEM = SHOP.PlayerInventories[ply][key]
        ITEM = SHOP:ParseVanillaItem(ITEM)
        local slot = ITEM.Slot or ITEM.Type

        if ITEM.Type == "Hat" then
            SHOP:UnequipCosmetic(ITEM, ply)
        elseif ITEM.Type == "Tracer" then
            SHOP:UnequipTracer(ply)
        elseif ITEM.Type == "Trail" then
            SHOP:UnequipTrail(ply)
        end

        -- Clear the table
        SHOP.PlayerEquipped[ply][key] = nil
        SHOP.PlayerEquippedSlots[ply][slot] = nil
        SHOP:NetworkEquipped(ply)
    end
end

-- Offset the equipped array
function SHOP:ShiftEquippedTable(ply, key)
    PrintTable(SHOP.PlayerEquipped[ply])

    if SHOP.PlayerEquipped[ply] then
        for eq, _ in pairs(SHOP.PlayerEquipped[ply]) do
            if eq == key then
                -- hm?
                SHOP:EquipItem(key, ply, false)
                SHOP.PlayerEquipped[ply][eq] = nil
            elseif eq > key then
                SHOP.PlayerEquipped[ply][eq] = nil
                SHOP.PlayerEquipped[ply][eq - 1] = true
            end
        end

        PrintTable(SHOP.PlayerEquipped[ply])
        SHOP:NetworkEquipped(ply)
    end
end

hook.Add("PlayerInitialSpawn", "LoadShopInventory", function(ply)
    -- to do
    SHOP.PlayerInventories[ply] = table.Copy(test_inventory)
end)

hook.Add("PlayerDisconnected", "ShopDisconnect", function(ply)
    -- save inventory here
    SHOP.PlayerInventories[ply] = nil
end)

net.Receive("SHOP_NetworkInventory", function(len, ply)
    -- stop this from being lagged out
    if ply.LastVerification and ply.LastVerification + 3 > CurTime() then
        return
    end

    ply.LastVerification = CurTime()
    local check = net.ReadString()

    -- Load the inventory if not loaded yet
    if not SHOP.PlayerInventories[ply] then
        SHOP:LoadInventory(ply, function()
            SHOP:NetworkInventory(ply)
        end)

        return
    end

    -- If the check differs from our version, resend all the data
    if check ~= SHOP:HashTable(SHOP.PlayerInventories[ply]) then
        SHOP:NetworkInventory(ply)
    end

    -- Send equipped anyway since it breaks like 90% of the time
    SHOP:NetworkEquipped(ply)
end)

net.Receive("SHOP_RequestItemAction", function(len, ply)
    if not SHOP.PlayerInventories[ply] then return end
    local action = net.ReadString()
    local key = net.ReadInt(16)

    if action == "EQUIP" then
        -- Handle equipping of items
        SHOP:EquipItem(key, ply)

    elseif action == "PAINT" then
        -- Handle painting of items
        local paintcan = net.ReadInt(16)
        -- Verify the item can be painted
        local ITEM = SHOP.PlayerInventories[ply][key]
        ITEM = SHOP:ParseVanillaItem(ITEM)
        if not ITEM.Paintable then return end
        local PAINT = SHOP.PlayerInventories[ply][paintcan]
        if PAINT.Type ~= "Paint" then return end

        local reequip = false
        -- Unequip the item if already equipped
        if SHOP.PlayerEquipped[ply] and SHOP.PlayerEquipped[ply][key] then
            SHOP:EquipItem(key, ply, false)
            reequip = true
        end

        SHOP.PlayerInventories[ply][key].Color = PAINT.Color
        SHOP:RemoveItem(paintcan, ply)

        -- Reequip the item automagically
        if reequip then
            SHOP:EquipItem(key, ply, true)
        end

    elseif action == "UNBOX" then
        -- Handle unboxing of items
        SHOP:OpenUnbox(key, ply)
        SHOP:RemoveItem(key, ply)

    elseif action == "DELETE" then
        -- Handle deletion of items
        -- Verify the item is not locked
        local ITEM = SHOP.PlayerInventories[ply][key]
        ITEM = SHOP:ParseVanillaItem(ITEM)
        if ITEM.Locked then return end
        SHOP:RemoveItem(key, ply)

    elseif action == "GIFT" then
        -- Handle gifting of items
        -- Verify the item is not locked
        local ITEM = SHOP.PlayerInventories[ply][key]
        ITEM = SHOP:ParseVanillaItem(ITEM)
        if ITEM.Locked then return end

        -- Verify the giftee is a player
        local giftee = net.ReadEntity()
        if not IsValid(giftee) then return end
        if not giftee:IsPlayer() then return end
        SHOP:AddItem(ITEM, giftee)
        giftee:ChatPrint(ply:Nick() .. " gave you an item!")
        SHOP:RemoveItem(key, ply)
    end
end)