AddCSLuaFile()
ENT.Type = "point"

-- KV properties for mapping data
function ENT:KeyValue(key, value)
    if key == 'colorstart' then
        local c = string.Split(value, ',')
        c = Color(tonumber(c[1]), tonumber(c[2]), tonumber(c[3]))
        GAMEMODE.PColorStart = c
        GAMEMODE:UpdatePDColors()
    elseif key == 'colorend' then
        local c = string.Split(value, ',')
        c = Color(tonumber(c[1]), tonumber(c[2]), tonumber(c[3]))
        GAMEMODE.PColorEnd = c
        GAMEMODE:UpdatePDColors()
    elseif key == 'colorbonus' then
        local c = string.Split(value, ',')
        c = Color(tonumber(c[1]), tonumber(c[2]), tonumber(c[3]))
        GAMEMODE.PColorBonus = c
    end
end