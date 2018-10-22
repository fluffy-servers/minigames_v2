ENT.Base = "base_entity"
ENT.Type = "brush"

-- Remove any entities that touch this
function ENT:Touch( entity )
	for k, v in pairs( ents.GetAll() ) do
		if ( entity == v and !v:IsPlayer() and v:GetClass() != "prop_ragdoll" ) then
			v:Remove()
		end
	end
end

-- Everything triggers this entity (as expected)
function ENT:PassesTriggerFilters( entity )
	return true
end