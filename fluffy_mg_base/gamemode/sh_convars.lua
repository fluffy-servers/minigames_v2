--[[
    All convars are created in this file
--]]

-- Shared convars
    CreateConVar("mg_discord_ad", "https://discord.gg/UdMTckn", FCVAR_ARCHIVE + FCVAR_REPLICATED, "The discord url displayed on the motd")

if SERVER then
    -- Server-specific convars

elseif CLIENT then
    -- Client-specific convars
    CreateClientConVar("mg_deathnotice_time", "6", true, false, "Amount of time to show death notice")
    CreateClientConVar("mg_killsound_enabled", 1, true, false, "Enable a sound effect when you get a kill")
    CreateClientConVar("mg_killsound_sound", "hl1/fvox/bell.wav", true, false, "Choose a sound effect for when you get a kill")
    --CreateClientConvar("mg_discord_ad_cl", "")

end