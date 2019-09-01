DeriveGamemode('fluffy_mg_base')

GM.Name = 'Assassination'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    pending
]]

GM.TeamBased = true		-- Is the gamemode FFA or Teams?
GM.Elimination = true	-- Is this gamemode elimination?
GM.RoundTime = 90 		-- How long each round should last, in seconds
GM.RoundNumber = 10		-- How many rounds are in each game?

function GM:Initialize()

end

-- Unique team names in this gamemode because I'm such a cool guy
function GM:CreateTeams()
	if not GAMEMODE.TeamBased then return end
	
	team.SetUp(TEAM_RED, "Killers", TEAM_COLORS['red'], true )
	team.SetSpawnPoint(TEAM_RED, TEAM_RED_SPAWNS)
	
	team.SetUp(TEAM_BLUE, "Guardians", TEAM_COLORS['blue'], true )
	team.SetSpawnPoint(TEAM_BLUE, TEAM_BLUE_SPAWNS)
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true )
	team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_start", "info_player_terrorist", "info_player_counterterrorist", "info_player_blue", "info_player_red"})
end