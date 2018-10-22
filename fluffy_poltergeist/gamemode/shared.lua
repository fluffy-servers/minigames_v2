DeriveGamemode('fluffy_mg_base')

GM.Name = 'Poltergeist'
GM.Author = 'FluffyXVI'

GM.TeamBased = true	-- Is the gamemode FFA or Teams?
GM.TeamSurvival = true
GM.SurvivorTeam = TEAM_BLUE
GM.HunterTeam = TEAM_RED

GM.NoSuicidePenalty = true

GM.RoundNumber = 10      -- How many rounds?
GM.RoundTime = 90      -- Seconds each round lasts for

function GM:Initialize()

end

TEAM_RED = 1
TEAM_BLUE = 2

function GM:CreateTeams()
	if ( !GAMEMODE.TeamBased ) then return end
	
	team.SetUp( TEAM_RED, "Poltergeists", Color( 255, 80, 80 ), true )
	team.SetSpawnPoint( TEAM_RED, { "info_player_start", "info_player_counterterrorist", "info_player_combine" }, true )
	
	team.SetUp( TEAM_BLUE, "Humans", Color( 80, 80, 255 ), true )
	team.SetSpawnPoint( TEAM_BLUE, { "info_player_start", "info_player_terrorist", "info_player_rebel", "info_player_deathmatch" } )
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_start", "info_player_terrorist", "info_player_combine" } ) 
end