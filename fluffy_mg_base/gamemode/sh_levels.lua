local meta = FindMetaTable("Player")

-- Get the current experience of the player
function meta:GetExperience()
    return self:GetNWInt("MGExperience", 0)
end

-- Get the required amount of experience to level up
function meta:GetMaxExperience()
    local level = self:GetLevel()
    return 100
end

-- Get the current level of the player
function meta:GetLevel()
    return self:GetNWInt("MGLevel", 0)
end