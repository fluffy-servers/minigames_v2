AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout( ply )
	ply:Give( "sniper_normal" )
	ply:Give( "firearm_p228" )
	ply:Give( "weapon_translocator" )
	
	if SHOP then
		--ply:EquipKnife()
	end
end

-- This doesn't work but at least I tried
-- Reduce fall damage for the anti-grav boost
function GM:GetFallDamage( ply, speed )
	if ply:GetGravity() < 0.5 then return end
	
	return speed / 8
end