MOD.Name = "Police"
MOD.RoundTime = 25
MOD.Elimination = true

function MOD:Initialize()
    GAMEMODE:Announce("Police!", "Stop resisting!")
end

function MOD:Loadout(ply)
    ply:SetModel("models/player/police.mdl")
    ply:Give("weapon_stunstick")
end