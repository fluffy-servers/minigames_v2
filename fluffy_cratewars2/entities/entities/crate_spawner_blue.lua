AddCSLuaFile()
ENT.Type = "point"

ENT.Model = "models/props_junk/wood_crate001a.mdl"

function ENT:Initialize()

end

function ENT:SpawnCrate()
	if table.Count(ents.FindByClass("prop_phys*")) > 200 then return end
	local prop = self.Entity:CreateProp( self:GetPos(), self:GetAngles(), self.Model)
	
	local phys = prop:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:AddAngleVelocity(Vector((VectorRand() * 200):Angle()))
	end
end

function ENT:CreateProp(pos, ang, model)
	local prop = ents.Create("prop_physics")
	prop:SetPos(pos)
	prop:SetAngles(ang)
	prop:SetModel(model)
	prop:Spawn()
	
	return prop
end