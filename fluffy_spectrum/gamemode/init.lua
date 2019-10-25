AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function GM:PlayerLoadout(ply)
    ply:StripAmmo()
    ply:StripWeapons()
    ply:Give("weapon_mg_pistol")
    ply:Give("weapon_mg_smg")
	ply:Give("weapon_mg_shotgun")
    ply:GiveAmmo(512, "Pistol", true)
    ply:GiveAmmo(512, "SMG1", true)
	ply:GiveAmmo(512, "Buckshot", true)
end

-- Check if there enough players to start a round
function GM:CanRoundStart()
    if GAMEMODE:NumNonSpectators() >= 2 then
        return true
    else
        return false
    end
end

-- Prepare the round properties
hook.Add('PreRoundStart', 'VIPPreparations', function()
    -- Shuffle a list of team colors & the list of players
    colors = table.Shuffle({TEAM_RED, TEAM_BLUE, TEAM_GREEN, TEAM_YELLOW, TEAM_PURPLE, TEAM_ORANGE, TEAM_PINK, TEAM_CYAN})
    players = table.Shuffle(player.GetAll())
    
    -- Assign players evenly to the teams
    -- If there are less than 9 players this works nicely
    -- Otherwise, by the Pigeonhole Principle, the teams will be unbalanced (unless a multiple of 8)
    -- Team balancing for this will be implemented at some point but until then there's some slight bias
    for k,v in pairs(players) do
        if v:Team() == TEAM_SPECTATOR then continue end
        
        local i = ((k-1)%8) + 1
        v:SetTeam(colors[i])
        v.InitialTeam = colors[i]
    end
end)

-- If one team has taken over, win the round
function GM:CheckVictory(t)
    if team.NumPlayers(t) >= GAMEMODE:GetLivingPlayers() then
        GAMEMODE:EndRound(t)
    end
end

-- Stop stupid bug
function GM:CheckRoundEnd()
    return false
end

-- Custom damage hook to handle conversions
function GM:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if not ent:Alive() then return end
    
    local attacker = dmg:GetAttacker()
    if not attacker:IsPlayer() then return end
    if attacker:Team() == ent:Team() then return end
    
    local amount = dmg:GetDamage()
    if ent:Health() - amount <= 0 then
        -- Reset the 'dead' player
        dmg:SetDamage(0)
        ent:SetHealth(100)
        ent:AddDeaths(1)
        
        -- Add points to inflictor
        attacker:AddFrags(1)
        attacker:AddStatPoints('Enemy Conversions', 1)
        
        -- Change the team
        local t = attacker:Team()
        local color = team.GetColor(t)
        ent:SetTeam(t)
		ent:SetPlayerColor(Vector(color.r/255, color.g/255, color.b/255))
        GAMEMODE:PlayerOnlyAnnouncement(ent, 2, 'You are now on ' .. team.GetName(t))
        GAMEMODE:CheckVictory(t)
        
        -- Fake a death in the killfeed
        net.Start('PlayerKilledByPlayer')
            net.WriteEntity(ent)
            net.WriteString(dmg:GetInflictor():GetClass())
            net.WriteEntity(attacker)
        net.Broadcast()
    end
end

-- Check for victory when people die
hook.Add('DoPlayerDeath', 'CheckVictoryOnDeath', function()
    -- Check all teams since we don't know who is winning
    timer.Simple(0.2, function()
        for i=1,8 do
            GAMEMODE:CheckVictory(i)
        end
    end)
end)

-- Nobody wins on time up
function GM:HandleTeamWin(reason)
    local winners, msg, extra
    if reason == 'TimeEnd' then
        winners = nil
        msg = 'No team has won!'
    elseif type(reason) == 'number' then
        winners = reason
        msg = team.GetName(winners) .. ' win the round!'
        extra = nil
    end
    
    return winners, msg, extra
end

-- Register XP for Spectrum
hook.Add('RegisterStatsConversions', 'AddSpectrumStatConversions', function()
    GAMEMODE:AddStatConversion('Enemy Conversions', 'Enemy Conversions', 0.5)
end)