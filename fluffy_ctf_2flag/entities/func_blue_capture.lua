ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Touch(ent)
    if ent:GetClass() == 'ctf_flag_red' then
        GAMEMODE:ScoreGoal(TEAM_BLUE, ent)
    elseif ent:IsPlayer() then
        if ent:HasWeapon('weapon_ctf_flag_red') and ent:Team() == TEAM_BLUE then
            GAMEMODE:ScoreGoal(TEAM_BLUE, ent)
        end
    end
end