--[[
    Stats tracking library
    Useful for tracking kills, round wins, damage dealt, etc.
    Ties in with sv_levels.lua to convert these stats to XP at the end of the game
    Use this wherever possible! Stats are always fun to have!
--]]

GM.StatsTracking = {}

-- Prepare some prepared queries to make database stuff faster and more secure
hook.Add("InitPostEntity", "PrepareStatsStuff", function()
    local db = GAMEMODE:CheckDBConnection()
    if not db then return end
    GAMEMODE.MinigamesPQueries["getstats"] = db:prepare("SELECT category, points FROM stats_minigames_new WHERE `steamid64` = ? AND `gamemode` = ?;")
    GAMEMODE.MinigamesPQueries["addnewstats"] = db:prepare("INSERT INTO stats_minigames VALUES(?, ?, \"{}\");")
    GAMEMODE.MinigamesPQueries["updatestats"] = db:prepare("INSERT INTO stats_minigames_new VALUES(?, ?, ?, ?) ON DUPLICATE KEY UPDATE points = VALUES(points);")
end)

-- Add some points to a given statistic
function GM:AddStatPoints(ply, stat, amount)
    -- Create player index if not there
    if not GAMEMODE.StatsTracking[ply] then
        GAMEMODE.StatsTracking[ply] = {}
    end

    -- Get current value of stat
    local current = 0

    if GAMEMODE.StatsTracking[ply][stat] then
        current = GAMEMODE.StatsTracking[ply][stat]
    end

    -- Add the stat points
    GAMEMODE.StatsTracking[ply][stat] = current + amount
    -- Return new value

    return current + amount
end

-- Get a players statistic
function GM:GetStat(ply, stat)
    if not GAMEMODE.StatsTracking[ply] then return end
    if not GAMEMODE.StatsTracking[ply][stat] then return end

    return GAMEMODE.StatsTracking[ply][stat]
end

-- Return the players statistic table
function GM:GetPlayerStatTable(ply)
    if GAMEMODE.StatsTracking[ply] then
        return GAMEMODE.StatsTracking[ply]
    else
        return {}
    end
end

-- Get the player with the highest score in a certain stat
function GM:GetStatWinner(stat)
    local highest_score = 0
    local winning_player = nil

    for k, v in pairs(GAMEMODE.StatsTracking) do
        if not v[stat] then continue end

        if v[stat] > highest_score then
            highest_score = v[stat]
            winning_player = k
        end
    end

    return {winning_player, highest_score}
end

-- Generate a table of scores for each stat
function GM:GenerateStatisticsTable()
    if not GAMEMODE.StatConversions then return end
    -- Iterate over all the stat types to generate the table
    local tbl = {}

    for stat, _ in pairs(GAMEMODE.StatConversions) do
        if stat == "Deaths" or stat == "Rounds Played" then continue end
        if GAMEMODE.TeamBased and stat == "Rounds Won" then continue end
        local passed = false
        local stat_tbl = {}

        -- Get the results for each player
        for k, v in pairs(player.GetAll()) do
            local value = v:GetStat(stat) or 0

            table.insert(stat_tbl, {v, value})

            if value > 0 then
                passed = true
            end
        end

        -- Sort & store if there is at least one non-zero value
        if passed then
            table.sort(stat_tbl, function(a, b) return a[2] > b[2] end)
            tbl[stat] = stat_tbl
        end
    end

    return tbl
end

-- Meta functions for player stats
-- Call the corresponding functions above - see those for more information
local meta = FindMetaTable("Player")

function meta:GetStat(stat)
    return GAMEMODE:GetStat(self, stat)
end

function meta:GetStatTable()
    return GAMEMODE:GetPlayerStatTable(self)
end

function meta:AddStatPoints(stat, amount)
    return GAMEMODE:AddStatPoints(self, stat, amount)
end

function meta:LoadStatsFromDB()
    if not self:SteamID64() or self:IsBot() then return end
    local ply = self
    local db = GAMEMODE:CheckDBConnection()
    if not db then return end
    -- Prepare the query
    local q = GAMEMODE.MinigamesPQueries["getstats"]
    if not q then return end
    q:setString(1, self:SteamID64())
    q:setString(2, string.Replace(GAMEMODE_NAME, "fluffy_", ""))

    -- Success function
    function q:onSuccess(data)
        if type(data) == "table" and #data > 0 then
            -- Load information from DB
            ply.GamemodeDBStatsTable = {}

            for key, value in pairs(data) do
                local category = data[key]["category"]
                local points = data[key]["points"]
                ply.GamemodeDBStatsTable[category] = points
            end
        else
            ply.GamemodeDBStatsTable = {}
        end
    end

    q:start()
end

function meta:UpdateStatsToDB()
    if not self:SteamID64() or self:IsBot() then return end
    local ply = self
    local db = GAMEMODE:CheckDBConnection()
    if not db then return end
    -- Copy the current gamemode stats table
    -- Then add any new data to the table
    if not ply.GamemodeDBStatsTable then return end
    local new_table = table.Copy(ply.GamemodeDBStatsTable)

    for k, v in pairs(self:GetStatTable()) do
        if not new_table[k] then
            new_table[k] = v
        else
            new_table[k] = new_table[k] + v
        end
    end

    -- Prepare the query
    for k, v in pairs(new_table) do
        local q = GAMEMODE.MinigamesPQueries["updatestats"]
        if not q then return end
        q:setString(1, self:SteamID64())
        q:setString(2, string.Replace(GAMEMODE_NAME, "fluffy_", ""))
        q:setString(3, k)
        q:setNumber(4, v)
        q:start()
    end
end