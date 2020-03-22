MOD.Name = 'Sticky Grenades'
MOD.Elimination = true
MOD.Region = 'empty'

function MOD:Initialize()
    GAMEMODE:Announce("Sticky Grenades", "Just to clarify: you are sticky")
end

function MOD:Loadout(ply)
    ply:SetRunSpeed(1)
    ply:SetWalkSpeed(1)
    ply:SetJumpPower(1)
    ply:Give('weapon_frag')
    ply:GiveAmmo(100, 'Grenade')
end