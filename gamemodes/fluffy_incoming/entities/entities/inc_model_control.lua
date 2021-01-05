ENT.Type = "point"

ENT.CustomPreset = {}

function ENT:KeyValue(key, value)
    if key == "preset" then
        if value == "Custom" then value = "Custom" .. self:EntIndex() end
        self.Preset = value
    elseif key == "delay" then
        self.CustomPreset.delay = tonumber(value)
    elseif key == "material" then
        self.CustomPreset.material = value
    elseif string.StartWith(key, "model") then
        if not self.CustomPreset.models then self.CustomPreset.models = {} end
        table.insert(self.CustomPreset.models, value)
    end
end