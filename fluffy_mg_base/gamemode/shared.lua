--[[
    Robert A Fraser 2018
    Minigames Reborn
]]--

DeriveGamemode('base')
include('sound_tables.lua')
include('sh_levels.lua')

GM.Name = 'Minigames'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    There doesn't appear to be any help text for this gamemode.
    Report this to the creator.
]]

GM.TeamBased = false -- Is the gamemode team based, or is it FFA?
GM.Elimination = false -- Should players stay dead, or should they respawn?

GM.RoundNumber = 5 -- How many rounds?
GM.RoundTime = 90 -- How long should each round go for?
GM.RoundCooldown = 5 -- How long between each round?

GM.CanSuicide = true -- Should players be able to die at will? :(
GM.ThirdPersonEnabled = false -- Should players have access to thirdperson?

GM.DeathSounds = true	-- Should voicelines play on player death?

GM.TeamSurvival = false		-- Is this a Hunter vs Hunted gametype?
GM.SurvivorTeam = TEAM_BLUE	-- Survivor team
GM.HunterTeam = TEAM_RED	-- Hunter team

function GM:Initialize()

end

--[[
CreateConVar('fluffy_gametype', 'suicidebarrels', FCVAR_REPLICATED, 'Fluffy Minigames gamemode controller')
function GM:Initialize()
    -- Determine the gamemode type from convar
    local gtype = GetConVar('fluffy_gametype'):GetString()
    local gamemode = GetConVar('gamemode'):GetString() -- i hate this
    if not file.Exists(gamemode..'/gamemode/gametypes/'..gtype..'/shared.lua', 'LUA') then print('Could not find directory') return end
    
    -- Load the files
    if SERVER then
        AddCSLuaFile(gamemode..'/gamemode/gametypes/'..gtype..'/cl_init.lua')
        AddCSLuaFile(gamemode..'/gamemode/gametypes/'..gtype..'/shared.lua')
        include(gamemode..'/gamemode/gametypes/'..gtype..'/init.lua')
    elseif CLIENT then
        include(gamemode..'/gamemode/gametypes/'..gtype..'/cl_init.lua')
    end
    include(gamemode..'/gamemode/gametypes/'..gtype..'/shared.lua')
end
--]]

-- These teams should work fantastically for most gamemodes
TEAM_RED = 1
TEAM_BLUE = 2

-- Note that RED is CT and BLUE is T
-- Not sure why I did this but oh well, way too late to change it
-- seriously don't change it you'll break a lot of maps
function GM:CreateTeams()
	if not GAMEMODE.TeamBased then return end
	
	team.SetUp(TEAM_RED, "Red Team", Color( 255, 80, 80 ), true )
	team.SetSpawnPoint(TEAM_RED, {"info_player_counterterrorist", "info_player_rebel"})
	
	team.SetUp(TEAM_BLUE, "Blue Team", Color( 80, 80, 255 ), true )
	team.SetSpawnPoint(TEAM_BLUE, {"info_player_terrorist", "info_player_combine"})
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true )
	team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_terrorist", "info_player_combine", "info_player_counterterrorist", "info_player_rebel"}) 
end

-- Function to toggle displaying cosmetics
-- Obviously, cosmetic items shouldn't be displayed on barrels etc.
function GM:ShouldDrawCosmetics(ply)
    if GAMEMODE.TeamSurvival then
        -- Cosmetics shouldn't show for the Hunter Team (in most cases)
        -- Override in some cases
        if ply:Team() == GAMEMODE.HunterTeam then
            return false
        else
            return true
        end
    else
        -- Should be okay in most cases
        -- Override in others
        return true
    end
end