AddCSLuaFile()
ENT.Type = "point"

-- KV properties for mapping data
function ENT:KeyValue(key, value)
    if key == 'redchange' then
        -- Red team change
        if not TEAM_COLORS[value] then return end
        local name = value:sub(1,1):upper() .. value:sub(2) .. ' Team'
        local color = TEAM_COLORS[value]
        
        team.SetColor(TEAM_RED, color)
        team.SetName(TEAM_RED, name)
    elseif key == 'bluechange' then
        -- Blue team change
        if not TEAM_COLORS[value] then return end
        local name = value:sub(1,1):upper() .. value:sub(2) .. ' Team'
        local color = TEAM_COLORS[value]
        
        team.SetColor(TEAM_BLUE, color)
        team.SetName(TEAM_BLUE, name)
    end
end