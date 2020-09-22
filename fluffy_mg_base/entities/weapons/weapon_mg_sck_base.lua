--[[
    This base is heavily based off the original SWEP Construction Kit base code

    A handful of code style improvements have been made, but also importantly an CSEnt bug has been fixed
    Due to a bug recently introduced in Garry's Mod, CSEnts are not garbage collected
    This modification of the base will handle the cleanup of these entities as expected
    
    For more information on SCK, see the workshop page:
    https://steamcommunity.com/sharedfiles/filedetails/?id=109724869
]]
--
SWEP.Base = "weapon_mg_base"

function SWEP:Initialize()
    if CLIENT then
        -- Create a new table for every weapon instance
        self.VElements = table.FullCopy(self.VElements)
        self.WElements = table.FullCopy(self.WElements)
        self.ViewModelBoneModes = table.FullCopy(self.ViewModelBoneModes)
        -- Create the models
        self:CreateModels(self.VElements)
        self:CreateModels(self.WElements)

        if IsValid(self:GetOwner()) then
            local vm = self:GetOwner():GetViewModel()

            if IsValid(vm) then
                self:ResetBonePositions(vm)

                if self.ShowViewModel == nil or self.ShowViewModel then
                    vm:SetColor(Color(255, 255, 255, 255))
                else
                    vm:SetColor(Color(255, 255, 255, 1))
                    vm:SetMaterial("debug/hsv")
                end
            end
        end
    end

    self:SetHoldType(self.HoldType)
end

function SWEP:Holster()
    if CLIENT and IsValid(self:GetOwner()) then
        local vm = self:GetOwner():GetViewModel()

        if IsValid(vm) then
            self:ResetBonePositions(vm)
        end
    end

    return true
end

function SWEP:OnRemove()
    self:Holster()

    if CLIENT then
        -- Cleanup CS entities
        self:RemoveModels(self.VElements)
        self:RemoveModels(self.WElements)
    end
end

if CLIENT then
    SWEP.vRenderOrder = nil
    SWEP.wRenderOrder = nil

    function SWEP:DrawClientModel(v, pos, ang)
        local model = v.modelEnt
        if not IsValid(model) then return end
        -- Adjust position and angles
        model:SetPos(pos)
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        model:SetAngles(ang)
        -- Scaling
        local matrix = Matrix()
        matrix:Scale(v.size)
        model:EnableMatrix("RenderMultiply", matrix)

        -- Material
        if v.material == "" then
            model:SetMaterial("")
        elseif model:GetMaterial() ~= v.material then
            model:SetMaterial(v.material)
        end

        -- Skin
        if v.skin and v.skin ~= model:GetSkin() then
            model:SetSkin(v.skin)
        end

        -- Bodygroups
        if v.bodygroup then
            for k, v in pairs(v.bodygroup) do
                if model:GetBodygroup(k) ~= v then
                    model:SetBodygroup(k, v)
                end
            end
        end

        -- Supress lighting
        -- This checks the stupid named variable for legacy compatibility
        -- Blame Clavus not me for that one
        if v.surpresslightning or v.suppresslighting then
            render.SuppressEngineLighting(true)
        end

        -- Color
        if v.color then
            render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
            render.SetBlend(v.color.a / 255)
        end

        model:DrawModel()

        -- Reverse color changes
        if v.color then
            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)
        end

        -- Reverse lighting suppression
        if v.surpresslightning or v.suppresslighting then
            render.SuppressEngineLighting(false)
        end
    end

    function SWEP:DrawClientSprite(v, pos, ang)
        local sprite = v.spriteMaterial
        if not sprite then return end
        render.SetMaterial(sprite)
        render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
    end

    function SWEP:DrawClientQuad(v, pos, ang)
        local func = v.draw_func
        if not func then return end
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        cam.Start3D2D(drawpos, ang, v.size)
        v.draw_func(self)
        cam.End3D2D()
    end

    function SWEP:ViewModelDrawn()
        local vm = self:GetOwner():GetViewModel()
        if not self.VElements then return end
        self:UpdateBonePositions(vm)

        -- Build a render order if one does not yet exist
        -- This is because sprites need to be rendered after models
        if not self.vRenderOrder then
            self.vRenderOrder = {}

            for k, v in pairs(self.VElements) do
                if v.type == "Model" then
                    table.insert(self.vRenderOrder, 1, k)
                elseif v.type == "Sprite" or v.type == "Quad" then
                    table.insert(self.vRenderOrder, k)
                end
            end
        end

        -- Render all components of the weapon
        for k, name in ipairs(self.vRenderOrder) do
            local v = self.VElements[name]

            if not v then
                self.vRenderOrder = nil
                break
            end

            if v.hide then continue end
            if not v.bone then continue end
            local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
            if not pos then continue end
            pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

            if v.type == "Model" then
                self:DrawClientModel(v, pos, ang)
            elseif v.type == "Sprite" then
                self:DrawClientSprite(v, pos, ang)
            elseif v.type == "Quad" then
                self:DrawClientQuad(v, pos, ang)
            end
        end
    end

    function SWEP:DrawWorldModel()
        if self.ShowWorldModel == nil or self.ShowWorldModel then
            self:DrawModel()
        end

        if not self.WElements then return end

        -- Build a render order if one does not yet exist
        -- This is because sprites need to be rendered after models
        if not self.wRenderOrder then
            self.wRenderOrder = {}

            for k, v in pairs(self.WElements) do
                if v.type == "Model" then
                    table.insert(self.wRenderOrder, 1, k)
                elseif v.type == "Sprite" or v.type == "Quad" then
                    table.insert(self.wRenderOrder, k)
                end
            end
        end

        -- Find the bone entity thingo
        -- This is the owner if the weapon is held, or itself if the weapon is dropped
        local bone_ent = self

        if IsValid(self:GetOwner()) then
            bone_ent = self:GetOwner()
        end

        for k, name in ipairs(self.wRenderOrder) do
            local v = self.WElements[name]

            if not v then
                self.wRenderOrder = nil
                break
            end

            if v.hide then continue end
            -- Calculate position
            local pos, ang

            if v.bone then
                pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
            else
                pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
            end

            if not pos then continue end
            pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

            if v.type == "Model" then
                self:DrawClientModel(v, pos, ang)
            elseif v.type == "Sprite" then
                self:DrawClientSprite(v, pos, ang)
            elseif v.type == "Quad" then
                self:DrawClientQuad(v, pos, ang)
            end
        end
    end

    function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
        local pos, ang

        if tab.rel and tab.rel ~= "" then
            local v = basetab[tab.rel]
            if not v then return end
            pos, ang = self:GetBoneOrientation(basetab, v, ent)
            if not pos then return end
            pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        else
            local bone = ent:LookupBone(bone_override or tab.bone)
            if not bone then return end
            pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
            local m = ent:GetBoneMatrix(bone)

            if m then
                pos, ang = m:GetTranslation(), m:GetAngles()
            end

            if self.ViewModelFlip then
                if IsValid(self:GetOwner()) and ent == self:GetOwner():GetViewModel() then
                    ang.r = -ang.r
                end
            end
        end

        return pos, ang
    end

    function SWEP:CreateModels(tab)
        if not tab then return end

        for k, v in pairs(tab) do
            if v.type == "Model" then
                if not v.model or v.model == "" then continue end
                if IsValid(v.modelEnt) and v.createdModel == v.model then continue end

                if string.find(v.model, ".mdl") and file.Exists(v.model, "GAME") then
                    v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)

                    if IsValid(v.modelEnt) then
                        v.modelEnt:SetPos(self:GetPos())
                        v.modelEnt:SetAngles(self:GetAngles())
                        v.modelEnt:SetParent(self)
                        v.modelEnt:SetNoDraw(true)
                        v.createdModel = v.model
                    else
                        v.modelEnt = nil
                    end
                else
                    print("Could not find model ", v.model)
                end
            elseif v.type == "Sprite" then
                if not v.sprite or v.sprite == "" then continue end
                if v.spriteMaterial and v.createdSprite == v.sprite then continue end

                if file.Exists("materials/" .. v.sprite .. ".vmt", "GAME") then
                    local name = v.sprite .. "-"

                    local params = {
                        ["$basetexture"] = v.sprite
                    }

                    -- Make sure we create a unique name based on the selected options
                    local tocheck = {"nocull", "additive", "vertexalpha", "vertexolor", "ignorez"}

                    for i, j in pairs(tocheck) do
                        if v[j] then
                            params["$" .. j] = 1
                            name = name .. "1"
                        else
                            name = name .. "0"
                        end
                    end

                    v.createdSprite = v.sprite
                    v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
                end
            end
        end
    end

    function SWEP:RemoveModels(tab)
        if not tab then return end

        for k, v in pairs(tab) do
            if v.type == "Model" then
                if IsValid(v.modelEnt) then
                    v.modelEnt:Remove()
                end
            end
        end
    end

    local allbones

    function SWEP:UpdateBonePositions(vm)
        if self.ViewModelBoneMods then
            local num = vm:GetBoneCount()
            if not num then return end
            local loopthrough = self.ViewModelBoneMods

            if true then
                allbones = {}

                for i = 0, vm:GetBoneCount() do
                    local bonename = vm:GetBoneName(i)

                    if self.ViewModelBoneMods[bonename] then
                        allbones[bonename] = self.ViewModelBoneMods[bonename]
                    else
                        allbones[bonename] = {
                            scale = Vector(1, 1, 1),
                            pos = Vector(0, 0, 0),
                            angle = Angle(0, 0, 0)
                        }
                    end
                end

                loopthrough = allbones
            end

            for k, v in pairs(loopthrough) do
                local bone = vm:LookupBone(k)
                if not bone then continue end
                local s = Vector(v.scale.x, v.scale.y, v.scale.z)
                local p = Vector(v.pos.x, v.pos.y, v.pos.z)
                local ms = Vector(1, 1, 1)

                if true then
                    local cur = vm:GetBoneParent(bone)

                    while (cur >= 0) do
                        local pscale = loopthrough[vm:GetBoneName(cur)].scale
                        ms = ms * pscale
                        cur = vm:GetBoneParent(cur)
                    end
                end

                s = s * ms

                if vm:GetManipulateBoneScale(bone) ~= s then
                    vm:ManipulateBoneScale(bone, s)
                end

                if vm:GetManipulateBoneAngles(bone) ~= v.angle then
                    vm:ManipulateBoneAngles(bone, v.angle)
                end

                if vm:GetManipulateBonePosition(bone) ~= p then
                    vm:ManipulateBonePosition(bone, p)
                end
            end
        else
            self:ResetBonePositions(vm)
        end
    end

    function SWEP:ResetBonePositions(vm)
        local num = vm:GetBoneCount()
        if not num then return end

        for i = 0, num do
            vm:ManipulateBoneScale(i, Vector(1, 1, 1))
            vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
            vm:ManipulateBonePosition(i, Vector(0, 0, 0))
        end
    end

    function table.FullCopy(tab)
        if not tab then return nil end
        local res = {}

        for k, v in pairs(tab) do
            if type(v) == "table" then
                res[k] = table.FullCopy(v)
            elseif type(v) == "Vector" then
                res[k] = Vector(v.x, v.y, v.z)
            elseif type(v) == "Angle" then
                res[k] = Angle(v.p, v.y, v.r)
            else
                res[k] = v
            end
        end

        return res
    end
end