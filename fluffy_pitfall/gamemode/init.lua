AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_levelgen.lua")

-- Players start with a platform breaker weapon
function GM:PlayerLoadout(ply)
    ply:SetWalkSpeed(350)
    ply:SetRunSpeed(360)
    ply:SetJumpPower(200)

    -- Give weapons after the safe period has ended
    timer.Simple(GAMEMODE.RoundCooldown + GAMEMODE.SafeTime, function()
        ply:Give("weapon_platformbreaker")
    end)
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

    -- Find the position for the center platform
    local pos = GAMEMODE.PlatformPositions[game.GetMap()]
    if not pos then
        local origins = ents.FindByClass("pf_origin")
        if #origins < 1 then
            pos = Vector(0, 0, 0)
        else
            pos = origins[1]:GetPos()
        end
    end
    GAMEMODE:GenerateLevel(pos)
end)

-- Remove any leftover entities when the level is cleared
function GM:ClearLevel()
    local classes = {"pf_platform", "info_player_start", "gmod_player_start", "info_player_terrorist", "info_player_counterterrorist"}

    for _, class in pairs(classes) do
        for k,v in pairs(ents.FindByClass(class)) do
            v:Remove()
        end
    end
end

-- Register XP for Pitfall
hook.Add("RegisterStatsConversions", "AddPitfallStatConversions", function()
    GAMEMODE:AddStatConversion("Platform Damage", "Platform Damage", 0.01)
end)