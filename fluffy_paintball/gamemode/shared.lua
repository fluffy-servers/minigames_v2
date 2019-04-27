DeriveGamemode('fluffy_mg_base')

GM.Name = 'Paintball'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Eliminate the other team or get the most kills!
    This is a fast-paced team deathmatch.
    
    Collect the weapons scattered around the map!
    
    When you are knocked out, you will have to rush back to spawn.
    If you are knocked out too many times, you will be eliminated.
]]

GM.TeamBased = true	-- Is the gamemode FFA or Teams?
GM.RoundTime = 150
GM.RoundNumber = 7
GM.Elimination = true
GM.TeamSurvival = false

GM.LifeTimer = 30
GM.CanSuicide = false

function GM:Initialize()

end