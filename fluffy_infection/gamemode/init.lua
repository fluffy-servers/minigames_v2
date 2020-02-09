AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Appropiate weapon stuff
function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    ply:StripAmmo()
    
    if ply:Team() == TEAM_BLUE then
        -- Survivors
        ply:Give('weapon_mg_pistol')
        ply:Give('weapon_mg_smg')
        ply:Give('weapon_mg_shotgun')
        ply:GiveAmmo(512, 'Pistol', true)
        ply:GiveAmmo(512, 'Buckshot', true)
        ply:GiveAmmo(1024, 'SMG1', true)
        
        ply:SetRunSpeed(300)
        ply:SetWalkSpeed(200)
        ply:SetBloodColor(BLOOD_COLOR_RED)
    elseif ply:Team() == TEAM_RED then
        -- Infected
        -- Initial infected are stronger but slower
        ply:SetBloodColor(BLOOD_COLOR_GREEN)
        if ply.InitialHunter then
            ply:SetMaxHealth(75)
            ply:SetHealth(75)
            ply:SetRunSpeed(305)
            ply:SetWalkSpeed(255)
        else
            ply:SetMaxHealth(50)
            ply:SetHealth(50)
            ply:SetRunSpeed(325)
            ply:SetWalkSpeed(300)
        end
        ply:Give('weapon_fists')
    end
end

-- Pick player models
function GM:PlayerSetModel(ply)
    if ply:Team() == TEAM_RED then
        if ply.InitialHunter then
            ply:SetModel("models/player/zombie_classic.mdl")
        else
            ply:SetModel("models/player/zombie_fast.mdl")
        end
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

-- Buff fists
hook.Add('EntityTakeDamage', 'BuffFists', function(target, dmg)
    local wep = dmg:GetInflictor()
    if wep:GetClass() == 'player' then wep = wep:GetActiveWeapon() end
    if wep:GetClass() == 'weapon_fists' then
        dmg:ScaleDamage(20)
        dmg:SetDamageForce(dmg:GetDamageForce()*50)
    end
end)