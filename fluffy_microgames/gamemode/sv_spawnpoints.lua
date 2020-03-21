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

    local region = 'generic'
    if GAMEMODE.CurrentModifier then
        if GAMEMODE.CurrentModifier.Region then
            region = GAMEMODE.CurrentModifier.Region
        end
    end

    local spawntable = GAMEMODE.Spawnpoints[region]
    local count = table.Count(spawntable)
    local chosen = nil

    -- Pick the best random spawnpoint
    for i = 1, count do
        chosen = table.Random(spawntable)
        if IsValid(chosen) and chosen:IsInWorld() then
            if hook.Call('IsSpawnpointSuitable', GAMEMODE, ply, chosen, i == count) then
                return chosen
            end
        end
    end

    return chosen
end