-- Crowbar Wars
-- Simple deathmatch with crowbars
MOD = {
    name = 'Crowbar Wars',
    subtext = 'The red colour hides the blood',
    func_player = function(ply)
        ply:Give('weapon_crowbar')
    end,
}