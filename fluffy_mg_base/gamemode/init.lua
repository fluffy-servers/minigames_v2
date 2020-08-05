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
AddCSLuaFile('cl_chat.lua')
AddCSLuaFile('cl_mapedits.lua')

AddCSLuaFile('vgui/AvatarCircle.lua')
AddCSLuaFile('vgui/MapVotePanel.lua')
AddCSLuaFile('vgui/ScoreboardRow.lua')

AddCSLuaFile('shop/sh_init.lua')

AddCSLuaFile('shared.lua')
AddCSLuaFile('sound_tables.lua')
AddCSLuaFile('sh_levels.lua')
AddCSLuaFile('sh_scorehelper.lua')

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
util.AddNetworkString('VisualiseMapOverrides')
util.AddNetworkString('SpectateState')

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
    ply:EndSpectate()
    
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

-- Minigames team preparation
function GM:PlayerInitialSpawn(ply)
    -- Nobody can spawn unless allowed to later
    ply:KillSilent()

    -- Open up the menu
    timer.Simple(1, function()
        if not ply:IsBot() then
            ply:ConCommand("mg_info")
        end

        if not GAMEMODE:InRound() or GAMEMODE.Elimination then
            GAMEMODE:PlayerSpawnAsSpectator(ply)
        end
    end)
    

    -- Ensure that players don't respawn if it's an elimination gamemode
    if GAMEMODE.Elimination then
        ply.FirstSpawn = true
    end

    -- Set teams to unassigned if the gamemode is not team based
    -- Otherwise, automatically assign teams (hopefully evenly..)
    if not GAMEMODE.TeamBased then
        ply:SetTeam(TEAM_UNASSIGNED)
        return
    else
        GAMEMODE:PlayerRequestTeam(ply, team.BestAutoJoinTeam())
    end
end

-- Ensure that players really stay dead
hook.Add('PlayerSpawn', 'KeepInitialDead', function(ply)
    if ply.FirstSpawn then
        ply.FirstSpawn = nil
        ply:KillSilent()
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
    ply:ConCommand("mg_info")
end

-- Rebind team menu
function GM:ShowTeam(ply)
    ply:ConCommand("mg_team")
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
    if !GAMEMODE:InRound() then return end
    
    -- Add the frag to scoreboard
    attacker:AddFrags(GAMEMODE.KillValue)
    GAMEMODE:AddStatPoints(attacker, 'Kills', 1)
    
    if GAMEMODE.TeamBased then
        -- Add the kill to the team
        local team = attacker:Team()
        if team == TEAM_SPECTATOR or team == TEAM_UNASSIGNED then return end
        team.AddRoundScore(team, 1)
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
include('sv_mapedits.lua')
include('sv_announcements.lua')
include('sv_spectating.lua')
include('sv_teams.lua')
include('gametype_hunter.lua')