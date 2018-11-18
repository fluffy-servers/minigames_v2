DeriveGamemode('fluffy_mg_base')

GM.Name = 'Shootingrange'
GM.Author = 'unospaghetto'
GM.HelpText = [[
    Try and survive the onslaught!
    
    Teams are swapped after every round.
    
    Shooters
     Eliminate all the runners.
     Weapons are random each round.
     
    Captives
     Run around and try not to die
]]

TEAM_RED = 1
TEAM_BLUE = 2

GM.TeamBased = true		
GM.Elimination = true	
GM.WinBySurvival = true
GM.RoundTime = 100		
GM.RoundNumber = 6		
GM.RoundCooldown = 5

GM.CanSuicide = false
GM.ThirdPersonEnabled = false

function GM:CreateTeams()
	if ( !GAMEMODE.TeamBased ) then return end
team.SetUp(TEAM_RED, "Shooters", Color( 255, 80, 80 ), true )
    team.SetSpawnPoint(TEAM_RED, {"info_player_counterterrorist", "info_player_rebel"})

    team.SetUp(TEAM_BLUE, "Captives", Color( 80, 80, 255 ), true )
    team.SetSpawnPoint(TEAM_BLUE, {"info_player_terrorist", "info_player_combine"})
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_start", "info_player_terrorist", "info_player_combine" } ) 
end
	