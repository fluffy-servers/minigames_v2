ENT.Type = "point"

function ENT:KeyValue(key, value)
    if key == "stage" then
        self.CheckpointStage = tonumber(value)
    end
end