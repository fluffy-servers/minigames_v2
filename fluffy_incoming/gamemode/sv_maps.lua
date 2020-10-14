include("sv_prop_presets.lua")

GM.CurrentPropsCategory = "Geometric"
GM.PropSpawnTimer = 0

-- Spawn props at appropiate times
hook.Add("Tick", "TickPropSpawn", function()
    local roundstate = GAMEMODE:GetRoundState()
    if roundstate ~= "InRound" and roundstate ~= "PreRound" then return end

    -- Get information from the currently selected props category
    -- See sv_maps for the prop data
    local data = GAMEMODE.PropPresets[GAMEMODE.CurrentPropsCategory]
    if not data then
        ErrorNoHalt("Invalid prop preset specified - this is probably a map issue!")
    end
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
            if not IsValid(phys) then return end

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
    GAMEMODE.CurrentPropsCategory = table.Random(GAMEMODE.MapPresets)
end)

-- Handle custom model control
GM.MapPresets = GM.MapPresets or {"Geometric", "Vehicles", "Geometric and Vehicles", "Cubes And Spheres"}

hook.Add("InitPostEntity", "IncomingCustomProps", function()
    local controls = ents.FindByClass("inc_model_control")
    if not controls or #controls < 1 then return end

    GAMEMODE.MapPresets = {}
    for _, v in pairs(controls) do
        if string.StartWith(v.Preset, "Custom") then
            GAMEMODE.PropPresets[v.Preset] = v.CustomPreset
        end
        table.insert(GAMEMODE.MapPresets, v.Preset)
    end

    print("Loaded custom presets!")
    PrintTable(GAMEMODE.MapPresets)
end)