AddCSLuaFile()
ENT.Base = "ctf_flag"

function ENT:OnRemove()
	if SERVER then
		GAMEMODE:SpawnFlag(TEAM_BLUE)
	end
end

if CLIENT then
	killicon.AddFont("ctf_flag_blue", "HL2MPTypeDeath", "8", Color( 255, 80, 0, 255 ))
	local mat_blue = CreateMaterial("flaginner_blue", "VertexLitGeneric", {
        ["$basetexture"] = "models/fw/flaginner",
        ["$model"] = 1
    })

	function ENT:Think()

	end
end