--[[
    Functions related to the player
    Stuff like playermodels, FFA colors, etc.
--]]

-- Stop suicide in some gamemodes
function GM:CanPlayerSuicide()
    return self.CanSuicide
end

-- Playermodels
function GM:PlayerSetModel(ply)
    local cl_playermodel = ply:GetInfo("cl_playermodel")
    local modelname = GAMEMODE:TranslatePlayerModel(cl_playermodel, ply)
    util.PrecacheModel(modelname)
    ply:SetModel(modelname)

    -- Set player colors
    if GAMEMODE.TeamBased and not GAMEMODE.ForceFFAColors then
        local color = team.GetColor(ply:Team())
        ply:SetPlayerColor(Vector(color.r / 255, color.g / 255, color.b / 255))

        if ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED or state == "GameNotStarted" then
            self:PlayerSpawnAsSpectator(ply)

            return
        end
    else
        if not ply.FFAColor then
            ply.FFAColor = HSVToColor(math.random(360), 1, 1)
        end

        local c = Vector(ply.FFAColor.r / 255, ply.FFAColor.g / 255, ply.FFAColor.b / 255)
        ply:SetPlayerColor(c)
    end
end


-- Attempt to pick a spawnpoint from a list of entities
function GM:AttemptSpawnPoint(ply, ents, attempts)
    attempts = attempts or 10
    local chosen = nil

    for i = 1, attempts do
        chosen = table.Random(ents)
        if not IsValid(chosen) or not chosen:IsInWorld() then continue end

        if hook.Call("IsSpawnpointSuitable", GAMEMODE, ply, chosen, i == attempts) then
            return chosen
        end
    end

    -- Even if the last attempt isn't viable, we need *somewhere* to spawn
    return chosen
end

function GM:PlayerSelectSpawn(ply)
    if self.TeamBased then
        local spawns = team.GetSpawnPoints(ply:Team())
        if IsTableOfEntitiesValid(spawns) then
            return GAMEMODE:AttemptSpawnPoint(ply, spawns)
        end
    end

    -- Find FFA spawn entities
    if not IsTableOfEntitiesValid(GAMEMODE.SpawnPoints) then
        GAMEMODE.SpawnPoints = ents.FindByClass("info_player_start")
        if #GAMEMODE.SpawnPoints < 2 then
            GAMEMODE.SpawnPoints = table.Add(GAMEMODE.SpawnPoints, ents.FindByClass("info_player_terrorist"))
            GAMEMODE.SpawnPoints = table.Add(GAMEMODE.SpawnPoints, ents.FindByClass("info_player_counterterrorist"))
        end
    end

    return GAMEMODE:AttemptSpawnPoint(ply, GAMEMODE.SpawnPoints)
end