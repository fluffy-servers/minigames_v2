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

-- During the crate phase, players cannot die
function GM:EntityTakeDamage(target, dmginfo)
    local attacker = dmginfo:GetAttacker()

    if attacker == target then
        if dmginfo:GetDamage() > 75 then
            target:AddStatPoints('Rocket Jumps', 1)
        end

        dmginfo:SetDamage(0)
        target:SetLocalVelocity(dmginfo:GetDamageForce():GetNormalized() * 650)
    end
end

-- Register XP for Mortar
hook.Add('RegisterStatsConversions', 'AddMortarStatConversions', function()
    GAMEMODE:AddStatConversion('Mortars Launched', 'Mortars Launched', 0.15)
    GAMEMODE:AddStatConversion('Rocket Jumps', 'Rocket Jumps', 0.25)
end)