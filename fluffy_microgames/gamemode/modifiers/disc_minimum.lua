MOD.Name = 'Disc Balance'
MOD.Countdown = true

MOD.SurviveValue = 2

local function spawnDisc(pos, color)
    local ent = ents.Create('microgames_disc')
    ent:SetPos(pos)
    ent:SetColor(color)
    ent:Spawn()
    return ent
end

function MOD:SpawnCircles()
    local number = GAMEMODE:PlayerScale(0.3, 2, 5)
    local positions = GAMEMODE:GetRandomLocations(number, 'ground')
    local colors = table.Shuffle(GAMEMODE.DiscColors)
    GAMEMODE.Circles = {}
    for i=1,number do
        local circle = spawnDisc(positions[i], colors[i][2])
        table.insert(GAMEMODE.Circles, circle)
    end
end

function MOD:Initialize()
    self:SpawnCircles()
    GAMEMODE:Announce("Balance", "Get on the circle with the least players!")
end

function MOD:Cleanup()
    -- Find out who is on what circle
    local results = {}
    local all_players = {}
    for k,v in pairs(GAMEMODE.Circles) do
        results[k] = v:GetPlayers()
        table.Add(all_players, results[k])
    end

    -- Kill everyone not on a circle
    for k,v in pairs(player.GetAll()) do
        if not v:Alive() then continue end
        if not table.HasValue(all_players, v) then
            v:Kill()
        end
    end

    -- Determine the minimum and the number of players on the minimum
    local min = 100
    local min_players = {}
    for k, v in pairs(results) do
        if #v > 0 and #v < min then
            min = #v
            min_players = v
        elseif #v == min then
            table.Add(min_players, v)
        end
    end

    -- Perform the final murder pass
    -- If everyone is on the same circle, punish them anyway
    local alive = GAMEMODE:GetNumberAlive()
    for k,v in pairs(player.GetAll()) do
        if not v:Alive() then continue end

        if min == alive and min > 1 then
            v:Kill()
        elseif table.HasValue(min_players, v) then
            v:AwardWin()
        else
            v:Kill()
        end
    end
end