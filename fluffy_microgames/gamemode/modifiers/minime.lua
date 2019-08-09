-- Mini Me
-- Random weapons with smaller playermodels
MOD = {
    name = 'Mini Me',
    subtext = 'Good things come in small packages',
	-- Make the player really small
    func_player = function(ply)
        GAMEMODE:PickRandomWeapons(CurTime(), 1)(ply)
        
        ply:SetModelScale(0.25)
        ply:SetHull(Vector(-8, -8, 0), Vector(8, 8, 18))
        ply:SetHullDuck(Vector(-8, -8, 0), Vector(8, 8, 9))
        ply:SetViewOffset(Vector(0, 0, 16))
        ply:SetViewOffsetDucked(Vector(0, 0, 8))
        
        ply:SetMaxHealth(30)
        ply:SetHealth(30)
    end,
    
	-- Reset the player to a normal size
    func_finish = function(ply)
        ply:SetModelScale(1)
        ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 72))
        ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 36))
        ply:SetViewOffset(Vector(0, 0, 64))
        ply:SetViewOffsetDucked(Vector(0, 0, 28))
        
        -- prevent getting stuck in walls
        if ply:Alive() and not ply.Spectating then ply:Spawn() end
    end,
}