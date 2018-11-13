include('shared.lua')

GM.ScoringPaneEnabled = true

function GM:ScoringPaneScore(ply)
	return ply:GetNWInt("KingFrags", 0)
end