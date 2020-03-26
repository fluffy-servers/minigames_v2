--[[
    Robert A Fraser 2018
    Minigames Reborn
	
	Base file for the gamemode which is loaded on both client and server
]]--

-- Load the other shared files
DeriveGamemode('base')
include('sound_tables.lua')
include('sh_levels.lua')
include('shop/sh_init.lua')

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
GM.PlayerChooseTeams = true -- Can players choose their own teams?

GM.DeathLingerTime = 3  -- How long should players linger on their corpse before ghosting?
GM.RespawnTime = 2      -- How long do players have to wait before respawning?
GM.AutoRespawn = true   -- Should players automatically respawn?

GM.RoundNumber = 5      -- How many rounds?
GM.RoundTime = 90       -- How long should each round go for?
GM.RoundCooldown = 5    -- How long between each round?
GM.StartWaitTime = 10

GM.RoundType = 'default'    -- What system should be used for game/round logic?
GM.GameTime = 600           -- If not using rounds, how long should the game go for?
GM.EndOnTimeOut = false     -- If using 'timed' RoundType, should this cut off the middle of a round?

GM.CanSuicide = false           -- Should players be able to die at will? :(
GM.ThirdPersonEnabled = false   -- Should players have access to thirdperson?
GM.SpawnProtection = false      -- Should players have brief spawn protection?
GM.EnableFallDamage = false     -- Should players take fall damage?

GM.DeathSounds = true	-- Should voicelines play on player death?
GM.KillValue = 1        -- How many points should be awarded for a kill?

GM.TeamSurvival = false		-- Is this a Hunter vs Hunted gametype?
GM.SurvivorTeam = TEAM_BLUE	-- Survivor team
GM.HunterTeam = TEAM_RED	-- Hunter team

GM.DisableConfetti = false      -- Should the round win confetti be disabled?
GM.HUDTeamColor = true          -- Should the HUD color be based on the team color?
GM.ShowTeamScoreboard = true    -- Should the team scores be displayed at the top of the scoreboard?

GM.MinPlayers = 2   -- How many players are needed to play the gamemode

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

TEAM_RED_SPAWNS = {"info_player_counterterrorist", "info_player_red"}
TEAM_BLUE_SPAWNS = {"info_player_terrorist", "info_player_blue"}

-- Extra team colors
-- These can be selected with mg_team_control
TEAM_COLORS = {}
TEAM_COLORS['orange'] = Color(250, 130, 49)
TEAM_COLORS['red'] = Color(255, 80, 80)
TEAM_COLORS['blue'] = Color(80, 80, 255)
TEAM_COLORS['green'] = Color(46, 213, 115)
TEAM_COLORS['purple'] = Color(165, 94, 234)
TEAM_COLORS['pink'] = Color(243, 104, 224)
TEAM_COLORS['cyan'] = Color(72, 219, 251)
TEAM_COLORS['yellow'] = Color(254, 202, 87)

-- Upsettingly, Garry's Mod by default doesn't provide a way to change the name of teams
-- This overrides the functions to create global variables for team names
-- This also caches the old function and then uses it for reverse-compatibility
local old = team.GetName
function team.GetName(id)
    local name = GetGlobalString("Team" .. tostring(id) .. ".GName", "")
    if name == "" then
        return old(id)
    else
        return name
    end
end

function team.SetName(id, name)
    return SetGlobalString("Team" .. tostring(id) .. ".GName", name)
end

local oldc = team.GetColor
function team.GetColor(id)
    local color = GetGlobalVector("Team" .. tostring(id) .. ".GColor", false)
    if not color then
        return oldc(id)
    else
        color = Color(color.x, color.y, color.z)
        return color
    end
end

function team.SetColor(id, color)
    color = Vector(color.r, color.g, color.b)
    return SetGlobalVector("Team" .. tostring(id) .. ".GColor", color)
end

-- Note that RED is CT and BLUE is T
-- Not sure why I did this but oh well, way too late to change it
-- seriously don't change it you'll break a lot of maps
function GM:CreateTeams()
	if not GAMEMODE.TeamBased then return end
	
	team.SetUp(TEAM_RED, "Red Team", TEAM_COLORS['red'], true)
	team.SetSpawnPoint(TEAM_RED, TEAM_RED_SPAWNS)
	
	team.SetUp(TEAM_BLUE, "Blue Team", TEAM_COLORS['blue'], true)
	team.SetSpawnPoint(TEAM_BLUE, TEAM_BLUE_SPAWNS)

	team.SetUp(TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true)
	team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_start", "info_player_terrorist", "info_player_counterterrorist", "info_player_blue", "info_player_red"})
end

-- Get a table of all alive players
function GM:GetAlivePlayers()
    local tbl = {}
    for k,v in pairs(player.GetAll() ) do
        if v:Alive() and v:Team() != TEAM_SPECTATOR and !v.Spectating then table.insert(tbl, v) end
    end
    
    return tbl
end

-- Convenience function to get number of living players
-- This isn't fantastically efficient don't overuse
function GM:GetNumberAlive()
    return #GAMEMODE:GetAlivePlayers()
end

-- Convenience function to get number of non-spectators
function GM:NumNonSpectators()
    local num = 0
    for k,v in pairs( player.GetAll() ) do
        if GAMEMODE.TeamBased then
            if v:Team() != TEAM_SPECTATOR and v:Team() != TEAM_UNASSIGNED and v:Team() != 0 then num = num + 1 end
        else
            if v:Team() != TEAM_SPECTATOR then num = num + 1 end
        end
    end

    return num
end

-- Convenience function to get number of living players in a team
function GM:GetTeamLivingPlayers( t )
    local alive = 0
    for k,v in pairs( team.GetPlayers( t ) ) do
        if v:Alive() and !v.Spectating then alive = alive + 1 end
    end
    return alive
end

-- Much nicer wrapper for this function
function GM:GetRoundState()
    return GetGlobalString('RoundState', 'GameNotStarted')
end

function GM:SetRoundState(newstate)
    return SetGlobalString('RoundState', newstate)
end

-- This is the most common use of the above function
-- Helps clean up code
function GM:IsInRound()
    return (GAMEMODE:GetRoundState() == 'InRound')
end

-- Another nice wrapper for a global variable
function GM:GetRoundStartTime()
    return GetGlobalFloat('RoundStart', 0)
end

-- Fisher-Yates table shuffle
function table.Shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- Helper function to scale data based on the number of players
function GM:PlayerScale(ratio, min, max)
    local players = GAMEMODE:GetNumberAlive()
    return math.Clamp(math.ceil(players * ratio), min, max)
end