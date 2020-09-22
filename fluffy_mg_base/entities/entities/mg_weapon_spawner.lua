AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.MinRespawn = 10
ENT.MaxRespawn = 20

if SERVER then
    function ENT:Initialize()
        if not GAMEMODE.WeaponSpawners then
            self:Remove()

            return
        end

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
        local ready = self:GetNWBool("GiftReady", false)

        if ready then
            self:NextThink(CurTime() + 2)
        elseif CurTime() > self.NextTime then
            self:SetNWBool("GiftReady", true)
            self:PrepareWeapon()
        end

        self:NextThink(CurTime() + 1)
    end

    function ENT:PrepareWeapon()
        -- oh boy
        local class = self:GetNWString("WeaponType", "weapon_mg_shotgun")
        local wep = ents.Create(class)
        wep:SetPos(self:GetPos() + Vector(0, 0, 48))
        wep:SetAngles(Angle(0, 0, 0))
        wep:Spawn()
        local phys = wep:GetPhysicsObject()

        if IsValid(phys) then
            phys:EnableMotion(false)
        end

        wep.SpawnerEntity = self
        self.WeaponEntity = wep
    end

    function ENT:CollectWeapon(ply)
        print("Collecting weapon!")
        if not ply:IsPlayer() then return end
        local wep = self.WeaponEntity

        -- Reset the spawner
        if self.RandomTable then
            self:SetNWString("WeaponType", table.Random(self.RandomTable))
        end

        self:SetNWBool("GiftReady", false)
        self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
        -- Announce to the player
        local name = wep:GetPrintName()
        GAMEMODE:PlayerOnlyAnnouncement(ply, 1.5, name, 1, "top")
    end

    -- KV properties for mapping data
    function ENT:KeyValue(key, value)
        if not GAMEMODE.WeaponSpawners then return end
        local wep_table = GAMEMODE.WeaponSpawners["spawns"]

        if key == "level" then
            self.RandomTable = wep_table[value]
            self:SetNWString("WeaponType", table.Random(self.RandomTable))
        elseif key == "minspawn" then
            self.MinRespawn = tonumber(value)
            self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
        elseif key == "maxspawn" then
            self.MaxRespawn = tonumber(value)
            self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
        end
    end
end

if CLIENT then
    function ENT:Draw()
        if self:GetNWBool("GiftReady", false) then
            -- Draw particle effect
            if (self.NextReady or 0) < CurTime() then
                local ef = EffectData()
                ef:SetOrigin(self:GetPos())
                util.Effect("spawner_ready", ef)
                self.NextReady = CurTime() + 1
            end
        end
    end
end