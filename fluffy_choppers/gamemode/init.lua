AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

local meta = FindMetaTable("Player")

function meta:GetProp()
    return self:GetNWEntity("Prop", NULL)
end

function meta:MakeProp()
    local prop = ents.Create('prop_physics')
    prop:SetPos(self:GetPos() + Vector(0, 0, 64))
    prop:SetModel('models/hunter/misc/sphere1x1.mdl')
    prop:SetMaterial('phoenix_storms/metalset_1-2')
    prop:Spawn()
    
    timer.Simple(0.1, function()
        self:SetProp(prop)
    end)
end

function meta:SetProp(prop)
    self:SetNWEntity("Prop", prop)
    self:Spectate(OBS_MODE_CHASE)
    self:SpectateEntity(prop)
end

function GM:PlayerLoadout(ply)
    if ply:Team() != TEAM_RED then return end
    ply:MakeProp()
end

hook.Add('Move', 'ChopperMove', function(ply, mv)
    if ply:Team() != TEAM_RED then return end
    
    local ball = ply:GetProp()
    if not ball or not ball:IsValid() then return end
    
    local phys = ball:GetPhysicsObject()
    if not phys or not phys:IsValid() then return end
    if phys:IsGravityEnabled() then phys:EnableGravity(false) end
    
    local move = Vector(0, 0, 0)
    local aimvec = ply:GetAimVector()
    local aim = Angle(0, ply:EyeAngles().y, 0)
    local speed = 20
    
    if ply:KeyDown(IN_FORWARD) then
        move = move + aim:Forward() * speed
    elseif ply:KeyDown(IN_BACK) then
        move = move + aim:Forward() * -speed
    end
    
    if ply:KeyDown(IN_MOVERIGHT) then
        move = move + aim:Right() * speed
    elseif ply:KeyDown(IN_MOVELEFT) then
        move = move + aim:Right() * -speed
    end
    
    if ply:KeyDown(IN_JUMP) then
        move = move + Vector(0, 0, speed*0.6)
    elseif ply:KeyDown(IN_DUCK) then
        move = move + Vector(0, 0, -speed*0.6)
    end
    
    phys:AddVelocity(move - phys:GetVelocity() * 0.01)
    
    if ply:KeyDown(IN_ATTACK) and (ply.NextAttack or 0) < CurTime() then
        ply.NextAttack = CurTime() + 1
        ply:EmitSound('npc/attack_helicopter/aheli_mine_drop1.wav')
        
        local bomb = ents.Create('chopper_bomb')
        bomb:SetPos(ball:GetPos() - Vector(0, 0, 50))
        bomb:Spawn()
        bomb.Owner = ply
        bomb:GetPhysicsObject():AddVelocity(ball:GetVelocity() + VectorRand() * 100)
    end
end)