--[[
    Utility functionality allowing for map customization
    This allows for server owners to update maps to suit various gamemodes
    This data is stored locally in server data files
--]]

GM.MapOverrideProperties = {}

-- Load configured map override properties from a file
function GM:LoadMapOverrideProperties()
    local map = game.GetMap()
    local data = file.Read("minigames_maps/" .. map .. ".txt", "DATA")
    if data then
        GAMEMODE.MapOverrideProperties = util.JSONToTable(data)
    end
end

-- Save any configured map override properties into a file
function GM:SaveMapOverrideProperties()
    local map = game.GetMap()

    -- Create directory if it doesn't exist
    if not file.Exists("minigames_maps/", "DATA") then
        file.CreateDir("minigames_maps")
    end

    -- Save the configured map override properties
    local json = util.TableToJSON(GAMEMODE.MapOverrideProperties)
    file.Write("minigames_maps/" .. map .. ".txt", json)
end

-- Apply any configured map overrides
-- This is usually for adding and/or removing entities
function GM:ApplyMapOverrideEntities()
    local props = GAMEMODE.MapOverrideProperties
    -- Remove spawns from the map (if applicable)
    if props['cleanSpawns'] then
        -- todo
    end

    -- Add defined entities into the map (if applicable)
    if props['addEntities'] then
        -- todo
    end
end

-- Call the override handlers on round cleanup
hook.Add('PostCleanup', 'MapOverrideEntities', function()
    GAMEMODE:ApplyMapOverrideEntities()
end)

