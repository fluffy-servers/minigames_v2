--[[
    Utility functionality allowing for map customization
    This allows for server owners to update maps to suit various gamemodes
    This data is stored locally in server data files
--]]
local spawnpoint_classes = {'info_player_start', 'info_player_terrorist', 'info_player_counterterrorist'}

-- Load configured map override properties from a file
function GM:LoadMapOverrideProperties()
    local map = game.GetMap()
    local data = file.Read("minigames_maps/" .. map .. ".txt", "DATA")

    if data then
        GAMEMODE.MapOverrideProperties = util.JSONToTable(data)
    else
        GAMEMODE.MapOverrideProperties = {}
    end

    GAMEMODE:GetOriginalSpawnLocations()
end

local function registerSpawnType(tbl, class)
    for k, v in pairs(ents.FindByClass(class)) do
        table.insert(tbl, {v:GetPos(), class})
    end
end

-- Store the original spawn locations for the map
function GM:GetOriginalSpawnLocations()
    local originalSpawns = {}

    for _, class in pairs(spawnpoint_classes) do
        for _, ent in pairs(ents.FindByClass(class)) do
            table.insert(originalSpawns, {ent:GetPos(), class})
        end
    end

    GAMEMODE.MapOverrideProperties['originalSpawns'] = originalSpawns
end

-- Save any configured map override properties into a file
function GM:SaveMapOverrideProperties()
    local map = game.GetMap()

    -- Create directory if it doesn't exist
    if not file.Exists("minigames_maps/", "DATA") then
        file.CreateDir("minigames_maps")
    end

    -- Trim out some utility info before saving (eg. original map spawns)
    local properties = table.Copy(GAMEMODE.MapOverrideProperties)
    properties['originalSpawns'] = nil
    -- Save the configured map override properties
    local json = util.TableToJSON(properties)
    file.Write("minigames_maps/" .. map .. ".txt", json)
end

-- Apply any configured map overrides
-- This is usually for adding and/or removing entities
function GM:ApplyMapOverrideEntities()
    local props = GAMEMODE.MapOverrideProperties
    if not props then return end

    -- Remove spawns from the map (if applicable)
    if props['cleanSpawns'] then
        for _, class in pairs(spawnpoint_classes) do
            for _, ent in pairs(ents.FindByClass(class)) do
                ent:Remove()
            end
        end
    end

    -- Add new spawns into the map
    if props['customSpawns'] then
        for k, v in pairs(props['customSpawns']) do
            local pos = v[1]
            local class = v[2]
            local spawn = ents.Create(class)
            spawn:SetPos(pos)
            spawn:Spawn()
        end
    end

    -- Add defined entities into the map (if applicable)
    if props['addEntities'] then
        local pos = v[1]
        local class = v[2]
        local kvs = v[3]
        local e = ents.Create(class)
        e:SetPos(pos)
        e:Spawn()

        for k, v in pairs(kvs) do
            e:SetKeyValue(k, v)
        end
    end
end

function GM:AddCustomSpawnpoint(class, pos, ply)
    local props = GAMEMODE.MapOverrideProperties

    if not props['customSpawns'] then
        props['customSpawns'] = {}
    end

    table.insert(props['customSpawns'], {pos, class})

    if ply then
        GAMEMODE:NetworkSpawnAddition(ply, {pos, class})
    end
end

function GM:NetworkMapOverrideProperties(ply)
    if not GAMEMODE.MapOverrideProperties then
        GAMEMODE:LoadMapOverrideProperties()
    end

    local mode = 0
    net.Start('VisualiseMapOverrides')
    net.WriteInt(mode, 8)
    net.WriteTable(GAMEMODE.MapOverrideProperties)
    net.Send(ply)
end

function GM:NetworkSpawnAddition(ply, new)
    if not GAMEMODE.MapOverrideProperties then return end
    local mode = 1
    net.Start('VisualiseMapOverrides')
    net.WriteInt(mode, 8)
    net.WriteTable(new)
    net.Send(ply)
end

-- Call the override handlers on round cleanup
hook.Add('PostCleanup', 'MapOverrideEntities', function()
    GAMEMODE:ApplyMapOverrideEntities()
end)