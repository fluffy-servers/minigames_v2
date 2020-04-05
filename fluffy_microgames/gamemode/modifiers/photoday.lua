MOD.Name = 'Photoday'
MOD.Region = 'knockback'
MOD.ScoreValue = 0.5
MOD.ScoringPane = true
MOD.WinValue = 3

local function spawnCScanner()
    local number = GAMEMODE:PlayerScale(2, 10, 32)
    local positions = GAMEMODE:GetRandomLocations(number, 'sky')

    for i=1,number do
        local pos = positions[i] + Vector(0, 0, 32)
        local cscanner = ents.Create("npc_cscanner")
        cscanner:SetPos(pos)
        cscanner:Spawn()
    end
end

function MOD:OnNPCKilled(npc, attacker, inflictor)
  if not attacker:IsPlayer() then return end
  if npc:GetClass() != "npc_cscanner" then return end

  attacker:AddMScore(1)
end

function MOD:Initialize()
    spawnCScanner()
    GAMEMODE:Announce("Say Cheese!")
end

function MOD:Loadout(ply)
    ply:Give('weapon_crowbar')
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
end