DeriveGamemode('fluffy_mg_base')
GM.Name = 'Dodgeball'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Eliminate the other team with dodgeballs!
]]
GM.TeamBased = true -- Is the gamemode FFA or Teams?
GM.RoundType = 'timed'
GM.RoundTime = 60
GM.GameTime = 600
GM.HUDStyle = HUD_STYLE_TEAM_SCORE_ROUNDS
GM.Elimination = true
GM.WinBySurvival = true
GM.DeathSounds = true
GM.SpawnProtection = true -- Spawn protection enabled

function GM:Initialize()
end