AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Give the player these weapons on loadout
function GM:PlayerLoadout(ply)
    -- Give weapons
    ply:Give("weapon_cloaker")
    ply:Give("weapon_mg_knife")
    ply:Give("weapon_mg_pistol")
    ply:Give("weapon_mg_sniper")
    ply:GiveAmmo(512, "Pistol", true)
    ply:SetNoDraw(false)
    ply:SetRunSpeed(350)
    ply:SetWalkSpeed(325)
    -- Select the sniper rifle on spawn
    ply:SelectWeapon("weapon_mg_sniper")
end

-- Add frags to player & team when someone dies
function GM:HandlePlayerDeath(ply, attacker, dmginfo)
    if not attacker:IsValid() or not attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
    -- Add the frag to scoreboard
    attacker:AddFrags(GAMEMODE.KillValue)
    GAMEMODE:AddStatPoints(attacker, "Kills", 1)
    -- Add the point to the team
    if attacker:Team() ~= TEAM_RED and attacker:Team() ~= TEAM_BLUE then return end
    team.AddRoundScore(attacker:Team(), 1)
end