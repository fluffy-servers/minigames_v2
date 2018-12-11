AddCSLuaFile()
ENT.Type = "brush"
ENT.Base = "base_brush"
ENT.PrintName = "Tile"

ENT.FallSounds = {
    Sound( "doors/vent_open1.wav" ),
    Sound( "doors/vent_open2.wav" ),
    Sound( "doors/vent_open3.wav" )
}

ENT.ActivateSounds = {
    Sound( "physics/metal/sawblade_stick1.wav" ),
    Sound( "physics/metal/sawblade_stick2.wav" ),
    Sound( "physics/metal/sawblade_stick3.wav" ),
}

function ENT:Initialize()
    self:PhysicsInit(SOLID_BSP)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BSP)
    self:SetNoDraw(false)
    
    self.MyHealth = 100
    self.CreationTime = CurTime()
end

function ENT:Touch(ent)
    if GetGlobalString( 'RoundState', 'none' ) != 'InRound' then return end
    if GetGlobalFloat( 'RoundStart', 0 )+3 > CurTime() then return end
    
    if not IsValid(ent) then return end
    if not ent:IsPlayer() then return end
    if not ent:Alive() or ent.Spectating then return end
    
    if self.HasPowerUp and ent.ActivePowerUp == nil then
        GAMEMODE:PowerUpApply(ent, self.PowerUp, true)
        self.PowerUp = nil
        self.HasPowerUp = false
        self:AddDamage(0)
    end
    
    self:AddDamage(FrameTime() * 80)
end

function ENT:AddPowerUp(type)
    self.HasPowerUp = true
    self.PowerUp = type
    
    self:SetColor( Color(0, 255, 150) )
end

function ENT:OnTakeDamage(attacker, weapon)
    if attacker and IsValid(attacker) then
        self.LastAttacker = attacker
    end
    
    if weapon == 'crowbar' then
        self:AddDamage(100)
    else
        local tmod = CurTime() - self.CreationTime
        local damageamount = 20 + 35*(tmod/120)
        self:AddDamage(damageamount)
    end
end

function ENT:AddDamage(amount)
    self.MyHealth = self.MyHealth - amount
    local scale = math.Clamp(self.MyHealth/100, 0, 1)
    
    if not self.HasPowerUp then
        local r,g,b = (255), (scale*255), (scale*255)
        self:SetColor( Color( r, g, b ) )
    end
    
    if self.MyHealth <= 0 and not self.Dropped and not self.HasPowerUp then
        self.Dropped = true
        self:EmitSound(table.Random(self.ActivateSounds), 33, math.random(70, 130))
        
        timer.Simple(1, function()
            if not IsValid(self) then return end
            self:EmitSound(table.Random(self.FallSounds), 33, math.random(70, 130))
            self:Drop()
        end)
    end
end

function ENT:Drop()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if phys and IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end
    
    timer.Simple(1, function()
        if not IsValid(self) then return end
        self:Remove()
    end)
end