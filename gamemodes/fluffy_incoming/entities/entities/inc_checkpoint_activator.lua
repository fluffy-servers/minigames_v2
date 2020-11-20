ENT.Type = "brush"

function ENT:StartTouch(ent)
    if not ent:IsPlayer() then return end
    if not GAMEMODE:InRound() then return end

    GAMEMODE:CheckpointTriggered(ent, self.CheckpointStage, self.CheckpointMessage)
end

function ENT:KeyValue(key, value)
    if key == "stage" then
        self.CheckpointStage = tonumber(value)
    elseif key == "message" then
        self.CheckpointMessage = value
    end
end