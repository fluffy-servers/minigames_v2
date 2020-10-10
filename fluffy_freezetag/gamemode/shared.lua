DeriveGamemode("fluffy_mg_base")
GM.Name = "Freeze Tag"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    pending
]]
GM.TeamBased = true -- Is the gamemode FFA or Teams?
GM.Elimination = true -- Is this gamemode elimination?
GM.RoundTime = 90 -- How long each round should last, in seconds
GM.RoundNumber = 10 -- How many rounds are in each game?

function GM:Initialize()
end

local meta = FindMetaTable("Player")

function meta:IsIceFrozen()
    return self:GetNWBool("Frozen", false)
end