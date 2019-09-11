AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

AddCSLuaFile('player_class/class_ghost.lua')

include('shared.lua')
include( "ply_extension.lua" ) 
include( "tables.lua" )

function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    
    if ply:Team() == TEAM_BLUE then
		-- Give humans the prop killer weapon
        ply:Give( "weapon_propkilla" )
        ply:SetWalkSpeed( 250 )
        ply:SetRunSpeed( 300 )
    elseif ply:Team() == TEAM_RED then
		-- Reset timers for Poltergeists
        ply.SwapTime = 0
        ply.TauntTime = 0
		ply.AttackTime = 0
		ply.Exploding = false
        ply.Speed = 10
        ply:SpawnProp( 100 )
    end
end

--[[ Called for round setup time ]]--
-- Modified in Poltergeist to stop map cleanups
function GM:PreStartRound()
    local round = GetGlobalInt('RoundNumber', 0 )
    -- End the game if enough rounds have been played
    if round >= GAMEMODE.RoundNumber then
        GAMEMODE:EndGame()
        return
    end
    
    if GAMEMODE.TeamBased then
        GAMEMODE.TeamKills = nil
    end
    
    -- Set global round data
    SetGlobalInt('RoundNumber', round + 1 )
    SetGlobalString( 'RoundState', 'PreRound' )
	SetGlobalFloat( 'RoundStart', CurTime() )
    hook.Call('PreRoundStart')
    
    -- Respawn everybody & freeze them until the round actually starts
    for k,v in pairs( player.GetAll() ) do
        v:Spawn()
        v:Freeze( true )
    end
    
    -- Start the round after a short cooldown
    timer.Simple( GAMEMODE.RoundCooldown, function() GAMEMODE:StartRound() end )
end

-- Spawn props at all the prop spawners
function GM:SpawnProps()
    for k,v in pairs(ents.FindByClass('prop_spawner')) do
        v:SpawnProp()
    end
end

-- Spawn some initial props to populate the map at the very start
hook.Add('InitPostEntity', 'PopulateStartingProps', function()
    for i = 1,10 do
        timer.Simple(i*2, function() GAMEMODE:SpawnProps() end)
    end
end )

-- Pick player models
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        ply:SetModel( "models/props_junk/wood_crate001a.mdl" )
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Stop Poltergeists from exploding
function GM:CanPlayerSuicide(ply)
   if ply:Team() == TEAM_RED then return false end
   return true
end

-- Fix a spawning bug for Poltergeists
hook.Add('RoundStart', 'FixGhostBug', function()
    for k,v in pairs( team.GetPlayers( TEAM_RED ) ) do
        v:Spawn()
    end
end )

-- Damage hooks
-- Complicated mess for calculating attackers?
function GM:EntityTakeDamage( ent, dmginfo )
	local attacker = dmginfo:GetAttacker()
	if not ent:IsPlayer() then
		if ent:GetOwner() and ent:GetOwner():IsValid() then
			if dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():IsPlayer() then
				ent:EmitSound( Sound( table.Random( GAMEMODE.PropHit ) ) )
				ent:GetOwner():SetHealth( ent:GetOwner():Health() - dmginfo:GetDamage() )
				if ent:GetOwner():Health() < 1 then
					ent:EmitSound( Sound( table.Random( GAMEMODE.PropDie ) ) )
					ent:GetOwner():Kill()
				end
			end
			dmginfo:SetDamage( 0 )
		end
		return
	end
	
	if not ent:Alive() then return end
	if string.find( attacker:GetClass(), "prop_phys" ) then
		if attacker:GetOwner() and attacker:GetOwner():IsValid() then
			dmginfo:SetAttacker( attacker:GetOwner() ) 
		end
	end
end

