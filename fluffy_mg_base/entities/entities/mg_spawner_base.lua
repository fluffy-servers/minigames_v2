AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.MinRespawn = 10
ENT.MaxRespawn = 20

if SERVER then
    function ENT:Initialize()
        self.CreationTime = CurTime()
        self.NextTime = self.CreationTime + math.random(self.MinRespawn, self.MaxRespawn)
        self:SetModel("models/hunter/blocks/cube075x2x075.mdl")

        self:SetAngles(Angle(0, 0, 90))
        self:SetTrigger(true)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:PhysWake()
    end

    function ENT:Think()
        -- Check if enough time has elapsed to be 'ready'
        local ready = self:GetNWBool("GiftReady", false)
        if ready then
            self:NextThink(CurTime() + 2)
            return
        elseif CurTime() > self.NextTime then
            self:SetNWBool("GiftReady", true)
            self:PrepareItem()
        end

        self:NextThink(CurTime() + 1)
    end

    function ENT:PrepareItem()
        local class = self:GetNWString("ItemType", self.DefaultItem)
        local ent = ents.Create(class)
        ent:SetPos(self:GetPos() + Vector(0, 0, 48))
        ent:SetAngles(Angle(0, 0, 0))
        ent:Spawn()

        -- Freeze the entity in place
        -- Todo: add some spinning animation? Is that possible?
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end

        ent.SpawnerEntity = self
        self.ItemEntity = ent
    end

    function ENT:CollectItem(ply)
        if not ply:IsPlayer() then return end

        -- If random table is specified, pick a new entity for next time
        if self.RandomTable then
            self:SetNWString("ItemType", table.Random(self.RandomTable))
        end

        self:SetNWBool("GiftReady", false)
        self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
    end

    function ENT:KeyValue(key, value)
        if key == "minspawn" then
            self.MinRespawn = tonumber(value)
            self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
        elseif key == "maxspawn" then
            self.MaxRespawn = tonumber(value)
            self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
        end
    end
    
end

if CLIENT then
    -- Particle effect when the spawner is ready
    function ENT:Draw()
        if self:GetNWBool("GiftReady", false) and ((self.NextReady or 0) < CurTime()) then
            local ef = EffectData()
            ef:SetOrigin(self:GetPos())
            util.Effect("spawner_ready", ef)
            self.NextReady = CurTime() + 1
        end
    end

end