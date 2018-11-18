DeriveGamemode('fluffy_mg_base')

GM.Name = 'Kingmaker'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Become the King and defeat everyone!
    
    As the King, you are more powerful than everyone else
    Get kills as the King to earn points
    
    If you're not the King, work together to defeat the King!
    You can kill anyone - but there's no points for it.
    Only kills you make while you are the King will give you points.
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.Elimination = false
GM.WinBySurvival = false

GM.RoundNumber = 8      -- How many rounds?
GM.RoundTime = 90      -- Seconds each round lasts for

GM.ThirdpersonEnabled = true

function GM:Initialize()

end