AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

GM.WeaponOptions = {
    weapon_stunstick = {'Stunstick', nil, 0},
    weapon_357 = {'Revolver', '357', 3},
    weapon_frag = {'Grenade', 'Grenade', 1},
    weapon_crossbow = {'Crossbow', 'XBowBolt', 3},
    weapon_pistol = {'Pistol', 'Pistol', 12},
    weapon_smg1 = {'SMG Bomb', 'SMG1_Grenade', 1},
    weapon_shotgun = {'Shotgun', 'Buckshot', 6},
}

GM.BonusPercentage = 0.06

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
        v:SetHealth(v.SmashedCrates * 5) -- 5HP per crate
        v:SetMaxHealth(v.SmashedCrates * 5)
        v:AddFrags( math.floor(v.SmashedCrates / 10) ) -- 1 point for 10 crates
        
        if not v.Bonuses then continue end
        for wep, amount in pairs(v.Bonuses) do
            local tbl = GAMEMODE.WeaponOptions[wep]
            v:Give(wep)
            v:GiveAmmo(tbl[3], tbl[2])
        end
    end
end

hook.Add('PreRoundStart', 'PrepareCratePhase', function()
    for k,v in pairs(player.GetAll()) do
        v.SmashedCrates = 0
        v.Bonuses = {}
        v:SetNWInt('Crates', 0)
    end
    
    GAMEMODE.CratePhase = true
    -- Check if this map has any crate spawners
    if #ents.FindByClass('crate_spawner') > 0 then
        GAMEMODE.SpawnCrates = true
    else
        GAMEMODE.SpawnCrates = false
    end
    
    -- Apply bonus weapons to any already existing crates
    for k, prop in pairs(ents.FindByClass('prop_physics')) do
        if math.random() <= GAMEMODE.BonusPercentage then
            prop.BonusWeapon = table.Random(table.GetKeys(GAMEMODE.WeaponOptions))
        end
    end
    
    local time = math.random(40, 60)
    timer.Simple(time-3, function() GAMEMODE:CountdownAnnouncement(3, "Fight!") end)
    timer.Simple(time, function() GAMEMODE:StartBattlePhase() end)
end )

hook.Add('PropBreak', 'TrackBrokenCrates', function(ply, prop)
    if !GAMEMODE.CratePhase then return end
    if !ply.SmashedCrates then return end
    ply.SmashedCrates = ply.SmashedCrates + 1
    ply:SetNWInt("Crates", ply.SmashedCrates)
    ply:AddStatPoints('Crates', 1)
    
    if prop.BonusWeapon then
        if not ply.Bonuses then ply.Bonuses = {} end
        if not ply.Bonuses[prop.BonusWeapon] then 
            ply.Bonuses[prop.BonusWeapon] = 0
        else
            ply.Bonuses[prop.BonusWeapon] = ply.Bonuses[prop.BonusWeapon] + 1
        end
        
        local text = GAMEMODE.WeaponOptions[prop.BonusWeapon][1]
        GAMEMODE:PlayerOnlyAnnouncement(ply, 1, text or 'Bonus!', 1)
    end
end )

-- Prop
CrateSpawnTimer = 0
local Delay = 0.5
hook.Add("Tick", "TickCrateSpawn", function()
    if !GAMEMODE.SpawnCrates then return end
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