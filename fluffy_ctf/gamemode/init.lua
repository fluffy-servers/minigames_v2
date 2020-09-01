AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Players start off with a variety of weapons
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()
    
    ply:SetWalkSpeed(300)
    ply:SetRunSpeed(320)
    
    ply:Give('weapon_crowbar')
    ply:Give("weapon_smg1")
	ply:Give("weapon_shotgun")
    ply:GiveAmmo(512, "SMG1", true)
	ply:GiveAmmo(512, "Buckshot", true)
end

-- Spawn the flag
function GM:SpawnSingleFlag()
    if not GAMEMODE:InRound() then return end

    local spawns = ents.FindByClass('ctf_flagspawn')[1]
    if not IsValid(spawn) then
        error('No flag spawn in map!')
    end

    local flag = ents.Create('ctf_flag')
    flag:SetPos(spawn:GetPos())
    flag:Spawn()
    flag:SetNWInt('CurrentTeam', 0)
    return flag
end

function GM:SpawnTeamFlag(team)
    -- Determine spawnpoint entity
    local spawn
    if team == TEAM_BLUE then
        spawn = ents.FindByClass('ctf_flagspawn_blue')[1]
    elseif team == TEAM_RED then
        spawn = ents.FindByClass('ctf_flagspawn_red')[1]
    end
    if not IsValid(spawn) then
        error('No flag spawn in map!')
    end

    -- Determine flag entity
    local flag
    if team == TEAM_BLUE then
        flag = ents.Create('ctf_flag_blue')
    elseif team == TEAM_RED then
        flag = ents.Create('ctf_flag_red')
    end
    if not IsValid(flag) then
        error('Could not create flag entity')
    end

    flag:SetPos(spawn:GetPos())
    flag:Spawn()
    return flag
end

-- Reset flags at the start of a round
hook.Add('RoundStart', 'InitialFlagSpawn', function()
    if GetGlobalBool('CTF_1Flag', false) then
        GAMEMODE:SpawnSingleFlag()
    else
        GAMEMODE:SpawnTeamFlag(TEAM_BLUE)
        GAMEMODE:SpawnTeamFlag(TEAM_RED)
    end
end)

-- Determine if the game is 1Flag or 2Flag mode
hook.Add('PreRoundStart', 'RegisterTeamCrates', function()
    local base_spawners = ents.FindByClass('ctf_flagspawn_one')
    if #base_spawners >= 1 then
        SetGlobalBool('CTF_1Flag', true)
    else
        SetGlobalBool('CTF_1Flag', false)
    end
end)

-- Triggered when a goal is scored
function GM:ScoreGoal(team, entity)
    if not GAMEMODE:InRound() then return end
    
    local message = nil
    local carrier = entity.LastCarrier
    -- Bonus to the person who scores the capture
    if IsValid(carrier) then
        carrier:AddFrags(3)
        carrier:AddStatPoints('CTFCaptures', 1)
        message = carrier:Nick() .. ' scored the capture'
    end
    
    -- End the round, counting a win for the given team
    GAMEMODE:EndRound(team, message)
end

-- Dissolve any players that get killed with the flag
function GM:EntityTakeDamage(target, dmginfo)
    local inflictor = dmginfo:GetInflictor()
    if inflictor:GetClass() == 'ctf_flag_blue' then
        if target:Team() == TEAM_BLUE then return true end
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetAttacker(inflictor.LastCarrier)
    elseif inflictor:GetClass() == 'ctf_flag_red' then
        if target:Team() == TEAM_RED then return true end
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetAttacker(inflictor.LastCarrier)
    elseif inflictor:GetClass() == 'ctf_flag' then
        -- Block damage for teammates
        if target:Team() == inflictor:GetNWInt('HoldingTeam', 0) then return true end
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetAttacker(GAMEMODE.LastCarrier)
    end
end

-- Drop flags on player death
function GM:DoPlayerDeath(ply, attacker, inflictor)
    if ply:HasWeapon('weapon_ctf_flag_red') then
        ply:GetWeapon('weapon_ctf_flag_red'):TossFlag(200)
    end

    if ply:HasWeapon('weapon_ctf_flag_blue') then
        ply:GetWeapon('weapon_ctf_flag_blue'):TossFlag(200)
    end

    if ply:HasWeapon('weapon_ctf_flag') then
        ply:GetWeapon('weapon_ctf_flag'):TossFlag(200)
    end
    
    GAMEMODE.BaseClass:DoPlayerDeath(ply, attacker, inflictor)
end