MOD.Name = "Social Distancing"
MOD.RoundTime = 5
MOD.SurviveValue = 1

function MOD:Initialize()
    GAMEMODE:Announce("Social Distancing", "Keep away from everyone else!")
end

function MOD:PlayerFinish(ply)
    local nearby = ents.FindInSphere(ply:GetPos(), 160)

    for k, v in pairs(nearby) do
        if v:IsPlayer() and v ~= ply then
            ply:Kill()
            break
        end
    end
end