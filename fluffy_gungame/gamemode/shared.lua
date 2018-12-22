DeriveGamemode('fluffy_mg_base')

GM.Name = 'Gun Game'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Free for all deathmatch with constantly changing weapons
    Every 2 kills you get a new weapon!
    
    First person to complete every weapon wins the round
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.Elimination = false
GM.WinBySurvival = false

GM.RoundNumber = 3      -- How many rounds?
GM.RoundTime = 240      -- Seconds each round lasts for

GM.ThirdpersonEnabled = true

function GM:Initialize()

end