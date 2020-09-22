ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Touch(ent)
    if ent:GetClass() == 'ctf_flag_blue' or ent:GetClass() == 'ctf_flag_blue' then
        GAMEMODE:ScoreGoal(TEAM_RED, ent)
    elseif ent:IsPlayer() then
        if ent:Team() ~= TEAM_RED then return end

        if ent:HasWeapon('weapon_ctf_flag_blue') or ent:HasWeapon('weapon_ctf_flag') then
            GAMEMODE:ScoreGoal(TEAM_RED, ent)
        end
    end
end