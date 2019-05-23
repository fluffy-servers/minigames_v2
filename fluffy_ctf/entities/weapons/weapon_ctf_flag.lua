AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.PrintName = "Flag"

SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"
SWEP.UseHands = true

SWEP.BashSound = Sound('Weapon_Crowbar.Single')
SWEP.ThrowSound = Sound('WeaponFrag.Throw')

function SWEP:Initialize()
    self:SetHoldType('melee')
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.4)
    
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
        self:SendWeaponAnim(ACT_VM_HITCENTER)
    
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
				self:EmitSound(self.BashSound)
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
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
		self:EmitSound('Weapon_Knife.Slash')
    end
    
    --Animate
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    
    --Damage entity
    if HitEnt and HitEnt:IsValid() then
        local dmg = DamageInfo()
        dmg:SetDamage(25)
        dmg:SetAttacker(self.Owner)
        dmg:SetInflictor(self)
        dmg:SetDamagePosition(self.Owner:GetPos())
        dmg:SetDamageType(DMG_DISSOLVE)
        HitEnt:DispatchTraceAttack(dmg, ShootPos + (self.Owner:GetAimVector() * 3), ShootDest)
        
        if HitEnt:IsPlayer() then
            local vel = self.Owner:GetAimVector() * 500
            vel.z = math.abs(vel.z)*0.25 + 100
            HitEnt:SetVelocity(vel) 
        end
    end
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    self:Remove()
    self:TossFlag(625)
    self.Owner:EmitSound(self.ThrowSound)
    
    -- Loadout and select crowbar
    GAMEMODE:PlayerLoadout(self.Owner)
    self.Owner:SelectWeapon('weapon_crowbar')
end

function SWEP:TossFlag(strength)
    local ent = ents.Create('ctf_flag')
    ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 42))
    ent:Spawn()
    
    local phys = ent:GetPhysicsObject()
    if phys:IsValid() then
        local vel = self.Owner:GetAimVector() * phys:GetMass() * math.random(strength-75, strength+75)
        vel = vel + VectorRand() * 20
        phys:Wake()
        phys:ApplyForceCenter(vel)
    end
end

if CLIENT then
    SWEP.ModelPath = "models/fw/fw_flag.mdl"
    SWEP.WorldRotation = Angle(0, 0, 0)
    SWEP.WorldOffset = Vector(-7.25, 2, 0)
    SWEP.ViewRotation = Angle(0, 0, 0)
    SWEP.ViewOffset = Angle(9, 6, 1)
    
    local mat = Material( "models/fw/flaginner" )
    
    function SWEP:CheckCSModel()
        if not IsValid(self.CSModel) then
            self.CSModel = ClientsideModel(self.ModelPath, RENDERGROUP_OPAQUE)
            self.CSModel:SetNoDraw(true)
            self.CSModel:SetModelScale(0.6)
        end
        
        -- Recolor the ball
        local col = Color(0, 0, 0)
        if IsValid(self.Owner) then col = self.Owner:GetPlayerColor() end
        mat:SetVector("$refracttint", col)
        
        return self.CSModel
    end
    
    function SWEP:DrawWorldModel()
        -- Check the model is valid
        local m = self:CheckCSModel()
        if not IsValid(m) then return end
        
        local pos = self:GetPos()
        local ang = self:GetAngles()
        
        -- Lookup the hand attachment
        if IsValid(self.Owner) then
            local attid = self.Owner:LookupAttachment('anim_attachment_RH')
            local att = self.Owner:GetAttachment(attid)
            pos = att.Pos
            ang = att.Ang
            
            -- Rotate and offset
            ang:RotateAroundAxis(ang:Right(), self.WorldRotation.p)
            ang:RotateAroundAxis(ang:Up(), self.WorldRotation.y)
            ang:RotateAroundAxis(ang:Forward(), self.WorldRotation.r)
            
            pos = pos + att.Ang:Forward() * self.WorldOffset.y
            pos = pos + att.Ang:Right() * self.WorldOffset.x
            pos = pos + att.Ang:Up() * self.WorldOffset.z
        end
        
        -- Draw the model
        m:SetPos(pos)
        m:SetAngles(ang)
        m:DrawModel()
    end
    
    function SWEP:Holster()
        local m = self:CheckCSModel()
        m:Remove()
        self.CSModel = nil
        
        self.Owner:GetViewModel():SetMaterial("")
    end
    
    function SWEP:PreDrawViewModel(vm, ply, wep)
        vm:SetMaterial("engine/occlusionproxy")
    end
    
    function SWEP:PostDrawViewModel(vm, ply, wep)
        vm:SetMaterial("")
        
        -- Check the model is valid
        local m = self:CheckCSModel()
        if not IsValid(m) then return end
        
        local pos = self:GetPos()
        local ang = self:GetAngles()
        
        -- Lookup the hand attachment
        if IsValid(self.Owner) then
            local vpos, vang = vm:GetBonePosition(23)
            pos, ang = vpos, vang
            
            -- Rotate and offset
            ang:RotateAroundAxis(ang:Right(), self.ViewRotation.p)
            ang:RotateAroundAxis(ang:Up(), self.ViewRotation.y)
            ang:RotateAroundAxis(ang:Forward(), self.ViewRotation.r)
            
            pos = pos + vang:Forward() * self.ViewOffset.y
            pos = pos + vang:Right() * self.ViewOffset.x
            pos = pos + vang:Up() * self.ViewOffset.z
        end
        
        -- Draw the model
        m:SetPos(pos)
        m:SetAngles(ang)
        m:DrawModel()
    end
    
    function SWEP:GetViewModelPosition(pos, ang)
        pos = pos + ang:Right() * 7 + ang:Forward() * 1
        ang = ang + Angle(-16, 0, 0)
        return pos, ang
    end
    
    function SWEP:CustomAmmoDisplay()
        self.AmmoDisplay = self.AmmoDisplay or {}
        self.AmmoDisplay.Draw = false
        return self.AmmoDisplay
    end
end