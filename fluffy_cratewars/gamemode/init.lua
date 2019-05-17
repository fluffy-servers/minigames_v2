AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Define the weapons that can be awarded from crates
GM.WeaponOptions = {
    weapon_stunstick = {'Stunstick', nil, 0},
    weapon_357 = {'Revolver', '357', 3},
    weapon_frag = {'Grenade', 'Grenade', 1},
    weapon_crossbow = {'Crossbow', 'XBowBolt', 3},
    weapon_pistol = {'Pistol', 'Pistol', 12},
    weapon_smg1 = {'SMG Bomb', 'SMG1_Grenade', 1},
    weapon_shotgun = {'Shotgun', 'Buckshot', 6},
}

-- Percentage of crates that have bonuses
GM.BonusPercentage = 0.06

-- Players start with a crowbar
-- See the StartBattlePhase function for that part of the round
function GM:PlayerLoadout( ply )
    ply:StripAmmo()
    ply:StripWeapons()
    ply:Give("weapon_crowbar")
end

-- Spawn a crate at a random spawn entity
function GM:SpawnCrate()
    local spawnents = ents.FindByClass('crate_spawner')
    if #spawnents == 0 then return end
    table.Random(spawnents):SpawnCrate()
end

-- Start the Battle Phase of a round
-- This awards bonuses based on the crates broken
function GM:StartBattlePhase()
    GAMEMODE.CratePhase = false
    
    -- Find and open specific door entities
    local doors = ents.FindByName('battle_door')
    if istable(doors) and #doors > 0 then
        for k,v in pairs(doors) do
            v:Fire('Open')
        end
    end
    
    -- Award the stuff to all the living players
    for k,v in pairs(player.GetAll()) do
        if !v:Alive() or v.Spectating then continue end
        v:StripWeapons()
        
        -- Players get an SMG by default
        v:Give('weapon_smg1')
        v:GiveAmmo(1000, 'SMG1', true)
        
        -- Award HP and prizes based on what they collected
        if v.SmashedCrates and v.SmashedCrates > 0 then
            v:SetHealth(v.SmashedCrates * 5) -- 5HP per crate
            v:SetMaxHealth(v.SmashedCrates * 5)
            v:AddFrags(math.floor(v.SmashedCrates / 10)) -- 1 point for 10 crates
            for wep, amount in pairs(v.Bonuses) do
                local tbl = GAMEMODE.WeaponOptions[wep]
                v:Give(wep)
                v:GiveAmmo(tbl[3], tbl[2], true)
            end
        else
            -- Make sure players have at least some HP
            v:SetHealth(10)
            v:SetMaxHealth(10)
        end
    end
end

hook.Add('PreRoundStart', 'PrepareCratePhase', function()
    -- Reset the number of smashed crates
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
    
    -- Set a timer for when the battle begins
    local time = math.random(40, 60)
    timer.Simple(time-3, function() GAMEMODE:CountdownAnnouncement(3, "Fight!") end)
    timer.Simple(time, function() GAMEMODE:StartBattlePhase() end)
end )

-- Crate breaking handler
hook.Add('PropBreak', 'TrackBrokenCrates', function(ply, prop)
    -- Keep track of any crates broken in the crates phase
    if !GAMEMODE.CratePhase then return end
    if !ply.SmashedCrates then return end
    ply.SmashedCrates = ply.SmashedCrates + 1
    ply:SetNWInt("Crates", ply.SmashedCrates)
    ply:AddStatPoints('Crates Smashed', 1)
    
    -- Award bonuses to the player if lucky
    if prop.BonusWeapon then
        if not ply.Bonuses then ply.Bonuses = {} end
        if not ply.Bonuses[prop.BonusWeapon] then 
            ply.Bonuses[prop.BonusWeapon] = 0
        else
            ply.Bonuses[prop.BonusWeapon] = ply.Bonuses[prop.BonusWeapon] + 1
        end
        
        local text = GAMEMODE.WeaponOptions[prop.BonusWeapon][1]
        GAMEMODE:PlayerOnlyAnnouncement(ply, 1, text or 'Bonus!', 1)
        ply:AddStatPoints('Bonuses Earned', 1)
    end
end )

-- Delay between crate spawns
-- Scales based on player count
function GM:GetCrateDelay()
    local count = player.GetCount()
    if count < 4 then
        return 0.6
    elseif count < 8 then
        return 0.4
    else
        return 0.2
    end
end

-- Spawn crates at spawn entities every so often
-- Note that crates will not spawn if there are over 200 in the map already
GM.CrateSpawnTimer = 0
hook.Add("Tick", "TickCrateSpawn", function()
    if !GAMEMODE.SpawnCrates then return end
    if GetGlobalString('RoundState') != 'InRound' then return end
    if !GAMEMODE.CratePhase then return end
    
    if GAMEMODE.CrateSpawnTimer < CurTime() then
        GAMEMODE.CrateSpawnTimer = CurTime() + GAMEMODE:GetCrateDelay()
        GAMEMODE:SpawnCrate()
    end
end )

-- During the crate phase, players cannot die
function GM:EntityTakeDamage(target, dmginfo)
    if GAMEMODE.CratePhase then
        if target:IsPlayer() then
            dmginfo:SetDamage(0)
            local vec = dmginfo:GetDamageForce()
            target:SetVelocity(vec*10)
        else
            dmginfo:SetDamage(500)
        end
    else
        return
    end
end

-- Register XP for Crate Wars
hook.Add('RegisterStatsConversions', 'AddCrateWarsStatConversions', function()
    GAMEMODE:AddStatConversion('Crates Smashed', 'Destroyed Crates', 0.1)
    GAMEMODE:AddStatConversion('Bonuses Earned', 'Bonuses Earned', 0)
end)