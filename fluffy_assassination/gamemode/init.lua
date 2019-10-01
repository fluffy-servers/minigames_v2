AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Override the VIP playermodel
function GM:PlayerSetModel( ply )
    if ply.IsVIP then
        ply:SetModel("models/player/breen.mdl")
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Loadout function
-- VIPs get nothing
-- Guardians get good defensive weapons
-- Killers get blam blam weapons
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    
    if ply:Team() == TEAM_BLUE then
        if ply.IsVIP then return end
        ply:GiveAmmo(512, "Pistol", true)
        ply:Give('weapon_mg_pistol')
        ply:Give('weapon_mg_sniper')
    elseif ply:Team() == TEAM_RED then
        ply:GiveAmmo(512, "SMG1", true)
        ply:GiveAmmo(512, "Buckshot", true)
        ply:Give('weapon_mg_smg')
        ply:Give('weapon_mg_shotgun')
    end
end

-- Prepare the round properties
hook.Add('PreRoundStart', 'VIPPreparations', function()
    -- Step 0: Reset data from previous round
    for k,v in pairs(player.GetAll()) do
        v.IsVIP = false
    end
    GAMEMODE.CurrentVIP = nil
    
    -- Step 1: Swap the teams at the start of Round 6
    if GetGlobalInt('RoundNumber', 0) == 6 then
        GAMEMODE:SwapTeams()
    end
    
    -- Step 2: Select a VIP from the Guardians team
    local vip = table.Random(team.GetPlayers(TEAM_BLUE))
    GAMEMODE.CurrentVIP = vip
    vip.IsVIP = true
    GAMEMODE:TableOnlyAnnouncement(team.GetPlayers(TEAM_BLUE), 3, vip:Nick() .. ' is the VIP')
    
    -- Step 3: Team balance if needed?
    -- todo
end)

-- End the round when the VIP gets ka-shooted
hook.Add('DoPlayerDeath', 'VIPDeath', function(victim, attacker, dmg)
    if GAMEMODE.CurrentVIP != victim then return end
    GAMEMODE:EndRound('VIPDead')
    
    if attacker:IsPlayer() then
        attacker:AddStatPoints('Assassinations', 1)
    end
end)

-- End the round if the VIP disconnects
hook.Add('PlayerDisconnected', 'VIPDisconnect', function(ply)
    if GAMEMODE.CurrentVIP == ply then
        GAMEMODE:EndRound('VIPDead')
    end
end)

-- Guardians win if the VIP survives til TimeEnd
function GM:HandleTeamWin(reason)
    local winners, msg, extra
    if reason == 'TimeEnd' or reason == TEAM_BLUE then
        winners = TEAM_BLUE
        msg = team.GetName(TEAM_BLUE) .. ' win the round!'
        extra = GAMEMODE.CurrentVIP:Nick() .. ' survived!'
        
        if IsValid(GAMEMODE.CurrentVIP) then
            GAMEMODE.CurrentVIP:AddStatPoints('VIP Survivals', 1)
        end
    elseif reason == 'VIPDead' then
        winners = TEAM_RED
        msg = team.GetName(TEAM_RED) .. ' win the round!'
        extra = GAMEMODE.CurrentVIP:Nick() .. ' is dead'
        
        if IsValid(GAMEMODE.CurrentVIP) then
            GAMEMODE.CurrentVIP:AddStatPoints('VIP Deaths', 1)
        end
    else
        msg = 'The round is over!'
    end
    
    return winners, msg, extra
end

-- Register XP for Assassination
hook.Add('RegisterStatsConversions', 'AddAssassinationStatConversions', function()
    GAMEMODE:AddStatConversion('Assassinations', 'Assassinations', 2)
    GAMEMODE:AddStatConversion('VIP Deaths', 'VIP Deaths', 0)
    GAMEMODE:AddStatConversion('VIP Survivals', 'VIP Survivals', 1)
end)