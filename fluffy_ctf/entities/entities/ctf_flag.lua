AddCSLuaFile()
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

function ENT:Initialize()
    if CLIENT then return end
	self.Entity:SetModel( "models/fw/fw_flag.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )  
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Sleep()
	end
    self.NoExplode = true
end

function ENT:Use(ply)
    if IsValid(ply) and ply:IsPlayer() then
        GAMEMODE:CollectFlag(ply)
    end
end

function ENT:OnTakeDamage( dmg )
    -- Remove if in contact with a trigger hurt
    if dmg:GetInflictor():GetClass() == 'trigger_hurt' or dmg:GetAttacker():GetClass() == 'trigger_hurt' then
        self.NoExplode = false
        self:Remove()
        return
    end
	self.Entity:TakePhysicsDamage( dmg ) 
end

function ENT:OnRemove()
    -- if anything happens to the flag, spawn a new one
    if CLIENT then return end
    if self.NoExplode then return end
    
    -- Mild explosion effection
    local ed = EffectData()
	ed:SetOrigin(self:GetPos())
	util.Effect("Explosion", ed, true, true)
    
    GAMEMODE:SpawnFlag()
end
 
function ENT:PhysicsUpdate()
end

if CLIENT then
    killicon.AddFont("ctf_flag", "HL2MPTypeDeath", "8", Color( 255, 80, 0, 255 ))
    local mat = Material( "models/fw/flaginner" )
    local col = Vector( 0, 0, 0 )
    local progress = 0
    local changing = false
    
    function ENT:Think()
        -- Color the ball based on the holding team
        local tnum = GetGlobalInt('HoldingTeam', 0)
        local col = team.GetColor(tnum)
        if tnum == 0 then col = color_white end
        local c_norm = Vector(col.r/255, col.g/255, col.b/255)
        mat:SetVector("$refracttint", c_norm)
        
        -- Create a subtle light around the ball
        local size = 256
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.Pos = self:GetPos()
            dlight.r = col.r / 2
            dlight.g = col.g / 2
            dlight.b = col.b / 2
            dlight.Brightness = 3
            dlight.Size = size
            dlight.Decay = 100
            dlight.DieTime = CurTime() + 1
        end
        
        self.Entity:NextThink(CurTime() + 1)
        return true
    end
    
    function ENT:Draw()
        self.Entity:DrawModel()
    end
end