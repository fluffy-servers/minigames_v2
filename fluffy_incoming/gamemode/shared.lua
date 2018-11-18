DeriveGamemode('fluffy_mg_base')

GM.Name = 'Incoming!'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Race to the top of the slope!
    Avoid all the falling props!
    
    First person to reach the top wins.
    Points are given based on distance travelled.
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.Elimination = false

GM.RoundNumber = 10      -- How many rounds?
GM.RoundTime = 90      -- Seconds each round lasts for

GM.ThirdpersonEnabled = true
GM.DeathSounds = true

function GM:Initialize()

end