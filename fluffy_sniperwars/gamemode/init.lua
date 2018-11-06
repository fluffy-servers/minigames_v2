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

-- Remove fall damage
function GM:GetFallDamage( ply, speed )
    return 0
end