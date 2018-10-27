include('shared.lua')

function GM:HUDDrawTargetID()
	return false
end

-- Dodgy thirdperson code
-- Barrels get thirdperson always
function GM:CalcView(pl, pos, angles, fov)
    if LocalPlayer():Team() != TEAM_CACTUS then return self.BaseClass:CalcView(pl,pos,angles,fov) end
    if pl:IsBot() then return end
    
    local cactus = pl:GetNWEntity("cactusobj")
    if !IsValid(cactus) then return end
    if !pl:Alive() then return end
    
    local view = {}
    
    
    local pos = cactus:GetPos()
    angles = pl:EyeAngles()
    local newP = angles.p
    if angles.p <= -45 then angles.p = (angles.p - 45) * 0.5 newP = (newP - 45) * 0.5 end
    local newAng = Angle(newP, angles.y, angles.r)
    local tr = util.TraceLine({
        start = pos,
        endpos = pos - ( newAng:Forward() * 150 ),
        filter = pl
    })

    if tr.Entity:IsWorld() then
        view.origin = tr.HitPos + Vector(0,0,24)
    else
        view.origin = pos - ( newAng:Forward() * 150 ) + Vector(0,0,24)
    end

    view.angles = angles
    view.drawviewer = false
    view.fov = 115

    return view
end
