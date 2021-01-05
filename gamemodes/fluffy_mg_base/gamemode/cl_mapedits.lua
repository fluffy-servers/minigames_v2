--[[
    Utility functionality allowing for map customization
    This handles any clientside functionality for this system
    Things such as visualisation and UI are defined here
--]]
GM.MapOverrideProperties = {}

local type_colors = {
    ["blue"] = Color(0, 0, 150),
    ["red"] = Color(150, 0, 0),
    ["all"] = Color(0, 150, 0),
    ["info_player_start"] = Color(0, 150, 0),
    ["info_player_terrorist"] = Color(0, 0, 150),
    ["info_player_counterterrorist"] = Color(150, 0, 0)
}

local function drawMarker(v, color, size, text)
    size = size or 12
    local pos = v:ToScreen()

    if pos.visible then
        local outsize = size + 2
        draw.RoundedBox(outsize / 2, pos.x - outsize / 2, pos.y - outsize / 2, outsize, outsize, Color(0, 0, 0))
        draw.RoundedBox(size / 2, pos.x - size / 2, pos.y - size / 2, size, size, color)

        if text then
            draw.SimpleTextOutlined(text, "DermaDefault", pos.x, pos.y - 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        end
    end
end

hook.Add("HUDPaint", "MapEditVisualization", function()
    local originalSpawns = GAMEMODE.MapOverrideProperties["originalSpawns"]

    if originalSpawns then
        for k, v in pairs(originalSpawns) do
            local pos = v[1]
            local type = v[2]
            drawMarker(pos, type_colors[type], 6)
        end
    end

    local customSpawns = GAMEMODE.MapOverrideProperties["customSpawns"]

    if customSpawns then
        for k, v in pairs(customSpawns) do
            local pos = v[1]
            local type = v[2]
            drawMarker(pos, type_colors[type], 16, k)
        end
    end
end)

net.Receive("VisualiseMapOverrides", function()
    local mode = net.ReadInt(8)

    if mode == 0 then
        -- Load full table
        GAMEMODE.MapOverrideProperties = net.ReadTable()
    elseif mode == 1 then
        -- Register single custom spawn
        if not GAMEMODE.MapOverrideProperties then return end

        if not GAMEMODE.MapOverrideProperties["customSpawns"] then
            GAMEMODE.MapOverrideProperties["customSpawns"] = {}
        end

        table.insert(GAMEMODE.MapOverrideProperties["customSpawns"], net.ReadTable())
    elseif mode == 2 then
        -- Remove single custom spawn
        if not GAMEMODE.MapOverrideProperties then return end
        if not GAMEMODE.MapOverrideProperties["customSpawns"] then return end
    -- elseif mode == 3 then
    -- elseif mode == 4 then
    end

    -- Register single custom entity
    -- Remove single custom entity
    PrintTable(GAMEMODE.MapOverrideProperties)
end)