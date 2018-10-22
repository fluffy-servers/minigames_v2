AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function GM:PlayerLoadout(ply)
    ply:Give("weapon_laserdance")
end

function GM:GetFallDamage()
    return 0
end

hook.Add('PlayerSpawn', 'AddLaserTrails', function(ply)
    if ply:Team() == TEAM_SPECTATOR then return end
    
    if IsValid(ply.LaserTrail) then
        SafeRemoveEntity(ply.LaserTrail)
    end
    
    local c = Color(255, 255, 255, 255)
    if GAMEMODE.TeamBased then
        c = team.GetColor( ply:Team() )
    else
        local pc = ply:GetPlayerColor()
        c.r = pc[1]*255
        c.g = pc[2]*255
        c.b = pc[3]*255
    end
    ply.LaserTrail = util.SpriteTrail(ply, 0, c, true, 32, 4, 10, 0, "trails/plasma.vmt")
end )