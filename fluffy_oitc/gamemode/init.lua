AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout( ply )
	ply:StripWeapons()
	ply:StripAmmo()
	ply:Give("oitc_gun")
	ply:Give("weapon_mg_knife")
	ply:SetAmmo(0, "Pistol")
end

hook.Add('DoPlayerDeath', 'OITCDeath', function(victim, attacker, dmg)
	if not attacker:IsPlayer() then return end
	
	attacker:GiveAmmo(1, "Pistol", true)
end)