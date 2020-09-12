local block_options = {
    'circle',
    'square',
    'hexagon',
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

function GM:GenerateStackedLevel(basepos, layerfunc)
    -- Calculate some scaling figures
    local scale = math.min(math.ceil(player.GetCount() / 3), 4)
    local mins = 3
    local maxs = 6
    local rows = math.random(mins + scale, maxs + scale)
    local columns = math.random(mins + scale, maxs + scale)
    local levels = math.random(1, 3 + math.floor(scale/1.5))

    -- Pick a model for the level
    local model = table.Random(block_options)

    -- Double check to ensure we have enough platforms in the top level
    while (rows*columns) < player.GetCount() do
        rows = rows + 1
    end

    -- Calculate center of the layers
    local psize = 96
    local px = basepos.x - (psize * rows)/2
    local py = basepos.y - (psize * rows)/2
    local pz = basepos.z

    -- Generate layers
    for level = 1, levels do
        layerfunc(Vector(px, py, pz), model, level, {rows, columns, psize})
        pz = pz - 150
    end
end

-- Generate a level, picking a random generator system
function GM:GenerateLevel(basepos)
    local func = GenerateSquareLayer
    GAMEMODE:GenerateStackedLevel(basepos, func)
end