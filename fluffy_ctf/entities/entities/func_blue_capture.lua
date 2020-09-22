ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Touch(ent)
    if ent:GetClass() == 'ctf_flag_red' or ent:GetClass() == 'ctf_flag_blue' then
        GAMEMODE:ScoreGoal(TEAM_BLUE, ent)
    elseif ent:IsPlayer() then
        if ent:Team() ~= TEAM_BLUE then return end

        if ent:HasWeapon('weapon_ctf_flag_red') or ent:HasWeapon('weapon_ctf_flag') then
            GAMEMODE:ScoreGoal(TEAM_BLUE, ent)
        end
    end
end