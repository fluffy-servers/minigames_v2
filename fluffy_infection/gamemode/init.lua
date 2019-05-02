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
        
        ply:SetRunSpeed(300)
        ply:SetWalkSpeed(200)
        ply:SetBloodColor(BLOOD_COLOR_RED)
    elseif ply:Team() == TEAM_RED then
        -- Infected
        -- Initial infected are stronger but slower
        ply:SetBloodColor(BLOOD_COLOR_GREEN)
        ply:Give('weapon_fists')
        ply:SetMaxHealth(200)
        ply:SetHealth(200)
        ply:SetRunSpeed(400)
        ply:SetWalkSpeed(250)
    end
end

-- Pick player models
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        ply:SetModel("models/player/zombie_soldier.mdl")
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Humans can stil commit suicide
function GM:CanPlayerSuicide(ply)
   if ply:Team() == TEAM_RED then return false end
   
   return true
end

-- Make new players join the Hunter team on connection
function GM:PlayerInitialSpawn(ply)
    ply:SetTeam(TEAM_RED)
end

-- Make everyone start as a human
hook.Add('PreRoundStart', 'InfectionResetPlayers', function()
    for k,v in pairs(player.GetAll()) do
        if v:Team() == TEAM_SPECTATOR then continue end
        v:SetTeam(TEAM_BLUE)
    end
end)

-- Stop Zombies from switching back to the other team
hook.Add('PlayerCanJoinTeam', 'StopZombieSwap', function(ply, team)
    local current_team = ply:Team()
    if current_team == TEAM_RED then
        ply:ChatPrint('You cannot change teams currently')
        return false
    end 
end)

-- Assign dead survivors to the hunter team
hook.Add('PlayerDeath', 'InfectionDeath', function(ply)
    if ply:Team() == TEAM_BLUE then
        ply:SetTeam(TEAM_RED)
    end
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

-- Last Survivor gets a message and a stat bonus
hook.Add('DoPlayerDeath', 'AwardLastSurvivorInfection', function(ply)
    if ply:Team() != TEAM_BLUE then return end
    
    local last_player = GAMEMODE:GetLastPlayer(ply)
    if IsValid(last_player) and last_player != false then
        -- Award the last survivor bonus
        local name = string.sub(last_player:Nick(), 1, 10)
        GAMEMODE:PulseAnnouncement(4, name .. ' is the lone survivor!', 0.8)
        last_player:AddStatPoints('Last Survivor', 1)
    end
end)

hook.Add('EntityTakeDamage', 'FistsBuff', function(target, dmg)
    local wep = dmg:GetInflictor()
    if wep:GetClass() == 'player' then wep = wep:GetActiveWeapon() end
    if wep:GetClass() == "weapon_fists" then
        dmg:ScaleDamage(3)
    end
end)