MOD.Name = 'Photoday'
MOD.Region = 'knockback'
MOD.ScoreValue = 0.5
MOD.ScoringPane = true
MOD.WinValue = 3
MOD.RoundTime = 25

local function spawnHacks()
    local number = GAMEMODE:PlayerScale(0.5, 2, 6)
    local positions = GAMEMODE:GetRandomLocations(number, 'sky')

    for i=1,number do
        local pos = positions[i] + Vector(0, 0, 32)
        local cscanner = ents.Create("npc_manhack")
        cscanner:SetPos(pos)
        cscanner:Spawn()
        cscanner:SetHealth(1)
        cscanner:SetMaxHealth(1)
    end
end

function MOD:OnNPCKilled(npc, attacker, inflictor)
  if not attacker:IsPlayer() then return end
  if npc:GetClass() != "npc_manhack" then return end

  attacker:AddMScore(1)
end

function MOD:Initialize()
    spawnHacks()
    GAMEMODE:Announce("Hacks!", "Break as many as you can!")
end

function MOD:Loadout(ply)
    ply:Give('weapon_crowbar')
end

function MOD:EntityTakeDamage(ent, dmg)
    if ent:IsPlayer() then return true end
end

MOD.ThinkTime = 2
function MOD:Think()
    spawnHacks()
end