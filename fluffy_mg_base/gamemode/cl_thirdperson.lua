-- Thirdperson toggle when F3 (default) is pressed
hook.Add("PlayerBindPress", "ThirdpersonToggle", function(ply, bind, pressed)
    if bind == "gm_showspare1" and pressed == true then
        if !GAMEMODE.ThirdpersonEnabled and !LocalPlayer():IsSuperAdmin() then return end
        if !LocalPlayer().Thirdperson then LocalPlayer().Thirdperson = false end
        LocalPlayer().Thirdperson = !( LocalPlayer().Thirdperson )
    end
end)

-- Dodgy thirdperson code
function GM:CalcView(ply, pos, angles, fov)
    if !self.ThirdpersonEnabled and !LocalPlayer():IsSuperAdmin() then return self.BaseClass:CalcView(ply,pos,angles,fov) end -- Check that thirdperson is useable
    if ply:IsBot() then return end
    local view = {}
    
    -- Get plyayer eye angles
    angles = ply:EyeAngles()
    if not angles then return end
    
    -- not sure how much commenting will help
    if ply:Alive() and ply:GetObserverMode() == OBS_MODE_NONE and ( LocalPlayer().Thirdperson ) then
        view.fov = 60 -- GetConVar( "default_fov" ):GetFloat()
        
        -- Calculate the angle better
        local newP = angles.p
        if angles.p <= -45 then angles.p = (angles.p - 45) * 0.5 newP = (newP - 45) * 0.5 end
        local newAng = Angle(newP, angles.y, angles.r)
        
        -- Make a trace backwards and check for collisions with the world
        local tr = util.TraceLine({
            start = pos,
            endpos = pos - ( newAng:Forward() * 150 ),
            filter = ply
        })

        if tr.Entity:IsWorld() then
            view.origin = tr.HitPos + tr.HitNormal*12 + Vector(0,0,24)
        else
            view.origin = pos - newAng:Forward()*150 + Vector(0,0,24)
        end
        
        -- Update angles
        view.angles = angles
        view.drawviewer = true
    else
        -- rethink this section tbh
        --view.fov = GetConVar( "default_fov" ):GetFloat() BAD FLUFFY NO DON'T DO THIS
        view.origin = pos
        view.angles = angles
    end

    return view
end