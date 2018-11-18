DeriveGamemode('fluffy_mg_base')

include('balls.lua')

GM.Name = 'Dodgeball'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Team based deathmatch with dodgeballs!
    
    Every kill will level up your weapon.
    Dying will reset your level.
]]

GM.TeamBased = true	-- Is the gamemode FFA or Teams?
GM.RoundTime = 90
GM.RoundNumber = 5

GM.DeathSounds = true

function GM:Initialize()

end