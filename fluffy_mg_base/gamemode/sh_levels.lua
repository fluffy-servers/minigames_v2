local meta = FindMetaTable("Player")

-- Get the current experience of the player
function meta:GetExperience()
    return self:GetNWInt("MGExperience", 0)
end

-- Get the required amount of experience to level up
function meta:GetMaxExperience()
    local level = self:GetLevel()
    if level < 5 then
        return 100
    elseif level < 10 then
        return 200
    elseif level < 25 then
        return 500
    else
        return 1000
    end
end

-- Get the total amount of XP a player has, including previous levels
function meta:CumulativeExperience()
    local level_xp = 0
    local level = self:GetLevel()
    if level < 5 then
        level_xp = level*100
    elseif level < 10 then
        level_xp = 500 + (level-5)*200
    elseif level < 25 then
        level_xp = 1500 + (level-10)*200
    else
        level_xp = 9000 + (level-25)*1000
    end
    
    return level_xp + self:GetExperience()
end

-- Get the current level of the player
function meta:GetLevel()
    return self:GetNWInt("MGLevel", 0)
end