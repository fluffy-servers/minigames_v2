ENT.Type = "point"

function ENT:KeyValue(key, value)
    if key == "stage" then
        self.CheckpointStage = value
    end
end