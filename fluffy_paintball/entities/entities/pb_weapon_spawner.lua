AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.MinRespawn = 10
ENT.MaxRespawn = 20

local weapon_table = {}
weapon_table['shotgun'] = 'paint_shotgun'
weapon_table['bazooka'] = 'paint_bazooka'
weapon_table['smg'] = 'paint_smg'
weapon_table['crossbow'] = 'paint_crossbow'
weapon_table['grenade'] = 'paint_grenade_wep'
weapon_table['knife'] = 'paint_knife'

local models_table = {}
models_table['shotgun'] = 'models/weapons/w_shotgun.mdl'
models_table['bazooka'] = 'models/weapons/w_rocket_launcher.mdl'
models_table['smg'] = 'models/weapons/w_smg1.mdl'
models_table['crossbow'] = 'models/weapons/w_crossbow.mdl'
models_table['grenade'] = 'models/weapons/w_grenade.mdl'
models_table['knife'] = 'models/weapons/w_knife_t.mdl'

local ammo_table = {}
ammo_table['shotgun'] = {'Buckshot', 12}
ammo_table['bazooka'] = {'RPG_Round', 3}
ammo_table['smg'] = {'SMG1', 60}
ammo_table['crossbow'] = {'SniperRound', 5}
ammo_table['grenade'] = {'Grenade', 3}

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
        
        --self:SetNWString('WeaponType', 'grenade')
    end
    
    function ENT:Think()
        local ready = self:GetNWBool('GiftReady', false)
        if ready then
            self:NextThink(CurTime() + 3)
        elseif CurTime() > self.NextTime then
            self:SetNWBool('GiftReady', true)
            self:SetCollisionGroup(COLLISION_GROUP_NONE)
            
            -- Check that nobody is stuck
            local nearby_ents = ents.FindInSphere(self:GetPos(), 48)
            for _, v in pairs(nearby_ents) do
                if v:IsPlayer() then
                    self:Touch(v)
                    break
                end
            end
        end
        
        self:NextThink(CurTime() + 1)
    end
    
    function ENT:Touch(ent)
        if not self:GetNWBool('GiftReady', false) then return end
        if not ent:IsPlayer() then return end
        if ent:GetNWBool('IsGhost', false) then return end
        
        -- Award the player the weapon
        local type = self:GetNWString('WeaponType', 'shotgun')
        local wep = weapon_table[type]
        if ent:HasWeapon(wep) then
            -- If they already have the weapon, award ammo instead
            if ammo_table[type] then
                ent:GiveAmmo(ammo_table[type][2], ammo_table[type][1])
            end
        else
            ent:Give(wep)
        end
        ent:AddStatPoints('Weapons Collected', 1)
        
        -- Shuffle the type (if applicable)
        if self.RandomTable then
            PrintTable(self.RandomTable)
            self:SetNWString('WeaponType', table.Random(self.RandomTable))
        end
        
        -- Reset the timer
        self:SetNWBool('GiftReady', false)
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
    end
    
    -- KV properties for mapping data
    function ENT:KeyValue(key, value)
        if key == 'type' then
            if string.match(value, ',') then
                -- List of weapons
                value = string.Split(value, ',')
                self.RandomTable = value
                self:SetNWString('WeaponType', table.Random(self.RandomTable))
            else
                -- Single weapon
                self:SetNWString('WeaponType', value)
            end
        elseif key == 'minspawn' then
            self.MinRespawn = tonumber(value)
            self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
        elseif key == 'maxspawn' then
            self.MaxRespawn = tonumber(value)
            self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
        end
    end
end

if CLIENT then
    -- Render the weapon preview
    function ENT:RenderPreviewModel()
        if not self.PreviewModel then
            local type = self:GetNWString('WeaponType', 'shotgun')
            self.PreviewModel = ClientsideModel(models_table[type])
            self.PreviewType = type
            self.PreviewModel:SetNoDraw(true)
        end
        
        if self.PreviewType != self:GetNWString('WeaponType', 'shotgun') then
            SafeRemoveEntity(self.PreviewModel)
            self.PreviewModel = nil
            return
        end
        
        -- Render the model rotating gently
        self.PreviewModel:SetPos(self:GetPos() + Vector(0, 0, 32))
        self.PreviewModel:SetAngles(Angle(0, CurTime()*100, 0))
        self.PreviewModel:DrawModel()
    end
    
    function ENT:Draw()
        --self:DrawModel()
        if self:GetNWBool('GiftReady', false) then
            self:RenderPreviewModel()
            
            -- Draw particle effect
            if (self.NextReady or 0) < CurTime() then
                local ef = EffectData()
                ef:SetOrigin(self:GetPos())
                util.Effect('spawner_ready', ef)
                self.NextReady = CurTime() + 1
            end
        end
    end
end