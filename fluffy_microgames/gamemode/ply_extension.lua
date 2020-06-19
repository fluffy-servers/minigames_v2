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
    return self:SetNWInt("Microscore", self:GetMScore() + amount)
end

function meta:ConvertMScore(scale)
    local mscore = self:GetMScore()
    local scaled = math.Round(scale * mscore)
    self:AddFrags(scaled)
end

function meta:AwardWin(confetti)
    self:AddFrags(1)
    if confetti then
        GAMEMODE:ConfettiEffectSingle(self)
    end
end