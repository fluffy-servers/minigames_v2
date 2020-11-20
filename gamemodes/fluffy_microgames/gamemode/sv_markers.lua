GM.Markers = {}
GM.Markers["generic"] = {}

function GM:LoadMarkers()
    for _, v in pairs(ents.FindByClass("microgames_marker")) do
        -- Find what region this marker is in
        local region = v.Region

        if not region then
            region = "generic"
        else
            if not GAMEMODE.Markers[region] then
                GAMEMODE.Markers[region] = {}
            end
        end

        -- Determine the type of the marker and register it
        local type = v.MarkerType

        if not GAMEMODE.Markers[region][type] then
            GAMEMODE.Markers[region][type] = {}
        end

        table.insert(GAMEMODE.Markers[region][type], v:GetPos())
    end
end

hook.Add("InitPostEntity", "LoadMicrogamesMarkers", function()
    GAMEMODE:LoadMarkers()
end)

function GM:GetRandomLocations(num, type, region)
    if not region then
        region = GAMEMODE.CurrentRegion or "generic"
    end

    -- Shuffle the table
    local tbl = table.Shuffle(GAMEMODE.Markers[region][type])
    num = math.Clamp(num, 0, #tbl)
    -- Take as many positions as required
    local results = {}

    for i = 1, num do
        table.insert(results, tbl[i])
    end

    return results
end

function GM:HasRegion(region)
    return GAMEMODE.Markers[region]
end