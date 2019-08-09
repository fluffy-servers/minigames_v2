-- Rocket Jump
-- Players can only move by jumping
MOD = {
    name = 'Rocket Jump',
    subtext = 'Do not use the rockets to jump.',
    func_player = function(ply)
        ply:Give('weapon_rpg')
        ply:GiveAmmo(10, 'RPG_Round')
        ply:SetRunSpeed(1)
        ply:SetWalkSpeed(1)
        ply:SetJumpPower(500)
    end
}