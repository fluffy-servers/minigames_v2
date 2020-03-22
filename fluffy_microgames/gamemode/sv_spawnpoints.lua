-- Similiar to IsTableOfEntitiesValid, but handles the nesting
local function IsSpawnpointTableValid(tab)
    if not tab then return false end

    for k,v in pairs(tab) do
        for k2,v2 in pairs(v) do
            if not IsValid(v) then return false end
        end
    end

    return true
end

function GM:LoadSpawnpoints()
    GAMEMODE.Spawnpoints = {}

    for _, v in pairs(ents.FindByClass("microgames_spawnpoint")) do
        -- Find what region this marker is in
        local region = v.Region
        if not region then
            region = 'generic'
        else
            if not GAMEMODE.Spawnpoints[region] then
                GAMEMODE.Spawnpoints[region] = {}
            end
        end
        table.insert(GAMEMODE.Spawnpoints[region], v)
    end
end

hook.Add('InitPostEntity', 'LoadMicrogamesSpawnpoints', function()
    GAMEMODE:LoadSpawnpoints()
end)

function GM:PlayerSelectSpawn(ply, transition)
    if transition then return end

    if not IsSpawnpointTableValid(GAMEMODE.Spawnpoints) then
        GAMEMODE:LoadSpawnpoints()
    end

    local region = GAMEMODE.CurrentRegion or 'generic'

    -- Iterate over the spawnpoints in a random order until we find a suitable one
    local spawntable = GAMEMODE.Spawnpoints[region]
    local chosen = nil

    for i=0,6 do
        chosen = table.Random(spawntable)
        if hook.Call('IsSpawnpointSuitable', GAMEMODE, ply, chosen, i == 6) then
            return chosen
        end
    end

    return chosen
end