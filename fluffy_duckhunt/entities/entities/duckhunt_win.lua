ENT.Base = "base_entity"
ENT.Type = "brush"

-- Award players that touch this entity a round win
function ENT:StartTouch(ent)
	if IsValid(self) and ent:IsPlayer() then
        if not ent:Alive() or ent.Spectating then return end
        if ent:Team() != TEAM_BLUE then return end
        self:Remove()
		GAMEMODE:EndRound(ent)
	end
end