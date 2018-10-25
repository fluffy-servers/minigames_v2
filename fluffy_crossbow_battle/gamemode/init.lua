-- Send the required files to clients & include shared
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function GM:PlayerLoadout( ply )
	ply:StripWeapons()
	ply:StripAmmo()
	ply:Give("weapon_crossbow")
	ply:Give("weapon_crowbar")
	ply:GiveAmmo(200, "XBowBolt")
end
