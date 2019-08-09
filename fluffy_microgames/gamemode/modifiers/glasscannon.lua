-- Glass Cannon
-- Random weapons with 1HP
MOD = {
    name = 'Glass Cannon',
    subtext = 'One shot. One kill.',
    func_player = function(ply)
        GAMEMODE:PickRandomWeapons(CurTime(), 1)(ply)
        ply:SetMaxHealth(1)
        ply:SetHealth(1)
    end 
}