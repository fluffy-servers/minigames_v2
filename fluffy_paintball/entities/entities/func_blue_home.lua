ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Touch(ent)
    if not ent:IsPlayer() then return end
    if ent:Team() != TEAM_BLUE then return end
    if ent:GetNWBool('IsGhost', false) then
        GAMEMODE:SetPlayerUnGhost(ent)
    end
end