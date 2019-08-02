DeriveGamemode('fluffy_mg_base')

GM.Name = 'Crate Wars'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Break crates to power up during the final battle!
    
    During the first phase of each round, break all the crates!
    Each crate will give you extra health and a chance of rare weapons
    
    About halfway through the round, the battle will begin!
    The last player standing will win the round
]]

GM.Elimination = true
GM.WinBySurvival = true

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.RoundNumber = 7      -- How many rounds?
GM.RoundTime = 100      -- Seconds each round lasts for

function GM:Initialize()

end