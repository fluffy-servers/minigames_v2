--[[
    Infection
]]
--
DeriveGamemode("fluffy_mg_base")
GM.Name = "Infection"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    Oh no! A generic zombie outbreak!
    
    Zombies have to eliminate all the humans.
    Humans have to stay alive until the round ends.
    When a human dies, they will become a zombie.
]]
TEAM_RED = 1
TEAM_BLUE = 2
-- Configure teams for Hunter vs Hunted
GM.TeamBased = true
GM.TeamSurvival = true
GM.SurvivorTeam = TEAM_BLUE
GM.HunterTeam = TEAM_RED
GM.RoundNumber = 999 -- How many rounds?
GM.RoundTime = 90 -- How long should each round go for?
GM.CanSuicide = false -- Should players be able to die at will? :(
GM.ThirdPersonEnabled = false -- This gamemode overrides some functions to do with this
GM.HUDStyle = HUD_STYLE_CLOCK_ALIVE

function GM:CreateTeams()
    if (not GAMEMODE.TeamBased) then return end
    team.SetUp(TEAM_RED, "Infected", TEAM_COLORS["green"], true)

    team.SetSpawnPoint(TEAM_RED, {"info_player_start"})

    team.SetUp(TEAM_BLUE, "Survivors", TEAM_COLORS["blue"], true)

    team.SetSpawnPoint(TEAM_BLUE, {"info_player_start"})

    team.SetUp(TEAM_SPECTATOR, "Spectators", Color(255, 255, 80), true)

    team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_start", "info_player_terrorist", "info_player_combine"})
end