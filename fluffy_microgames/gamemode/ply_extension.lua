-- Scoring functions for modifiers
-- Simple networked variables
local meta = FindMetaTable("Player")

function meta:GetMScore()
    return self:GetNWInt("Microscore", 0)
end

function meta:SetMScore(amount)
    return self:SetNWInt("Microscore", amount)
end

function meta:AddMScore(amount)
    return self:SetNWInt("Microscore", self:GetScore() + amount)
end

function meta:AwardWin(confetti)
    self:AddFrags(1)
    GAMEMODE:ConfettiEffectSingle(self)
end