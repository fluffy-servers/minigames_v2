AddCSLuaFile()
ENT.Type = "point"

ENT.Model = "models/props_junk/wood_crate001a.mdl"
ENT.Team  = TEAM_BLUE

function ENT:Initialize()
end

function ENT:SpawnCrate()
	if table.Count(ents.FindByClass("prop_phys*")) > 200 then return end
	local prop = self.Entity:CreateProp( self:GetPos(), self:GetAngles(), self.Model)
	
	local phys = prop:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:AddAngleVelocity(Vector((VectorRand() * 200):Angle()))
	end

    -- Increment team score
    team.AddRoundScore(self.Team, 1)
end

function ENT:CreateProp(pos, ang, model)
    local class
    if self.Team == TEAM_BLUE then
        class = 'crate_blue'
    else
        class = 'crate_red'
    end

	local prop = ents.Create(class)
	prop:SetPos(pos)
	prop:SetAngles(ang)
    prop.Model = model
	prop:SetModel(model)
	prop:Spawn()
	
	return prop
end