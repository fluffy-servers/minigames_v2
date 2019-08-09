DeriveGamemode('fluffy_mg_base')

GM.Name = 'Capture The Flag'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    A classic game of Capture The Flag!
    Collect the flag from the middle and bring it to the enemy's goal
    Be careful! Don't forget to defend your own goal!
]]

GM.TeamBased = true	-- Is the gamemode FFA or Teams?

GM.RoundType = 'timed'
GM.RoundTime = 120
GM.GameTime = 600
GM.HUDStyle = 4
GM.RoundCooldown = 3

GM.ThirdpersonEnabled = true

function GM:Initialize()

end