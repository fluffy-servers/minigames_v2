-- Flight
-- Random weapons with 0 gravity
MOD = {
    name = 'Flight',
    subtext = 'Gravity is on lunch break',
    func_player = function(ply)
        GAMEMODE:PickRandomWeapons(CurTime(), 1)(ply)
        ply:SetMoveType(4)
    end
}