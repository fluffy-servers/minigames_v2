function GM:GravGunOnPickedUp(ply, ent)
    if ent:GetClass() != "fw_flag" then return end
    local col = team.GetColor(ply:Team())
    ent:SetNWVector("RColor", Vector(col.r/127, col.g/127, col.b/127))
    ent:SetNWVector("Carrier", ply)
    
    return true
end

function GM:GravGunOnDropped(ply, ent)
    if ent:GetClass() != "fw_flag" then return end
    ent:SetNWVector("RColor", Vector(1, 1, 1))
    ent:SetOwner(nil)
end