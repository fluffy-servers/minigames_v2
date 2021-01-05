AddCSLuaFile()
ENT.Base = "mg_spawner_base"
ENT.DefaultItem = "item_healthvial"

if SERVER then
    -- KV properties for mapping data
    function ENT:KeyValue(key, value)
        if key == "size" then
            if value == "large" then
                self:SetNWString("ItemType", "item_healthkit")
            elseif value == "small" then
                self:SetNWString("ItemType", "item_healtvial")
            end
        end

        local BaseClass = baseclass.Get("mg_spawner_base")
        BaseClass.KeyValue(self, key, value)
    end
end