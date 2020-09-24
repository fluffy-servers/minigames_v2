--[[
    Robert A Fraser 2018
    Minigames Reborn
	
	Base file for the gamemode which is loaded on both client and server
]]
--
-- Load the other shared files
DeriveGamemode("base")
include("sound_tables.lua")
include("sh_levels.lua")
include("sh_scorehelper.lua")
include("shop/sh_init.lua")

GM.Name = "Minigames"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    There doesn't appear to be any help text for this gamemode.
    Report this to the creator.
]]

GM.IsMinigames = true           -- Don't change, easy lookup for other addons

GM.TeamBased = false            -- Is the gamemode team based, or is it FFA?
GM.Elimination = false          -- Should players stay dead, or should they respawn?
GM.PlayerChooseTeams = true     -- Can players choose their own teams?

GM.DeathLingerTime = 3          -- How long should players linger on their corpse before ghosting?
GM.RespawnTime = 2              -- How long do players have to wait before respawning?
GM.AutoRespawn = true           -- Should players automatically respawn?

GM.RoundNumber = 5              -- How many rounds?
GM.RoundTime = 90               -- How long should each round go for?
GM.RoundCooldown = 5            -- How long between each round?
GM.WarmupTime = 10              -- How long to wait for players to join before starting the game?

GM.RoundType = "default"        -- What system should be used for game/round logic?
GM.GameTime = 600               -- If not using rounds, how long should the game go for?
GM.EndOnTimeOut = false         -- If using 'timed' RoundType, should this cut off the middle of a round?

GM.CanSuicide = false           -- Should players be able to die at will? :(
GM.ThirdPersonEnabled = false   -- Should players have access to thirdperson?
GM.SpawnProtection = false      -- Should players have brief spawn protection?
GM.EnableFallDamage = false     -- Should players take fall damage?

GM.DeathSounds = true	        -- Should voicelines play on player death?
GM.KillValue = 1                -- How many points should be awarded for a kill?

GM.TeamSurvival = false		    -- Is this a Hunter vs Hunted gametype?
GM.SurvivorTeam = TEAM_BLUE	    -- Survivor team
GM.HunterTeam = TEAM_RED	    -- Hunter team

GM.DisableConfetti = false      -- Should the round win confetti be disabled?
GM.HUDTeamColor = true          -- Should the HUD color be based on the team color?
GM.ShowTeamScoreboard = true    -- Should the team scores be displayed at the top of the scoreboard?

GM.MinPlayers = 2               -- How many players are needed to play the gamemode

function GM:Initialize()
    -- Gamemode crashes without this function so don't remove it
    -- There's nothing that needs to be handled here, hence the blank
end

-- Fisher-Yates table shuffle
function table.Shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end

    return t
end

-- Utility function to get table keys
function table.Keys(t)
    local keyset = {}
    for k, _ in pairs(t) do
        table.insert(keyset, k)
    end
    return keyset
end

-- These teams should work fantastically for most gamemodes
TEAM_RED = 1
TEAM_BLUE = 2

TEAM_RED_SPAWNS = {"info_player_counterterrorist", "info_player_red"}

TEAM_BLUE_SPAWNS = {"info_player_terrorist", "info_player_blue"}

-- Extra team colors
-- These can be selected with mg_team_control
TEAM_COLORS = {}
TEAM_COLORS["orange"] = Color(253, 150, 68)
TEAM_COLORS["red"] = Color(252, 92, 101)
TEAM_COLORS["blue"] = Color(0, 168, 255)
TEAM_COLORS["green"] = Color(38, 222, 129)
TEAM_COLORS["purple"] = Color(165, 94, 234)
TEAM_COLORS["pink"] = Color(255, 159, 243)
TEAM_COLORS["cyan"] = Color(72, 219, 251)
TEAM_COLORS["yellow"] = Color(254, 211, 48)
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

-- Additional score tracking utilities
-- This allows for team round-scores and team rounds won to be tracked
function team.SetRoundScore(id, score)
    return SetGlobalInt("Team" .. tostring(id) .. ".RScore", score)
end

function team.AddRoundScore(id, amount)
    team.SetRoundScore(id, team.GetRoundScore(id) + amount)
end

function team.GetRoundScore(id)
    return GetGlobalInt("Team" .. tostring(id) .. ".RScore", 0)
end

-- Note that RED is CT and BLUE is T
-- Not sure why I did this but oh well, way too late to change it
-- seriously don't change it you'll break a lot of maps
function GM:CreateTeams()
    if not GAMEMODE.TeamBased then return end
    team.SetUp(TEAM_RED, "Red Team", TEAM_COLORS["red"], true)
    team.SetSpawnPoint(TEAM_RED, TEAM_RED_SPAWNS)
    team.SetUp(TEAM_BLUE, "Blue Team", TEAM_COLORS["blue"], true)
    team.SetSpawnPoint(TEAM_BLUE, TEAM_BLUE_SPAWNS)
    team.SetUp(TEAM_SPECTATOR, "Spectators", Color(255, 255, 80), true)

    team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_start", "info_player_terrorist", "info_player_counterterrorist", "info_player_blue", "info_player_red"})
end

-- Get a table of all alive players
function GM:GetAlivePlayers()
    local tbl = {}

    for k, v in pairs(player.GetAll()) do
        if v:Alive() and v:Team() ~= TEAM_SPECTATOR and not v.Spectating then
            table.insert(tbl, v)
        end
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

    for k, v in pairs(player.GetAll()) do
        if GAMEMODE.TeamBased then
            if v:Team() ~= TEAM_SPECTATOR and v:Team() ~= TEAM_UNASSIGNED and v:Team() ~= 0 then
                num = num + 1
            end
        else
            if v:Team() ~= TEAM_SPECTATOR then
                num = num + 1
            end
        end
    end

    return num
end

-- Convenience function to get number of living players in a team
function GM:GetTeamLivingPlayers(t)
    local alive = 0

    for k, v in pairs(team.GetPlayers(t)) do
        if v:Alive() and not v.Spectating then
            alive = alive + 1
        end
    end

    return alive
end

function GM:GetTeamSurvivors(t)
    local tbl = {}

    for k, v in pairs(team.GetPlayers(t)) do
        if v:Alive() and not v.Spectating then
            table.insert(tbl, v)
        end
    end

    return tbl
end

-- Much nicer wrapper for this function
function GM:GetRoundState()
    return GetGlobalString("RoundState", "GameNotStarted")
end

function GM:SetRoundState(newstate)
    return SetGlobalString("RoundState", newstate)
end

-- This is the most common use of the above function
-- Helps clean up code
function GM:InRound()
    return GAMEMODE:GetRoundState() == "InRound"
end

-- Another nice wrapper for a global variable
function GM:GetRoundStartTime()
    return GetGlobalFloat("RoundStart", 0)
end

function GM:GetRoundNumber()
    return GetGlobalInt("RoundNumber", 0)
end

-- Helper function to scale data based on the number of players
function GM:PlayerScale(ratio, min, max)
    local players = GAMEMODE:GetNumberAlive()

    return math.Clamp(math.ceil(players * ratio), min, max)
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
    if GAMEMODE.ValidModels[name] ~= nil then
        return GAMEMODE.ValidModels[name]
    elseif ply.TemporaryModel then
        return ply.TemporaryModel
    else
        ply.TemporaryModel = table.Random(GAMEMODE.ValidModels)

        return ply.TemporaryModel
    end
end