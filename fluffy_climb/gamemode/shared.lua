DeriveGamemode('fluffy_mg_base')

GM.Name = 'Climb!'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Race to the top in this fast-paced climbing gamemode!
    
    Platforms are randomly generated. Be careful not to fall!
    Bright green platforms will launch you into the air.
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.Elimination = true
GM.WinBySurvival = true

GM.RoundNumber = 15      -- How many rounds?
GM.RoundTime = 90      -- Seconds each round lasts for

GM.RoundType = 'timed'
GM.GameTime = 500
GM.HUDStyle = HUD_STYLE_CLOCK_TIMER_ALIVE

GM.ThirdpersonEnabled = true
GM.DeathSounds = true

function GM:Initialize()

end

function GM:GetLavaHeight()
    local t = CurTime() - GetGlobalFloat('RoundStart', 0) - 10
    if t < 0 then return 96 end
    
    return 96 + t*28
end