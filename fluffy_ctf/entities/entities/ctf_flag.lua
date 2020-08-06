AddCSLuaFile()
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

function ENT:Initialize()
    if CLIENT then return end
	self.Entity:SetModel( "models/fw/fw_flag.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )  
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Sleep()
	end
    self.NoExplode = true
end

function ENT:Use(ply)
    if IsValid(ply) and ply:IsPlayer() then
        GAMEMODE:CollectFlag(ply)
    end
end