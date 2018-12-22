AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = 'base_anim'

function ENT:Initialize()
    if CLIENT then return end
	self:SetModel("models/Items/item_item_crate.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
    self:PhysWake()
    self.CreationTime = CurTime()
    
    self:PrecacheGibs()
    self:EmitSound("Weapon_MegaPhysCannon.Launch")
    
    local eff = EffectData()
    eff:SetStart(self:GetPos())
    eff:SetOrigin(self:GetPos())
    eff:SetScale(3)
    util.Effect('ManhackSparks', eff)
end

function ENT:SetPowerUp(type)
    self.PowerUp = type
end

function ENT:OnTakeDamage(dmg)
    if not self.PowerUp then return end
    local attacker = dmg:GetAttacker()
    if not attacker or not IsValid(attacker) then return end
    if not attacker:IsPlayer() then attacker = dmg:GetInflictor() end
    if not attacker:IsPlayer() then return end

    print(attacker, attacker:CanHavePowerUp())
    if attacker:CanHavePowerUp() then
        attacker:PowerUpApply(self.PowerUp, true)
        
        self:GibBreakClient(dmg:GetDamageForce())
        self:Remove()
    end
end