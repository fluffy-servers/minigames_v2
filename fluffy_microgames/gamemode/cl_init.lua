include("shared.lua")

-- Scoring pane can be toggled by the modifier
function GM:ScoringPaneActive()
    return GetGlobalBool("ScoringPaneActive", false)
end

-- Scoring pane uses the generic micro score variable
function GM:ScoringPaneScore(ply)
    return ply:GetMScore()
end