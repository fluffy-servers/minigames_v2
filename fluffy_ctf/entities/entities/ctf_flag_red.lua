AddCSLuaFile()
ENT.Base = "ctf_flag"

function ENT:OnRemove()
	if SERVER then
		GAMEMODE:SpawnFlag(TEAM_RED)
	end
end

if CLIENT then
	killicon.AddFont("ctf_flag_red", "HL2MPTypeDeath", "8", Color( 255, 80, 0, 255 ))
	local mat_red = CreateMaterial("flaginner_red", "VertexLitGeneric", {
        ["$basetexture"] = "models/fw/flaginner",
        ["$model"] = 1
    })

	function ENT:Think()

	end
end