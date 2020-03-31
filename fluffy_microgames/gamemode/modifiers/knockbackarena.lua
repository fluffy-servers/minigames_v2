MOD.Name = "Knockback"
MOD.Region = 'knockback'
MOD.Elimination = true

MOD.KillValue = 1

function MOD:Initialize()
    GAMEMODE:Announce("Knockback", "Don't get punched off!")
end

function MOD:Loadout(ply)
    ply:Give('weapon_fists')
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if not dmg:GetAttacker():IsPlayer() then return end
    
    dmg:SetDamage(0)
    local v = dmg:GetDamageForce():GetNormalized()
    v.z = math.max(math.abs(v.z) * 0.3, 0.001)
    ent:SetGroundEntity(nil)
    ent:SetVelocity(v * 1000)
end