ENT.Type = "brush"

function ENT:StartTouch(ent)
    if not ent:IsPlayer() then return end
    if not GAMEMODE:InRound() then return end

    self:Remove()
    GAMEMODE:IncomingVictory(ent)
end