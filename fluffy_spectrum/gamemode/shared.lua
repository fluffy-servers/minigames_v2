DeriveGamemode('fluffy_mg_base')

GM.Name = 'Spectrum'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    pending
]]

GM.TeamBased = true		-- Is the gamemode FFA or Teams?
GM.Elimination = true	-- Is this gamemode elimination?
GM.WinBySurvival = false
GM.RoundTime = 90 		-- How long each round should last, in seconds
GM.RoundNumber = 10		-- How many rounds are in each game?
GM.PlayerChooseTeams = false    -- Players cannot change teams at will

function GM:Initialize()

end

-- Oh boy
function GM:CreateTeams()
	if not GAMEMODE.TeamBased then return end
    TEAM_SPAWNS = {"info_player_start"}
    TEAM_RED = 1
    TEAM_BLUE = 2
    TEAM_GREEN = 3
    TEAM_PURPLE = 4
    TEAM_YELLOW = 5
    TEAM_ORANGE = 6
    TEAM_PINK = 7
    TEAM_CYAN = 8
	
	team.SetUp(TEAM_RED, "Red Team", TEAM_COLORS['red'], true)
	team.SetSpawnPoint(TEAM_RED, TEAM_SPAWNS)
	
	team.SetUp(TEAM_BLUE, "Blue Team", TEAM_COLORS['blue'], true)
	team.SetSpawnPoint(TEAM_BLUE, TEAM_SPAWNS)
    
	team.SetUp(TEAM_GREEN, "Green Team", TEAM_COLORS['green'], true)
	team.SetSpawnPoint(TEAM_GREEN, TEAM_SPAWNS)
    
    team.SetUp(TEAM_PURPLE, "Purple Team", TEAM_COLORS['purple'], true)
	team.SetSpawnPoint(TEAM_PURPLE, TEAM_SPAWNS)
    
    team.SetUp(TEAM_YELLOW, "Yellow Team", TEAM_COLORS['yellow'], true)
	team.SetSpawnPoint(TEAM_YELLOW, TEAM_SPAWNS)
    
    team.SetUp(TEAM_ORANGE, "Orange Team", TEAM_COLORS['orange'], true)
	team.SetSpawnPoint(TEAM_ORANGE, TEAM_SPAWNS)
    
    team.SetUp(TEAM_PINK, "Pink Team", TEAM_COLORS['pink'], true)
	team.SetSpawnPoint(TEAM_PINK, TEAM_SPAWNS)
    
    team.SetUp(TEAM_CYAN, "Cyan Team", TEAM_COLORS['cyan'], true)
	team.SetSpawnPoint(TEAM_CYAN, TEAM_SPAWNS)
	
	team.SetUp(TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true)
	team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_start", "info_player_terrorist", "info_player_counterterrorist", "info_player_blue", "info_player_red"})
end