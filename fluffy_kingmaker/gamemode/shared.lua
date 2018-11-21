DeriveGamemode('fluffy_mg_base')

GM.Name = 'Kingmaker'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Become the King and survive!
    
    Whoever is the King will earn a point for every second they survive.
    Anyone who kills the King will become the King.
    
    The King is defenseless apart from a slight speed & health boost.
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.Elimination = false
GM.WinBySurvival = false

GM.RoundNumber = 8      -- How many rounds?
GM.RoundTime = 90      -- Seconds each round lasts for

GM.ThirdpersonEnabled = true

function GM:Initialize()

end