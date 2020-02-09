AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.MinRespawn = 10
ENT.MaxRespawn = 20

local weapon_table = {}
weapon_table['1'] = {'weapon_mg_knife', 'weapon_mg_pistol', 'weapon_mg_smg'}
weapon_table['2'] = {'weapon_mg_shotgun', 'weapon_mg_smg', 'weapon_crossbow', 'weapon_357'}
weapon_table['3'] = {'weapon_mg_sniper', 'weapon_rpg', 'weapon_mg_mortar', 'weapon_frag'}

local models_table = {}
models_table['weapon_mg_shotgun'] = 'models/weapons/w_shotgun.mdl'
models_table['weapon_mg_knife'] = 'models/weapons/w_knife_t.mdl'
models_table['weapon_mg_pistol'] = 'models/weapons/w_pistol.mdl'
models_table['weapon_mg_smg'] = 'models/weapons/w_smg1.mdl'
models_table['weapon_crossbow'] = 'models/weapons/w_crossbow.mdl'
models_table['weapon_357'] = 'models/weapons/w_357.mdl'
models_table['weapon_mg_sniper'] = 'models/weapons/w_snip_awp.mdl'
models_table['weapon_rpg'] = 'models/weapons/w_rocket_launcher.mdl'
models_table['weapon_mg_mortar'] = 'models/weapons/w_rocket_launcher.mdl'
models_table['weapon_frag'] = 'models/weapons/w_grenade.mdl'

local ammo_table = {}
ammo_table['weapon_mg_shotgun'] = {'Buckshot', 12}
ammo_table['weapon_mg_pistol'] = {'Pistol', 12}
ammo_table['weapon_mg_smg'] = {'SMG1', 60}
ammo_table['weapon_crossbow'] = {'XBowBolt', 5}
ammo_table['weapon_357'] = {'357', 12}
ammo_table['weapon_mg_sniper'] = {'Pistol', 12}
ammo_table['weapon_rpg'] = {'RPG_Round', 3}
ammo_table['weapon_mg_mortar'] = {'RPG_Round', 3}
ammo_table['weapon_frag'] = {'Grenade', 3}

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
        local wep = self:GetNWString('WeaponType', 'weapon_mg_shotgun')

        -- Award weapon
        if not ent:HasWeapon(wep) then
            local weapon_ent = ent:Give(wep)
            ent:SelectWeapon(wep)

            if weapon_ent then
                GAMEMODE:PlayerOnlyAnnouncement(ent, 1, weapon_ent.PrintName, 1)
            end
        end

        -- Award ammo
        if ammo_table[wep] then
            ent:GiveAmmo(ammo_table[wep][2], ammo_table[wep][1])
        end

        ent:AddStatPoints('Weapons Collected', 1)
        
        -- Shuffle the type (if applicable)
        if self.RandomTable then
            self:SetNWString('WeaponType', table.Random(self.RandomTable))
        end
        
        -- Reset the timer
        self:SetNWBool('GiftReady', false)
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) -- this seems strange but it's so bullets work
        self.NextTime = CurTime() + math.random(self.MinRespawn, self.MaxRespawn)
    end
    
    -- KV properties for mapping data
    function ENT:KeyValue(key, value)
        if key == 'level' then
            self.RandomTable = weapon_table[value]
            self:SetNWString('WeaponType', table.Random(self.RandomTable))
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
            local type = self:GetNWString('WeaponType', 'weapon_mg_shotgun')
            self.PreviewModel = ClientsideModel(models_table[type])
            self.PreviewType = type
            self.PreviewModel:SetNoDraw(true)
        end
        
        if self.PreviewType != self:GetNWString('WeaponType', 'weapon_mg_shotgun') then
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