MOD.Name = 'Balloons'

MOD.Region = 'knockback'
MOD.ScoreValue = 0.1
MOD.ScoringPane = true

MOD.WinValue = 3
MOD.RoundTime = 20

local function spawnBalloons()
    local number = GAMEMODE:PlayerScale(0.4, 3, 8)
    local positions = GAMEMODE:GetRandomLocations(number, 'edge')

    for i=1,number do
        local pos = positions[i]
        local ent = ents.Create("microgames_balloon")
        ent:SetPos(pos + Vector(0, 0, 8))
        ent:Spawn()
    end
end

function MOD:Initialize()
    spawnBalloons()
    GAMEMODE:Announce("Balloons!", "Pop as many as you can!")
end

function MOD:Loadout(ply)
    ply:Give("balloon_popper")
    ply:GiveAmmo(256, "Pistol")
end

function MOD:PropBreak(ply, prop)
    if prop:GetClass() != "microgames_balloon" then return end
    ply:AddMScore(prop.Score or 1)
end

MOD.ThinkTime = 1
function MOD:Think()
    spawnBalloons()
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if dmg:GetAttacker():IsPlayer() then return true end
end