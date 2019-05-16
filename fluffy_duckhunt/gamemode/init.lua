AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Appropiate weapon stuff
function GM:PlayerLoadout( ply )
    if ply:Team() == TEAM_BLUE then
        -- Runners
        ply:StripWeapons()
        ply:SetWalkSpeed(350)
        ply:SetRunSpeed(400)
    elseif ply:Team() == TEAM_RED then
        -- Snipers
        ply:Give('sniper_normal')
        ply:SetWalkSpeed(475)
        ply:SetRunSpeed(525)
    end
end

-- Runners can still commit suicide
function GM:CanPlayerSuicide(ply)
   if ply:Team() == TEAM_RED then return false end
   
   return true
end

function GM:HandleEndRound(reason)
    if type(reason) == 'number' then
        team.AddScore(reason, 1)
        return reason, team.GetName(reason) .. ' win the round!'
    elseif type(reason) == 'Player' then
        -- Winning player gets 3 points
        reason:AddFrags(3)
        GAMEMODE:AddStatPoints(reason, 'Finished First', 1)
        
        -- Other survivors get 1 point
        if reason:Team() == TEAM_BLUE then
            team.AddScore(TEAM_BLUE, 1)
            for k,v in pairs( team.GetPlayers(TEAM_BLUE) ) do
                GAMEMODE:AddStatPoints(v, 'Survived Rounds', 1)
                if v != reason then v:AddFrags(1) end
            end
        end
        
        return reason, reason:Nick() .. ' wins the round!'
    else
        return 0, "Nobody wins"
    end
end

function GM:StatsRoundWin()
    -- Handled above
end

-- Register XP for Duck Hunt
hook.Add('RegisterStatsConversions', 'AddDuckHuntStatConversions', function()
    GAMEMODE:AddStatConversion('Finished First', 'Finished First', 5)
    GAMEMODE:AddStatConversion('Runners Sniped', 'Runners Sniped', 0.5)
end)