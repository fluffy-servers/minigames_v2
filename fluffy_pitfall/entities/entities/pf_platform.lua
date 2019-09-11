AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = 'base_anim'

local mixedmodels = {
    "models/hunter/blocks/cube2x2x025.mdl",
    "models/hunter/blocks/cube2x2x025.mdl",
    "models/hunter/tubes/circle2x2.mdl",
    "models/hunter/tubes/circle2x2.mdl",
    "models/hunter/blocks/cube075x075x075.mdl",
    --"models/hunter/misc/shell2x2a.mdl",
    "models/hunter/tubes/circle4x4c.mdl",
    "models/hunter/triangles/2x2.mdl",
    "models/hunter/triangles/2x2.mdl",
    "models/hunter/triangles/3x3.mdl",
}

local props = {

}

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

local gametypefunctions = {}
gametypefunctions['square'] = function(p) p:SetModel("models/hunter/blocks/cube2x2x025.mdl") end
gametypefunctions['circle'] = function(p) p:SetModel("models/hunter/tubes/circle2x2.mdl") end
gametypefunctions['mixed'] = function(p) p:SetModel( table.Random( mixedmodels ) ); p:SetAngles( Angle(0, math.random(360), 0 ) ) end
gametypefunctions['hexagon'] = function(p) p:SetModel("models/hunter/geometric/hex1x1.mdl") end

function ENT:Initialize()
    if CLIENT then return end
    
    -- Set the model and data based on the game submode
    local mode = GetGlobalString('PitfallType', 'square')
	self:SetModel("models/hunter/blocks/cube2x2x025.mdl")
    gametypefunctions[mode](self)
    self:SetColor(GAMEMODE.PColorStart)
    
    -- Initialize physics
	self:PhysicsInit(SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion( false )
		phys:Sleep()
	end
	
    -- Other variables
	self.MyHealth = 100
    self.CreationTime = CurTime()
    self:SetTrigger(true)
end

-- Make platforms take damage when someone is touching them
function ENT:Touch(ent)
    -- 3 seconds of spawn protection in rounds
    if GAMEMODE:GetRoundState() != 'InRound' then return end
    if GM:GetRoundStartTime() + 3 > CurTime() then return end
    
    -- Only living players make the platforms fall
    if not IsValid(ent) then return end
    if not ent:IsPlayer() then return end
    if not ent:Alive() or ent.Spectating then return end
    
    -- Apply powerups if applicable
    if self.HasPowerUp and ent.ActivePowerUp == nil then
        GAMEMODE:PowerUpApply(ent, self.PowerUp, true)
        self.PowerUp = nil
        self.HasPowerUp = false
        self:AddDamage(0)
    end
    
    local scale = CurTime() - self.CreationTime
    scale = 1 + (4 * (scale/GAMEMODE.RoundTime))
    
    -- yay damage
    self:AddDamage(FrameTime() * 40*scale)
end

-- Add a powerup to this platform
function ENT:AddPowerUp(type)
    self.HasPowerUp = true
    self.PowerUp = type
    
    self:SetColor(GAMEMODE.PColorBonus)
end

-- Called when this platform is damaged by an entity
-- usually when a player hits it with a weapon
-- See the below damage for more details
function ENT:OnTakeDamage(dmg)
    -- Register attackers if applicable
    local attacker = dmg:GetAttacker()
    if attacker:IsValid() and attacker:IsPlayer() then
        self.LastAttacker = attacker
    end
    
    -- Get the weapon that the player is using
    local inflictor = dmg:GetInflictor()
    if inflictor:IsPlayer() then inflictor = inflictor:GetActiveWeapon() end
    
    if inflictor:GetClass() == 'weapon_crowbar' then
        -- Instabreak for crowbars
        self:AddDamage(100, attacker)
    elseif inflictor:GetClass() == 'weapon_platformbreaker' then
        -- pew pew does some damage
        local scale = CurTime() - self.CreationTime
        scale = 1 + (4 * (scale/GAMEMODE.RoundTime))
        self:AddDamage(15 * scale, attacker)
    else
        -- Deal damage based on round time
        local scale = CurTime() - self.CreationTime
        scale = 1 + (4 * (scale/GAMEMODE.RoundTime))
        self:AddDamage(dmg:GetDamage() * scale, attacker)
    end
end

-- Apply damage to a platform
function ENT:AddDamage(amount, ply)
    -- Reduce health
    local damage = math.Clamp(amount, 0, self.MyHealth)
    self.MyHealth = self.MyHealth - damage
    local scale = math.Clamp(self.MyHealth/100, 0, 1)
    
    if IsValid(ply) and ply:IsPlayer() then
        ply:AddStatPoints('Platform Damage', math.floor(damage))
    end
    
    -- Adjust color based on gamemode
    if not self.HasPowerUp then
        local r = GAMEMODE.PColorEnd.r - GAMEMODE.PDR*scale
        local g = GAMEMODE.PColorEnd.g - GAMEMODE.PDG*scale
        local b = GAMEMODE.PColorEnd.b - GAMEMODE.PDB*scale
        self:SetColor(Color(r, g, b))
    end
    
    -- Drop the platform after 1 second if applicable
    if self.MyHealth <= 0 and not self.Dropped and not self.HasPowerUp then
        self.Dropped = true
        self:EmitSound(table.Random(self.ActivateSounds), 50, math.random(70, 130))
        
        timer.Simple(0.7, function()
            if not IsValid(self) then return end
            self:EmitSound(table.Random(self.FallSounds), 65, math.random(70, 130))
            self:Drop()
        end)
    end
end

-- Make the platform fall
function ENT:Drop()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_NONE)
    
    local phys = self:GetPhysicsObject()
    if phys and IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end
    
    -- Remove the platform after one second
    timer.Simple(1, function()
        if not IsValid(self) then return end
        self:Remove()
    end)
end

-- Get the center of this platform
function ENT:GetCenter()
    return self:LocalToWorld(self:OBBCenter())
end