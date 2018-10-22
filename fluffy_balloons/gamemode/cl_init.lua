include('shared.lua')

-- Enable the scoring pane
GM.ScoringPaneEnabled = true

-- Track balloons on the scoring pane
function GM:ScoringPaneScore(ply)
	return ply:GetNWInt("Balloons", 0)
end