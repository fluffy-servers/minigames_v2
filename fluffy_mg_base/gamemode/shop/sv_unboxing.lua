-- Return a weighted random result from a table
local function PickWeightedRandom(tbl)
    local sum = 0

    for k, v in pairs(tbl) do
        sum = sum + v
    end

    local select = math.random() * sum

    for k, v in pairs(tbl) do
        select = select - v
        if select < 0 then return k end
    end
    -- this case shouldn't happen

    return #tbl
end

function SHOP:PrepareUnbox(cratekey, ply)
    if not SHOP.PlayerInventories[ply] then return end
    if not SHOP.PlayerInventories[ply][cratekey] then return end
    local unbox = SHOP:ParseVanillaItem(SHOP.PlayerInventories[ply][cratekey])
    if not unbox.Items then return end

    return unbox.Items, unbox.Chances
end

function SHOP:OpenUnbox(cratekey, ply)
    local items, chances = SHOP:PrepareUnbox(cratekey, ply)
    if not items or not chances then return end
    -- Generate a queue of 50 items
    local queue = {}

    for i = 1, 50 do
        table.insert(queue, PickWeightedRandom(chances))
    end

    -- Take the 24th item in the queue
    -- Why 24th? I have no idea it's a nice number ok
    local item = items[queue[24]]

    if type(item) == "string" then
        item = {
            VanillaID = item
        }
    end

    -- Add the item to the inventory
    SHOP:AddItem(item, ply)
    -- Announce the unbox
    local ITEM = SHOP:ParseVanillaItem(item)

    timer.Simple(10, function()
        if not IsValid(ply) then return end
        local rarity = SHOP.RarityColors[ITEM.Rarity or 1]

        rarity = {
            r = rarity.r,
            g = rarity.g,
            b = rarity.b
        }

        net.Start("SHOP_AnnounceUnbox")
        net.WriteString(ply:Nick() or "Somebody")
        net.WriteString(ITEM.Name)
        net.WriteString("unboxed")
        net.WriteTable(rarity)
        net.Broadcast()
    end)
end

function SHOP:InstantUnbox(unbox, ply, message)
    if not unbox.Items then return end
    local items = unbox.Items

    -- Pick an item randomly
    local idx = PickWeightedRandom(unbox.Chances)
    SHOP:AddItem(items[idx], ply)

    -- Display a message
    local rarity = SHOP.RarityColors[item.Rarity]

    rarity = {
        r = rarity.r,
        g = rarity.g,
        b = rarity.b
    }

    net.Start("SHOP_AnnounceUnbox")
    net.WriteString(ply:Nick() or "Somebody")
    net.WriteString(item.Name)
    net.WriteString("unboxed")
    net.WriteTable(rarity)
    net.Broadcast()
end