-- Define tables of random weapons
local random_weapons = {}
random_weapons['shotgun'] = function(p)
    p:Give('weapon_shotgun')
    p:GiveAmmo(20, 'Buckshot')
end

random_weapons['smg'] = function(p)
    p:Give('weapon_smg1')
    p:GiveAmmo(100, 'SMG1')
end

random_weapons['ar2'] = function(p)
    p:Give('weapon_ar2')
    p:GiveAmmo(100, 'AR2')
end

random_weapons['357'] = function(p)
    p:Give('weapon_357')
    p:GiveAmmo(10, '357')
end

random_weapons['pistol'] = function(p)
    p:Give('weapon_pistol')
    p:GiveAmmo(60, 'Pistol')
end

random_weapons['crossbow'] = function(p)
    p:Give('weapon_crossbow')
    p:GiveAmmo(10, 'XBowBolt')
end

local cache_seed = nil
local cache = nil

-- Pick a number of random weapons from the above list
function GM:PickRandomWeapons(seed, num)
    if cache_seed and seed == cache_seed then
        return cache
    else
        cache = table.Random(random_weapons)
        cache_seed = seed
        return cache
    end
end

-- Award survival bonuses to any living players
function GM:SurvivalBonus(victim, attacker, dmg)
    for k,v in pairs(player.GetAll()) do
        if v == victim then continue end
        if v.Spectating or not v:Alive() or v:Team() == TEAM_SPECTATOR then continue end
        
        v:AddFrags(1)
    end
end

-- Make crowbars knock players back instead of doing damage
function GM:CrowbarKnockback(ent, dmg)
    if not ent:IsPlayer() then return true end
    if not dmg:GetAttacker():IsPlayer() then return end
    
    dmg:SetDamage(0)
    local v = dmg:GetDamageForce()
    ent:SetVelocity(v * 100)
end

-- Load all the modifiers from the files
-- This has to be outside of a function
-- Blame Garry not me
GM.Modifiers = {}
print('Loading Microgames modifiers...')
for _, file in pairs(file.Find("gamemodes/fluffy_microgames/gamemode/modifiers/*.lua", "GAME")) do
    local k = string.Replace(file, ".lua", "")
    print('Loading', k)
    
    MOD = {}
    include("modifiers/" .. file)
    GM.Modifiers[k] = MOD
end

-- Clear global variable once this process is done
MOD = nil