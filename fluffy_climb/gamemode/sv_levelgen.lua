--[[
local function WeightedRandom(table)
    local total = 0

    for k, v in pairs(table) do
        total = total + item[2]
    end

    local c = math.random(total - 1)
    local cur = 0

    for k, v in pairs(table) do
        cur = cur + item[2]
        if c < cur then return item[1] end
    end
end
]]--

local block_models = {
    "models/hunter/blocks/cube125x125x025.mdl",
    "models/hunter/blocks/cube150x150x025.mdl",
    "models/hunter/blocks/cube1x2x025.mdl",
    "models/hunter/blocks/cube2x2x025.mdl"
}

local circle_models = {
    "models/hunter/tubes/circle2x2.mdl",
    "models/hunter/tubes/circle2x2b.mdl",
    "models/hunter/tubes/circle2x2c.mdl",
    "models/hunter/tubes/circle2x2d.mdl",
    "models/hunter/tubes/circle4x4d.mdl",
    "models/hunter/tubes/circle2x2.mdl",
    "models/hunter/tubes/circle2x2b.mdl",
    "models/hunter/tubes/circle2x2c.mdl",
    "models/hunter/tubes/circle2x2d.mdl",
    "models/hunter/tubes/circle4x4d.mdl",
    "models/hunter/tubes/circle4x4b.mdl",
    "models/hunter/tubes/circle4x4c.mdl"
}

local triangle_models = {
    "models/hunter/geometric/tri1x1eq.mdl",
    "models/hunter/triangles/2x2.mdl",
    "models/hunter/triangles/3x3.mdl",
    "models/hunter/triangles/1x1mirrored.mdl",
    "models/hunter/triangles/trapezium.mdl",
    "models/hunter/geometric/para1x1.mdl"
}

local poly_models = {
    "models/hunter/plates/plate1x1.mdl",
    "models/hunter/triangles/trapezium.mdl",
    "models/hunter/geometric/tri1x1eq.mdl",
    "models/hunter/geometric/para1x1.mdl",
    "models/hunter/geometric/pent1x1.mdl",
    "models/hunter/geometric/hex1x1.mdl"
}

local crate_models = {
    "models/props_junk/wood_crate001a.mdl",
    "models/props_junk/wood_crate002a.mdl"
}

GM.HueMin = 0
GM.HueMax = 360

function GM:SpawnBlob(position, hue, generator)
    -- Create the block
    local block = ents.Create("jump_block")
    if not IsValid(block) then return end
    block:SetModel(table.Random(generator.models))
    block:SetColor(HSVToColor(hue, math.random(0.8, 1), math.random(0.8, 1)))
    block:SetPos(position)
    block:SetAngles(Angle(0, math.random(0, 360), 0))
    block:Spawn()

    if math.random() < generator.percentJump then
        block:SetJumpBlock()
    end

    return block
end

function GM:GenerateStrand(generator)
    -- Generation variables
    local mins = generator.mins
    local maxs = generator.maxs
    local height = generator.height
    local gAngle = math.random(0, 360)
    local gPower = math.random(generator.powerMin, generator.powerMax)
    local num = math.random(generator.minNumBlobs, generator.maxNumBlobs)
    local hue = math.random(GAMEMODE.HueMin, GAMEMODE.HueMax)
    local curPos = Vector(math.random(-352, 352), math.random(-352, 352), 32 * math.random())

    for i = 1, num do
        -- Calculate the new position
        local pAdd = (Angle(0, gAngle, 0):Forward() * gPower) + Vector(0, 0, (height / num) + 16 * math.random() - 8)
        curPos = curPos + pAdd

        -- Ensure that the new position is within the bounds of the map
        if not curPos:WithinAABox(mins, maxs) then
            curPos.x = math.Clamp(curPos.x, mins.x, maxs.x)
            curPos.y = math.Clamp(curPos.y, mins.y, maxs.y)
            curPos.z = math.Clamp(curPos.z, mins.z, maxs.z)
            gAngle = math.random(0, 360)
        end

        GAMEMODE:SpawnBlob(curPos, hue, generator)
        -- Update generation variables
        gAngle = (gAngle + math.random(-generator.angleIncrement, generator.angleIncrement)) % 360
        gPower = math.Clamp(gPower + math.random(-generator.powerIncrement, generator.powerIncrement), generator.powerMin, generator.powerMax)
    end
end

function GM:GenerateLevel()
    game.CleanUpMap()
    local seed = os.time()
    math.randomseed(seed)
    -- Bounds of the generation
    local mins = Vector(-736, -736, 160)
    local maxs = Vector(736, 736, 3000)
    local height = math.abs(mins.z - maxs.z)
    height = math.random(height - 512, height)
    -- Select a random model set
    local models = block_models

    if math.random() > 0.6 then
        models = table.Random({circle_models, circle_models, triangle_models, poly_models, crate_models})
    end

    local generator = {
        mins = mins,
        maxs = maxs,
        height = height,
        models = models,
        numStrands = math.random(5, 15),
        minNumBlobs = math.random(20, 40),
        maxNumBlobs = math.random(40, 60),
        angleIncrement = 40 + 100 * math.random(),
        powerIncrement = math.random(25, 100),
        powerMin = math.random(50, 150),
        powerMax = math.random(160, 320),
        percentJump = math.random(0.02, 0.15),
    }

    for i = 1, generator.numStrands do
        GAMEMODE:GenerateStrand(generator)
    end

    return height
end