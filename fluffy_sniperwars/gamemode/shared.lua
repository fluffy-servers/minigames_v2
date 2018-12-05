DeriveGamemode('fluffy_mg_base')

GM.Name = 'Sniper Wars'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    It's Sniper vs Sniper in this intense team battle!
    
    The team with the most kills when time runs out is the winner.
    
    Each player has a dangerous Utility Device.
    These devices will give one of the following buffs:
     - Invisibility
     - Teleportation
     - Speed Boost
     - Low Gravity
]]

GM.TeamBased = true	-- Is the gamemode FFA or Teams?
GM.RoundTime = 200
GM.RoundNumber = 3

GM.RoundType = 'timed_endless'
GM.GameTime = 300

GM.MaxProps = 10

function GM:Initialize()

end