SWEP.Base = 'weapon_mg_base'

if CLIENT then
    SWEP.PrintName = "Platform Breaker!"
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.IconLetter = '-'
    SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("weapon_platformbreaker", "HL2MPTypeDeath", "-", Color(255, 80, 0, 255))
end

SWEP.Purpose = "Hurt a platform or push the nearest person"
SWEP.Instructions = "Primary to attack a platform, Secondary to punt people close to you"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.UseHands = true
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.Primary.Recoil = 0.25
SWEP.Primary.Damage = 1
SWEP.Primary.BulletForce = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = -1
SWEP.Primary.Delay = 0.15
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = 9999
SWEP.Secondary.DefaultClip = 9999
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 9999
SWEP.Secondary.Delay = 1
SWEP.Secondary.NextUse = 0
SWEP.Secondary.Recoil = 2

function SWEP:PrimaryAttack()
    self.Weapon:EmitSound("Weapon_AR2.Single")
    self:ShootBullet(0.01, self.Primary.NumShots, self.Primary.Cone) -- for effects

    if SERVER then
        local tr = {}
        tr.start = self.Owner:GetShootPos()
        tr.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 1500

        tr.filter = {self.Owner}

        local trace = util.TraceLine(tr)

        if IsValid(trace.Entity) and trace.Entity:GetClass() == 'til_tile' then
            trace.Entity:OnTakeDamage(self.Owner)
        end
    end

    self.Owner:ViewPunch(Angle(-self.Primary.Recoil, math.Rand(-1, 1) * self.Primary.Recoil, 0))
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    self.Weapon:EmitSound("AlyxEMP.Discharge")
    self:Knockback()
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:Knockback()
    --[[
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 100)
	tr.filter = {self.Owner }
	
	for k,v in pairs(ents.FindByClass("pf_platform")) do
		table.insert(tr.filter,v)
	end
	tr.mask = MASK_SHOT
	
	local trace = util.TraceLine(tr)
    --]]
    local ents = ents.FindInCone(self.Owner:GetShootPos(), self.Owner:GetAimVector(), 100, 0.3)
    local effectdata = EffectData()
    effectdata:SetStart(self.Owner:GetShootPos())
    effectdata:SetEntity(self.Weapon)
    effectdata:SetOrigin(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 150)
    effectdata:SetAttachment(1)
    util.Effect("mg_tracer", effectdata)

    for k, v in pairs(ents) do
        if not v:IsPlayer() then continue end
        if v == self.Owner then continue end

        if v then
            local dist = self.Owner:GetPos():DistToSqr(v:GetPos())

            if dist < 400000 then
                v:ViewPunch(Angle(-10, 0, 0))
                local vec = self.Owner:GetAimVector()
                vec.z = math.abs(vec.z) + 0.25
                v:SetGroundEntity(NULL)
                v:SetLocalVelocity(vec * math.random(250, 550))
            end

            v.LastKnockback = self.Owner
            v.KnockbackTime = CurTime()
        end
    end

    --[[
            if trace.Hit and trace.Entity and trace.Entity:IsPlayer() then
            local dist = self.Owner:GetPos():DistToSqr(trace.Entity:GetPos())
            if dist < 400000 then
                trace.Entity:ViewPunch(Angle(-10, 0, 0))
                
                local vec = self.Owner:GetAimVector()
                vec.z = math.abs(vec.z) + 0.15
                trace.Entity:SetGroundEntity(NULL)
                trace.Entity:SetLocalVelocity(vec * math.random(250, 550))
            end
        end
    ]]
    --
    self.Owner:SetAnimation(PLAYER_ATTACK1)
end