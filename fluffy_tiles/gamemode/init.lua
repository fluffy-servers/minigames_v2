AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
include('sv_powerups.lua')

-- Backwards compatibility for Pitfall maps
GM.PlatformPositions = {}
GM.PlatformPositions['pf_ocean'] = Vector(0, 0, 1500)
GM.PlatformPositions['pf_ocean_d'] = Vector(0, 0, 1500)
GM.PlatformPositions['gm_flatgrass'] = Vector(0, 0, 0)
GM.PlatformPositions['pf_midnight_v1_fix'] = Vector(0, 0, 0)
GM.PlatformPositions['pf_midnight_v1'] = Vector(0, 0, 0)

GM.BlockOptions = {
    'circle',
    'square',
    --'triangle',
    'mixed',
    --'props',
}

hook.Add('RegisterPowerUps', 'TilesPowerUps', function()
    GM:RegisterPowerup('shotgun', {
        Time = 10,
        OnCollect = function(ply)
            ply:Give('weapon_shotgun')
        end,
        
        OnFinish = function(ply)
            ply:StripWeapon('weapon_shotgun')
        end,
        Text = 'Shotgun!',
    })
end)

function GM:PlayerLoadout( ply )
    ply:Give( 'weapon_platformbreaker' )
    ply:SetWalkSpeed( 350 )
    ply:SetRunSpeed( 360 )
    ply:SetJumpPower(200)
end

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

function GM:GetFallDamage( ply, vel )
    return vel/7
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
    -- Always make the ragdoll
    ply:CreateRagdoll()
    
    -- Do not count deaths unless in round
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, 'deaths', 1)
    
    -- Every living players earns a point
    for k,v in pairs(player.GetAll()) do
        if !v:Alive() or v == ply then continue end
        v:AddFrags(1)
        GAMEMODE:AddStatPoints(v, 'pitfall_score', 1)
    end
end

-- Functions below this comment are for backwards-compatibility with Pitfall maps
-- This includes platform spawning, etc.
hook.Add('PreRoundStart', 'CreatePlatforms', function()
    local map = game.GetMap()
    if string.StartWith(map, 'til_') then return end
    
    local gametype = table.Random(GAMEMODE.BlockOptions)
    SetGlobalString('PitfallType', gametype)
    
    GAMEMODE:ClearLevel()
    GAMEMODE:SpawnPlatforms()
    GAMEMODE.NextPowerup = CurTime() + 5
end )

hook.Add('Think', 'PowerupThink', function()
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    --if not GAMEMODE.NextPowerup then GAMEMODE.NextPowerup = CurTime() + 5 return end
    
    if GAMEMODE.NextPowerup < CurTime() then
        GAMEMODE:AddPowerUp()
        GAMEMODE.NextPowerup = CurTime() + 20
    end
end)

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

function GM:SpawnPlatforms()
    local pos = GAMEMODE.PlatformPositions[ game.GetMap() ]
    if !pos then return end
    local players = #player.GetAll()
    players = math.ceil( players/3 )
    local num = 3 + (players*2)
    local size = 200
    
    local px = pos.x - (size*num)/2
    local py = pos.y - (size*num)/2
    local pz = pos.z
    
    for row = 1,num do
        for col=1,num do
            self:SpawnPlatform( Vector( px, py, pz ), true )
            self:SpawnPlatform( Vector( px, py, pz - 160 ), false )
            self:SpawnPlatform( Vector( px, py, pz - 320 ), false )
            py = py + size
        end
        
        px = px + size
        py = pos.y - (size*num)/2
    end
end

function GM:SpawnPlatform(pos, addspawn)
	local prop = ents.Create( "pf_platform" )
	if ( !prop ) then return end
	prop:SetAngles( Angle( 0, 0, 0 ) )
	prop:SetPos( pos )
	prop:Spawn()
	prop:Activate()
    
    local spawn
    if addspawn then
        spawn = ents.Create("info_player_start")
        if ( !spawn ) then return end
	end
    
	local center = prop:GetCenter()
	center.z = center.z + 24
    if addspawn then
        spawn:SetPos(center)
        spawn.spawnUsed = false
    end
end

function GM:AddPowerUp()
    local t = table.Random(GAMEMODE.PowerUpTypes)
    local target = false
    local platforms = ents.FindByClass('til_tile')
    while not target do
        local ent = table.Random(platforms)
        if ent.HasPowerUp then continue end
        ent:AddPowerUp(t)
        target = true
    end
end