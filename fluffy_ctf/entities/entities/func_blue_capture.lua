ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Touch(ent)
    if ent:GetClass() != 'ctf_flag' then return end
    if IsValid(GAMEMODE.FlagEntity) then
        local team = GAMEMODE.FlagEntity:GetNWString('CurrentTeam')
        if team == 'blue' then
            GAMEMODE:ScoreGoal(TEAM_BLUE)
        end
    end
end