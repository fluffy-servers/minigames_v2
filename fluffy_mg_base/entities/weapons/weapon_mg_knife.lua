SWEP.Base = 'weapon_mg_base'

if SERVER then
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if CLIENT then
	SWEP.ViewModelFOV		= 65
	SWEP.ViewModelFlip		= false
	SWEP.Slot				= 2
	SWEP.SlotPos			= 0

	SWEP.IconLetter = 'j'
	SWEP.IconFont = 'CSSelectIcons'
    killicon.AddFont("weapon_mg_knife", "CSKillIcons", "j", Color(255, 80, 0, 255))
end
SWEP.PrintName			= "Knife" 

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel 				= "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel 			= "models/weapons/w_knife_t.mdl" 
SWEP.UseHands               = true

SWEP.Primary.Automatic			= true
SWEP.Primary.Damage 			= 50
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo			    = "none"
SWEP.Secondary.Delay 			= 0.75

SWEP.AttackRange = 56

function SWEP:Think()
	if self.Idle and CurTime() >= self.Idle then
		self.Idle = nil
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
	end
end

function SWEP:Initialize() 
	self:SetHoldType("knife")
end 

function SWEP:Deploy()
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Weapon:EmitSound("Weapon_Knife.Deploy")
	return true
end

-- port from weapon_knife.cpp
function SWEP:FindHullIntersection(src, tr, mins, maxs, ent)
    local vecHullEnd = src + ((tr.HitPos - src) * 2)
    local data = {}
    data.start = src
    data.endpos = vecHullEnd
    data.filter = ent
    data.mask = MASK_SOLID
    data.mins = mins
    data.maxs = maxs

    local tmp = util.TraceLine(data)
    if tmp.Hit then
        return tmp
    end

    local distance = 999999
    for i = 0, 1 do
        for j = 0, 1 do
            for k = 0, 1 do
                local vecEnd = Vector()
                vecEnd.x = vecHullEnd.x + (i > 0 and maxs.x or mins.x)
                vecEnd.y = vecHullEnd.y + (j > 0 and maxs.y or mins.y)
                vecEnd.z = vecHullEnd.z + (k > 0 and maxs.z or mins.z)
                data.endpos = vecEnd

                tmp = util.TraceLine(data)
                if tmp.Hit then
                    local dist = (tmp.HitPos - src):Length()
                    if dist < distance then
                        tr = tmp
                        distance = dist
                    end
                end
            end
        end
    end

    return tr
end

function SWEP:DoAttack(alt)
    local attacker = self:GetOwner()
    attacker:LagCompensation(true)

    local range = self.AttackRange
    local forward = attacker:GetAimVector()
    local src = attacker:GetShootPos()
    local trace_end = src + forward * range

    -- Setup trace structure
    local trace = {}
    trace.filter = attacker
    trace.start = src
    trace.mask = MASK_SOLID
    trace.endpos = trace_end
    trace.mins = Vector(-16, -16, -18)
    trace.maxs = Vector(16, 16, 18)

    -- Run the trace
    -- This does some fancy hull stuff for approximating near-misses
    local tr = util.TraceLine(trace)
    if not tr.Hit then tr = util.TraceHull(trace) end
    if tr.Hit and (tr.Entity or tr.HitWorld) then
        local dmins, dmaxs = attacker:GetHullDuck()
        tr = self:FindHullIntersection(src, tr, dmins, dmaxs, attacker)
        trace_end = tr.HitPos
    end

    if tr.Hit then
        self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
        
        if IsValid(tr.Entity) then
            -- Apply damage
            local dmg = DamageInfo()
            dmg:SetDamage(self.Primary.Damage)
            dmg:SetAttacker(self.Owner)
            dmg:SetInflictor(self.Weapon or self)
            dmg:SetDamageForce(self.Owner:GetAimVector() * 1500)
            dmg:SetDamagePosition(tr.HitPos)
            dmg:SetDamageType(DMG_SLASH)
            tr.Entity:DispatchTraceAttack(dmg, tr)
            
            -- Blood effects for humans
            if tr.Entity:IsPlayer() then
                local edata = EffectData()
                edata:SetStart(self.Owner:GetShootPos())
                edata:SetOrigin(tr.HitPos)
                edata:SetNormal(tr.Normal)
                edata:SetEntity(tr.Entity)
                util.Effect("BloodImpact", edata)
                
                self:EmitSound('Weapon_Knife.Hit')
            end
        else
            -- Attack hit world
            self:EmitSound('Weapon_Crowbar.Melee_Hit')
            util.Decal("ManhackCut", src - forward, trace_end + forward, true)
        end
    else
        -- Attack missed
        self:EmitSound('Weapon_Knife.Slash')
        self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
    end

    attacker:LagCompensation(false)
end

function SWEP:PrimaryAttack()
	self:SecondaryAttack()
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:DoAttack()
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