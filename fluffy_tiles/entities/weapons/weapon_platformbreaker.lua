AddCSLuaFile()

SWEP.Purpose = "Hurt a platform or push the nearest person"
SWEP.Instructions = "Primary to attack a platform, Secondary to punt people close to you"
SWEP.ViewModel	= "models/weapons/c_pistol.mdl"
SWEP.UseHands   = true
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.PrintName = "Platform Breaker!"
SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage 		= 1
SWEP.Primary.BulletForce	= 1
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone		    = 0.01
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay		    = 0.15
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
 
SWEP.Secondary.ClipSize		= 9999
SWEP.Secondary.DefaultClip	= 9999
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = 9999
SWEP.Secondary.Delay		= 3
SWEP.Secondary.NextUse		= 0
SWEP.Secondary.Recoil       = 2

function SWEP:PrimaryAttack()
    self.Weapon:EmitSound("Weapon_AR2.Single")
    self:ShootBullet(0.01, self.Primary.NumShots, self.Primary.Cone) -- for effects
    
    if SERVER then
        local tr = {}
        tr.start = self.Owner:GetShootPos()
        tr.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 500
        tr.filter = {self.Owner}
        local trace = util.TraceLine(tr)
        print(trace.Entity, IsValid(trace.Entity))
        if IsValid(trace.Entity) and trace.Entity:GetClass() == 'til_tile' then
            trace.Entity:OnTakeDamage(self.Owner)
        end
    end
    
    self.Owner:ViewPunch( Angle( -self.Primary.Recoil, math.Rand(-1,1)*self.Primary.Recoil, 0))
    self:SetNextPrimaryFire(CurTime()+ self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    self.Weapon:EmitSound("AlyxEMP.Discharge")
    self:Knockback()
    self:SetNextSecondaryFire(CurTime()+ self.Secondary.Delay)
end

function SWEP:Knockback()
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 100 )
	tr.filter = { self.Owner }
	
	for k,v in pairs(ents.FindByClass( "pf_platform" )) do
		table.insert(tr.filter,v)
	end
	tr.mask = MASK_SHOT
	
	local trace = util.TraceLine( tr )	
	
	local effectdata = EffectData()
	effectdata:SetStart( tr.start )
	effectdata:SetEntity( self.Weapon )
	effectdata:SetOrigin( trace.HitPos )
	effectdata:SetAttachment( 1 )
	util.Effect( "punch_tracer", effectdata )
    
    if trace.Hit and trace.Entity and trace.Entity:IsPlayer() then
        local dist = self.Owner:GetPos():DistToSqr(trace.Entity:GetPos())
        if dist < 90000 then
            trace.Entity:SetVelocity(trace.Entity:GetVelocity() + ((self.Owner:GetAimVector()+Vector(0, 0, 0.5)) * 1200) )
        end
    end
    
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
end