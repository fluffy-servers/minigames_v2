MOD.Name = 'Player Towers'
MOD.RoundTime = 15
MOD.Countdown = true

MOD.SurviveValue = 1

function MOD:Initialize()
    GAMEMODE:Announce("Towers", "Get on top of another player!")
end

function MOD:Loadout(ply)
    ply:SetJumpPower(300)
    ply:SetRunSpeed(375)
    ply:SetWalkSpeed(300)
end

function MOD:PlayerFinish(ply)
    local ground = ply:GetGroundEntity()
    if IsValid(ground) and ground:IsPlayer() then
        ply:AwardWin(true)
    else
        ply:Kill()
    end
end