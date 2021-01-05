ENT.Type = "brush"

function ENT:Touch(ent)
    if ent:IsPlayer() then return end
    if ent:GetClass() == "prop_ragdoll" then return end
    ent:Remove()
end