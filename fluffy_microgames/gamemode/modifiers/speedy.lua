-- Speedy
-- Random weapons with faster movement speed
MOD = {
    name = 'Speedy',
    subtext = 'Think fast. Move faster.',
    func_player = function(ply)
        ply:SetRunSpeed(600)
        ply:SetWalkSpeed(400)
        GAMEMODE:PickRandomWeapons(CurTime(), 1)(ply)
    end
}