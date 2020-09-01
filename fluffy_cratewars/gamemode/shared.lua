DeriveGamemode('fluffy_mg_base')

GM.Name = 'Crate Wars 2'

GM.HelpText = [[
        Description pending
    ]]

GM.Author = 'FluffyXVI'

GM.TeamBased = true	    -- Is the gamemode FFA or Teams?
GM.RoundNumber = 6      -- How many rounds?
GM.RoundTime = 100      -- Seconds each round lasts for

GM.HUDStyle = function()
    if GetGlobalBool('CW_Asymmetric', false) then
        return HUD_STYLE_CLOCK_TEAM_SCORE_SINGLE
    else
        return HUD_STYLE_CLOCK_TEAM_SCORE
    end
end

function GM:Initialize()

end