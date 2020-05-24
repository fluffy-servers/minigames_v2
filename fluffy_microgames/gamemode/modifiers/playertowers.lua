MOD.Name = 'Player Towers'
MOD.RoundTime = 15
MOD.Countdown = true

MOD.SurviveValue = 1

function MOD:Initialize()
    GAMEMODE:Announce("Towers", "Make the tallest human tower!")
end

function MOD:Loadout(ply)
    ply:SetJumpPower(300)
    ply:SetRunSpeed(375)
    ply:SetWalkSpeed(300)
end

function MOD:Cleanup()
    -- Make a table which has who is on top of who
    local tower = {}
    for k,v in pairs(player.GetAll()) do
        v:Freeze(true)

        local ground = v:GetGroundEntity()
        if IsValid(ground) and ground:IsPlayer() then
            if tower[ground] then
                table.insert(tower[ground], v)
            else
                tower[ground] = {v}
            end
        end
    end

    -- Find the tallest players in the map
    local tallest = -10000
    local player_list = {}
    for k,v in pairs(player.GetAll()) do
        -- Check that the tallest player is on top of someone else
        local ground = v:GetGroundEntity()
        if not IsValid(ground) or not ground:IsPlayer() then
            continue
        end

        local z = v:EyePos().z
        if z > tallest then
            tallest = z
            player_list = {v}
        elseif z == tallest or (z < tallest and z >= (tallest - 2)) then
            table.insert(player_list, v)
        end
    end

    if #player_list < 1 then
        -- Everybody sucks, kill them all
        for k,v in pairs(player.GetAll()) do
            v:Kill()
        end
    end

    -- Find everyone in the tower
    local i = 1
    while i <= #player_list do
        -- Get any players below or above this player
        local ply = player_list[i]
        local below = ply:GetGroundEntity()
        local goals = {}
        if below:IsPlayer() then
            table.insert(goals, below)
        end
        table.Add(goals, tower[ply] or {})

        -- If they're not currently in the player list, put them in
        for k,v in pairs(goals) do
            if not table.HasValue(player_list, v) then
                table.insert(player_list, v)
            end
        end

        i = i + 1
    end

    -- We've finally computed the tower group
    -- Kill anyone not part of this tower
    for k,v in pairs(player.GetAll()) do
        v:Freeze(false)

        if not v:Alive() then continue end
        if not table.HasValue(player_list, v) then
            v:Kill()
        end

        -- Respawn everyone to prevent stucks
        timer.Simple(1.5, function()
            v:Spawn()
        end)
    end
end