AddCSLuaFile()
ENT.Type = "point"

function ENT:KeyValue(key, value)
    if key == 'maxlevels' then
        self.MaxLevels = math.Clamp(tonumber(value), 1, 5)
    elseif key == 'size' then
        self.Size = math.Clamp(tonumber(value), 1, 5)
    end
end