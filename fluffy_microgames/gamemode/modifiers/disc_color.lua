MOD.Name = 'Colored Discs'

local function spawnDisc(pos, color)
    local ent = ents.Create('microgames_disc')
    ent:SetPos(pos)
    ent:SetColor(color)
    ent:Spawn()
    return ent
end

local function giveCrowbars()
    for k,v in pairs(player.GetAll()) do
        v:Give('weapon_crowbar')
    end
end

function MOD:Initialize()
    local positions = GAMEMODE:GetRandomLocations(6, 'ground')
    local colors = table.Shuffle(GAMEMODE.DiscColors)
    GAMEMODE.CorrectCircle = spawnDisc(positions[1], colors[1][2])
    for i=1,6 do
        spawnDisc(positions[i], colors[i][2])
    end

    local goal = colors[1][1]
    GAMEMODE:Announce("Get on the " .. goal .. " circle!")
end

function MOD:Loadout(ply)
    ply:Give('weapon_crowbar')
end

function MOD:Cleanup()
    if GAMEMODE:GetNumberAlive() >= 1 then
        local winning_players = GAMEMODE.CorrectCircle:GetPlayers()
        for k,v in pairs(winning_players) do
            v.Winner = true 
        end
    end
    GAMEMODE.CorrectCircle = nil
end

function MOD:PlayerFinish(ply)
    if ply.Winner then
        ply:AwardWin()
    elseif ply:Alive() then
        ply:Kill()
    end
    ply.Winner = nil
end

MOD.ThinkTime = 0.1
MOD.EntityTakeDamage = GM.CrowbarKnockback