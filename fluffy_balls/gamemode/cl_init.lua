include('shared.lua')

GM.ScoringPaneEnabled = true

function GM:ScoringPaneScore(ply)
	return ply:GetNWInt("Balls", 0)
end