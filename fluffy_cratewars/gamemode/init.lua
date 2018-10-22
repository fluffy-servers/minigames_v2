AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function GM:PlayerLoadout( ply )
	ply:StripAmmo()
	ply:StripWeapons()
	ply:Give("weapon_crowbar")
end

function GM:SpawnCrate()
	local spawnents = ents.FindByClass('crate_spawner')
	if #spawnents == 0 then return end
	table.Random(spawnents):SpawnCrate()
end

function GM:StartBattlePhase()
	GAMEMODE.CratePhase = false
	
	for k,v in pairs(player.GetAll()) do
		if !v:Alive() or v.Spectating then continue end
		v:StripWeapons()
		v:Give('weapon_smg1')
		v:GiveAmmo(1000, 'SMG1', true)
		if not v.SmashedCrates then v.SmashedCrates = 1 end
		v:GiveAmmo( math.floor(v.SmashedCrates / 25), 'SMG1_Grenade', true) -- 1 grenade for 25 crates
		v:SetHealth(v.SmashedCrates * 5) -- 5HP per crate
		v:SetMaxHealth(v.SmashedCrates * 5)
		v:AddFrags( math.floor(v.SmashedCrates / 10) ) -- 1 point for 10 crates
	end
end

hook.Add('RoundStart', 'PrepareCratePhase', function()
	for k,v in pairs(player.GetAll()) do
		v.SmashedCrates = 0
	end
	
	GAMEMODE.CratePhase = true
	
	timer.Simple(math.random(40, 60), function() GAMEMODE:StartBattlePhase() end)
end )

hook.Add('PropBreak', 'TrackBrokenCrates', function(ply, prop)
	if !GAMEMODE.CratePhase then return end
	if !ply.SmashedCrates then return end
	ply.SmashedCrates = ply.SmashedCrates + 1
	ply:SetNWInt("Crates", ply.SmashedCrates)
end )

-- Prop
CrateSpawnTimer = 0
local Delay = 0.5
hook.Add("Tick", "TickCrateSpawn", function()
    if GetGlobalString('RoundState') != 'InRound' then return end
	if !GAMEMODE.CratePhase then return end
	
	if CrateSpawnTimer < CurTime() then
		CrateSpawnTimer = CurTime() + Delay
		GAMEMODE:SpawnCrate()
	end
end )

function GM:EntityTakeDamage(target, dmginfo)
	if !target:IsPlayer() then return end
	
	if GAMEMODE.CratePhase then
		dmginfo:SetDamage(0)
		local vec = dmginfo:GetDamageForce()
		target:SetVelocity(vec*10)
	else
		return
	end
end