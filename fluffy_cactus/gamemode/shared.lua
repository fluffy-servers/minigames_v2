--[[
    Robert A Fraser 2018
    Cactus
    Original by Grea$eMonkey
]]--

DeriveGamemode('fluffy_mg_base')

GM.Name = 'Cactus'
GM.Author = 'FluffyXVI'

TEAM_CACTUS = 1
TEAM_BLUE = 2

-- Configure teams for Hunter vs Hunted
GM.TeamBased = true
GM.TeamSurvival = false

GM.RoundNumber = 5 -- How many rounds?
GM.RoundTime = 150 -- How long should each round go for?
GM.RoundCooldown = 5 -- How long between each round?

GM.CanSuicide = false -- Should players be able to die at will? :(
GM.ThirdPersonEnabled = false -- This gamemode overrides some functions to do with this

function GM:CreateTeams()
	if ( !GAMEMODE.TeamBased ) then return end
	
	team.SetUp( TEAM_CACTUS, "Cactus", Color( 255, 80, 80 ), true )
	team.SetSpawnPoint( TEAM_CACTUS, {"info_player_counterterrorist", "info_player_rebel"} )
	
	team.SetUp( TEAM_BLUE, "Humans", Color( 80, 80, 255 ), true )
	team.SetSpawnPoint( TEAM_BLUE, {"info_player_terrorist", "info_player_combine"} )
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_start", "info_player_terrorist", "info_player_combine" } ) 
end

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
    if ply:Team() == TEAM_RED then return true end
end