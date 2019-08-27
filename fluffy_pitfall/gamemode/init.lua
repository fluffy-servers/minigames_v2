AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Backwards compatibility for Pitfall maps
GM.PlatformPositions = {}
GM.PlatformPositions['pf_ocean'] = Vector(0, 0, 1500)
GM.PlatformPositions['pf_ocean_d'] = Vector(0, 0, 1500)
GM.PlatformPositions['gm_flatgrass'] = Vector(0, 0, 0)
GM.PlatformPositions['pf_midnight_v1_fix'] = Vector(0, 0, 0)
GM.PlatformPositions['pf_midnight_v1'] = Vector(0, 0, 0)

-- Color properties
-- pf_settings can edit these
GM.PColorStart = Color(0, 255, 128)
GM.PColorEnd = Color(255, 0, 128)
GM.PColorBonus = Color(255, 128, 0)
GM.PDR = GM.PColorEnd.r - GM.PColorStart.r
GM.PDG = GM.PColorEnd.g - GM.PColorStart.g
GM.PDB = GM.PColorEnd.b - GM.PColorStart.b

-- Update the above settings
function GM:UpdatePDColors()
    GAMEMODE.PDR = GAMEMODE.PColorEnd.r - GAMEMODE.PColorStart.r
    GAMEMODE.PDG = GAMEMODE.PColorEnd.g - GAMEMODE.PColorStart.g
    GAMEMODE.PDB = GAMEMODE.PColorEnd.b - GAMEMODE.PColorStart.b
end

GM.BlockOptions = {
    'circle',
    'square',
    'hexagon',
    'mixed',
    --'props',
}

-- Register the powerups using the base powerups library
hook.Add('RegisterPowerUps', 'TilesPowerUps', function()
    -- Shotgun for 10 seconds
    GAMEMODE:RegisterPowerUp('shotgun', {
        Time = 10,
        OnCollect = function(ply)
            ply:Give('weapon_shotgun')
        end,
        
        OnFinish = function(ply)
            ply:StripWeapon('weapon_shotgun')
        end,
        Text = 'Shotgun!',
    })
    
    -- Crowbar for 10 seconds
    GAMEMODE:RegisterPowerUp('crowbar', {
        Time = 10,
        OnCollect = function(ply)
            ply:Give('weapon_crowbar')
        end,
        
        OnFinish = function(ply)
            ply:StripWeapon('weapon_crowbar')
        end,
        
        Text = 'Crowbar!',
    })
end)

-- Players start with a platform breaker weapon
function GM:PlayerLoadout( ply )
    ply:Give('weapon_platformbreaker')
    ply:SetWalkSpeed(350)
    ply:SetRunSpeed(360)
    ply:SetJumpPower(200)
end

-- Handle spawns slightly differently due to the random platforms
function GM:PlayerSelectSpawn( pl )
    local spawns = ents.FindByClass( "info_player_start" )
    if(#spawns <= 0) then return false end
    local selected = table.Random( spawns )
    while selected.spawnUsed do
        selected = table.Random( spawns )
    end
    
    selected.spawnUsed = true
    return selected
end

-- Disable fall damage
function GM:GetFallDamage(ply, vel)
    return 0
end

-- Credit damage to players for Knockbacks
hook.Add('EntityTakeDamage', 'CreditPitfallKills', function(ply, dmginfo)
    if not ply:IsPlayer() then return end
    if dmginfo:GetAttacker():GetClass() == 'trigger_hurt' then
    
        if ply.LastKnockback and (CurTime() - ply.KnockbackTime) < 5 then
            attacker = ply.LastKnockback
            dmginfo:SetAttacker(attacker)
        end
    end
end)

-- Handle player death
-- It's hard to track kills in this gamemode
function GM:DoPlayerDeath(ply, attacker, dmginfo)
    -- Always make the ragdoll
    ply:CreateRagdoll()
    
    -- Do not count deaths unless in round
    if GetGlobalString('RoundState') != 'InRound' then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, 'Deaths', 1)
    
    -- Award an point to the attacker (if there is one)
    if IsValid(attacker) and attacker:IsPlayer() then
        attacker:AddFrags(1)
        attacker:AddStatPoints('Kills', 1)
    end
    
    -- Every living players earns a point
    for k,v in pairs(player.GetAll()) do
        if !v:Alive() or v == ply then continue end
        v:AddFrags(1)
        --GAMEMODE:AddStatPoints(v, 'pitfall_score', 1)
    end
end

-- Functions below this comment are for backwards-compatibility with Pitfall maps
-- This includes platform spawning, etc.
hook.Add('PreRoundStart', 'CreatePlatforms', function()
    GAMEMODE.NextPowerUp = CurTime() + 5
    
	-- Tiles maps already have platforms
    local map = game.GetMap()
    if string.StartWith(map, 'til_') then return end
    
	-- Clear the level then randomly place platforms
    local gametype = table.Random(GAMEMODE.BlockOptions)
    SetGlobalString('PitfallType', gametype)
    GAMEMODE:ClearLevel()
    GAMEMODE:SpawnPlatforms()
end )

-- Add platforms to the platforms at random intervals
hook.Add('Think', 'PowerUpThink', function()
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    if not GAMEMODE.NextPowerUp then GAMEMODE.NextPowerUp = CurTime() + 5 return end
    
    if GAMEMODE.NextPowerUp < CurTime() then
        GAMEMODE:AddPowerUp()
        GAMEMODE.NextPowerUp = CurTime() + 20
    end
end)

-- Remove any leftover entities when the level is cleared
function GM:ClearLevel()
	for k,v in pairs(ents.FindByClass( "pf_platform" )) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass( "info_player_start" )) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass( "gmod_player_start" )) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass( "info_player_terrorist" )) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass( "info_player_counterterrorist" )) do
		v:Remove()
	end
end

-- Spawn the platforms
function GM:SpawnPlatforms()
    local pos = GAMEMODE.PlatformPositions[game.GetMap()]
    if !pos then
        -- Check if this is a Trembling Tiles map
        if #ents.FindByClass('til_tile') > 0 then return end
        
        -- Check if we have markers defined
        local p = ents.FindByClass('pf_marker')
        if p and #p > 0 then
            GAMEMODE:MarkerPlatforms(p)
            return
        end
        
        -- All else fails, just generate them randomly at 0, 0, 0
        local p = Vector(0, 0, 0)
        GAMEMODE:RandomPlatforms(pos)
    else
        GAMEMODE:RandomPlatforms(pos)
    end
end

-- Generate a grid of platforms
function GM:RandomPlatforms(pos)
    -- Scaling information
    local levelscale = math.min(math.ceil(player.GetCount() / 4), 5)
    local mins = 3
    local maxs = 9
    local rows = math.random(mins + levelscale, maxs + levelscale)
    local columns = math.random(mins + levelscale, maxs + levelscale)
    local levels = math.random(1, 3 + math.floor(levelscale/2))
    if math.random() > 0.5 then levels = levels + 1 end
    
    -- Ensure everybody has a platform to stand on
    while (rows*columns) < player.GetCount() do
        rows = rows + 1
    end
    
    -- Position the platforms in the middle of the level
    local size = math.random(75, 120)
    local px = pos.x - (size*rows)/2
    local py = pos.y - (size*columns)/2
    local pz = pos.z
    
    for level = 1,levels do
        for row = 1, rows do
            for col = 1, columns do
                self:SpawnPlatform( Vector(px, py, pz), (level == 1) )
                py = py + size
            end
            
            px = px + size
            py = pos.y - (size*columns)/2
        end
        
        pz = pz - 150
        px = pos.x - (size*rows)/2
        py = pos.y - (size*columns)/2
    end
    print('Spawned platforms!')
end

-- Certain maps have platform positions predefined
-- In this case, spawn the platforms at these markers
function GM:MarkerPlatforms(ents)
    local levels = math.random(1, 3)
    if math.random() > 0.5 then levels = levels + 1 end
    
    local size = math.random(1, 5)
    
	-- Level is randomly assigned between a certain amount
	-- Each marker has a 'level' - higher levels = more platforms?
    for k,v in pairs(ents) do
        if size > v.Size then continue end
        
        for level = 1,levels do
            if level > v.MaxLevels then break end
            self:SpawnPlatform(v:GetPos(), (level == 1))
        end
    end
end

-- Spawn a platform at a given position
function GM:SpawnPlatform(pos, addspawn)
	-- Create the platform entity
	local prop = ents.Create( "pf_platform" )
	if not IsValid(prop) then return end
	prop:SetAngles( Angle( 0, 0, 0 ) )
	prop:SetPos( pos + Vector(0, 0, math.random()*math.random(-2, 2)) )
	prop:Spawn()
	prop:Activate()
    
	--- Add a spawn if required
    local spawn
    if addspawn then
        spawn = ents.Create("info_player_start")
        if not IsValid(spawn) then return end
	end
    
	-- Make sure the platform origin is perfect
	local center = prop:GetCenter()
	center.z = center.z + 24
    if addspawn then
        spawn:SetPos(center)
        spawn.spawnUsed = false
    end
end

-- Award powerups to players randomly when triggered
function GM:AddPowerUp()
    if true then return end


    local t = table.Random(GAMEMODE:GetPowerUpTypes())
    local target = false
    local platforms = ents.FindByClass('til_tile')
    if not platforms or #platforms < 1 then
        platforms = ents.FindByClass('pf_platform')
    end
    while not target do
        local ent = table.Random(platforms)
        if ent.HasPowerUp then continue end
        ent:AddPowerUp(t)
        target = true
    end
end

-- Register XP for Crate Wars
hook.Add('RegisterStatsConversions', 'AddPitfallStatConversions', function()
    GAMEMODE:AddStatConversion('Platform Damage', 'Platform Damage', 0.01)
end)