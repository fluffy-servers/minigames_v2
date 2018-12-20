AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    ply:StripAmmo()
    ply:Give('weapon_physcannon')
end

function GM:SpawnBall()
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    
    local ball = ents.Create('db_dodgeball')
    if not IsValid(ball) then return end
    GAMEMODE.BallNumber = GAMEMODE.BallNumber + 1
    if GAMEMODE.BallNumber > #GAMEMODE.SpawnQueue then return end
    
    return GAMEMODE:RespawnBall(GAMEMODE.BallNumber)
end

function GM:RespawnBall(number)
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    
    local ball = ents.Create('db_dodgeball')
    
    local pos = GAMEMODE.SpawnQueue[number]:GetPos()
    ball:SetPos(pos)
    ball:Spawn()
    ball:SetNWString('CurrentTeam', 'none')
    ball.Number = number
    return ball
end

hook.Add('RoundStart', 'InitialSpawnFlag', function()
    GAMEMODE.BallNumber = 0
    GAMEMODE.SpawnQueue = table.Shuffle(ents.FindByClass('db_ballspawn'))
    timer.Simple(1, function() GAMEMODE:SpawnBall() end)
    timer.Simple(2, function() GAMEMODE:SpawnBall() end)
    
    GAMEMODE.NextSpawn = CurTime() + 5
end )

-- Ball Spawn
hook.Add("Think", "ThinkBallSpawn", function()
    if GetGlobalString('RoundState') != 'InRound' then return end
    if not GAMEMODE.NextSpawn then return end
    
	if CurTime() > GAMEMODE.NextSpawn then
        GAMEMODE:SpawnBall()
        GAMEMODE.NextSpawn = CurTime() + 20
	end
end )

function GM:CollectBall(ball, team)
    if ball:GetClass() != 'db_dodgeball' then return end
    
    local c = Vector(1, 1, 1)
    local name = 'none'
    if team == TEAM_RED then
        c = Vector(1, 0.3, 0.3)
        name = 'red'
    elseif team == TEAM_BLUE then
        c = Vector(0.3, 0.3, 1)
        name = 'blue'
    end

    ball:SetNWString('CurrentTeam', name)
    ball:SetNWVector('RColor', c)
end

function GM:GravGunOnPickedUp(ply, ent)
    if ply:Team() != TEAM_BLUE and ply:Team() != TEAM_RED then return end
    
    if ent:GetClass() == 'db_dodgeball' then
        GAMEMODE:CollectBall(ent, ply:Team())
        ent.LastTime = CurTime()
        ent.LastHolder = ply
    end
end

function GM:GravGunPunt(ply, ent)
    if ply:Team() != TEAM_BLUE and ply:Team() != TEAM_RED then return end
    
    if ent:GetClass() == 'db_dodgeball' then
        GAMEMODE:CollectBall(ent, ply:Team())
        ent.LastTime = CurTime()
        ent.LastHolder = ply
        return true
    end
end

function GM:EntityTakeDamage(target, dmginfo)
    if target:IsPlayer() then
        local inflictor = dmginfo:GetInflictor()
        if inflictor:GetClass() == "db_dodgeball" then
            dmginfo:SetDamageType(DMG_DISSOLVE)
        end
    end
end