AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_levelgen.lua")

-- Backwards compatibility for Pitfall maps
GM.PlatformPositions = {}
GM.PlatformPositions["pf_ocean"] = Vector(0, 0, 0)
GM.PlatformPositions["pf_ocean_d"] = Vector(0, 0, 0)
GM.PlatformPositions["gm_flatgrass"] = Vector(0, 0, 0)
GM.PlatformPositions["pf_midnight_v1_fix"] = Vector(0, 0, 0)
GM.PlatformPositions["pf_midnight_v1"] = Vector(0, 0, 0)

-- Color properties
-- pf_settings can edit these
GM.PColorStart = Color(0, 255, 128)
GM.PColorEnd = Color(255, 0, 128)
GM.PDR = GM.PColorEnd.r - GM.PColorStart.r
GM.PDG = GM.PColorEnd.g - GM.PColorStart.g
GM.PDB = GM.PColorEnd.b - GM.PColorStart.b

-- Update the above settings
function GM:UpdatePDColors()
    GAMEMODE.PDR = GAMEMODE.PColorEnd.r - GAMEMODE.PColorStart.r
    GAMEMODE.PDG = GAMEMODE.PColorEnd.g - GAMEMODE.PColorStart.g
    GAMEMODE.PDB = GAMEMODE.PColorEnd.b - GAMEMODE.PColorStart.b
end

-- Players start with a platform breaker weapon
function GM:PlayerLoadout(ply)
    ply:Give("weapon_platformbreaker")
    ply:SetWalkSpeed(350)
    ply:SetRunSpeed(360)
    ply:SetJumpPower(200)
end

-- Handle spawns slightly differently due to the random platforms
function GM:PlayerSelectSpawn(ply)
    local spawns = ents.FindByClass("info_player_start")
    if (#spawns <= 0) then return false end
    local selected = table.Random(spawns)

    while selected.spawnUsed do
        selected = table.Random(spawns)
    end

    selected.spawnUsed = true

    return selected
end

-- Credit damage to players for Knockbacks
hook.Add("EntityTakeDamage", "CreditPitfallKills", function(ply, dmginfo)
    if not ply:IsPlayer() then return end

    if dmginfo:GetAttacker():GetClass() == "trigger_hurt" and ply.LastKnockback and (CurTime() - ply.KnockbackTime) < 5 then
        local attacker = ply.LastKnockback
        dmginfo:SetAttacker(attacker)
    end
end)

-- Handle player death
-- Tracking kills is difficult
function GM:DoPlayerDeath(ply, attacker, dmginfo)
    -- Always make the ragdoll
    ply:CreateRagdoll()
    -- Do not count deaths unless in round
    if not GAMEMODE:InRound() then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, "Deaths", 1)

    -- Award an point to the attacker (if there is one)
    if IsValid(attacker) and attacker:IsPlayer() then
        attacker:AddFrags(1)
        attacker:AddStatPoints("Kills", 1)
    end

    -- Every living players earns a point
    for k, v in pairs(player.GetAll()) do
        if not v:Alive() or v == ply then continue end
        v:AddFrags(1)
        --GAMEMODE:AddStatPoints(v, "pitfall_score", 1)
    end
end

-- Spawn platforms
hook.Add("PreRoundStart", "CreatePlatforms", function()
    GAMEMODE:ClearLevel()

    local pos = GAMEMODE.PlatformPositions[game.GetMap()] or Vector(0, 0, 0)
    GAMEMODE:GenerateLevel(pos)
end)

-- Remove any leftover entities when the level is cleared
function GM:ClearLevel()
    for k, v in pairs(ents.FindByClass("pf_platform")) do
        v:Remove()
    end

    for k, v in pairs(ents.FindByClass("info_player_start")) do
        v:Remove()
    end

    for k, v in pairs(ents.FindByClass("gmod_player_start")) do
        v:Remove()
    end

    for k, v in pairs(ents.FindByClass("info_player_terrorist")) do
        v:Remove()
    end

    for k, v in pairs(ents.FindByClass("info_player_counterterrorist")) do
        v:Remove()
    end
end

-- Register XP for Pitfall
hook.Add("RegisterStatsConversions", "AddPitfallStatConversions", function()
    GAMEMODE:AddStatConversion("Platform Damage", "Platform Damage", 0.01)
end)