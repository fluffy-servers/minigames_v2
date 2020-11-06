-- This is not a standalone weapon!
-- This is a helper base for melee weapons
SWEP.Base = "weapon_mg_base"
SWEP.AttackRange = 56

-- port from weapon_knife.cpp
function SWEP:FindHullIntersection(src, tr, mins, maxs, ent)
    local vecHullEnd = src + ((tr.HitPos - src) * 2)
    local data = {}
    data.start = src
    data.endpos = vecHullEnd
    data.filter = ent
    data.mask = MASK_SOLID
    data.mins = mins
    data.maxs = maxs

    local tmp = util.TraceLine(data)
    if tmp.Hit then
        return tmp
    end

    local distance = 999999
    for i = 0, 1 do
        for j = 0, 1 do
            for k = 0, 1 do
                local vecEnd = Vector()
                vecEnd.x = vecHullEnd.x + (i > 0 and maxs.x or mins.x)
                vecEnd.y = vecHullEnd.y + (j > 0 and maxs.y or mins.y)
                vecEnd.z = vecHullEnd.z + (k > 0 and maxs.z or mins.z)
                data.endpos = vecEnd

                tmp = util.TraceLine(data)
                if tmp.Hit then
                    local dist = (tmp.HitPos - src):Length()
                    if dist < distance then
                        tr = tmp
                        distance = dist
                    end
                end
            end
        end
    end

    return tr
end

function SWEP:EntityFaceBack(ent)
    local angle = self:GetOwner():GetAngles().y - ent:GetAngles().y

    if angle < -180 then
        angle = 360 + angle
    end

    return angle <= 90 and angle >= -90
end

function SWEP:DoAttack(alt)
    local attacker = self:GetOwner()
    attacker:LagCompensation(true)

    local range = self.AttackRange
    local forward = attacker:GetAimVector()
    local src = attacker:GetShootPos()
    local trace_end = src + forward * range

    -- Setup trace structure
    local trace = {}
    trace.filter = attacker
    trace.start = src
    trace.mask = MASK_SOLID
    trace.endpos = trace_end
    trace.mins = Vector(-16, -16, -18)
    trace.maxs = Vector(16, 16, 18)

    -- Run the trace
    -- This does some fancy hull stuff for approximating near-misses
    local tr = util.TraceLine(trace)
    if not tr.Hit then tr = util.TraceHull(trace) end
    if tr.Hit and (tr.Entity or tr.HitWorld) then
        local dmins, dmaxs = attacker:GetHullDuck()
        tr = self:FindHullIntersection(src, tr, dmins, dmaxs, attacker)
        trace_end = tr.HitPos
    end

    -- Call the AttackHit or AttackMissed methods
    if tr.Hit then
        self:AttackHit(tr.Entity, tr)
    else
        self:AttackMissed()
    end

    attacker:LagCompensation(false)
end

function SWEP:AttackHit(ent)
    -- Override in child!
end

function SWEP:AttackMissed(ent)
    -- Override in child!
end