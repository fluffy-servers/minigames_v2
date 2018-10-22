AddCSLuaFile()
ENT.Type = 'brush'

function ENT:Initialize()

end

function ENT:GetNumber()
    return self:GetNWInt('number', 0)
end

function ENT:KeyValue(key, value)
    if key == 'number' then
        self:SetNWInt('number', value)
    end
end

function ENT:StartTouch(ent)
    if ent:GetClass() == 'player_melon' then
        GAMEMODE:HitCheckpoint(ent, self:GetNumber())
    end
end