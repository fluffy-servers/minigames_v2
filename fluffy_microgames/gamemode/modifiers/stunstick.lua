-- This is the Police
-- Players get a police playermodel and a stun baton
MOD = {
    name = 'This is the Police',
    subtext = 'It\'s beating time!',
    func_player = function(ply)
        ply:SetModel('models/player/police.mdl')
        ply:Give('weapon_stunstick')
    end,
}