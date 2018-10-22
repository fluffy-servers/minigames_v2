AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('balls.lua')

include('shared.lua')
include('ply_extension.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout( ply )
    --ply:StripWeapons()
    --ply:StripAmmo()
    ply:Give('weapon_ballgun')
end

function GM:EntityTakeDamage(ent, dmginfo)
	if not ent:IsPlayer() then return end
	if not ent:Alive() then return end
    
    local attacker = dmginfo:GetAttacker()
	
	if string.find(attacker:GetClass(),"ball") then
		dmginfo:SetDamage(0) //manually set the damage in the ball collide hooks
	end
end

hook.Add('PreRoundStart', 'ResetBallLevels', function()
    for k,v in pairs(player.GetAll()) do
        v:SetNWInt('BallLevel', 0)
    end
end )

hook.Add('DoPlayerDeath', 'ResetScore', function(ply, attacker, dmg)
    if ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then return end
    ply:ResetScore()
    ply:SetNWInt('BallLevel', 0)
    
    if attacker:IsPlayer() and attacker != ply then
        local level = attacker:GetNWInt('BallLevel', 0)
        attacker:SetNWInt('BallLevel', level+1)
        attacker:UpgradeBalls(level+1)
    end
end )