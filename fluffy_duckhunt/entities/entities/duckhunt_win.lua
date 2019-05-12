ENT.Base = "base_entity"
ENT.Type = "brush"

-- Award players that touch this entity a round win
function ENT:StartTouch(ent)
	if IsValid(self) and ent:IsPlayer() then
        self:Remove()
		GAMEMODE:EndRound(ent)
	end
end