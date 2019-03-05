include('shared.lua')

GM.ScoringPaneEnabled = true

-- Scoring pane should show the # of balls
function GM:ScoringPaneScore(ply)
	return ply:GetNWInt("Balls", 0)
end