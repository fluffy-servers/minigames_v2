-- Send the required files to clients & include shared
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout(ply)
	-- Strip any old weapons & ammo just in case
	ply:StripWeapons()
	ply:StripAmmo()
	-- Give the OITC gun & the Minigames knife
	ply:Give("oitc_gun")
	ply:Give("weapon_mg_knife")
	-- Make sure the player has no spare ammo for the gun
	ply:SetAmmo(0, "Pistol")
end

-- Give 1 pistol ammo when a player gets a kill
hook.Add('DoPlayerDeath', 'OITCDeath', function(victim, attacker, dmg)
	-- Verify the attacker is a player
	if not attacker:IsPlayer() then return end
	-- Verify it wasn't a suicide
	if attacker == victim then return end
	-- Award the 1 ammo for kills
	attacker:GiveAmmo(1, "Pistol", true)
end)

-- Buff the knife in OITC
hook.Add('ScalePlayerDamage', 'BuffOITCKnife', function(ply, hg, dmg)
    if dmg:GetInflictor():GetClass() == 'weapon_mg_knife' then
        dmg:SetDamage(100)
        dmg:ScaleDamage(10)
        return
    end
end)