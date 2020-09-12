local block_options = {
    'circle',
    'square',
}

-- Spawn a platform at a given position
function GM:SpawnPlatform(pos, addspawn, model)
	-- Create the platform entity
	local prop = ents.Create("pf_platform")
	if not IsValid(prop) then return end
	prop:SetAngles(Angle(0, 0, 0))
	prop:SetPos(pos)
	prop:Spawn()
	prop:Activate()
    prop:ApplyModel(model)
    
	--- Add a spawn if required
    local spawn
    if addspawn then
        spawn = ents.Create("info_player_start")
        if not IsValid(spawn) then return end
	end
    
	-- Make sure the platform origin is perfect
	local center = prop:GetCenter()
    if addspawn then
        spawn:SetPos(center + Vector(0, 0, 24))
        spawn.spawnUsed = false
    end
end

local function GenerateSquareLayer(basepos, model, level, size)
    local rows, cols, psize = unpack(size)
    local pos = Vector(basepos)

    for row = 1, rows do
        for col = 1, cols do
            GAMEMODE:SpawnPlatform(pos, (level == 1), model)
            pos.y = pos.y + psize
        end
        pos.x = pos.x + psize
        pos.y = basepos.y
    end
end

local function GenerateHexagonLayer(basepos, _, level, size)
    local rows, cols, psize = unpack(size)
    local pos = Vector(basepos)

    -- Scale up both rows and cols since it's so tightly packed
    rows = math.ceil(rows * 1.5)
    cols = math.ceil(cols * 1.25)

    -- Hexagon sizes
    local w = psize * 0.75
    local h = math.sqrt(3) * psize/2

    for row = 1, rows do
        for col = 1, math.ceil(cols/2) do
            GAMEMODE:SpawnPlatform(pos, (level == 1), 'hexagon')
            pos.y = pos.y + w*2
        end

        -- Offset odd numbered rows
        pos.y = basepos.y + (row%2)*w
        pos.x = pos.x + h/2
    end
end

local function GenerateDiscLayer(basepos, model, level, size)
    local rows, cols, psize = unpack(size)
    rows = rows - 2
    if rows > 4 then
        rows = 4
    end

    local inner = math.random(0, 192)
    for row = 1, rows do
        -- Calculate the size of this ring
        local radius = (inner + psize * row)
        local segs = math.ceil((6.28 * radius)/psize)
        local offset = math.rad(360/segs)

        -- Add each segment of the ring
        for seg = 1, segs do
            local ang = seg * offset
            local xx = radius * math.cos(ang)
            local yy = radius * math.sin(ang)
            local p = Vector(xx, yy, basepos.z)
            GAMEMODE:SpawnPlatform(p, (level == 1), 'circle')
        end
    end
end

function GM:GetScalingInfo()
    -- Calculate some scaling figures
    local scale = math.min(math.ceil(player.GetCount() / 3), 4)
    local mins = 3
    local maxs = 6
    local rows = math.random(mins + scale, maxs + scale)
    local columns = math.random(mins + scale, maxs + scale)
    local levels = math.random(1, 3 + math.floor(scale/1.5))

    -- Sanity check to make sure we have enough space for everyone
    while (rows*columns) < player.GetCount() or (rows*rows) < player.GetCount() do
        rows = rows + 1
    end

    return rows, columns, levels
end

function GM:ApproximateCentre(basepos, psize, rows, cols)
    if not cols then cols = rows end
    local px = basepos.x - (psize * rows)/2
    local py = basepos.y - (psize * cols)/2
    local pz = basepos.z
    return px, py, pz
end

function GM:GenerateStacked(basepos, layerfunc)
    local rows, columns, levels = GAMEMODE:GetScalingInfo()
    local model = table.Random(block_options)
    local psize = 96
    local px, py, pz = GAMEMODE:ApproximateCentre(basepos, psize, rows, columns)

    -- Generate simple layers
    for level = 1, levels do
        layerfunc(Vector(px, py, pz), model, level, {rows, columns, psize})
        pz = pz - 150
    end
end

function GM:GenerateDecreasingPyramid(basepos, layerfunc)
    local rows, columns, levels = GAMEMODE:GetScalingInfo()
    local model = table.Random(block_options)
    local psize = 96
    local px, py, pz = GAMEMODE:ApproximateCentre(basepos, psize, rows, columns)

    -- Generate layers decreasing in size
    local level = 1
    while rows > 2 and columns > 2 do
        layerfunc(Vector(px, py, pz), model, level, {rows, columns, psize})
        pz = pz - 150

        rows = rows - 1
        columns = columns - 1
        level = 0
        px, py = GAMEMODE:ApproximateCentre(basepos, psize, rows, columns)
    end
end

function GM:GenerateIncreasingPyramid(basepos, layerfunc)
    -- Adjust some sizing stuff
    local rows, columns, levels = GAMEMODE:GetScalingInfo()
    rows = rows - math.random(1, 2)
    columns = columns - math.random(1, 2)
    while (rows * columns) < player.GetCount() do
        rows = rows + 1
    end

    local model = table.Random(block_options)
    local psize = 96
    local px, py, pz = GAMEMODE:ApproximateCentre(basepos, psize, rows, columns)

    -- Ensure we have at least three levels
    if levels <= 3 then
        levels = 3
    end

    -- Generate layers increasing in size
    for level = 1, levels do
        layerfunc(Vector(px, py, pz), model, level, {rows, columns, psize})
        pz = pz - 150

        rows = rows + math.random(1, 3)
        columns = columns + math.random(1, 3)
        px, py = GAMEMODE:ApproximateCentre(basepos, psize, rows, columns)
    end
end

-- Generate a level, picking a random generator system
function GM:GenerateLevel(basepos)
    local func = GenerateDiscLayer
    GAMEMODE:GenerateDecreasingPyramid(basepos, func)
end