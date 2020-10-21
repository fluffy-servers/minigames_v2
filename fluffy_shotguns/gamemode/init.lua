AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Give the player these weapons on loadout
function GM:PlayerLoadout(ply)
    ply:SetMaxHealth(100)
    ply:Give("super_shotgun")
    ply:GiveAmmo(1000, "Buckshot")
    ply:SetRunSpeed(350)
    ply:SetWalkSpeed(325)
end

-- Add frags to player & team when someone dies
function GM:HandlePlayerDeath(ply, attacker, dmginfo)
    if not attacker:IsValid() or not attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
    attacker:AddFrags(GAMEMODE.KillValue) -- Add the frag to scoreboard
    health = attacker:Health()
    attacker:SetHealth(health + 50) if health > 50 then attacker:SetHealth(100) end
    GAMEMODE:AddStatPoints(attacker, "Kills", 1) -- Add the point to the team
    if attacker:Team() ~= TEAM_RED and attacker:Team() ~= TEAM_BLUE then return end
    team.AddRoundScore(attacker:Team(), 1)
end