DeriveGamemode("fluffy_mg_base")
GM.Name = "Super Shotguns"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    Super Shotguns to the death in this intense deathmatch!
    
    The team with the most kills when time runs out is the winner.
]]
GM.TeamBased = true -- Is the gamemode FFA or Teams?
GM.RoundTime = 200
GM.RoundNumber = 3
GM.RoundType = "timed_endless"
GM.EndOnTimeOut = true
GM.GameTime = 500
GM.HUDStyle = HUD_STYLE_TEAM_SCORE
GM.RespawnTime = 1
GM.AutoRespawn = true
GM.SpawnProtection = true -- Spawn protection enabled

function GM:Initialize()
end