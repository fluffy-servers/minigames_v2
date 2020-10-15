﻿AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_player_extension.lua")

GM.BarrelModels = {"models/props_c17/oildrum001_explosive.mdl"}

GM.BarrelSkins = {0}

-- Appropriate weapon stuff
function GM:PlayerLoadout(ply)
    if ply:Team() == TEAM_BLUE then
        -- Humans get pistol ammo and the barrel killa weapon
        ply:GiveAmmo(1800, "pistol", true)
        ply:Give("weapon_barrel_killa")
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(250)
        ply:SetBloodColor(BLOOD_COLOR_RED)
    elseif ply:Team() == TEAM_RED then
        -- Make sure that barrels have no weapons
        ply:SetBloodColor(DONT_BLEED)
        ply:StripWeapons()
        ply.NextTaunt = CurTime() + 1
        ply.NextBoom = CurTime() + 2
        ply:SetWalkSpeed(300)
        ply:SetRunSpeed(175)
    end
end

function GM:ApplyBarrelModel(ply)
    local idx = math.random(#GAMEMODE.BarrelModels)
    ply:SetModel(GAMEMODE.BarrelModels[idx])
    ply:SetSkin(GAMEMODE.BarrelSkins[idx] or 0)
end

-- Pick player models
function GM:PlayerSetModel(ply)
    if ply:Team() == TEAM_RED then
        local color = team.GetColor(TEAM_RED)
        GAMEMODE:ApplyBarrelModel(ply)
        ply:SetPlayerColor(Vector(color.r / 255, color.g / 255, color.b / 255))
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Humans can still commit suicide
-- Barrels are terrifying, after all
function GM:CanPlayerSuicide(ply)
    if ply:Team() == TEAM_RED then return false end

    return true
end

-- Scoring for Suicide Barrels
function GM:HandlePlayerDeath(ply, attacker, dmginfo)
    if not attacker:IsValid() or not attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important

    if attacker:Team() == TEAM_RED then
        -- Barrel killed human
        attacker:AddFrags(5)
        GAMEMODE:AddStatPoints(attacker, "Humans Killed", 1)
    elseif attacker:Team() == TEAM_BLUE then
        -- Human killed barrel
        attacker:AddFrags(1)
        GAMEMODE:AddStatPoints(attacker, "Barrels Killed", 1)
    end
end

-- Track survived rounds
function GM:StatsRoundWin(winners)
    if winners == TEAM_BLUE then
        for k, v in pairs(team.GetPlayers(TEAM_BLUE)) do
            if v:Alive() then
                GAMEMODE:AddStatPoints(v, "Survived Rounds", 1)
            end
        end
    end
end

-- Register XP for Suicide Barrels
hook.Add("RegisterStatsConversions", "AddSuicideBarrelsStatConversions", function()
    GAMEMODE:AddStatConversion("Humans Killed", "Humans Killed", 3)
    GAMEMODE:AddStatConversion("Barrels Killed", "Barrels Killed", 0.5)
end)

hook.Add("EntityTakeDamage", "BarrelLessSuicide", function(ply, dmg)
    if not ply:IsPlayer() then return end
    local inflictor = dmg:GetInflictor()
    if inflictor:GetClass() ~= "env_explosion" then return end
    -- Reduce damage depending on who caused this explosion
    local cause = inflictor.PlayerCause
    if not cause:IsPlayer() then return end

    if cause == ply then
        dmg:ScaleDamage(0.6)
        dmg:SetDamageForce(dmg:GetDamageForce() * 2.5)
    elseif cause:Team() == TEAM_BLUE then
        dmg:ScaleDamage(0.8)
        dmg:SetDamageForce(dmg:GetDamageForce() * 1.5)
    end
end)