MOD.Name = "Stop Moving"
MOD.RoundTime = 1.5

function MOD:Initialize()
    GAMEMODE:Announce("Quick!", "Stop moving!")
end

function MOD:PlayerFinish(ply)
    if ply:GetVelocity():LengthSqr() > 100 then
        ply:Kill()
    else
        ply:AwardWin()
    end
end
