--[[
    Spectating functionality is contained in this file

    Pending reworks!
--]]

-- Fairly self-explanatory
function GM:PlayerSpawnAsSpectator(ply, mode, target)
	ply:StripWeapons()
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
end

function GM:EndSpectate(ply)
    ply:UnSpectate()
    ply.SpectateMode = nil
    ply.SpectateTarget = nil
    ply.Spectating = false
end

-- Death thinking hook
-- Used as a replacement to slightly broken spectating
function GM:PlayerDeathThink(ply)
    -- If outside of round, respawn dead players as spectators
    if not GAMEMODE:InRound() then
        GAMEMODE:PlayerSpawnAsSpectator(ply)
        return
    end

    if ply.Spectating then return end

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