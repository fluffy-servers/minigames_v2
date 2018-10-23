if (SERVER) then
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName			= "Knife" 
	SWEP.ViewModelFOV		= 65
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= true
	SWEP.Slot				= 2
	SWEP.SlotPos			= 0
end

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel 				= "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel 			= "models/weapons/w_knife_t.mdl" 
SWEP.UseHands               = true

SWEP.Primary.Automatic			= true
SWEP.Primary.Damage 			= 30
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo			    = "none"
SWEP.Secondary.Delay 			= 0.75

---------------------------------------------------------
--Think
---------------------------------------------------------*/
function SWEP:Think()
	if self.Idle and CurTime()>=self.Idle then
		self.Idle = nil
		self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
	end
end

--------------------------------------------------------
--Initialize
---------------------------------------------------------*/
function SWEP:Initialize() 
	self:SetWeaponHoldType( "knife" )
end 

---------------------------------------------------------
--Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Weapon:EmitSound( "Weapon_Knife.Deploy" )
	return true
end

---------------------------------------------------------
--PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self:SecondaryAttack()
end

---------------------------------------------------------
--SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
    self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
    
    --Lagcomp before trace
    self.Owner:LagCompensation(true)
    
    --Trace to see what we hit if anything
    local ShootPos = self.Owner:GetShootPos()
    local ShootDest = ShootPos + (self.Owner:GetAimVector() * 70)
    local tr_main = util.TraceLine({start=ShootPos, endpos=ShootDest, filter=self.Owner, mask=MASK_SHOT_HULL})
    local tr_hull = util.TraceHull({start=ShootPos, endpos=ShootDest, mins=Vector(-8,-8,-8), maxs=Vector(8,8,8), filter=self.Owner, mask=MASK_SHOT_HULL})
    
    local HitEnt = IsValid(tr_main.Entity) and tr_main.Entity or tr_hull.Entity
    
    --Trace is done, turn off lagcomp
    self.Owner:LagCompensation(false)
    
    --If we hit something (including world)
    if IsValid(HitEnt) or tr_main.HitWorld then
    
        --Animate view model
        self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    
        --Only do once/server
        if not (CLIENT and (not IsFirstTimePredicted())) then
            --Setup effect
            local edata = EffectData()
            edata:SetStart(ShootPos)
            edata:SetOrigin(tr_main.HitPos)
            edata:SetNormal(tr_main.Normal)
            edata:SetEntity(HitEnt)
            --Hit ragdoll or player, do blood
            if HitEnt:IsPlayer() or HitEnt:IsNPC() or HitEnt:GetClass() == "prop_ragdoll" then
				self:EmitSound('Weapon_Knife.Hit')
                util.Effect("BloodImpact", edata)
                -- do a bullet for blood decals
                self.Owner:FireBullets({Num=1, Src=ShootPos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0})
            else
                --Hit something other than player or ragdoll
                util.Effect("Impact", edata)
            end
        end
    else
        --Didn't hit anything, miss animation
        self:SendWeaponAnim( ACT_VM_MISSCENTER )
		self:EmitSound('Weapon_Knife.Slash')
    end
    
    --Animate
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    
    --Damage entity
    if HitEnt and HitEnt:IsValid() then
        local dmg = DamageInfo()
        dmg:SetDamage(self.Primary.Damage)
        dmg:SetAttacker(self.Owner)
        dmg:SetInflictor(self)
        dmg:SetDamageForce(self.Owner:GetAimVector() * 1500)
        dmg:SetDamagePosition(self.Owner:GetPos())
        dmg:SetDamageType(DMG_SLASH)
        HitEnt:DispatchTraceAttack(dmg, ShootPos + (self.Owner:GetAimVector() * 3), ShootDest)
    end
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

function SWEP:DoImpactEffect(tr, nDamageType)
	util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)	
	return true
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}
	self.AmmoDisplay.PrimaryClip = -1
	return self.AmmoDisplay
end