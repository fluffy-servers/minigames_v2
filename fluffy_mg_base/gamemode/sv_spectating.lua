--[[
    Spectating functionality is contained in this file

    Pending reworks!
--]]

-- Fairly self-explanatory
function GM:PlayerSpawnAsSpectator(ply, mode, target)
    if ply:Alive() then
        ply:KillSilent()
    end
    GAMEMODE:StartSpectate(ply, mode, target)
end

function GM:StartSpectate(ply, mode, target)
    mode = mode or OBS_MODE_ROAMING
    ply:Spectate(mode)

    if IsValid(target) then
        ply:SpectateEntity(target)
        ply.SpectateTarget = target
    else
        ply.SpectateTarget = nil
    end
    ply.SpectateMode = mode
    ply.Spectating = true
    
    GAMEMODE:NetworkSpectate(ply, mode, target)
end

function GM:EndSpectate(ply)
    ply:UnSpectate()
    ply.SpectateMode = nil
    ply.SpectateTarget = nil
    ply.Spectating = false

    GAMEMODE:NetworkSpectate(ply, -1)
end

function GM:NetworkSpectate(ply, mode, target)
    net.Start('SpectateState')
    net.WriteInt(mode or -1, 8)
    net.WriteEntity(target or Entity(-1))
    net.Send(ply)
end

function GM:NextSpectateTarget(ply, direction)
    direction = direction or 1

    -- TEAM_SPECTATOR can spectate anyone
    -- other players can only spectate their team
    local players = player.GetAll()
    if ply:Team() != TEAM_SPECTATOR then
        players = team.GetPlayers(ply:Team())
    end

    -- Build the spectate target list, finding our current target
    local targets = {}
    local index = 1
    for k, v in pairs(players) do
        if not v:Alive() then continue end
        table.insert(targets, v)
        if v == ply.SpectateTarget then index = #targets end
    end

    -- Spectate the next player in the queue
    if #targets > 0 then
        index = index + direction
        if index > #targets then index = 1 end
        if index < 1 then index = #targets end

        if IsValid(targets[index]) then
            local mode = ply.SpectateMode
            if mode == OBS_MODE_ROAMING then mode = OBS_MODE_CHASE end

            GAMEMODE:StartSpectate(ply, mode, targets[index])
            return
        end
    end
    
    GAMEMODE:StartSpectate(ply, OBS_ROAMING)
end

-- Spectating controls
function GM:SpectateControls(ply)
    if ply:KeyPressed(IN_JUMP) and ply.SpectateMode != OBS_MODE_ROAMING then
        -- "Jump" out of chase spectate mode
        -- This preserves eye angles to keep this nice and smooth
        ply.SpectateLastEyes = ply:EyeAngles()
        GAMEMODE:StartSpectate(ply, OBS_MODE_ROAMING)
        ply:SetEyeAngles(ply.SpectateLastEyes)
    elseif ply:KeyPressed(IN_DUCK) and IsValid(ply.SpectateTarget) then
        -- Toggle between chase and in-eye spectate mode when player is selected
        local mode = OBS_MODE_CHASE
        if ply.SpectateMode == OBS_MODE_CHASE then
            ply.SpectateLastEyes = ply:EyeAngles() 
            mode = OBS_MODE_IN_EYE 
        end
        GAMEMODE:StartSpectate(ply, mode, ply.SpectateTarget)

        if mode == OBS_MODE_CHASE then
            ply:SetEyeAngles(ply.SpectateLastEyes)
        end
    elseif ply:KeyPressed(IN_ATTACK) then
        -- Change spectating targets
        -- This will cycle through the list of possible players if applicable
        -- If in roaming mode, clicking on a player will jump into them
        if ply.SpectateMode == OBS_MODE_ROAMING then
            if ply:GetEyeTrace().Entity:IsPlayer() then
                GAMEMODE:StartSpectate(ply, OBS_MODE_CHASE, ply:GetEyeTrace().Entity)
                ply.SpectateLastEyes = ply:EyeAngles()
            else
                GAMEMODE:NextSpectateTarget(ply, 1)
            end
        else
            GAMEMODE:NextSpectateTarget(ply, 1)
        end
    elseif ply:KeyPressed(IN_ATTACK2) then
        -- Similar to the above code, except moving in reverse, and without roam jump
        GAMEMODE:NextSpectateTarget(ply, -1)
    end
end

-- Death thinking hook
-- Used as a replacement to slightly broken spectating
function GM:PlayerDeathThink(ply)
    -- If outside of round, respawn dead players as spectators
    if not GAMEMODE:InRound() then
        GAMEMODE:PlayerSpawnAsSpectator(ply)
        return
    end

    -- Handle spectating controls
    if ply.Spectating then
        GAMEMODE:SpectateControls(ply)
        return
    end

    ply.DeathTime = ply.DeathTime or CurTime()
    local t = CurTime() - ply.DeathTime
    
    -- Move players to spectate mode
    local dlt = GAMEMODE.DeathLingerTime or -1
    if dlt > 0 and t > dlt and ply:GetObserverMode() != OBS_MODE_ROAMING then
        GAMEMODE:PlayerSpawnAsSpectator(ply)
        return
    end
    
    -- Make sure players can respawn
    if GAMEMODE.Elimination then return false end
    if not GAMEMODE:CanRespawn(ply) then return false end
    if t < (GAMEMODE.RespawnTime or 2) then return end
    
    -- Respawn players when pressing buttons
    if GAMEMODE.AutoRespawn or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then
        ply:Spawn()
    end
end