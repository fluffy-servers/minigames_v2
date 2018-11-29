--[[
    Robert A Fraser 2018
    Suicide Barrels
    Inspired by countless prior gmod gamemodes
]]--

DeriveGamemode('fluffy_mg_base')

GM.Name = 'Suicide Barrels'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Some explosive barrels have turned sentient.
    
    When a human is eliminated, they will join the Barrel team.
    
    Humans:
     Try to survive against the onslaught
     Shoot a barrel and it will explode instantly
     Be cautious! Don't shoot barrels to close to teammates
     
    Barrels:
     Try to eliminate all the humans before time runs out
     Left click to explode after a short delay
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

function GM:CreateTeams()
	if ( !GAMEMODE.TeamBased ) then return end
	
	team.SetUp( TEAM_RED, "Barrels", Color( 255, 80, 80 ), true )
	team.SetSpawnPoint( TEAM_RED, {"info_player_counterterrorist", "info_player_rebel"} )
	
	team.SetUp( TEAM_BLUE, "Humans", Color( 80, 80, 255 ), true )
	team.SetSpawnPoint( TEAM_BLUE, {"info_player_terrorist", "info_player_combine"} )
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_start", "info_player_terrorist", "info_player_combine" } ) 
end

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
    if ply:Team() == TEAM_RED then return true end
end