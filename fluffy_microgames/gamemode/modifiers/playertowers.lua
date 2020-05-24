MOD.Name = 'Player Towers'
MOD.RoundTime = 15
MOD.Countdown = true

MOD.SurviveValue = 1

function MOD:Initialize()
    GAMEMODE:Announce("Towers", "Make a human tower!")
end

function MOD:Loadout(ply)
    ply:SetJumpPower(300)
    ply:SetRunSpeed(375)
    ply:SetWalkSpeed(300)
end

function MOD:Cleanup()
    -- Detect which players are in towers
    -- Players at the bottom of towers need to be counted too
    for k,v in pairs(player.GetAll()) do
        local ground = v:GetGroundEntity()
        if IsValid(ground) and ground:IsPlayer() then
            v.HasWon = true
            ground.HasWon = true
        end
    end
end

function MOD:PlayerFinish(ply)
    -- Award wins to players marked in the above function
    if ply.HasWon then
        ply:AwardWin(true)
    else
        ply:Kill()
    end
    ply.HasWon = nil
end