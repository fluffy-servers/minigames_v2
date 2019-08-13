AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()
    ply:Give('mortar')
    ply:GiveAmmo(1000, 'RPG_Round')
    
    local hp = 100 + 25 * GAMEMODE:NumNonSpectators()
    ply:SetMaxHealth(hp)
    ply:SetHealth(hp)
end

-- No fall damage
function GM:GetFallDamage()
    return 0
end

-- During the crate phase, players cannot die
function GM:EntityTakeDamage(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if attacker == target then
        dmginfo:SetDamage(0)
        target:SetLocalVelocity(dmginfo:GetDamageForce():GetNormalized() * 650)
    end
end