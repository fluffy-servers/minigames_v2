SHOP = SHOP or {}
SHOP.VanillaItems = {}
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

-- Get a hashed version of the table
-- This should not be used for security, only for verification
function SHOP:HashTable(tbl)
    if not tbl or type(tbl) ~= "table" then
        -- different results on state to ensure mismatch
        if CLIENT then
            return "NULL-TABLE-CLIENT"
        elseif SERVER then
            return "NULL-TABLE-SERVER"
        end
    else
        return util.CRC(table.ToString(tbl))
    end
end

-- Given a key (or information table), grab the rest of the item data
function SHOP:ParseVanillaItem(key)
    if type(key) == "string" then
        return SHOP.VanillaItems[key]
    elseif type(key) == "table" then
        local k = key.VanillaID

        if SHOP.VanillaItems[k] then
            return table.Merge(SHOP.VanillaItems[k], key)
        else
            if key.Type then
                return key
            else
                return nil
            end
        end
    end
end

-- Strip any unneeded information from a table
function SHOP:StripVanillaItem(ITEM)
    if type(ITEM) == "string" then
        return {
            VanillaID = ITEM
        }
    else
        local ret = {}
        ret.VanillaID = ITEM.VanillaID

        if ITEM.Color then
            ret.Color = ITEM.Color
        end

        return ret
    end
end

-- Registration functions for adding items into the master table
function SHOP:RegisterHat(ITEM)
    ITEM.Type = "Hat"
    SHOP.VanillaItems[ITEM.VanillaID] = ITEM
end

function SHOP:RegisterTrail(ITEM)
    ITEM.Type = "Trail"
    SHOP.VanillaItems[ITEM.VanillaID] = ITEM
end

function SHOP:RegisterTracer(ITEM)
    ITEM.Type = "Tracer"
    SHOP.VanillaItems[ITEM.VanillaID] = ITEM
end

function SHOP:RegisterUnbox(ITEM)
    ITEM.Type = "Crate"
    SHOP.VanillaItems[ITEM.VanillaID] = ITEM
end

-- Load all the files
function SHOP:LoadResources()
    local path = "fluffy_mg_base/gamemode/shop/item/"
    local _, folders = file.Find(path .. "*", "LUA")

    for _, v in pairs(folders) do
        -- Add every item file in subdirectories
        local files = file.Find(path .. v .. "/*", "LUA")

        for k, item in pairs(files) do
            if SERVER then
                AddCSLuaFile(path .. v .. "/" .. item, "LUA")
            end

            include(path .. v .. "/" .. item)
        end
    end

    if SERVER then
        AddCSLuaFile("fluffy_mg_base/gamemode/shop/item/paint_master.lua")
    end

    include("fluffy_mg_base/gamemode/shop/item/paint_master.lua")
end

-- Add the cosmetics check hook function
-- This function is hooked into various gamemodes to stop cosmetics from being drawn when they shouldn't be
-- Key examples of this is to override tracers, hide hats on certain playermodels, etc.
function GM:DoCosmeticsCheck(ply, ITEM)
    local hook_res = hook.Run("ShouldDrawCosmetics", ply, ITEM)

    if hook_res == false and hook_res ~= nil then
        return false
    else
        return true
    end
end

SHOP:LoadResources()

if SERVER then
    AddCSLuaFile("cl_init.lua")
    include("sv_init.lua")
else
    include("cl_init.lua")
end