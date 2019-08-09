-- Combine Balls
-- Utilises the alt-fire of the AR2 weapon
MOD = {
    name = 'Combine Balls',
    subtext = 'Like Dodgeball but much much worse',
    func_player = function(ply)
        ply:Give('weapon_ar2')
        ply:StripAmmo()
        ply:SetAmmo(0, 'AR2')
        ply:GetWeapon('weapon_ar2'):SetClip1(0)
        ply:GiveAmmo(50, 'AR2AltFire')
    end
}