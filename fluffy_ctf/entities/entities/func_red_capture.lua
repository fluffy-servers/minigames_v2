ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Touch(ent)
    if ent:GetClass() == 'ctf_flag' then
        if GetGlobalInt('HoldingTeam') == TEAM_RED then
            GAMEMODE:ScoreGoal(TEAM_RED, ent)
        else
            ent:Remove()
            GAMEMODE:SpawnFlag()
        end
    elseif ent:IsPlayer() then
        if ent:HasWeapon('weapon_ctf_flag') and ent:Team() == TEAM_RED then
            GAMEMODE:ScoreGoal(TEAM_RED, ent)
        end
    end
end