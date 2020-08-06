ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Touch(ent)
    if ent:GetClass() == 'ctf_flag_blue' then
        GAMEMODE:ScoreGoal(TEAM_RED, ent)
    elseif ent:IsPlayer() then
        if ent:HasWeapon('weapon_ctf_flag_blue') and ent:Team() == TEAM_RED then
            GAMEMODE:ScoreGoal(TEAM_RED, ent)
        end
    end
end