AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Called each time a player spawns
-- Overrides the base gamemode stuff
function GM:PlayerSpawn( ply )
    local state = GetGlobalString('RoundState', 'GameNotStarted')
    
    -- If elimination, block respawns during round
    if state != 'PreRound' and (GAMEMODE.Elimination == true and not ply.DeathPos) then
        self:PlayerSpawnAsSpectator( ply )
        return
    end
    
    -- Spectators should be spawned as spectators (duh)
    if ply:Team() == TEAM_SPECTATOR then
        self:PlayerSpawnAsSpectator( ply )
        return
    end
    
    -- Make sure players have a team
    if GAMEMODE.TeamBased and ( ply:Team() == TEAM_UNASSIGNED or ply:Team() == 0 ) then
        self:PlayerSpawnAsSpectator( ply )
        return
    end
    
    -- Call functions to setup model and loadout
	hook.Call('PlayerLoadout', GAMEMODE, ply )
    hook.Call('PlayerSetModel', GAMEMODE, ply )
    ply:SetupHands()
    
    -- Exit out of spectate
    ply:UnSpectate()
    ply.Spectating = false
end

function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:Give('paint_pistol')
    ply:Give('paint_baton')
    ply:SetBloodColor(DONT_BLEED)
    
    ply:SetRunSpeed(300)
    ply:SetWalkSpeed(200)
    ply:SetJumpPower(160)
end

-- Set the player into ghost mode
function GM:SetPlayerGhost(ply)
    -- Reset ghost variables
    ply.DeathPos = nil
    ply.DeathAng = nil
    
    local time = math.Clamp(ply.DeathTimer or 60, 0, 60)
    if time < 1 then
        ply:Kill()
        return
    end
    ply:StripWeapons()
    
    -- Ghost visuals
    ply:GodEnable()
    ply:SetRenderMode(1)
    ply:SetColor(Color(255, 255, 255, 50))
    
    -- Mild speed buff
    ply:SetRunSpeed(400)
    ply:SetWalkSpeed(400)
    ply:SetJumpPower(200)
    
    -- Network ghost state
    ply:SetNWBool('IsGhost', true)
    ply:SetNWFloat('GhostStart', CurTime())
    ply:SetNWInt('GhostTime', time)
    
    -- Eliminate the player PERMAMENTLY after this amount of time
    timer.Create(ply:AccountID() .. 'GHOST', time, 1, function()
        ply:Kill()
    end)
end

-- Unghost the player
function GM:SetPlayerUnGhost(ply)
    -- Essentially respawn the player
    ply:SetNWBool('IsGhost', false)
    timer.Simple(0.1, function() GAMEMODE:PlayerLoadout(ply) end)
    
    -- Remove ghost timer
    if timer.Exists(ply:AccountID() .. 'GHOST') then
        timer.Remove(ply:AccountID() .. 'GHOST')
    end
    
    ply:SetColor(color_white)
    ply:SetMaterial('models/props_combine/portalball001_sheet', true)
    
    -- Reduce the timer as a penalty
    local starttime = ply:GetNWFloat('GhostStart')
    local timetaken = CurTime() - starttime
    ply.DeathTimer = ply.DeathTimer - 2 - timetaken
    
    -- Ungodmode after given time
    timer.Simple(3, function()
        if IsValid(ply) then 
            ply:GodDisable()
            ply:SetRenderMode(0)
            ply:SetColor(color_white)
            ply:SetMaterial()
        end
    end)
end

-- Reset paintball data on spawn
hook.Add('PreRoundStart', 'ResetPaintball', function()
    for k,v in pairs(player.GetAll()) do
        -- Clear death data
        v.DeathPos = nil
        v.DeathAng = nil
        v.DeathTimer = 30
        
        -- Clear ghost effects
        v:SetNWBool('IsGhost', false)
        v:GodDisable()
        v:SetRenderMode(0)
        v:SetColor(color_white)
        v:SetMaterial()
        
        -- Remove ghost timer
        if timer.Exists(v:AccountID() .. 'GHOST') then
            timer.Remove(v:AccountID() .. 'GHOST')
        end
    end
end)

-- If killed by another player, enter ghost mode before dying
hook.Add('PlayerDeath', 'PaintballDeath', function(ply, inflictor, attacker)
    if ply:GetNWBool('IsGhost', false) or attacker == ply or not attacker:IsPlayer() then
        ply:SetNWBool('IsGhost', false)
        return 
    end
    
    ply.DeathPos = ply:GetPos()
    ply.DeathAng = ply:EyeAngles()
end)

-- Trigger ghost mode if applicable
hook.Add('PostPlayerDeath', 'PaintballSpawnGhost', function(ply)
    if not ply.DeathPos or not ply.DeathAng then return end
    
    ply:Spawn()
    ply:SetPos(ply.DeathPos)
    ply:SetEyeAngles(ply.DeathAng)
    GAMEMODE:SetPlayerGhost(ply)
end)