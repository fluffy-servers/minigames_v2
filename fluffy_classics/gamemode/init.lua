-- Send the required files to clients & include shared
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('maps.lua')
include('shared.lua')

-- No weapons on loadout
function GM:PlayerLoadout(ply)
	-- Strip any old weapons & ammo just in case
	ply:StripWeapons()
	ply:StripAmmo()

	-- Respect game_player_equip
	local equips = ents.FindByClass("game_player_equip")
	if equips and equips[1] then
		equips[1]:Use(ply)
	end

	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(400)
end

-- Disable picking up the same weapon twice
hook.Add("PlayerCanPickupWeapon", "StopDoublePickup", function(ply, wep)
	if ply:HasWeapon(wep:GetClass()) then return false end
end)