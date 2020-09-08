ENT.Type = "point"

/*
function ENT:Initialize()
    GAMEMODE.BarrelModels = ["models/props_c17/oildrum001_explosive.mdl"]
    GAMEMODE.BarrelSkins = [0]
end
*/

-- KV properties for mapping data
function ENT:KeyValue(key, value)
    if string.StartWith(key, "model") then
        local idx = tonumber(string.sub(key, 6))
        local model = value
        GAMEMODE.BarrelModels[idx] = model
    elseif string.StartWith(key, "skin") then
        local idx = tonumber(string.sub(key, 5))
        local skin = tonumber(value)
        GAMEMODE.BarrelSkins[idx] = skin
    end
end