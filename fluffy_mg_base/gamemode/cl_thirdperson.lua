--[[
    Handler for the thirdperson code
    Set the shared variable GM.ThirdpersonEnabled to use this file
--]]

-- Thirdperson toggle when F3 (default) is pressed
hook.Add("PlayerBindPress", "ThirdpersonToggle", function(ply, bind, pressed)
    if bind == "gm_showspare1" and pressed == true then
        if !GAMEMODE.ThirdpersonEnabled and !LocalPlayer():IsSuperAdmin() then return end
        if !LocalPlayer().Thirdperson then LocalPlayer().Thirdperson = false end
        LocalPlayer().Thirdperson = !( LocalPlayer().Thirdperson )
    end
end)

-- Dodgy thirdperson code
function GM:ThirdPersonView(ply, pos, angles, fov)
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

local camprogress = 0
-- Functions for starting/stopping cool transition modes
function GM:StartCoolTransition(table)
    camprogress = 0
    GAMEMODE.CoolTransition = table
end

function GM:EndCoolTransition()
    camprogress = 0
    GAMEMODE.CoolTransition = nil
end

-- Cool transitions
function GM:TransitionView(ply, origin, angles, fov)
    camprogress = math.min(camprogress + FrameTime(), 1)
    local smooth = math.EaseInOut(camprogress, 0.5, 0.5)
    
    if not GAMEMODE.CoolTransition then return end
    
    local targetpos = GAMEMODE.CoolTransition.pos
    if GAMEMODE.CoolTransition.ent then
        if not IsValid(GAMEMODE.CoolTransition.ent) then
            GAMEMODE:EndCoolTransition()
        end
        targetpos = targetpos + GAMEMODE.CoolTransition.ent:GetPos()
    end
    
    local distance = GAMEMODE.CoolTransition.dist or 80
    
    -- Calculate the goal position and angles based on the table
    local goalangles = GAMEMODE.CoolTransition.ang or Angle(0, math.fmod(CurTime() * 20, 360, 0))
    local goalpos = targetpos + (goalangles:Forward() * -distance)
    local goalfov = GAMEMODE.CoolTransition.fov or fov
    
    -- Smoothly transition the view
    local view = {}
    view.origin = origin + (goalpos - origin) * smooth
    view.angles = angles + (goalangles - angles) * smooth
    view.fov = fov + (goalfov - fov) * smooth
    view.drawviewer = true
    return view
end

-- Determine which view drawing to use
function GM:CalcView(ply, pos, angles, fov)
    if ply:IsBot() then return end
    if GAMEMODE.CoolTransition then
        return GAMEMODE:TransitionView(ply, pos, angles, fov)
    elseif self.ThirdpersonEnabled then
        return GAMEMODE:ThirdPersonView(ply, pos, angles, fov)
    else
        return self.BaseClass:CalcView(ply,pos,angles,fov)
    end  
end

-- Net receiver for cool camera transitions
net.Receive('CoolTransition', function()
    local tbl = net.ReadTable()
    if not tbl.pos then
        if not tbl.ent then
            return
        else
            tbl.pos = Vector(0, 0, 0)
        end
    end
    
    GAMEMODE:StartCoolTransition(tbl)
        
    timer.Simple(tbl.duration or 5, function()
        GAMEMODE:EndCoolTransition()
    end)
end)