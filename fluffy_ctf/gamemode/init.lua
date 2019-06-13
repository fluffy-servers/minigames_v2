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
function GM:SpawnFlag()
    local flag = ents.Create('ctf_flag')
    if not IsValid(flag) then return end
    if GetGlobalString('RoundState') != 'InRound' then return end
    
	-- If the spawn position is not yet defined, find it
    if not GAMEMODE.FlagSpawnPosition then
        local spawn = ents.FindByClass('ctf_flagspawn')[1]
        if not IsValid(spawn) then
            print('Spawn not found! Oh no!')
            return
        end
        
        GAMEMODE.FlagSpawnPosition = spawn:GetPos()
    end
    
	-- Create a flag at the position
    flag:SetPos(GAMEMODE.FlagSpawnPosition)
    flag:Spawn()
    flag:SetNWString('CurrentTeam', 'none')
    GAMEMODE.FlagEntity = flag
    return flag
end

-- Reset the flag at the start of a round
hook.Add('RoundStart', 'InitialSpawnFlag', function()
    timer.Simple(1, function() GAMEMODE:SpawnFlag() end)
    GAMEMODE.LastCarrier = nil
    SetGlobalInt('HoldingTeam', 0)
end)

-- Handle when a team takes control of the flag
function GM:CollectFlag(ply)
	-- Determine the new colour of the flag
    local team = ply:Team()
    SetGlobalInt('HoldingTeam', team)
    
    ply:StripWeapons()
    ply:SetWalkSpeed(375)
    ply:SetRunSpeed(415)
    ply:Give('weapon_ctf_flag')
    GAMEMODE.LastCarrier = ply
    
    -- Make sure we only have one flag left
    for k,v in pairs(ents.FindByClass('ctf_flag')) do
        v:Remove()
    end
end

-- Triggered when a goal is scored
function GM:ScoreGoal(team, entity)
    if GetGlobalString('RoundState') != 'InRound' then return end
    
	-- End the round, counting a win for the given team
    GAMEMODE:EndRound(team)
    
    -- Bonus to the person who scores the capture
    if IsValid(GAMEMODE.LastCarrier) then
        GAMEMODE.LastCarrier:AddFrags(3)
        GAMEMODE.LastCarrier:AddStatPoints('CTFCaptures', 1)
    end
    
    --GAMEMODE:EntityCameraAnnouncement(entity, GAMEMODE.RoundCooldown or 5)
end

-- Dissolve any players that get killed with the flag
function GM:EntityTakeDamage(target, dmginfo)
    local inflictor = dmginfo:GetInflictor()
    if inflictor:GetClass() == 'ctf_flag' then
        -- Block damage for teammates
        if target:Team() == GetGlobalInt('HoldingTeam', 0) then return true end
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetAttacker(GAMEMODE.LastCarrier)
    end
end

function GM:DoPlayerDeath(ply, attacker, inflictor)
    if ply:HasWeapon('weapon_ctf_flag') then
        ply:GetWeapon('weapon_ctf_flag'):TossFlag(200)
    end
    
    GAMEMODE.BaseClass:DoPlayerDeath(ply, attacker, inflictor)
end