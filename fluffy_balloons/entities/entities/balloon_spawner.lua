AddCSLuaFile()
ENT.Type = "point"

function ENT:Initialize()

end

function ENT:SpawnBalloon(type)
	local prop = self.Entity:CreateProp(self:GetPos(), self:GetAngles(), type)
	
	local phys = prop:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:AddAngleVelocity( Vector( (VectorRand() * 200 ):Angle() ))
	end
end

function ENT:CreateProp(pos, ang, type)
	local prop = ents.Create(type or "balloon_base")
	prop:SetPos( pos )
	prop:SetAngles( ang )
	prop:Spawn()
	
	return prop
end