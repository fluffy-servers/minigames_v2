AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Appropiate weapon stuff
function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    ply:StripAmmo()
    
    if ply:Team() == TEAM_BLUE then
        -- Survivors
        ply:Give('weapon_pistol')
        ply:Give('weapon_smg1')
        ply:Give('weapon_shotgun')
        ply:GiveAmmo(512, 'Pistol', true)
        ply:GiveAmmo(512, 'Buckshot', true)
        ply:GiveAmmo(1024, 'SMG1', true)
        
        ply:SetRunSpeed(300)
        ply:SetWalkSpeed(200)
    elseif ply:Team() == TEAM_RED then
        -- Infected
        -- Initial infected are stronger but slower
        if ply.InitialHunter then
            ply:SetMaxHealth(200)
            ply:SetHealth(200)
            ply:Give('weapon_fists')
            ply:SetRunSpeed(400)
            ply:SetWalkSpeed(200)
        else
            ply:Give('weapon_fists')
            ply:SetRunSpeed(500)
            ply:SetWalkSpeed(300)
        end
    end
end

-- Pick player models
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        ply:SetModel( "models/player/zombie_classic.mdl" )
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Humans can stil commit suicide
function GM:CanPlayerSuicide(ply)
   if ply:Team() == TEAM_RED then return false end
   
   return true
end

-- Track survived rounds
function GM:StatsRoundWin(winners)
    if winners == TEAM_BLUE then
        for k,v in pairs(team.GetPlayers(TEAM_BLUE)) do
            if v:Alive() then
                GAMEMODE:AddStatPoints(v, 'survived_rounds', 1)
            end
        end
    end
end