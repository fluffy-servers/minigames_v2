AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Give the player the fancy knockback gun
function GM:PlayerLoadout(ply)
    ply:Give("weapon_laserdance")
end

-- Add laser trails to players that spawn
hook.Add('PlayerSpawn', 'AddLaserTrails', function(ply)
	-- Don't duplicate the laser trail
    if IsValid(ply.LaserTrail) then
        SafeRemoveEntity(ply.LaserTrail)
    end
    if ply:Team() == TEAM_SPECTATOR then return end
    
	-- Assign the trail based on the player (or team?) colour
    local c = Color(255, 255, 255, 255)
    if GAMEMODE.TeamBased then
        c = team.GetColor(ply:Team())
    else
        local pc = ply:GetPlayerColor()
        c.r = pc[1]*255
        c.g = pc[2]*255
        c.b = pc[3]*255
    end
    ply.LaserTrail = util.SpriteTrail(ply, 0, c, true, 32, 4, 10, 0, "trails/plasma.vmt")
end)

hook.Add('DoPlayerDeath', 'RemoveLaserTrails', function(ply)
    if IsValid(ply.LaserTrail) then
        ply.LaserTrail:Remove()
    end
end)