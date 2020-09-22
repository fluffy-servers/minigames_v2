﻿AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()
    ply:Give('weapon_physcannon')
    --ply:Give('db_launcher')
end

-- Add a new ball to the field
function GM:SpawnBall()
    if not GAMEMODE:InRound() then return end
    -- Pick spawns in a 'sequential order', looping around
    -- This should allow random ball spawns while limiting collisions
    -- Spawn 'queue' is shuffled at the start of each round
    local pos = GAMEMODE.SpawnEntities[GAMEMODE.CurrentSpawn]:GetPos()
    GAMEMODE.CurrentSpawn = GAMEMODE.CurrentSpawn + 1

    if GAMEMODE.CurrentSpawn >= #GAMEMODE.SpawnEntities then
        GAMEMODE.CurrentSpawn = 1
    end

    -- Spawn a ball at the given position
    local ball = ents.Create('db_dodgeball')
    if not IsValid(ball) then return end
    ball:SetPos(pos + (VectorRand() * 32))
    ball:Spawn()
    ball:SetNWString('CurrentTeam', 'none')

    return ball
end

-- Reset the ball counter on round start
hook.Add('RoundStart', 'InitialSpawnFlag', function()
    GAMEMODE.BallNumber = 0
    GAMEMODE.CurrentSpawn = 1
    GAMEMODE.SpawnEntities = table.Shuffle(ents.FindByClass('db_ballspawn'))

    timer.Simple(1, function()
        GAMEMODE:SpawnBall()
    end)

    timer.Simple(2, function()
        GAMEMODE:SpawnBall()
    end)

    timer.Simple(3, function()
        GAMEMODE:SpawnBall()
    end)

    GAMEMODE.NextSpawn = CurTime() + 5
end)

-- Add a new ball to the field every 20 seconds
hook.Add("Think", "ThinkBallSpawn", function()
    if not GAMEMODE:InRound() then return end
    if not GAMEMODE.NextSpawn then return end

    if CurTime() > GAMEMODE.NextSpawn then
        GAMEMODE:SpawnBall()
        GAMEMODE.NextSpawn = CurTime() + math.random(2, 5)
    end
end)

-- Change color and team when a ball is picked up
function GM:CollectBall(ball, team)
    if ball:GetClass() ~= 'db_dodgeball' then return end
    -- Determine the new colour
    local c = Vector(1, 1, 1)
    local name = 'none'

    if team == TEAM_RED then
        c = Vector(1, 0.3, 0.3)
        name = 'red'
    elseif team == TEAM_BLUE then
        c = Vector(0.3, 0.3, 1)
        name = 'blue'
    end

    ball:SetNWString('CurrentTeam', name)
    ball:SetNWVector('RColor', c)
end

-- Handle collection when the gravity gun picks up a ball
function GM:GravGunOnPickedUp(ply, ent)
    if ply:Team() ~= TEAM_BLUE and ply:Team() ~= TEAM_RED then return end

    if ent:GetClass() == 'db_dodgeball' then
        GAMEMODE:CollectBall(ent, ply:Team())
        ent:ResetTracer()
        ent.LastTime = CurTime()
        ent.LastHolder = ply
        ent.CurrentBounces = 0
    end
end

-- Make punting dodgeballs still switch the ball to the team
function GM:GravGunPunt(ply, ent)
    if ply:Team() ~= TEAM_BLUE and ply:Team() ~= TEAM_RED then return end

    if ent:GetClass() == 'db_dodgeball' then
        GAMEMODE:CollectBall(ent, ply:Team())
        ent.LastTime = CurTime()
        ent.LastHolder = ply
        ent.CurrentBounces = 0
        ent:MakeTracer(ply)

        return true
    end
end

-- Dissolve players that get hit by dodgeballs
function GM:EntityTakeDamage(target, dmginfo)
    if target:IsPlayer() then
        local inflictor = dmginfo:GetInflictor()

        if inflictor:GetClass() == "db_dodgeball" then
            dmginfo:SetDamageType(DMG_DISSOLVE)
        end
    end
end