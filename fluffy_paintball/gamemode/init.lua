AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Called each time a player spawns
-- Overrides the base gamemode stuff
function GM:PlayerSpawn( ply )
    local state = GAMEMODE:GetRoundState()
    
    -- If elimination, block respawns during round
    if state != 'PreRound' and (GAMEMODE.Elimination and not ply.DeathPos) then
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
    ply:EndSpectate()
end

function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()
    ply:Give('paint_pistol')
    ply:Give('paint_baton')
    --ply:Give('paint_bazooka')
    --ply:Give('paint_grenade_wep')
    --ply:Give('paint_shotgun')
    --ply:Give('paint_smg')
    --ply:Give('paint_knife')
    --ply:Give('paint_crossbow')
    ply:SetBloodColor(DONT_BLEED)
    
    ply:SetRunSpeed(300)
    ply:SetWalkSpeed(200)
    ply:SetJumpPower(160)
end

function GM:GeneratePlayerColor(ply)
    local huemin = 0
    local huemax = 360
    if ply:Team() == TEAM_RED then
        huemin = 300
        huemax = 390
    elseif ply:Team() == TEAM_BLUE then
        huemin = 180
        huemax = 270
    end
    
    local c = HSVToColor(math.random(huemin, huemax) % 360, 1, 1)
    local v = Vector(c.r/255, c.g/255, c.b/255)
    ply:SetNWVector('WeaponColor', v)
end

-- Reset paintball data on spawn
hook.Add('PreRoundStart', 'ResetPaintball', function()
    for k,v in pairs(player.GetAll()) do
        v:SetNWInt('PaintballLives', 3)
        GAMEMODE:GeneratePlayerColor(v)
    end
end)

hook.Add('PlayerDeath', 'PlayerDeathTime', function(ply)
    ply:SetNWFloat('DeathTime', CurTime())
    ply:SetNWInt('PaintballLives', ply:GetNWInt('PaintballLives', 3) - 1)
end)

-- Death thinking function
-- Handles spectating stuff + lives timing
function GM:PlayerDeathThink(ply)
    -- If outside of round, respawn dead players as spectators
    if not GAMEMODE:InRound() and not ply.Spectating then
        GAMEMODE:PlayerSpawnAsSpectator(ply)
        return
    end

    -- Handle spectating controls
    if ply.Spectating then
        GAMEMODE:SpectateControls(ply)
        return
    end

    -- Out of lives? Spawn as spectator
    if ply:GetNWInt('PaintballLives', 3) <= 0 then
        GAMEMODE:PlayerSpawnAsSpectator(ply)
        return
    end

    -- Wait for the spawn timer to finish before respawning again
    local t = CurTime() - ply:GetNWFloat('DeathTime', CurTime())
    if t > GAMEMODE.LifeTimer then
        ply:Spawn()
        ply:SetNWFloat('DeathTime', -1)
    end
end

-- Register XP for Paintball
hook.Add('RegisterStatsConversions', 'AddPaintballStatConversions', function()
    GAMEMODE:AddStatConversion('Weapons Collected', 'Weapons Collected', 0.25)
end)

-- Hide all Tracer cosmetics
-- Wouldn't be paintball without paintball tracers
hook.Add('ShouldDrawCosmetics', 'HideLaserDanceCosmetics', function(ply, ITEM)
    if ITEM.Type == 'Tracer' then return false end
end)