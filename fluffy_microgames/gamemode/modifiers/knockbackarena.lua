MOD.Name = "Knockback"
MOD.Region = 'knockback'
MOD.Elimination = true
MOD.RoundTime = 25
MOD.KillValue = 1

function MOD:Initialize()
    GAMEMODE:Announce("Knockback", "Don't get punched off!")
end

function MOD:Loadout(ply)
    ply:Give('weapon_fists')
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end

    if dmg:GetAttacker():IsPlayer() then
        dmg:SetDamage(0)
        ent.LastAttacker = dmg:GetAttacker()
        local t = CurTime() - GetGlobalFloat('RoundStart', 0)
        local strength = 800 + (t * 40)
        -- Apply knockback
        local v = dmg:GetDamageForce():GetNormalized()
        v.z = math.max(math.abs(v.z) * 0.3, 0.001)
        ent:SetGroundEntity(nil)
        ent:SetVelocity(v * strength)
    elseif dmg:GetAttacker():GetClass() == 'trigger_hurt' then
        -- Credit kills to the last attacker
        dmg:SetAttacker(ent.LastAttacker)
        dmg:SetDamage(100)
        ent.LastAttacker = nil
    end
end