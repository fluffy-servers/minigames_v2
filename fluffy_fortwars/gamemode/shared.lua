DeriveGamemode('fluffy_mg_base')
include('prop_list.lua')

GM.Name = 'Fortwars'
GM.Author = 'FluffyXVI'

GM.TeamBased = true	-- Is the gamemode FFA or Teams?
GM.RoundTime = 240
GM.RoundNumber = 3
GM.MaxProps = 25
GM.KillValue = 10

function GM:Initialize()

end

-- The default FortWars map has these the other way round to other gamemodes
-- I knew something like this would come up eventually
function GM:CreateTeams()
	if not GAMEMODE.TeamBased then return end
	
	team.SetUp(TEAM_RED, "Red Team", Color( 255, 80, 80 ), true )
	team.SetSpawnPoint(TEAM_RED, {"info_player_terrorist", "info_player_combine"})
	
	team.SetUp(TEAM_BLUE, "Blue Team", Color( 80, 80, 255 ), true )
	team.SetSpawnPoint(TEAM_BLUE, {"info_player_counterterrorist", "info_player_rebel"})
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true )
	team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_terrorist", "info_player_combine", "info_player_counterterrorist", "info_player_rebel"}) 
end