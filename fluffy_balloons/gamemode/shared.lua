DeriveGamemode('fluffy_mg_base')

GM.Name = 'Balloons'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Shoot the balloons and earn points!
    
    Regular balloons:   1 point
    Heart balloons:     5 points
    Star balloons:      10 points
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.RoundNumber = 7      -- How many rounds?
GM.RoundTime = 60      -- Seconds each round lasts for

function GM:Initialize()

end