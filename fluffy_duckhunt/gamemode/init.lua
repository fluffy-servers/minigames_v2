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
        ply:StripWeapons()
        ply:Give('dh_sniper')
        ply:SetWalkSpeed(475)
        ply:SetRunSpeed(525)
    end
end

-- Assign FFA colors to all the runners and the basic red to the Snipers
function GM:PlayerSetModel(ply)
	local cl_playermodel = ply:GetInfo("cl_playermodel")
	local modelname = GAMEMODE:TranslatePlayerModel(cl_playermodel, ply)
	util.PrecacheModel(modelname)
	ply:SetModel(modelname)
    
    if ply:Team() == TEAM_RED then
		local color = team.GetColor( ply:Team() )
		ply:SetPlayerColor( Vector( color.r/255, color.g/255, color.b/255 ) )
    else
        if not ply.FFAColor then
            ply.FFAColor = HSVToColor(math.random(360), 1, 1)
        end
        
        local c = Vector(ply.FFAColor.r/255, ply.FFAColor.g/255, ply.FFAColor.b/255)
        ply:SetPlayerColor(c)
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
        local extra = nil
        if GAMEMODE.LastSurvivor then
            extra = string.sub(GAMEMODE.LastSurvivor:Nick(), 1, 10) .. ' was the last survivor'
        end
        
        return reason, team.GetName(reason) .. ' win the round!', extra
    elseif type(reason) == 'Player' then
        -- Winning player gets 3 points
        reason:AddFrags(3)
        GAMEMODE:AddStatPoints(reason, 'Finished First', 1)
        
        -- Other survivors get 1 point
        if reason:Team() == TEAM_BLUE then
            team.AddScore(TEAM_BLUE, 1)
            for k,v in pairs( team.GetPlayers(TEAM_BLUE) ) do
                if v.Spectating then continue end
                if not v:Alive() then continue end
                
                GAMEMODE:AddStatPoints(v, 'Survived Rounds', 1)
                if v != reason then v:AddFrags(1) end
            end
        end
        
        return reason, reason:Nick() .. ' completed the course!'
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