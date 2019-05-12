AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Player loadout function
-- Gives weapons to the human teams
-- Makes the Stalker invisible and sets HP
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    
    if ply:Team() == TEAM_RED then
        -- Stalker loadout here
        ply:SetColor(Color(255, 255, 255, 10))
        ply:SetRenderMode(RENDERMODE_TRANSALPHA)
        ply:SetWalkSpeed(500)
        ply:SetRunSpeed(500)
        
        
        local hp = 150 + math.Clamp(team.NumPlayers(TEAM_BLUE), 1, 16) * 10
        ply:SetHealth(hp)
        ply:SetMaxHealth(hp)
        ply:Give('weapon_fists')
    elseif ply:Team() == TEAM_BLUE then
        -- Reset colour
        ply:SetColor(color_white)
        ply:SetRenderMode(RENDERMODE_NORMAL)
        
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(300)
        
        -- Pick from one of three random loadouts
        if math.random() > 0.8 then
            ply:Give('weapon_shotgun')
            ply:Give('weapon_pistol')
        elseif math.random() > 0.4 then
            ply:Give('weapon_smg1')
            ply:Give('weapon_pistol')
        else
            ply:Give('weapon_pistol')
        end
    end
end

-- Set player models for the Stalker
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        ply:SetModel('models/player/soldier_stripped.mdl')
    else
        ply:SetModel('models/player/combine_soldier_prisonguard.mdl')
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Make everyone start as a human
hook.Add('PreRoundStart', 'InfectionResetPlayers', function()
    for k,v in pairs(player.GetAll()) do
        if v:Team() == TEAM_SPECTATOR then continue end
        v:SetTeam(TEAM_BLUE)
    end
    
    local stalker = table.Random(team.GetPlayers(TEAM_BLUE))
    stalker:SetTeam(TEAM_RED)
    stalker:Spawn()
end)

-- Check if there enough players to start a round
function GM:CanRoundStart()
    if GAMEMODE:NumNonSpectators() >= 2 then
        return true
    else
        return false
    end
end

-- Make new players join the Hunter team on connection
function GM:PlayerInitialSpawn(ply)
    ply:SetTeam(TEAM_BLUE)
end

-- No fall damage
function GM:GetFallDamage()
    return 0
end

-- Flashlight enabled for humans only
function GM:PlayerSwitchFlashlight(ply, state)
    return (ply:Team() == TEAM_BLUE)
end

-- Stop any form of team swapping in this gamemode
-- Teams are rigorously chosen before the round starts
hook.Add('PlayerCanJoinTeam', 'StopTeamSwap', function(ply, team)
    if ply:Team() == TEAM_RED or team == TEAM_RED then return false end
end)

-- Movement tricks for the Stalker
-- This includes super jumping and the ability to stick to walls
hook.Add('KeyPress', 'StalkerMovementTricks', function(ply, key)
    if ply:Team() != TEAM_RED then return end
    
    if key == IN_SPEED then
        if ply:OnGround() and (ply.JumpTime or 0) < CurTime() then
            -- Jump into the air
            local jump = ply:GetAimVector() * 500 + Vector(0, 0, 200)
            ply:SetVelocity(jump)
            ply.JumpTime = CurTime() + 1
        else
            -- Stick to walls check
            local tr = util.TraceLine(util.GetPlayerTrace(ply))
            if tr.HitPos:DistToSqr(ply:GetShootPos()) < 2500 and not ply:OnGround() then
                ply:SetMoveType(MOVETYPE_NONE)
            elseif ply:GetMoveType() == MOVETYPE_NONE then
                ply:SetMoveType(MOVETYPE_WALK)
                ply:SetLocalVelocity(ply:GetAimVector() * 400)
            end
        end
    elseif key == IN_JUMP and ply:GetMoveType() == MOVETYPE_NONE then
        -- Unstick from walls
        ply:SetMoveType(MOVETYPE_WALK)
        ply:SetLocalVelocity(Vector(0, 0, 50))
    end
end)

-- Buff fists
hook.Add('EntityTakeDamage', 'FistsBuff', function(target, dmg)
    local wep = dmg:GetInflictor()
    if wep:GetClass() == 'player' then wep = wep:GetActiveWeapon() end
    if wep:GetClass() == "weapon_fists" then
        dmg:ScaleDamage(4)
    end
end)