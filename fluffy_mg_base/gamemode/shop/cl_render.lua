SHOP.ClientModels = {}

-- Render the currently equipped cosmetics of a player
-- Notice the ent parameter: this can be used in the shop etc.
function SHOP:RenderCosmetics(ent, ply, force)
    if not SHOP.ClientModels[ply] then return end

    for _, ITEM in pairs(SHOP.ClientModels[ply]) do
        if not GAMEMODE:DoCosmeticsCheck(ply, ITEM) and not force then continue end
        if not ITEM.ent then continue end

        -- Search for the attachment and calculate the position & angles
        if not ITEM.Attachment then
            print("missing attachment!")
            continue
        end

        local attach_id = ent:LookupAttachment(ITEM.Attachment)
        if not attach_id then continue end
        local attach = ent:GetAttachment(attach_id)
        if not attach then continue end
        local pos = attach.Pos
        local ang = attach.Ang
        if not pos or not ang then continue end

        -- Apply any modifications
        if ITEM.Modify then
            -- Scale modification
            if ITEM.Modify.scale then
                ITEM.ent:SetModelScale(ITEM.Modify.scale, 0)
            end

            -- Offset modification
            if ITEM.Modify.offset then
                local offset = ITEM.Modify.offset
                pos = pos + (ang:Forward() * offset.x) + (ang:Right() * offset.y) + (ang:Up() * offset.z)
            end

            -- Rotation modification
            if ITEM.Modify.angle then
                local rotation = ITEM.Modify.angle
                ang:RotateAroundAxis(ang:Right(), rotation.p)
                ang:RotateAroundAxis(ang:Forward(), rotation.r)
                ang:RotateAroundAxis(ang:Up(), rotation.y)
            end
        end

        -- Apply custom colours
        if ITEM.Paintable and ITEM.Color then
            render.SetColorModulation(ITEM.Color.r / 255, ITEM.Color.g / 255, ITEM.Color.b / 255)
        end

        -- Apply override material
        if ITEM.MaterialOverride then
            ITEM.ent:SetMaterial(ITEM.MaterialOverride)
        end

        -- Draw the model!
        ITEM.ent:SetPos(pos)
        ITEM.ent:SetAngles(ang)
        ITEM.ent:DrawModel()

        -- Reset paintable colors
        if ITEM.Paintable and ITEM.Color then
            render.SetColorModulation(1, 1, 1)
        end
    end
end

-- Hook to draw player cosmetics
-- This calls the above function
hook.Add("PostPlayerDraw", "DrawPlayerCosmetics", function(ply)
    if not ply:Alive() then return end
    if ply == LocalPlayer() and (GetViewEntity():GetClass() == "player" and not LocalPlayer().Thirdperson) then return end
    -- This renders the players cosmetics onto the player entity
    SHOP:RenderCosmetics(ply, ply)
end)

-- Create the ClientsideModel for a cosmetic and add it to the table
-- ITEM should be a Vanilla item table
function SHOP:EquipCosmetic(ITEM, ply)
    if not SHOP.ClientModels[ply] then
        SHOP.ClientModels[ply] = {}
    end

    ITEM = SHOP:ParseVanillaItem(ITEM)
    if not ITEM.Model then return end
    local ent = ClientsideModel(ITEM.Model, RENDERGROUP_OPAQUE)
    ent:SetNoDraw(true)

    if ITEM.Skin then
        ent:SetSkin(ITEM.Skin)
    end

    ITEM.ent = ent
    SHOP.ClientModels[ply][ITEM.VanillaID] = ITEM
end

-- Unequip a cosmetic
function SHOP:UnequipCosmetic(ITEM, ply)
    if not SHOP.ClientModels[ply] then return end

    if SHOP.ClientModels[ply][ITEM.VanillaID] then
        SafeRemoveEntity(SHOP.ClientModels[ply][ITEM.VanillaID].ent)
        SHOP.ClientModels[ply][ITEM.VanillaID] = nil
    end
end

-- Clientside tracer effect
hook.Add("EntityFireBullets", "ShopTracerEffects", function(ent, data)
    if not ent:IsPlayer() then return end
    local effect = ent:GetNWString("ShopTracerEffect")
    if not effect or effect == "" then return end
    data.Tracer = 1
    data.TracerName = effect

    return true
end)