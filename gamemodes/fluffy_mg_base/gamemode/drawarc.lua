﻿-- drawArc by Bobblehead
-- https://forum.facepunch.com/f/gmoddev/nycb/draw-Arc-Version-2-0/1/
function draw.Arc(cx, cy, radius, thickness, startang, endang, roughness, color)
    surface.SetDrawColor(color)
    surface.DrawArc(surface.PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness))
end

function surface.PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness)
    local triarc = {}
    -- local deg2rad = math.pi / 180
    -- Define step
    roughness = math.max(roughness or 1, 1)
    local step = roughness
    -- Correct start/end ang
    startang, endang = startang or 0, endang or 0

    if startang > endang then
        step = math.abs(step) * -1
    end

    -- Create the inner circle's points.
    local inner = {}
    local r = radius - thickness

    for deg = startang, endang, step do
        if endang - deg < step then
            deg = endang
        end

        local rad = math.rad(deg)
        -- local rad = deg2rad * deg
        local ox, oy = cx + (math.cos(rad) * r), cy + (-math.sin(rad) * r)

        table.insert(inner, {
            x = ox,
            y = oy,
            u = (ox - cx) / radius + .5,
            v = (oy - cy) / radius + .5,
        })
    end

    -- Create the outer circle's points.
    local outer = {}

    for deg = startang, endang, step do
        if endang - deg < step then
            deg = endang
        end

        local rad = math.rad(deg)
        -- local rad = deg2rad * deg
        local ox, oy = cx + (math.cos(rad) * radius), cy + (-math.sin(rad) * radius)

        table.insert(outer, {
            x = ox,
            y = oy,
            u = (ox - cx) / radius + .5,
            v = (oy - cy) / radius + .5,
        })
    end

    -- Triangulize the points.
    -- twice as many triangles as there are degrees.
    for tri = 1, #inner * 2 do
        local p1, p2, p3
        p1 = outer[math.floor(tri / 2) + 1]
        p3 = inner[math.floor((tri + 1) / 2) + 1]

        --if the number is even use outer.
        if tri % 2 == 0 then
            p2 = outer[math.floor((tri + 1) / 2)]
        else
            p2 = inner[math.floor((tri + 1) / 2)]
        end

        table.insert(triarc, {p1, p2, p3})
    end
    -- Return a table of triangles to draw.

    return triarc
end

--Draw a premade arc.
function surface.DrawArc(arc)
    for k, v in ipairs(arc) do
        surface.DrawPoly(v)
    end
end