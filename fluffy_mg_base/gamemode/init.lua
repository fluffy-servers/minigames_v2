--[[
    The big ol' core of the gamemode
    Probably needs to be split into some more files at this point
    But this isn't a total mess yet! Go me!
--]]

-- Send all the required files to the client
-- Very important! Don't forget!
AddCSLuaFile('drawarc.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('cl_crosshair.lua')
AddCSLuaFile('cl_endgame.lua')
AddCSLuaFile('cl_thirdperson.lua')
AddCSLuaFile('cl_playerpanel.lua')
AddCSLuaFile('cl_scoreboard.lua')
AddCSLuaFile('cl_hud.lua')
AddCSLuaFile('cl_announcements.lua')
AddCSLuaFile('cl_killfeed.lua')

AddCSLuaFile('vgui/avatar_circle.lua')
AddCSLuaFile('vgui/MapVotePanel.lua')

AddCSLuaFile('shop/sh_init.lua')

AddCSLuaFile('shared.lua')
AddCSLuaFile('sound_tables.lua')
AddCSLuaFile('sh_levels.lua')

-- Add workshop content
resource.AddWorkshop('1518438705')
resource.AddFile('resource/fonts/BebasKai.ttf')
resource.AddFile('resource/fonts/LemonMilk.ttf')

resource.AddFile('materials/fluffy/pattern1.png')
resource.AddFile('materials/fluffy/health.png')
resource.AddFile('materials/fluffy/ammo.png')
resource.AddFile('materials/fluffy/time.png')

-- Include useful server files
include('shared.lua')

-- Add net message
util.AddNetworkString('EndRound')
util.AddNetworkString('MinigamesGameEnd')
util.AddNetworkString('SendExperienceTable')
util.AddNetworkString('MinigamesAnnouncement')
util.AddNetworkString('CoolTransition')

-- Called each time a player spawns
function GM:PlayerSpawn(ply)
    local state = GAMEMODE:GetRoundState()
    
    -- If elimination, block respawns during round
    if state != 'PreRound' and GAMEMODE.Elimination then
        self:PlayerSpawnAsSpectator(ply)
        return
    end
    
    -- Spectators should be spawned as spectators (duh)
    if ply:Team() == TEAM_SPECTATOR then
        self:PlayerSpawnAsSpectator(ply)
        return
    end
    
    -- Make sure players have a team
    if GAMEMODE.TeamBased and (ply:Team() == TEAM_UNASSIGNED or ply:Team() == 0) then
        self:PlayerSpawnAsSpectator(ply)
        return
    end
    
    -- Call functions to setup model and loadout
	hook.Call('PlayerLoadout', GAMEMODE, ply)
    hook.Call('PlayerSetModel', GAMEMODE, ply)
    ply:SetupHands()
    
    -- Exit out of spectate
    ply:UnSpectate()
    ply.Spectating = false
    
    -- Spawn protection
    if GAMEMODE.SpawnProtection then
        ply:GodEnable()
        ply:SetRenderMode(1)
        ply:SetColor(Color(255, 255, 255, 50))
        
        -- Calculate time to be in god mode for
        local god_time = GAMEMODE.SpawnProtectionTime or 3
        if not GAMEMODE:InRound() then 
            god_time = god_time + GAMEMODE.RoundCooldown
        end
        
        -- Ungodmode after given time
        timer.Simple(god_time, function()
            if IsValid(ply) then 
                ply:GodDisable()
                ply:SetRenderMode(0)
                ply:SetColor(color_white)
            end
        end)
    end
end

-- Open up team menu
hook.Add('PlayerInitialSpawn', 'DisplayTeamMenu', function(ply)
    ply:KillSilent()
    
    -- Assign teams
    if ply:IsBot() then
        GAMEMODE:PlayerRequestTeam(ply, team.BestAutoJoinTeam())
    else
        ply:ConCommand("minigames_info")
    end
    
    if not GAMEMODE.TeamBased then
        ply:SetTeam(TEAM_UNASSIGNED)
    end
end)

-- Check for server autorestart situations
-- This reloads the map if the server is currently empty and has been up for more than 2 hours
hook.Add('PlayerInitialSpawn', 'CheckServerAutoRestart', function(ply)
    if(player.GetCount() == 1 and CurTime() > 7200) then
        RunConsoleCommand("changelevel", game.GetMap())
    end
end)

-- Rebind help menu
function GM:ShowHelp(ply)
    ply:ConCommand("minigames_info")
end

-- Rebind team menu
function GM:ShowTeam(ply)
    ply:ConCommand("minigames_info")
end

function GM:PlayerRequestTeam(ply, teamid)
	if not GAMEMODE.TeamBased then return end
    
    -- Stop players joining weird teams
	if not team.Joinable(teamid) then
		ply:ChatPrint("You can't join that team")
        return 
    end
    
    -- Stop players changing teams in certain gamemodes
    if not GAMEMODE.PlayerChooseTeams then
        ply:ChatPrint("You can't change teams in this gamemode!")
    end
        
	-- Run the can join hook
	if not hook.Run('PlayerCanJoinTeam', ply, teamid) then
        return
    end
	GAMEMODE:PlayerJoinTeam(ply, teamid)
end

-- Disable friendly fire
function GM:PlayerShouldTakeDamage(victim, ply)
    if !GAMEMODE.TeamBased then return true end
    if !ply:IsPlayer() then return true end
    if ply == victim then return true end
    if ply:Team() == victim:Team() then return false end
    return true
end

-- Attempt to fix the damage scaling system
-- Don't think it worked :(
function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
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
    if GAMEMODE.DeathSounds and ply:Team() != TEAM_UNASSIGNED and not ply.Spectating then
        local gender = GAMEMODE:DetermineModelGender(ply:GetModel())
        local sound = GAMEMODE:GetRandomDeathSound(gender)
        ply:EmitSound(sound)
    end

    -- Do not count deaths unless in round
    if not GAMEMODE:InRound() then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, 'Deaths', 1)
    
    -- Delegate this to each gamemode (defaults are provided lower down for reference)
    GAMEMODE:HandlePlayerDeath(ply, attacker, dmginfo)
end

-- Basic function to get the player with the most frags
function GM:GetWinningPlayer()
    -- Doesn't really make sense in Team gamemodes
    -- if GAMEMODE.TeamBased then return nil end
    
    -- Loop through all players and return the one with the most frags
    local bestscore = 0
    local bestplayer = nil
    for k,v in pairs(player.GetAll()) do
        local frags = v.FFAKills or 0
        if frags > bestscore then
            bestscore = frags
            bestplayer = v
        end
    end
    
    -- Return the winner! Yay!
    return bestplayer
end

-- Override function to stop respawning for whatever reason
function GM:CanRespawn(ply)
    return true
end

-- Useful function to swap the current teams
function GM:SwapTeams(respawn)
    local red_players = team.GetPlayers(TEAM_RED)
    local blue_players = team.GetPlayers(TEAM_BLUE)
    local respawn = respawn or true
    
    -- Move red players to blue
    for k,v in pairs(red_players) do 
        v:SetTeam(TEAM_BLUE)
        if respawn then v:Spawn() end
    end
    
    -- Move blue players to red
    for k,v in pairs(blue_players) do 
        v:SetTeam(TEAM_RED)
        if respawn then v:Spawn() end
    end
end

-- Useful function to scramble the teams nicely
-- This is good for rebalancing if things go really badly
function GM:ShuffleTeams(respawn)
    -- Figure out what players are eligible for team swaps
    local respawn = respawn or true
    local players = {}
    local num = 0
    for k,v in pairs(player.GetAll()) do
        if v:Team() != TEAM_SPECTATOR and v:Team() != TEAM_UNASSIGNED and v:Team() != 0 then 
            num = num + 1
            table.insert(players, v)
        end
    end
    
    -- Reassign the teams
    players = table.Shuffle(players)
    for i = 1,num do
        if i%2 == 0 then 
            players[i]:SetTeam(TEAM_RED) 
        else 
            players[i]:SetTeam(TEAM_BLUE) 
        end
        
        if respawn then players[i]:Spawn() end
    end
end

-- Fisher-Yates table shuffle
function table.Shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- Test the fairness of the shuffling
-- I'm pretty sure it's fair now
function testShuffle()
    local results1 = {}
    local results2 = {}
    local resultsN = {}
    local tester = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'}
    
    for i = 1, 10000 do
        local t = table.Copy(tester)
        t = table.Shuffle(t)
        
        results1[t[1]] = (results1[t[1]] or 0) + 1
        results2[t[1]] = (results2[t[2]] or 0) + 1
        resultsN[t[#t]] = (resultsN[t[#t]] or 0) + 1
    end
    
    PrintTable(results1)
    print('-')
    PrintTable(results2)
    print('-')
    PrintTable(resultsN)
end

-- Pick a random player
function GM:GetRandomPlayer(num, forcetable)
    num = num or 1
    
    -- Return one player for compatibility
    if num == 1 and not forcetable then
        local players = GAMEMODE:GetAlivePlayers()
        return players[math.random(1, #players)]
    end
    
    local players = table.Shuffle(table.Copy(player.GetAll()))
    local output = {}
    local i = 1
    while #output < num do
        if i > #players then break end
        local p = players[i]
        i = i + 1
        if p:Team() == TEAM_SPECTATOR then continue end
        if p.Spectating then continue end
        table.insert(output, p)
    end
    
    return output -- return table
end

-- This is for rewarding melons at the end of a game
-- Override for gamemodes with better scores
function GM:GetMVP()
	if !IsValid(fluffy_scoreboard) then return end
	
	local tbl = player.GetAll()
	local count = #tbl
	table.sort(tbl, function(a, b) return a:Frags()*-50 + a:EntIndex() < b:Frags()*-50 + b:EntIndex() end)
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
    for k,v in pairs(ents.GetAll()) do
        if deathmatch_remove[ v:GetClass() ] then v:Remove() end
    end
end

function GM:HandlePlayerDeath(ply, attacker, dmginfo) 
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
    
    -- Add the frag to scoreboard
    attacker:AddFrags(GAMEMODE.KillValue)
    GAMEMODE:AddStatPoints(attacker, 'Kills', 1)
    
    if GAMEMODE.TeamBased then
        -- Add the kill to the team
        local team = attacker:Team()
        if team == TEAM_SPECTATOR or team == TEAM_UNASSIGNED then return end
        local team_kills_current = GetGlobalInt(team .. 'TeamKills')
        SetGlobalInt(team .. 'TeamKills', team_kills_current + 1)
    else
        if not attacker.FFAKills then attacker.FFAKills = 0 end
        attacker.FFAKills = attacker.FFAKills + 1
    end
end

hook.Add('GetFallDamage', 'MinigamesFallDamage', function(ply, vel)
    if !GAMEMODE.EnableFallDamage then
        return 0
    end
end)

-- Import the component parts
include('sv_database.lua')
include('sv_stats.lua')
include('sv_round.lua')
include('sv_voting.lua')
include('sv_player.lua')
include('sv_levels.lua')
include('sv_announcements.lua')
include('sv_spectating.lua')
include('gametype_hunter.lua')