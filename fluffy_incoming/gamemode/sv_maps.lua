include("sv_prop_presets.lua")

GM.CurrentPropsCategory = "Both"
GM.PropSpawnTimer = 0

-- Spawn props at appropiate times
hook.Add("Tick", "TickPropSpawn", function()
    if not GAMEMODE:InRound() then return end

    -- Get information from the currently selected props category
    -- See sv_maps for the prop data
    local data = GAMEMODE.DefaultProps[GAMEMODE.CurrentPropsCategory]
    local props = data.models

    -- Choose material
    local material = data.materials
    if istable(data.materials) then
        material = table.Random(materials)
    elseif not material then
        material = "plastic"
    end

    if GAMEMODE.PropSpawnTimer < CurTime() then
        -- Spawn a prop at every spawner
        for k, v in pairs(ents.FindByClass("inc_prop_spawner")) do
            local ent = ents.Create("prop_physics")
            ent:SetModel(props[math.random(1, #props)])
            ent:SetPos(v:GetPos())
            ent:Spawn()

            -- Set physical properties
            local phys = ent:GetPhysicsObject()
            phys:SetMass(40000)
            phys:SetMaterial(material)

            -- Call the data function on every entity
            if data.func then
                data.func(ent)
            end
        end

        GAMEMODE.PropSpawnTimer = CurTime() + (data.delay or 2)
    end
end)

-- Randomly pick a group of props
-- Todo: Map flexibility
hook.Add("PreRoundStart", "IncomingPropsChange", function()
    GAMEMODE.CurrentPropsCategory = table.Random(table.GetKeys(GAMEMODE.PropPresets))
end)