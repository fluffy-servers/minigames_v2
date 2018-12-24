SHOP = {}
SHOP.VanillaItems = {}

if SERVER then
    AddCSLuaFile('cl_init.lua')
    include('sv_init.lua')
else
    include('cl_init.lua')
end

-- Get a hashed version of the table
-- This should not be used for security, only for verification
function SHOP:HashTable(tbl)
    return util.CRC(table.ToString(tbl))
end

-- Given a key (or information table), grab the rest of the item data
function SHOP:ParseVanillaItem(key)
    if type(key) == 'string' then
        return SHOP.VanillaItems[key]
    elseif type(key) == 'table' then
        local k = key.key
        return table.Merge(SHOP.VanillaItems[k], key)
    end
end

-- Strip any unneeded information from a table
function SHOP:StripVanillaItem(ITEM)
    if type(ITEM) == 'string' then
        return {VanillaID = ITEM}
    else
        local ret = {}
        ret.VanillaID = ITEM.VanillaID
        if ITEM.Color then ret.Color = ITEM.Color end
        
        return ret
    end
end

-- Registration functions for adding items into the master table
function SHOP:RegisterHat(ITEM)
	ITEM.Type = 'Hat'
	SHOP.VanillaItems[ITEM.VanillaID] = ITEM
end

function SHOP:RegisterTrail(ITEM)
	ITEM.Type = 'Trail'
	SHOP.VanillaItems[ITEM.VanillaID] = ITEM
end

function SHOP:RegisterTracer(ITEM)
	ITEM.Type = 'Tracer'
	SHOP.VanillaItems[ITEM.VanillaID] = ITEM
end

-- Load all the files
function SHOP:LoadResources()
    local path = 'fluffy_mg_base/gamemode/shop/item/'
    local files, folders = file.Find(path .. '*', 'LUA')
    for k, v in pairs(folders) do
        -- Add every item file in subdirectories
        local files = file.Find(path .. v .. '/*', 'LUA')
        for k, item in pairs(files) do
            if SERVER then AddCSLuaFile(path .. v .. '/' .. item, 'LUA' ) end
            include(path .. v .. '/' .. item)
        end
    end
end
SHOP:LoadResources()