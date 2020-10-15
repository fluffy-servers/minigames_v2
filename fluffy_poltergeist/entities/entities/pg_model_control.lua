ENT.Type = "point"

-- KV properties for mapping data
function ENT:KeyValue(key, value)
    if not self.Ready then
        GAMEMODE.PropModels = {}
        self.Ready = true
    end

    if string.StartWith(key, "model") then
        table.insert(GAMEMODE.PropModels, value)
    end
end