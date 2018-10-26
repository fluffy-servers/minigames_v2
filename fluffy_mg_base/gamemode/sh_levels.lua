local meta = FindMetaTable("Player")

function meta:GetExperience()
    return self:GetNWInt("MGExperience") or 0
end

function meta:GetMaxExperience()
    local level = self:GetLevel()
    return 100
end

function meta:GetLevel()
    return self:GetNWInt("MGLevel", 0)
end