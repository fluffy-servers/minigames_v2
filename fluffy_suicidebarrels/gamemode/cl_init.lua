include('shared.lua')

-- Stop the plyayer information showing up on mouseover
function GM:HUDDrawTargetID()
	return false
end

-- Dodgy thirdperson code
-- Barrels get thirdperson always
function GM:CalcView(ply, pos, angles, fov)
	-- If the player is not a barrel, call the default version of this function
    if LocalPlayer():Team() != TEAM_RED then return self.BaseClass:CalcView(ply,pos,angles,fov) end
	-- Bots can't see anyway
    if ply:IsBot() then return end
    
	-- Barrels (Team Red) get thirdperson always
    local view = {}
    angles = ply:EyeAngles()
    if ply:Alive() and ply:GetObserverMode() == OBS_MODE_NONE then
        view.fov = GetConVar( "default_fov" ):GetFloat() -- this should probably be better
		
		-- Alter the angles so the camera is from the back
        local newP = angles.p
        if angles.p <= -45 then angles.p = (angles.p - 45) * 0.5 newP = (newP - 45) * 0.5 end
        local newAng = Angle(newP, angles.y, angles.r)
		
		-- Trace backwards a short distance to determine camera position
        local tr = util.TraceLine({
            start = pos,
            endpos = pos - ( newAng:Forward() * 150 ),
            filter = ply
        })

		-- Adjust camera position if collisions occur
        if tr.Entity:IsWorld() then
            view.origin = tr.HitPos + Vector(0,0,24)
        else
            view.origin = pos - ( newAng:Forward() * 150 ) + Vector(0,0,24)
        end

		-- Apply changes
        view.angles = angles
        view.drawviewer = true
    end

	-- Return the view table
    return view
end