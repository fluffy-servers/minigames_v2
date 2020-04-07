AddCSLuaFile()
ENT.Type = 'point'

function ENT:BuildTracer(color)
    self.trail = util.SpriteTrail(self, 0, color, true, 32, 4, 3, 0, "trails/laser.vmt")
end

function ENT:OnRemove()
    if IsValid(self.trail) then
        SafeRemoveEntity(self.trail)
    end
end