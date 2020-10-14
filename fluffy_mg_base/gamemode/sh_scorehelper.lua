--[[
    A small handful of score-related utility functions
--]]

-- Return a table of {player, score} pairs, sorted by highest score
-- Can specify an optional scoring function, defaults to frags
function GM:GetSortedScores(func)
    if not func then
        func = function(ply) return ply:Frags() end
    end

    -- Build the table to sort
    local tbl = {}

    for k, v in pairs(player.GetAll()) do
        table.insert(tbl, {v, func(v)})
    end

    local sorter = function(a, b) return a[2] > b[2] end
    table.sort(tbl, sorter)

    return tbl
end

-- Return the best n players in the game (or all players if limit is reached)
-- Can specify an optional scoring function, defaults to frags
function GM:GetTopPlayers(num, func)
    local scores = GAMEMODE:GetSortedScores(func)
    -- Return the best n players (or all players if a limit is reached)
    local tbl = {}

    for i = 1, num do
        if i > #scores then break end
        table.insert(tbl, scores[i][1])
    end

    return tbl
end