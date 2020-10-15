ENT.Type = "point"

--[[
function ENT:Initialize()
    GAMEMODE.BarrelModels = ["models/props_c17/oildrum001_explosive.mdl"]
    GAMEMODE.BarrelSkins = [0]
end
]]
function ENT:Initialize()
    GAMEMODE.PropModels = {}
end

-- KV properties for mapping data
function ENT:KeyValue(key, value)
    if string.StartWith(key, "model") then
        table.insert(GAMEMODE.PropModels, value)
    end
end