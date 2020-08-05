AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

GM.CRATE_DELAY = 3
GM.CHECK_DELAY = 5
GM.KillValue = 3

function GM:PlayerLoadout( ply )
    ply:StripAmmo()
    ply:StripWeapons()
    ply:Give("weapon_crowbar")
    ply:Give("weapon_mg_pistol")
    ply:GiveAmmo(512, "Pistol", true)
    ply:Give("weapon_physcannon")
end

function GM:CheckRoundEnd()
    if team.GetRoundScore(TEAM_BLUE) < 1 then
        GAMEMODE:EndRound(TEAM_RED)
    elseif team.GetRoundScore(TEAM_RED) < 1 and not GetGlobalBool('CW_Asymmetric', false) then
        GAMEMODE:EndRound(TEAM_BLUE)
    end
end

hook.Add('PreRoundStart', 'RegisterTeamCrates', function()
    local blue_crates = ents.FindByClass('crate_blue')
    local red_crates = ents.FindByClass('crate_red')
    team.SetRoundScore(TEAM_BLUE, #blue_crates)

    -- Check if this map is asymmetric or not
    if #red_crates < 1 then
        SetGlobalBool('CW_Asymmetric', true)
    else
        team.SetRoundScore(TEAM_RED, #red_crates)
    end

    -- Swap teams at the start of Round 4 if asymmetric
    if GetGlobalBool('CW_Asymmetric', false) and GAMEMODE:GetRoundNumber() == 4 then
        GAMEMODE:SwapTeams(true, true)
    end

    -- Check if this map has any crate spawners
    local blue_spawners = ents.FindByClass('crate_spawner_blue')
    local red_spawners = ents.FindByClass('crate_spawner_red')
    if #blue_spawners > 0 and (GetGlobalBool('CW_Asymmetric', false) or #red_spawners > 0) then
        GAMEMODE.SpawnCrates = true
        GAMEMODE.NextCrateSpawn = CurTime() + 15

        GAMEMODE.BlueSpawners = blue_spawners
        GAMEMODE.RedSpawners = red_spawners
    else
        GAMEMODE.SpawnCrates = false
    end
end)

hook.Add('Think', 'CrateThink', function()
    if not GAMEMODE:InRound() then return end

    -- Update crate scores to ensure we're in sync
    -- This stops weird things from affecting the scores
    if (GAMEMODE.NextCrateCheck or 0 < CurTime()) then
        team.SetRoundScore(TEAM_BLUE, #ents.FindByClass('crate_blue'))
        team.SetRoundScore(TEAM_RED, # ents.FindByClass('crate_red'))
        GAMEMODE.NextCrateCheck = CurTime() + GAMEMODE.CHECK_DELAY
    end
    
    -- Fire crate spawners when applicable
    if not GAMEMODE.SpawnCrates then return end
    if GAMEMODE.NextCrateSpawn < CurTime() then
        GAMEMODE.NextCrateSpawn = CurTime() + GAMEMODE.CRATE_DELAY
        GAMEMODE:SpawnCrate()
    end
end)

function GM:SpawnCrate()
    if GAMEMODE.Asymmetric then
        if #ents.FindByClass('crate_blue') >= 100 then return end
        table.Random(GAMEMODE.BlueSpawners):SpawnCrate()
    else
        if #ents.FindByClass('crate_blue') >= 100 then return end
        if #ents.FindByClass('crate_red') >= 100 then return end
        table.Random(GAMEMODE.BlueSpawners):SpawnCrate()
        table.Random(GAMEMODE.RedSpawners):SpawnCrate()
    end
end

hook.Add('EntityTakeDamage', 'CrowbarBuff', function(target, dmg)
    local wep = dmg:GetInflictor()
    if wep:IsPlayer() then wep = wep:GetActiveWeapon() end

    if wep:GetClass() == 'weapon_crowbar' then
        dmg:SetDamage(25)
    end
end)

hook.Add('EntityTakeDamage', 'PistolBuff', function(target, dmg)
    if not target:IsPlayer() then return end

    local wep = dmg:GetInflictor()
    if wep:IsPlayer() then wep = wep:GetActiveWeapon() end

    if wep:GetClass() == 'weapon_mg_pistol' then
        dmg:ScaleDamage(1.5)
    end
end)

-- Override the base scoring function
function GM:HandlePlayerDeath(ply, attacker, dmginfo) 
    if !attacker:IsValid() or !attacker:IsPlayer() then return end
    if attacker == ply then return end
    if !GAMEMODE:InRound() then return end
    
    -- Add the frag to scoreboard
    attacker:AddFrags(GAMEMODE.KillValue)
    GAMEMODE:AddStatPoints(attacker, 'Kills', 1)
end