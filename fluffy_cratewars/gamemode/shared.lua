DeriveGamemode('fluffy_mg_base')

GM.Name = 'Crate Wars'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Break crates to power up during the final battle!
    
    Each round is divided into two phases:
     Crate Breaking
       Break as many crates as you can!
       More crates = more health
       25 Crates = 1 SMG Grenade
        
     Deathmatch
       Eliminate all the other players
]]

GM.Elimination = true
GM.WinBySurvival = true

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.RoundNumber = 7      -- How many rounds?
GM.RoundTime = 100      -- Seconds each round lasts for

function GM:Initialize()

end