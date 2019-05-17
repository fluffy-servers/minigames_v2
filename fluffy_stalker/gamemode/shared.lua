DeriveGamemode('fluffy_mg_base')

GM.Name = 'Stalker'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    to do
]]

GM.TeamBased = true	-- Is the gamemode FFA or Teams?
GM.Elimination = true
GM.WinBySurvival = true

GM.RoundTime = 120
GM.RoundNumber = 10

function GM:Initialize()

end

function GM:CreateTeams()
	if not GAMEMODE.TeamBased then return end
	
	team.SetUp(TEAM_RED, "Stalker", Color( 255, 80, 80 ), true)
	team.SetSpawnPoint(TEAM_RED, {"info_player_counterterrorist", "info_player_rebel"})
	
	team.SetUp(TEAM_BLUE, "Survivors", Color( 80, 80, 255 ), true)
	team.SetSpawnPoint(TEAM_BLUE, {"info_player_terrorist", "info_player_combine"})
	
	team.SetUp(TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true)
	team.SetSpawnPoint(TEAM_SPECTATOR, { "info_player_start", "info_player_terrorist", "info_player_combine" }) 
end

-- Hide all cosmetics for the Stalker
-- It'd be a bit sucky for the invisible man to have a very obvious top hat equipped
hook.Add('ShouldDrawCosmetics', 'HideHunterCosmetics', function(ply, ITEM)
    if ply:Team() == TEAM_RED then return false end
end)