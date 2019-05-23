ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Touch(ent)
    if ent:GetClass() == 'ctf_flag' then
        if GetGlobalInt('HoldingTeam') == TEAM_BLUE then
            GAMEMODE:ScoreGoal(TEAM_BLUE, ent)
        end
    elseif ent:IsPlayer() then
        if ent:HasWeapon('weapon_ctf_flag') and ent:Team() == TEAM_BLUE then
            GAMEMODE:ScoreGoal(TEAM_BLUE, ent)
        end
    end
end