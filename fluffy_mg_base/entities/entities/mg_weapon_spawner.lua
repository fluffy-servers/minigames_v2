AddCSLuaFile()
ENT.Base = "mg_spawner_base"
ENT.DefaultItem = "weapon_mg_shotgun"

if SERVER then
    function ENT:Initialize()
        if not GAMEMODE.WeaponSpawners then
            self:Remove()

            return
        end

        local BaseClass = baseclass.Get("mg_spawner_base")
        BaseClass.Initialize(self)
    end

    function ENT:CollectItem(ply)
        if not ply:IsPlayer() then return end

        -- Announce to the player
        local name = self.WeaponEntity:GetPrintName()
        GAMEMODE:PlayerOnlyAnnouncement(ply, 1.5, name, 1, "top")

        local BaseClass = baseclass.Get("mg_spawner_base")
        BaseClass.CollectItem(self, ply)
    end

    -- KV properties for mapping data
    function ENT:KeyValue(key, value)
        if key == "level" then
            if not GAMEMODE.WeaponSpawners then return end
            local wep_table = GAMEMODE.WeaponSpawners["spawns"]

            self.RandomTable = wep_table[value]
            self:SetNWString("ItemType", table.Random(self.RandomTable))
        end

        local BaseClass = baseclass.Get("mg_spawner_base")
        BaseClass.KeyValue(self, key, value)
    end
end