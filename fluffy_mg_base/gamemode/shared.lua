--[[
    Robert A Fraser 2018
    Minigames Reborn
	
	Base file for the gamemode which is loaded on both client and server
]]--

-- Load the other shared files
DeriveGamemode('base')
include('sound_tables.lua')
include('sh_levels.lua')

-- These variables should be altered in each sub gamemode's shared.lua file
-- If not defined, they will return to these values here
GM.Name = 'Minigames'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    There doesn't appear to be any help text for this gamemode.
    Report this to the creator.
]]

GM.TeamBased = false    -- Is the gamemode team based, or is it FFA?
GM.Elimination = false  -- Should players stay dead, or should they respawn?

GM.RoundNumber = 5      -- How many rounds?
GM.RoundTime = 90       -- How long should each round go for?
GM.RoundCooldown = 5    -- How long between each round?

GM.RoundType = 'default'    -- What system should be used for game/round logic?
GM.GameTime = 600           -- If not using rounds, how long should the game go for?
GM.EndOnTimeOut = true      -- If using 'timed' RoundType, should this cut off the middle of a round?

GM.CanSuicide = true            -- Should players be able to die at will? :(
GM.ThirdPersonEnabled = false   -- Should players have access to thirdperson?
GM.SpawnProtection = false      -- Should players have brief spawn protection?

GM.DeathSounds = true	-- Should voicelines play on player death?
GM.KillValue = 1        -- How many points should be awarded for a kill?

GM.TeamSurvival = false		-- Is this a Hunter vs Hunted gametype?
GM.SurvivorTeam = TEAM_BLUE	-- Survivor team
GM.HunterTeam = TEAM_RED	-- Hunter team

function GM:Initialize()
	-- Gamemode crashes without this function so don't remove it
	-- There's nothing that needs to be handled here, hence the blank
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

-- Valid playermodels
GM.ValidModels = {
    male01 = "models/player/Group01/male_01.mdl",
    male02 = "models/player/Group01/male_02.mdl",
    male03 = "models/player/Group01/male_03.mdl",
    male04 = "models/player/Group01/male_04.mdl",
    male05 = "models/player/Group01/male_05.mdl",
    male06 = "models/player/Group01/male_06.mdl",
    male07 = "models/player/Group01/male_07.mdl",
    male08 = "models/player/Group01/male_08.mdl",
    male09 = "models/player/Group01/male_09.mdl",
    
    female01 = "models/player/Group01/female_01.mdl",
    female02 = "models/player/Group01/female_02.mdl",
    female03 = "models/player/Group01/female_03.mdl",
    female04 = "models/player/Group01/female_04.mdl",
    female05 = "models/player/Group01/female_05.mdl",
    female06 = "models/player/Group01/female_06.mdl",
}

-- Convert the playermodel name into a model
function GM:TranslatePlayerModel(name, ply)
    if GAMEMODE.ValidModels[name] != nil then
        return GAMEMODE.ValidModels[name]
    elseif ply.TemporaryModel then
        return ply.TemporaryModel
    else
        ply.TemporaryModel = table.Random(GAMEMODE.ValidModels)
        return ply.TemporaryModel
    end
end