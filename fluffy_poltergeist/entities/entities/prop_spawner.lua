ENT.Type = "point"
ENT.RespawnTime = 3

function ENT:KeyValue(key, value)
    if key == "frequency" then
        self.RespawnTime = math.Clamp(tonumber(value), 1, 60)
    end
end

function ENT:Think()
    if (self.Timer or 0) < CurTime() then
        self.Timer = CurTime() + self.RespawnTime
        self:SpawnProp()
    end
end

function ENT:SpawnProp()
    if table.Count(ents.FindByClass("prop_phys*")) > GAMEMODE.MaxProps then return end
    local prop = self:CreateProp(table.Random(GAMEMODE.PropModels))
    local phys = prop:GetPhysicsObject()

    if phys and phys:IsValid() then
        phys:AddAngleVelocity(Vector((VectorRand() * 200):Angle()))
    end
end

function ENT:CreateProp(model)
    local prop = ents.Create("prop_physics")
    prop:SetPos(self:GetPos())
    prop:SetAngles(self:GetAngles())
    prop:SetModel(model)
    prop:Spawn()
    prop:SetSkin(math.random(0, self:SkinCount()-1))
    return prop
end

function ENT:GetFrequency()
    return self.RespawnTime
end