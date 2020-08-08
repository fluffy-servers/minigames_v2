DeriveGamemode('fluffy_mg_base')

GM.Name = 'Pitfall'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Try not to fall to your demise!
    Knock out the platforms other players are standing on.
    
    Be the last player alive to win the round!
    
    Primary fire will damage platforms.
    Shoot a platform repeatedly and it will collapse suddenly.
    
    Secondary fire will send players flying.
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.Elimination = true
GM.WinBySurvival = true

GM.RoundNumber = 10      -- How many rounds?
GM.RoundTime = 90      -- Seconds each round lasts for

GM.ThirdpersonEnabled = true

GM.RoundType = 'timed'
GM.GameTime = 500
GM.HUDStyle = HUD_STYLE_CLOCK_TIMER_ALIVE

function GM:Initialize()

end