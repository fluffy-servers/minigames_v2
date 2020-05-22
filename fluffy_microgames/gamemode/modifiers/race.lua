MOD.Name = 'Race'
MOD.Countdown = true

MOD.ScoreValue = 0
MOD.ScoringPane = true
MOD.SurviveValue = 2
MOD.RoundTime = 30

local function spawnDisc(pos, color)
    local ent = ents.Create('microgames_race_disc')
    ent:SetPos(pos)
    ent:SetColor(color)
    ent:Spawn()
    return ent
end

function MOD:SpawnCircles()
    GAMEMODE.NumberNodes = math.random(3, 8)

    local positions = GAMEMODE:GetRandomLocations(GAMEMODE.NumberNodes, 'crate')
    local colors = table.Shuffle(GAMEMODE.DiscColors)
    GAMEMODE.RaceNodes = {}
    for i=1,GAMEMODE.NumberNodes do
        local circle = spawnDisc(positions[i], colors[i][2])
        circle:SetNWInt("RacePoint", i)
        table.insert(GAMEMODE.RaceNodes, circle)
    end
end

function MOD:Initialize()
    self:SpawnCircles()
    GAMEMODE:Announce("Race", "Go through the " ..  GAMEMODE.NumberNodes.. " circles in order!")
end

function MOD:Loadout(ply)
    ply:SetNWInt("RaceState", 0)
    ply:SetRunSpeed(350)
    ply:SetWalkSpeed(300)
    ply:Give("weapon_crowbar")
end

MOD.ThinkTime = 0.250
function MOD:Think()
    for number, disc in pairs(GAMEMODE.RaceNodes) do
        local playersOnDisc = disc:GetPlayers()
        for k, v in pairs(playersOnDisc) do
            if v:GetMScore() == (number - 1) then
                v:EmitSound("ambient/levels/canals/windchime2.wav", 100, 100 + (number*15))
                v:SetMScore(number)

                -- Confetti effect after passing the last node
                if number == GAMEMODE.NumberNodes then
                    GAMEMODE:ConfettiEffectSingle(v)
                end
            end
        end
    end
end

function MOD:Cleanup()
    for k,v in pairs(player.GetAll()) do
        if not v:Alive() then continue end
        if v:GetMScore() != GAMEMODE.NumberNodes then
            v:Kill()
        end
    end
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if not dmg:GetAttacker():IsPlayer() then return true end
    
    dmg:SetDamage(0)
    local v = dmg:GetDamageForce():GetNormalized()
    v.z = math.max(math.abs(v.z) * 0.5, 0.0025)
    ent:SetGroundEntity(nil)
    ent:SetVelocity(v * 800)
end