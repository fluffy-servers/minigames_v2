include('shared.lua')

GM.ScoringPaneEnabled = true

-- Scoring pane should show the # of balls
function GM:ScoringPaneScore(ply)
	return ply:GetNWInt("Balls", 0)
end

-- Add halo around the leading player
hook.Add('PreDrawHalos', 'DrawBallsHalo', function()
	if not GAMEMODE:InRound() then return end
	if not GAMEMODE.ScorePane then return end
	if not GAMEMODE.ScorePane.scores then return end

	local winner = GAMEMODE.ScorePane.scores[1][1]
    local pcolor = winner:GetPlayerColor()
    local color = Color(pcolor[1]*255, pcolor[2]*255, pcolor[3]*255)
    halo.Add({winner}, color, 2, 2, 2, true, true)
end)