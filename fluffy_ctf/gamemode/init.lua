AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Players start off with a variety of weapons
function GM:PlayerLoadout( ply )
    ply:SetWalkSpeed( 350 )
    ply:SetRunSpeed( 360 )
    
    ply:Give('weapon_physcannon')
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
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    
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
end )

-- Returns the flag entity or spawns a new flag
function GM:GetFlagEntity()
    if not IsValid(GAMEMODE.FlagEntity) then
        return GAMEMODE:SpawnFlag()
    else
        return GAMEMODE.FlagEntity
    end
end

-- Handle when a team takes control of the flag
function GM:CollectFlag(team)
	-- Determine the new colour of the flag
    local c = Vector(1, 1, 1)
    local name = 'none'
    if team == TEAM_RED then
        c = Vector(1, 0, 0)
        name = 'red'
    elseif team == TEAM_BLUE then
        c = Vector(0, 0, 1)
        name = 'blue'
    end
    
	-- Set the flag current team & color
    local flag = GAMEMODE:GetFlagEntity()
    flag:SetNWString('CurrentTeam', name)
    flag:SetNWVector('RColor', c)
end

-- Triggered when a goal is scored
function GM:ScoreGoal(team)
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    
	-- End the round, counting a win for the given team
    GAMEMODE:EndRound(team)
    
    -- Bonus to the person who scores the capture
    if IsValid(GAMEMODE.LastCarrier) then
        GAMEMODE.LastCarrier:AddFrags(3)
        GAMEMODE.LastCarrier:AddStatPoints('CTFCaptures', 1)
    end
    
    GAMEMODE:EntityCameraAnnouncement(GAMEMODE:GetFlagEntity(), GAMEMODE.RoundCooldown or 5)
end

-- Check for when the flag is picked up with the gravity gun
function GM:GravGunOnPickedUp(ply, ent)
    if ply:Team() != TEAM_BLUE and ply:Team() != TEAM_RED then return end
    if not IsValid(GAMEMODE.FlagEntity) then GAMEMODE:SpawnFlag() end
    
    if ent == GAMEMODE.FlagEntity then
        GAMEMODE:CollectFlag(ply:Team())
        GAMEMODE.LastCarrier = ply
    end
end

-- Dissolve any players that get killed with the flag
function GM:EntityTakeDamage(target, dmginfo)
    if target:IsPlayer() then
        local inflictor = dmginfo:GetInflictor()
        if inflictor:GetClass() == "ctf_flag" then
            dmginfo:SetDamageType(DMG_DISSOLVE)
        end
    end
end