DeriveGamemode('fluffy_mg_base')
include('ply_extension.lua')

GM.Name = 'Microgames'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Fast paced random rounds!
    
    Go with the flow.
    Help text will appear for each round.
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.RoundTime = 15      -- Seconds each round lasts for
GM.RoundCooldown = 1.5
GM.RoundType = 'timed'
GM.GameTime  = 600
GM.HUDStyle  = 3

function GM:Initialize()

end