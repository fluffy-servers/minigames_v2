AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function GM:PlayerLoadout( ply )
    ply:SetWalkSpeed( 350 )
    ply:SetRunSpeed( 360 )
    
    ply:Give('weapon_physcannon')
    ply:Give('weapon_crowbar')
end

function GM:SpawnFlag()
    local flag = ents.Create('ctf_flag')
    if not IsValid(flag) then return end
    
    if not GAMEMODE.FlagSpawnPosition then
        local spawn = ents.FindByClass('ctf_flagspawn')[1]
        if not IsValid(spawn) then
            print('Spawn not found! Oh no!')
            return
        end
        
        GAMEMODE.FlagSpawnPosition = spawn:GetPos()
    end
    
    flag:SetPos(GAMEMODE.FlagSpawnPosition)
    flag:Spawn()
    flag:SetNWString('CurrentTeam', 'none')
    GAMEMODE.FlagEntity = flag
    return flag
end

hook.Add('RoundStart', 'InitialSpawnFlag', function()
    timer.Simple(2, function() GAMEMODE:SpawnFlag() end)
    GAMEMODE.LastCarrier = nil
end )

function GM:GetFlagEntity()
    if not IsValid(GAMEMODE.FlagEntity) then
        return GAMEMODE:SpawnFlag()
    else
        return GAMEMODE.FlagEntity
    end
end

function GM:CollectFlag(team)
    local c = Vector(1, 1, 1)
    local name = 'none'
    if team == TEAM_RED then
        c = Vector(1, 0, 0)
        name = 'red'
    elseif team == TEAM_BLUE then
        c = Vector(0, 0, 1)
        name = 'blue'
    end
    
    local flag = GAMEMODE:GetFlagEntity()
    flag:SetNWString('CurrentTeam', name)
    flag:SetNWVector('RColor', c)
end

function GM:ScoreGoal(team)
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    
    GAMEMODE:EndRound(team)
    
    -- Bonus to the person who scores the capture
    if IsValid(GAMEMODE.LastCarrier) then
        GAMEMODE.LastCarrier:AddFrags(3)
        GAMEMODE.LastCarrier:AddStatPoints('CTFCaptures', 1)
    end
end

function GM:GravGunOnPickedUp(ply, ent)
    if ply:Team() != TEAM_BLUE and ply:Team() != TEAM_RED then return end
    if not IsValid(GAMEMODE.FlagEntity) then GAMEMODE:SpawnFlag() end
    
    if ent == GAMEMODE.FlagEntity then
        GAMEMODE:CollectFlag(ply:Team())
        GAMEMODE.LastCarrier = ply
    end
end

function GM:EntityTakeDamage(target, dmginfo)
    if target:IsPlayer() then
        local inflictor = dmginfo:GetInflictor()
        if inflictor:GetClass() == "ctf_flag" then
            dmginfo:SetDamageType(DMG_DISSOLVE)
        end
    end
end