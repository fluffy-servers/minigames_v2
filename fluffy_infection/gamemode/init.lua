AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
include('sv_zombies.lua')

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
        
        ply:SetRunSpeed(225)
        ply:SetWalkSpeed(200)
        ply:SetBloodColor(BLOOD_COLOR_RED)
    elseif ply:Team() == TEAM_RED then
        -- Infected
        -- Initial infected are stronger but slower
        ply:SetBloodColor(BLOOD_COLOR_GREEN)
        ply:Give('weapon_fists')
        ply:SetMaxHealth(125)
        ply:SetHealth(125)
        ply:SetRunSpeed(300)
        ply:SetWalkSpeed(250)
    end
end

-- Pick player models
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        ply:SetModel("models/player/zombie_classic.mdl")
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Make everyone start as a human
hook.Add('PreRoundStart', 'InfectionResetPlayers', function()
    GAMEMODE.WaveNumber = 0
    GAMEMODE.WaveTimer = 0
end)

-- Get the last player on the human team
function GM:GetLastPlayer(exclude_player)
    local last_alive = nil
    for k,v in pairs( player.GetAll() ) do
        if v:Alive() and v:Team() == TEAM_BLUE and !v.Spectating then
            if exclude_player and v == exclude_player then continue end
            if IsValid(last_alive) then
                return false
            else
                last_alive = v
            end
        end
    end
    return last_alive
end

-- Check if there enough players to start a round
function GM:CanRoundStart()
    if GAMEMODE:NumNonSpectators() >= 2 then
        return true
    else
        return false
    end
end

-- Stat Tracking for Zombie kills
hook.Add('OnNPCKilled', 'ZombieKilledStats', function(npc, attacker, inflictor)
    local class = npc:GetClass() -- not yet relevant
    if attacker:IsPlayer() and attacker:Team() == TEAM_BLUE then
        attacker:AddStatPoints('Zombies Killed', 1)
        attacker:AddFrags(1)
    end
end)

-- 1XP for every 5 zombies defeated
hook.Add('RegisterStatsConversions', 'AddInfectionStatConversions', function()
    GAMEMODE:AddStatConversion('Zombies Killed', 'Zombies Killed', 0.2)
end)

hook.Add('EntityTakeDamage', 'FistsBuff', function(target, dmg)
    local wep = dmg:GetInflictor()
    if wep:GetClass() == 'player' then wep = wep:GetActiveWeapon() end
    if wep:GetClass() == "weapon_fists" then
        dmg:ScaleDamage(3)
    end
end)