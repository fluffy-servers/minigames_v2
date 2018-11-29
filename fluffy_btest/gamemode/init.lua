AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

hook.Add('PlayerSpawn', 'CreateBall', function(ply)
    local ball = ents.Create('prop_physics')
    ball:SetModel('models/hunter/misc/shell2x2.mdl')
    ball:SetMaterial('models/debug/debugwhite')
    ball:SetRenderMode(RENDERMODE_TRANSALPHA)
    ball:SetColor(Color(0, 0, 255, 75))
    ball:Spawn()
    ball:SetPos(ply:GetPos() + Vector(0, 0, 32))
    constraint.NoCollide(ball, ply, 0, 0)
    ply.BallEntity = ball
    
    ply:Spectate( OBS_MODE_CHASE )
	ply:SpectateEntity( prop )
end)

hook.Add('DoPlayerDeath', 'RemoveBall', function(ply)
    if IsValid(ply.BallEntity) then
        SafeRemoveEntity(ply.BallEntity)
    end
end)

function GM:Move(ply, mv)
    if not IsValid(ply.BallEntity) then return end
    
    local speed = 15 * FrameTime()
    local phys = ply.BallEntity:GetPhysicsObject()
    
    local ang = mv:GetMoveAngles()
	local pos = mv:GetOrigin()
	local vel = mv:GetVelocity()
    
	vel = vel + ang:Forward() * mv:GetForwardSpeed() * speed
	vel = vel + ang:Right() * mv:GetSideSpeed() * speed
	vel = vel + ang:Up() * mv:GetUpSpeed() * speed
    
    phys:ApplyForceCenter(vel)
    return true
end