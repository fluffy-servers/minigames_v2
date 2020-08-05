AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

GM.CRATE_DELAY = 3

function GM:PlayerLoadout( ply )
    ply:StripAmmo()
    ply:StripWeapons()
    ply:Give("weapon_crowbar")
end

function GM:CheckRoundEnd()
    if team.GetRoundScore(TEAM_BLUE) < 1 then
        GAMEMODE:EndRound(TEAM_RED)
    elseif team.GetRoundScore(TEAM_RED) < 1 and not GAMEMODE.Asymmetric then
        GAMEMODE:EndRound(TEAM_BLUE)
    end
end

hook.Add('PreRoundStart', 'RegisterTeamCrates', function()
    local blue_crates = ents.FindByClass('crate_blue')
    local red_crates = ents.FindByClass('crate_red')
    team.SetRoundScore(TEAM_BLUE, #blue_crates)

    -- Check if this map is asymmetric or not
    if #red_crates < 1 then
        GAMEMODE.Asymmetric = true
    else
        team.SetRoundScore(TEAM_RED, #red_crates)
    end

    -- Check if this map has any crate spawners
    local blue_spawners = ents.FindByClass('crate_spawner_blue')
    local red_spawners = ents.FindByClass('crate_spawner_red')
    if #blue_spawners > 0 and (GAMEMODE.Asymmetric or #red_spawners > 0) then
        GAMEMODE.SpawnCrates = true
        GAMEMODE.NextCrateSpawn = CurTime() + 15

        GAMEMODE.BlueSpawners = blue_spawners
        GAMEMODE.RedSpawners = red_spawners
    else
        GAMEMODE.SpawnCrates = false
    end
end)

hook.Add('Think', 'CrateSpawn', function()
    if not GAMEMODE.SpawnCrates then return end
    if not GAMEMODE:InRound() then return end

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