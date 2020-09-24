DeriveGamemode("fluffy_mg_base")
include("tables.lua")
include("ply_extension.lua")
GM.Name = "Poltergeist"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    Angry ghosts are out to kill all humans!
    
    Humans have to survive until the round ends to win.
    Humans that die will join the angry ghosts.
    
    Poltergeists:
     Primary: dash attack. Best with large props.
     Reload to change props
     Secondary: explosion. Best with smaller props.
    
    Humans:
     Shoot the props to destroy them
     Don't get killed
]]
GM.TeamBased = true -- Is the gamemode FFA or Teams?
GM.TeamSurvival = true
GM.SurvivorTeam = TEAM_BLUE
GM.HunterTeam = TEAM_RED
GM.RoundNumber = 10 -- How many rounds?
GM.RoundTime = 60 -- Seconds each round lasts for
GM.ForceFFAColors = true -- Force team gamemodes to use FFA colors
GM.HUDStyle = HUD_STYLE_CLOCK_ALIVE
TEAM_RED = 1
TEAM_BLUE = 2

function GM:CreateTeams()
    if not GAMEMODE.TeamBased then return end
    team.SetUp(TEAM_RED, "Poltergeists", TEAM_COLORS["red"], true)

    team.SetSpawnPoint(TEAM_RED, {"info_player_start", "info_player_counterterrorist", "info_player_combine"}, true)

    team.SetUp(TEAM_BLUE, "Humans", TEAM_COLORS["blue"], true)

    team.SetSpawnPoint(TEAM_BLUE, {"info_player_start", "info_player_terrorist", "info_player_rebel", "info_player_deathmatch"})

    team.SetUp(TEAM_SPECTATOR, "Spectators", Color(255, 255, 80), true)

    team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_start", "info_player_terrorist", "info_player_combine"})
end

-- Hide all cosmetics on Poltergeists
hook.Add("ShouldDrawCosmetics", "HideHunterCosmetics", function(ply, ITEM)
    if ply:Team() == TEAM_RED then return false end
end)