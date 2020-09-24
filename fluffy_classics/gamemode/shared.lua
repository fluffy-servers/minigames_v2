DeriveGamemode('fluffy_mg_base')
include('maps.lua')

GM.Name = 'Classics'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Simple Deathmatch maps. Eliminate the others to win!

    The gameplay of this gamemode will strongly depend on the current map.
]]

GM.TeamBased = true
GM.Elimination = true
GM.WinBySurvival = true
GM.EnableFallDamage = true

GM.RoundTime = 120
GM.RoundNumber = 10

-- The "Classics" gamemode is meant to (very roughly) encompass a bunch of maps
-- These are currently defined (poorly) in maps.lua
function GM:Initialize()
    local map = game.GetMap()

    -- In the event we haven't loaded something properly yet, wait a little longer
    -- It's pretty important that this stays in sync!
    if not map or not GAMEMODE.FFAMaps then
        timer.Simple(1, function() GAMEMODE:CheckMapProperties() end)
    else
        GAMEMODE:CheckMapProperties()
    end
end

function GM:CheckMapProperties()
    local map = game.GetMap()
    if GAMEMODE.FFAMaps[map] then
        GAMEMODE.TeamBased = false
    elseif GAMEMODE.TeamSurvivalMaps[map] then
        GAMEMODE.TeamSurvival = true
        GAMEMODE.SurvivorTeam = TEAM_BLUE
        GAMEMODE.HunterTeam = TEAM_RED
    end
end

-- RED is T and BLUE is CT
-- This is different to standard Minigames teams
function GM:CreateTeams()
	if not GAMEMODE.TeamBased then return end
	
	team.SetUp(TEAM_RED, "Red Team", TEAM_COLORS['red'], true)
	team.SetSpawnPoint(TEAM_RED, TEAM_BLUE_SPAWNS)
	
	team.SetUp(TEAM_BLUE, "Blue Team", TEAM_COLORS['blue'], true)
	team.SetSpawnPoint(TEAM_BLUE, TEAM_RED_SPAWNS)

	team.SetUp(TEAM_SPECTATOR, "Spectators", Color(255, 255, 80), true)
	team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_start", "info_player_terrorist", "info_player_counterterrorist", "info_player_blue", "info_player_red"})
end

-- Default weapon spawners configuration
GM.WeaponSpawners = {
    ["spawns"] = {
        ["1"] = {'weapon_mg_knife', 'weapon_mg_pistol', 'weapon_mg_smg'},
        ["2"] = {'weapon_mg_shotgun', 'weapon_mg_smg', 'weapon_crossbow', 'weapon_357'},
        ["3"] = {'weapon_mg_sniper', 'weapon_rpg', 'weapon_mg_mortar', 'weapon_frag'}
    },

    ["ammo"] = {
        ['weapon_mg_shotgun'] = {'Buckshot', 12},
        ['weapon_mg_pistol'] = {'Pistol', 12},
        ['weapon_mg_smg'] = {'SMG1', 60},
        ['weapon_crossbow'] = {'XBowBolt', 5},
        ['weapon_357'] = {'357', 12},
        ['weapon_mg_sniper'] = {'Pistol', 12},
        ['weapon_rpg'] = {'RPG_Round', 3},
        ['weapon_mg_mortar'] = {'RPG_Round', 3},
        ['weapon_frag'] = {'Grenade', 3}
    }
}