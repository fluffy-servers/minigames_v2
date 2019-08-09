-- One In The Chamber
-- Players start with 1 bullet and get +1 bullet for each kill
MOD = {
    name = 'One In The Chamber',
    subtext = 'Use it wisely.',
    func_player = function(ply)
        ply:Give('weapon_357')
        ply:StripAmmo()
        ply:SetAmmo(0, '357')
        ply:GetWeapon('weapon_357'):SetClip1(1)
        ply:SetMaxHealth(1)
        ply:SetHealth(1)
        ply:Give('weapon_mg_knife')
    end,
    
	-- Award extra bullet on kill
    hooks = {
        DoPlayerDeath = function(victim, attacker, dmg)
            if not attacker:IsPlayer() then return end
            if attacker == victim then return end
            attacker:GiveAmmo(1, '357')
        end
    }
}