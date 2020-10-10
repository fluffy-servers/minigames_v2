DeriveGamemode("fluffy_mg_base")

GM.Name = "Ballz"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    Collect as many balls as you can!
    
    When you die, you drop all of your balls (plus some extra)
    Collect the balls of dead players and grow
]]

GM.TeamBased = false -- Is the gamemode FFA or Teams?
GM.Elimination = false
GM.WinBySurvival = false
GM.RoundNumber = 5 -- How many rounds?
GM.RoundTime = 90 -- Seconds each round lasts for
GM.ThirdpersonEnabled = true

function GM:Initialize()
end