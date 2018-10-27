--[[
    The big ol' core of the gamemode
    Probably needs to be split into some more files at this point
    But this isn't a total mess yet! Go me!
--]]

-- Send all the required files to the client
-- Very important! Don't forget!
AddCSLuaFile('avatar_circle.lua')
AddCSLuaFile('drawarc.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('cl_crosshair.lua')
AddCSLuaFile('cl_endgame.lua')
AddCSLuaFile('cl_thirdperson.lua')
AddCSLuaFile('cl_playerpanel.lua')
AddCSLuaFile('cl_scoreboard.lua')
AddCSLuaFile('cl_hud.lua')

AddCSLuaFile('vgui/MapVotePanel.lua')
AddCSLuaFile('vgui/Screen_Experience.lua')
AddCSLuaFile('vgui/Screen_Maps.lua')
AddCSLuaFile('vgui/Screen_Scoreboard.lua')

AddCSLuaFile('shared.lua')
AddCSLuaFile('sound_tables.lua')
AddCSLuaFile('sh_levels.lua')

-- Add workshop content
resource.AddWorkshop('1518438705')

-- Include useful server files
include('shared.lua')

-- Add net message
util.AddNetworkString('EndRound')
util.AddNetworkString('MinigamesGameEnd')
util.AddNetworkString('SendExperienceTable')

-- Called each time a player spawns
function GM:PlayerSpawn( ply )
    local state = GetGlobalString('RoundState', 'GameNotStarted')
    
    -- If elimination, block respawns during round
    if state != 'PreRound' and GAMEMODE.Elimination == true then
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

-- Initial spawn stuff
function GM:PlayerInitialSpawn(ply)
    -- Assign teams
    if ply:IsBot() then
        self:PlayerRequestTeam( ply, team.BestAutoJoinTeam() )
    elseif GAMEMODE.TeamBased then
        ply:ConCommand( "gm_showteam" )
    else
        ply:SetTeam( TEAM_UNASSIGNED )
    end
end

-- Disable friendly fire
function GM:PlayerShouldTakeDamage( victim, ply )
    if !GAMEMODE.TeamBased then return true end
    if !ply:IsPlayer() then return true end
    if ply:Team() == victim:Team() then return false end
    return true
end

-- Attempt to fix the damage scaling system
-- Don't think it worked :(
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
    return
end

-- Stop the beep beep
function GM:PlayerDeathSound()
    return false
end

-- Death function
function GM:DoPlayerDeath(ply, attacker, dmginfo)
    -- Always make the ragdoll
    ply:CreateRagdoll()
    
    -- Play a funny death sound
    if GAMEMODE.DeathSounds then
        local gender = GAMEMODE:DetermineModelGender(ply:GetModel())
        local sound = GAMEMODE:GetRandomDeathSound(gender)
        ply:EmitSound(sound)
    end

    -- Do not count deaths unless in round
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, 'deaths', 1)
    
    -- Delegate this to each gamemode (defaults are provided lower down for reference)
    GAMEMODE:HandlePlayerDeath(ply, attacker, dmginfo)
    
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important

    -- Track team kills for each round as well
    if GAMEMODE.TeamBased then
        -- Create the table if it does not exist
        if !GAMEMODE.TeamKills then 
            GAMEMODE.TeamKills = {}
            GAMEMODE.TeamKills[1] = 0
            GAMEMODE.TeamKills[2] = 0
        end
        
        -- Add the kill to the team
        local team = attacker:Team()
        if team == TEAM_SPECTATOR or team == TEAM_UNASSIGNED then return end
        GAMEMODE.TeamKills[team] = GAMEMODE.TeamKills[team] + 1
    end
end

-- Basic function to get the player with the most frags
function GM:GetWinningPlayer()
    -- Doesn't really make sense in Team gamemodes
    -- if GAMEMODE.TeamBased then return nil end
    
    -- Loop through all players and return the one with the most frags
    local bestscore = 0
    local bestplayer = nil
    for k,v in pairs( player.GetAll() ) do
        local frags = v.FFAKills or 0
        if frags > bestscore then
            bestscore = frags
            bestplayer = v
        end
    end
    
    -- Return the winner! Yay!
    return bestplayer
end

-- Fairly self-explanatory
function GM:PlayerSpawnAsSpectator( ply )
	ply:StripWeapons()
	ply.Spectating = true
    ply:Spectate( OBS_MODE_ROAMING )
    --if !GAMEMODE.TeamBased then ply:SetTeam( TEAM_SPECTATOR ) end
end

-- Convenience function to get number of living players
-- This isn't fantastically efficient don't overuse
function GM:GetLivingPlayers()
    local alive = 0
    for k,v in pairs( player.GetAll() ) do
        if v:Alive() and v:Team() != TEAM_SPECTATOR and !v.Spectating then alive = alive + 1 end
    end
    return alive
end

-- Convenience function to get number of non-spectators
-- I don't think there is actually a need for this anymore, but it's here
function GM:NumNonSpectators()
    local num = 0
    for k,v in pairs( player.GetAll() ) do
        if GAMEMODE.TeamBased then
            if v:Team() != TEAM_SPECTATOR and v:Team() != TEAM_UNASSIGNED and v:Team() != 0 then num = num + 1 end
        else
            if v:Team() != TEAM_SPECTATOR then num = num + 1 end
        end
    end

    return num
end

-- Convenience function to get number of living players in a team
function GM:GetTeamLivingPlayers( t )
    local alive = 0
    for k,v in pairs( team.GetPlayers( t ) ) do
        if v:Alive() and !v.Spectating then alive = alive + 1 end
    end
    return alive
end

-- Pick a random player
function GM:GetRandomPlayer()
    local ply = table.Random( player.GetAll() )
    while ply:Team() == TEAM_SPECTATOR do
        ply = table.Random( player.GetAll() )
    end
    
    return ply
end

-- This is for rewarding melons at the end of a game
-- Override for gamemodes with better scores
function GM:GetMVP()
	if !IsValid(fluffy_scoreboard) then return end
	
	local tbl = player.GetAll()
	local count = #tbl
	table.sort( tbl, function(a, b) return a:Frags()*-50 + a:EntIndex() < b:Frags()*-50 + b:EntIndex() end )
    return tbl[1]
end

-- Remove extra stuff on deathmatch maps
local deathmatch_remove = {
    ['item_healthcharger'] = true,
    ['item_suitcharger'] = true,
    ['weapon_crowbar'] = true,
    ['weapon_stunstick'] = true,
    ['weapon_ar2'] = true,
    ['weapon_357'] = true,
    ['weapon_pistol'] = true,
    ['weapon_crossbow'] = true,
    ['weapon_shotgun'] = true,
    ['weapon_frag'] = true,
    ['weapon_rpg'] = true,
    ['weapon_slam'] = true,
    ['item_ammo_357'] = true,
    ['item_ammo_357_large'] = true,
    ['item_ammo_pistol'] = true,
    ['item_ammo_crossbow'] = true,
    ['item_ammo_smg1_grenade'] = true,
    ['item_rpg_round'] = true,
    ['item_box_buckshot'] = true,
    ['item_healthkit'] = true,
    ['item_battery'] = true,
    ['item_ammo_ar2'] = true,
    ['item_ammo_ar2_large'] = true,
    ['item_ammo_ar2_altfire'] = true,
}
function GM:CleanUpDMStuff()
    for k,v in pairs( ents.GetAll() ) do
        if deathmatch_remove[ v:GetClass() ] then v:Remove() end
    end
end

-- [[ Default functions for round stuff ]] --
function GM:CheckRoundEnd()
    if GAMEMODE.TeamBased then
        return GAMEMODE:CheckTeamElimination()
    else
        return GAMEMODE:CheckFFAElimination()
    end
end

function GM:HandleEndRound(reason)
    if GAMEMODE.TeamBased then
        return GAMEMODE:HandleTeamWin(reason)
    else
        return GAMEMODE:HandleFFAWin(reason)
    end
end

function GM:HandlePlayerDeath(ply, attacker, dmginfo) 
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
    
    -- Add the frag to scoreboard
    attacker:AddFrags(1)
    GAMEMODE:AddStatPoints(attacker, 'kills', 1)
    
    if not GAMEMODE.TeamBased then
        attacker.FFAKills = attacker.FFAKills + 1
    end
end

-- Import the component parts
include('sv_database.lua')
include('sv_stats.lua')
include('sv_round.lua')
include('sv_voting.lua')
include('sv_player.lua')
include('sv_levels.lua')
include('gametype_hunter.lua')