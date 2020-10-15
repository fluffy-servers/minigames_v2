DeriveGamemode("fluffy_mg_base")
GM.Name = "Duck Hunt"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    Runners have to make it to the end before getting sniped!
    
    Runners that die will become Snipers.
    
    Runners
     Run! Make it to the end of the course as fast as you can!
     Try and dodge all the bullets flying at you.
     
    Snipers
     Shoot the Runners before they make it to the end
]]
TEAM_RED = 1
TEAM_BLUE = 2
-- Configure teams for Hunter vs Hunted
GM.TeamBased = true
GM.TeamSurvival = true
GM.SurvivorTeam = TEAM_BLUE
GM.HunterTeam = TEAM_RED
GM.RoundNumber = 10 -- How many rounds?
GM.RoundTime = 90 -- How long should each round go for?
GM.RoundCooldown = 5 -- How long between each round?
GM.CanSuicide = false -- Should players be able to die at will? :(
GM.ThirdPersonEnabled = false -- This gamemode overrides some functions to do with this
GM.SpawnProtection = true -- Spawn protection enabled
GM.SpawnProtectionTime = 5 -- Increased spawn protection time for runners
GM.HUDStyle = HUD_STYLE_CLOCK_ALIVE

function GM:CreateTeams()
    if (not GAMEMODE.TeamBased) then return end
    team.SetUp(TEAM_RED, "Snipers", TEAM_COLORS["red"], true)

    team.SetSpawnPoint(TEAM_RED, {"info_player_terrorist", "info_player_combine"})

    team.SetUp(TEAM_BLUE, "Runners", TEAM_COLORS["blue"], true)

    team.SetSpawnPoint(TEAM_BLUE, {"info_player_counterterrorist", "info_player_rebel"})

    team.SetUp(TEAM_SPECTATOR, "Spectators", Color(255, 255, 80), true)

    team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_start", "info_player_terrorist", "info_player_combine"})
end