AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Vacuum"
    SWEP.Slot = 0
    SWEP.DrawAmmo = false
end

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.HoldType = "pistol"

SWEP.Primary.ClipSize = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true

function SWEP:Initialize()
    if SERVER then self:SetWeaponHoldType("pistol") end
    
    if CLIENT and !IsValid(self.Cone) then
        local ViewModel = LocalPlayer():GetViewModel()
		self.Cone = ClientsideModel( "models/props_combine/portalball.mdl", RENDERGROUP_OPAQUE )
		self.Cone:SetPos(ViewModel:GetPos()+ViewModel:GetForward()*30+ViewModel:GetRight()*8 +Vector(0,0,0))
		self.Cone:SetAngles(ViewModel:GetAngles())
		self.Cone:SetColor(0,0,0,0)
		self.Cone:SetParent(ViewModel)
        
        local scale = Vector(1, 0.5, 0.5)
        local mat = Matrix()
        mat:Scale(scale)
        self.Cone:EnableMatrix("RenderMultiply", mat)
    end
end

function SWEP:OnRemove()
    SafeRemoveEntity(self.Cone)
end

function SWEP:PrimaryAttack()
    self.Owner:ViewPunch( Angle(-5, 0, 0) )
    self:SetNextPrimaryFire( CurTime() + 1)
    self.Owner:EmitSound('weapons/ar2/npc_ar2_altfire.wav')
    
    if CLIENT then return end
    
    local trace = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector()*200, {self.Owner})
    if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
        local aim = self.Owner:GetAimVector()
        aim.z = 0.65
        trace.Entity:SetVelocity( aim * 600 )
    elseif IsValid(trace.Entity) and trace.Entity:GetClass() == "cactus" then
        trace.Entity:ApplyMove( self.Owner:GetAimVector() * 750 )
    else
        self.Owner:SetVelocity( self.Owner:GetAimVector() * -600 )
    end
end

function SWEP:SecondaryAttack()
    --self.Weapon:SendWeaponAnim(ACT_VM_ATTACK2)
    if !self:CanSecondaryAttack() then
        return
    end
    
    if CLIENT then return end
    
    local dist_pull = 500
    local dist_grab = 100
    local force = 2
    local found_ents = nil
    
    local cone_ents = ents.FindInCone(self.Owner:GetShootPos(),self.Owner:GetAimVector(), 500, 0.850) 
    
    for k,v in pairs(cone_ents) do
        if !v:IsValid() then continue end
        if v:GetClass() != "cactus" then continue end
        if IsValid(v.PlayerObj) then continue end
        local dist = v:GetPos():Distance(self.Owner:GetShootPos())
        local tr = util.QuickTrace(self.Owner:GetShootPos(), v:GetPos(), {self.Owner}) -- Trace
        if tr.Hit then
            if dist < dist_pull then
                local vel = (self.Owner:GetRight() * math.Rand(-1, 1)*100) + (self.Owner:GetShootPos() - v:GetPos()) * force * (1 - dist/dist_pull)
                v:ApplyMove(vel)
            end
            
            if dist < dist_grab then
                --Caught the cactus!
                GAMEMODE:CatchCactus(self.Owner, v)
            end
            
            found_ents = true
        end
    end
    
    if found_ents then
        self:SetNextSecondaryFire( CurTime() )
    else
        self:SetNextSecondaryFire( CurTime() + 0.1 )
    end
end

if SERVER then return end

local function linearInterpolate( p1, p2, mu )
	return p1 * ( 1 - mu ) + p2 * mu
end

local cacti_caught = {}
local vortex_swirl_speed = 0
----------------------------------------------------------------------------------
local vortex_lastTime
local vortex_progress = 0
function SWEP:ViewModelDrawn()
	if !self.Weapon then return end
	local vm = LocalPlayer():GetViewModel()
	if !IsValid( vm ) then return end
	local vm_pos = vm:GetPos()
	vortex_lastTime = vortex_lastTime or CurTime()
	local Delta = CurTime() - vortex_lastTime
	vortex_lastTime = vortex_lastTime + Delta
	vortex_progress = math.Clamp( vortex_progress + ((self:CanSecondaryAttack() && LocalPlayer():KeyDown( IN_ATTACK2 )) and Delta or -Delta), 0, 0.5 )
	vortex_swirl_speed = (vortex_progress / 0.5) * 30
	local cone_angles = self.Cone:GetAngles()
	cone_angles:RotateAroundAxis( cone_angles:Forward(), vortex_swirl_speed )
	self.Cone:SetAngles( cone_angles )
	local mu = vortex_swirl_speed / 30
	self.Cone:SetColor( 80, 80, 100, mu * 255 )	// It would be cool if this worked.
    
    local scale = Vector( mu, 0.5 * mu, 0.5 * mu )
    local mat = Matrix()
    mat:Scale(scale)
    self.Cone:EnableMatrix("RenderMultiply", mat)
	--self.Cone:SetModelScale( Vector( mu, 0.5 * mu, 0.5 * mu ) )
	self.Cone:SetPos( vm:GetPos() + vm:GetForward() * linearInterpolate( 10, 30, mu ) + vm:GetRight() * 8 + vm:GetUp() * -8 )
    --[[
	for k, v in pairs( cacti_caught ) do
		if !v[ 5 ] then	// vm:GetPos() returns vector_origin in the hook below, this is a workaround.
			v[ 2 ] = vm:WorldToLocal( v[ 2 ] )
			v[ 3 ] = vm:WorldToLocalAngles( v[ 3 ] )
			v[ 1 ]:SetParent( vm )
			v[ 5 ] = true
		end
		v[ 4 ] = v[ 4 ] + Delta
		local mu = math.Clamp( v[ 4 ] / 0.5, 0, 1 )
		local lpos = Vector( linearInterpolate( v[ 2 ].x, 30, mu ),
							 linearInterpolate( v[ 2 ].y, -8, mu ),
							 linearInterpolate( v[ 2 ].z, -8, mu ) )
		v[ 1 ]:SetPos( vm:LocalToWorld( lpos ) )
		local lang = Angle( linearInterpolate( v[ 3 ].p, 90, mu ),
							linearInterpolate( v[ 3 ].y, 0, mu ),
							linearInterpolate( v[ 3 ].r, 0, mu ) )
		v[ 1 ]:SetAngles( vm:LocalToWorldAngles( lang ) )
		v[ 1 ]:SetModelScale( Vector( linearInterpolate( 1, 0.01, mu ),
									  linearInterpolate( 1, 0.01, mu ),
									  linearInterpolate( 1, 0.01, mu ) ) )
		if mu == 1 then	// Clear the cactus from the list, it's out of view.
			v[ 1 ]:Remove()
			cacti_caught[ k ] = nil
		end
	end
    --]]
end