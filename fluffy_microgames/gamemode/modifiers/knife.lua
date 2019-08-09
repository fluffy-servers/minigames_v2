-- Knife Battle
-- Simple deathmatch with knives
MOD = {
    name = 'Knife Battle',
    subtext = 'Stabby stab stab!',
    func_player = function(ply)
        ply:Give('weapon_mg_knife')
    end,
}