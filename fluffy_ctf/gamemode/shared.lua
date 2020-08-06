DeriveGamemode('fluffy_mg_base')

GM.Name = 'Capture The Flag (2F)'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    A classic game of Capture The Flag!
    Take the flag from the enemy's base and bring it back to your base!
    Don't forget to defend your own flag!
]]

GM.TeamBased = true	-- Is the gamemode FFA or Teams?

GM.RoundType = 'timed'
GM.RoundTime = 120
GM.GameTime = 600
GM.HUDStyle = HUD_STYLE_TEAM_SCORE_ROUNDS
GM.RoundCooldown = 3

GM.ThirdpersonEnabled = true

function GM:Initialize()

end