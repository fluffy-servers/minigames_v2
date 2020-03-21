MOD.Name = 'Colored Discs'
MOD.Colors = {
    {"Red", Color(231, 76, 60)},
    {"Orange", Color(230, 126, 34)},
    {"Yellow", Color(241, 196, 15)},
    {"Green", Color(46, 204, 113)},
    {"Blue", Color(52, 152, 219)},
    {"Purple", Color(155, 89, 182)}
}

local function spawnDisc(pos, color)
    local ent = ents.Create('microgames_disc')
    ent:SetPos(pos)
    ent:SetColor(color)
    ent:Spawn()
    return ent
end

function MOD:SpawnCircles()
    local positions = GAMEMODE:GetRandomLocations(6, 'ground')
    local colors = table.Shuffle(self.Colors)
    GAMEMODE.CorrectCircle = spawnDisc(positions[1], colors[1][2])
    for i=1,6 do
        spawnDisc(positions[i], colors[i][2])
    end

    local goal = colors[1][1]
    GAMEMODE:Announce("Get on the " .. goal .. " circle!")
end

function MOD:Initialize()
    GAMEMODE:Announce("Don't stop moving!")

    timer.Create("DiscTimer", 5, 1, function()
        self:SpawnCircles()
    end)
end

function MOD:Loadout(ply)
    ply:Give('weapon_crowbar')
end

function MOD:Cleanup()
    timer.Destroy("DiscTimer")

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
MOD.Think = GM.RunFiveSeconds
MOD.EntityTakeDamage = GM.CrowbarKnockback