MOD.Name = "Colored Discs"
MOD.SurviveValue = 2

local function spawnDisc(pos, color)
    local ent = ents.Create("microgames_disc")
    ent:SetPos(pos)
    ent:SetColor(color)
    ent:Spawn()

    return ent
end

function MOD:Initialize()
    local positions = GAMEMODE:GetRandomLocations(6, "ground")
    local colors = table.Shuffle(GAMEMODE.DiscColors)
    GAMEMODE.CorrectCircle = spawnDisc(positions[1], colors[1][2])

    for i = 1, 6 do
        spawnDisc(positions[i], colors[i][2])
    end

    local goal = colors[1][1]
    GAMEMODE:Announce("Get on the " .. goal .. " circle!")
end

function MOD:Loadout(ply)
    ply:Give("weapon_crowbar")
end

function MOD:Cleanup()
    if GAMEMODE:GetNumberAlive() >= 1 then
        local winning_players = GAMEMODE.CorrectCircle:GetPlayers()

        for k, v in pairs(winning_players) do
            v.Winner = true
        end
    end

    GAMEMODE.CorrectCircle = nil
end

function MOD:PlayerFinish(ply)
    if ply.Winner then
        ply:AwardWin(true)
    elseif ply:Alive() then
        ply:Kill()
    end

    ply.Winner = nil
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if not dmg:GetAttacker():IsPlayer() then return end
    dmg:SetDamage(0)
    local v = dmg:GetDamageForce():GetNormalized()
    v.z = math.max(math.abs(v.z) * 0.5, 0.0025)
    ent:SetGroundEntity(nil)
    ent:SetVelocity(v * 800)
end