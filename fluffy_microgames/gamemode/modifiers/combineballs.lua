MOD.Name = 'Combine Balls'

function MOD:Loadout(ply)
    ply:Give('weapon_ar2')
    ply:StripAmmo()
    ply:SetAmmo(0, 'AR2')
    ply:GetWeapon('weapon_ar2'):SetClip1(0)
    ply:GiveAmmo(50, 'AR2AltFire')
end

function MOD:Initialize()
    GAMEMODE:Announce("Combine Balls", "Like Dodgeball, but much much worse")
end
