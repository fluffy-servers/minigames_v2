DeriveGamemode("fluffy_mg_base")

GM.Name = "Bomb Tag"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    Try not to die in a firey explosion!
    
    One random player starts with a bomb.
    After a few seconds, it will explode - killing anyone nearby.
    A new player is selected to have the bomb. The cycle repeats.
    
    If you have the bomb, click to pass it to another player.
    If you don't, use your gun to knock players backwards.
]]

GM.TeamBased = false -- Is the gamemode FFA or Teams?
GM.Elimination = true
GM.WinBySurvival = true
GM.RoundNumber = 10 -- How many rounds?
GM.RoundTime = 120 -- Seconds each round lasts for
GM.ThirdpersonEnabled = true
GM.CanSuicide = false
GM.HUDStyle = HUD_STYLE_CLOCK_ALIVE