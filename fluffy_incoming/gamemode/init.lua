AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_maps.lua")

-- Nobody wins in Incoming ?
-- Used to override default functionality on FFA round end
function GM:GetWinningPlayer()
    return nil
end

-- No weapons
function GM:PlayerLoadout(ply)
    --ply:Give("weapon_crowbar")
end

GM.CurrentPropsCategory = "Both"
GM.PropSpawnTimer = 0

-- Spawn props at appropiate times
hook.Add("Tick", "TickPropSpawn", function()
    if not GAMEMODE:InRound() then return end

    -- Get information from the currently selected props category
    -- See sv_maps for the prop data
    local data = GAMEMODE.DefaultProps[GAMEMODE.CurrentPropsCategory]
    local props = data.models

    -- Choose material
    local material = data.materials
    if istable(data.materials) then
        material = table.Random(materials)
    elseif not material then
        material = "plastic"
    end

    if GAMEMODE.PropSpawnTimer < CurTime() then
        -- Spawn a prop at every spawner
        for k, v in pairs(ents.FindByClass("inc_prop_spawner")) do
            local ent = ents.Create("prop_physics")
            ent:SetModel(props[math.random(1, #props)])
            ent:SetPos(v:GetPos())
            ent:Spawn()

            -- Set physical properties
            local phys = ent:GetPhysicsObject()
            phys:SetMass(40000)
            phys:SetMaterial(material)

            -- Call the data function on every entity
            if data.func then
                data.func(ent)
            end
        end

        GAMEMODE.PropSpawnTimer = CurTime() + (data.delay or 2)
    end
end)

-- Randomly pick a group of props
hook.Add("PreRoundStart", "IncomingPropsChange", function()
    -- If the map has a category restriction, pay attention to that
    local category
    if GAMEMODE.MapInfo[game.GetMap()].categories then
        category = table.Random(GAMEMODE.MapInfo[game.GetMap()].categories)
    else
        category = table.Random(table.GetKeys(GAMEMODE.DefaultProps))
    end
    GAMEMODE.CurrentPropsCategory = category

    -- Reset distances
    for k, v in pairs(player.GetAll()) do
        v.BestDistance = nil
    end
end)

-- Get the distance the player has to the end
-- This function also tracks the current best distance
function GM:GetDistanceToEnd(ply)
    local endpos = GAMEMODE:EndingPoint()
    if not endpos then return end

    local distance = ply:GetPos():Distance(endpos)
    local maxdist = GAMEMODE.MapInfo[game.GetMap()].distance

    local percent = 1 - (distance / maxdist)
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
    GAMEMODE:GetDistanceToEnd(ply)
end)

-- Add scoring based on distance at the end of a round
-- Takes the best distance, rounds down to the nearest 10% and adds 1 point per 10%
-- eg. 48% -> 40% -> 4 points
hook.Add("RoundEnd", "IncomingDistancePoints", function()
    for k, v in pairs(player.GetAll()) do
        GAMEMODE:GetDistanceToEnd(v)

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

-- Network resources
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

-- Equivalent of 1XP for every 100% of distance travelled
hook.Add("RegisterStatsConversions", "AddIncomingStatConversions", function()
    GAMEMODE:AddStatConversion("Distance", "Distance Travelled", 0.01)
end)

IncludeResFolder("materials/models/clannv/incoming/")
IncludeResFolder("models/clannv/incoming/box/")
IncludeResFolder("models/clannv/incoming/cone/")
IncludeResFolder("models/clannv/incoming/cylinder/")
IncludeResFolder("models/clannv/incoming/hexagon/")
IncludeResFolder("models/clannv/incoming/pentagon/")
IncludeResFolder("models/clannv/incoming/sphere/")
IncludeResFolder("models/clannv/incoming/triangle/")