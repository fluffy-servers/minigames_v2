AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Give the player these weapons on loadout
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()
    ply:Give("weapon_stunstick")
    -- Health goes the opposite way to normal in this gamemode
    -- 500HP = WHOA
    -- 1HP = fine!
    ply:SetHealth(1)
    ply:SetMaxHealth(500)
end

-- Apply knockback proportional to health when damaged
function GM:EntityTakeDamage(target, dmg)
    if target:IsPlayer() and dmg:GetAttacker():IsPlayer() then
        local hp = target:Health()
        local newdamage = math.random(10, 30) -- random damage
        target:SetHealth(math.Clamp(hp + newdamage, 0, 500))
        -- Apply force
        dmg:SetDamage(0)
        local f = dmg:GetDamageForce():GetNormalized()
        f.z = math.abs(f.z)
        f = f * (hp + newdamage + 20) * 10
        f.z = math.Clamp(f.z, 250, 700)
        target:SetVelocity(f) -- force based on health

        return true
    end
end