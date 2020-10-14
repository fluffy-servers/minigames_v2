AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_maps.lua")

-- Record starting distances
hook.Add("PlayerSpawn", "IncomingCheckSpawnDistance", function(ply)
    if ply.CheckpointStage and ply.CheckpointStage > 0 then return end
    ply.StartingDistance = GAMEMODE:GetDistanceToEnd(ply)
end)

-- Reset best distances on round start
hook.Add("PreRoundStart", "IncomingResetBestDistance", function()
    for k, v in pairs(player.GetAll()) do
        v.CheckpointStage = 0
        v.BestDistance = nil
    end
end)

-- Trigger checkpoints
function GM:CheckpointTriggered(ply, stage, message)
    if ply.CheckpointStage and stage <= ply.CheckpointStage then return end
    ply.CheckpointStage = stage

    if message then
        GAMEMODE:PulseAnnouncementTwoLine(3, "Checkpoint!", message)
    else
        GAMEMODE:PulseAnnouncement(3, "Checkpoint!")
    end
end

-- Select player spawn based on checkpoint stage
function GM:PlayerSelectSpawn(ply)
    local stage = ply.CheckpointStage
    if not stage or stage < 1 then
        return GAMEMODE.BaseClass:PlayerSelectSpawn(ply)
    end

    -- Sort checkpoint spawns by stage
    if not GAMEMODE.CheckpointSpawns then GAMEMODE.CheckpointSpawns = {} end
    if not GAMEMODE.CheckpointSpawns[stage] or not IsTableOfEntitiesValid(GAMEMODE.CheckpointSpawns[stage]) then
        local spawns = ents.FindByClass("inc_checkpoint_spawn")
        for _,v in pairs(spawns) do
            local spawnStage = v.CheckpointStage
            if not GAMEMODE.CheckpointSpawns[spawnStage] then GAMEMODE.CheckpointSpawns[spawnStage] = {} end

            table.insert(GAMEMODE.CheckpointSpawns[spawnStage], v)
        end
    end

    -- Get checkpoint spawns for this level
    local stageSpawns = GAMEMODE.CheckpointSpawns[stage]
    if not stageSpawns then
        return GAMEMODE.BaseClass:PlayerSelectSpawn(ply)
    end

    return GAMEMODE:AttemptSpawnPoint(ply, stageSpawns)
end

-- Get the distance the player has to the end
function GM:GetDistanceToEnd(ply)
    local endpos = GAMEMODE:EndingPoint()
    return ply:GetPos():Distance(endpos)
end

-- Check if a player has set their new best distance to the end goal
function GM:CheckBestDistance(ply)
    if not ply.StartingDistance then return end
    local distance = GAMEMODE:GetDistanceToEnd(ply)

    local percent = 1 - (distance / ply.StartingDistance)
    if percent < 0 then return end

    if ply.BestDistance then
        if percent > ply.BestDistance then
            ply.BestDistance = percent
        end
    else
        ply.BestDistance = percent
    end
end

-- Get a % of how close the player got to the ending
-- This is used for better scoring than all-or-nothing
hook.Add("DoPlayerDeath", "IncomingDistanceCheck", function(ply)
    GAMEMODE:CheckBestDistance(ply)
end)

-- Add scoring based on distance at the end of a round
-- Takes the best distance, rounds down to the nearest 10% and adds 1 point per 10%
-- eg. 48% -> 40% -> 4 points
hook.Add("RoundEnd", "IncomingDistancePoints", function()
    for k, v in pairs(player.GetAll()) do
        GAMEMODE:CheckBestDistance(v)

        if v.BestDistance then
            local p = math.floor(v.BestDistance * 100)
            v:AddStatPoints("IncomingDistance", p)
            v:AddFrags(math.floor(p / 10))
        end
    end
end)

-- Function to be called when a player wins the round
-- This should only occur for the first player to reach the top
function GM:IncomingVictory(ply)
    ply:AddFrags(3)
    ply.BestDistance = 1
    GAMEMODE:EndRound(ply)
    GAMEMODE:EntityCameraAnnouncement(ply, GAMEMODE.RoundCooldown or 5)
end

-- Equivalent of 1XP for every 100% of distance travelled
hook.Add("RegisterStatsConversions", "AddIncomingStatConversions", function()
    GAMEMODE:AddStatConversion("Distance", "Distance Travelled", 0.01)
end)

-- Network resources
-- todo: workshop this!
function IncludeResFolder(dir)
    local files = file.Find(dir .. "*", "GAME")
    local FindFileTypes = {".mdl", ".vmt", ".vtf", ".dx90", ".dx80", ".phy", ".sw", ".vvd", ".wav", ".mp3"}

    for k, v in pairs(files) do
        for k2, v2 in pairs(FindFileTypes) do
            if (string.find(v, v2)) then
                resource.AddFile(dir .. v)
            end
        end
    end
end

IncludeResFolder("materials/models/clannv/incoming/")
IncludeResFolder("models/clannv/incoming/box/")
IncludeResFolder("models/clannv/incoming/cone/")
IncludeResFolder("models/clannv/incoming/cylinder/")
IncludeResFolder("models/clannv/incoming/hexagon/")
IncludeResFolder("models/clannv/incoming/pentagon/")
IncludeResFolder("models/clannv/incoming/sphere/")
IncludeResFolder("models/clannv/incoming/triangle/")