AddCSLuaFile('shared.lua')
include('shared.lua')

GM.CheckpointSound = "buttons/button17.wav"

function GM:PlayerSpawn( ply )
    local state = GetGlobalString('RoundState', 'GameNotStarted')
    -- Spectators should be spawned as spectators (duh)
    if ply:Team() == TEAM_SPECTATOR then
        self:PlayerSpawnAsSpectator( ply )
        return
    end
    
    if IsValid(ply.Melon) then ply.Melon:Remove() end
    
    ply.Melon = ents.Create('player_melon')
    ply.Melon:SetPlayer(ply)
    ply.Melon:SetPos(ply:GetPos() + Vector(0, 0, 16))
    
    ply.Melon:Spawn()
    ply:SetNWEntity('melon', ply.Melon)
    
    ply.NextCheckPoint = 1
    ply.PrevCheckPoint = 0
    
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(ply.Melon)
end

function GM:GetCheckpoint(num)
    for k,v in pairs(ents.FindByClass('checkpoint')) do
        if v:GetNumber() == num then return v end
    end
end

function GM:LastCheckpoint()
    return 10
end

function GM:HitCheckpoint(melon, num)
    local ply = melon:GetPlayer()
    num = tonumber(num)
    
    if num == ply.PrevCheckPoint then return end
    if num != ply.NextCheckPoint then
        -- Wrong way!
        print(num, ply.NextCheckPoint)
        return
    end

    if ply.NextCheckPoint == num then
        ply.PrevCheckPoint = ply.NextCheckPoint
        ply.NextCheckPoint = ply.NextCheckPoint + 1
        
        if ply.NextCheckPoint > GAMEMODE:LastCheckpoint() then
            -- Lap!
            ply.NextCheckPoint = 1
        end
        
        melon:EmitSound(GAMEMODE.CheckpointSound, 100, 100)
    end
end