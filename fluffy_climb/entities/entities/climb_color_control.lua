AddCSLuaFile()
ENT.Type = "point"

-- KV properties for mapping data
function ENT:KeyValue(key, value)
    if key == "hue" then
        local c = string.Split(value, ",")
        GAMEMODE.HueMin = tonumber(c[1])
        GAMEMODE.HueMax = tonumber(c[2])
    end
end