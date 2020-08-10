-- HUD enums so the numbers make actual sense
HUD_STYLE_DEFAULT = 1                   -- Simple clock with round counter attached
HUD_STYLE_TIMER = 2                     -- Simple clock with game timer attached
HUD_STYLE_TIMER_ONLY = 3                -- Large timer instead of clock
HUD_STYLE_TEAM_SCORE = 4                -- Large timer, with team scores underneath
HUD_STYLE_TEAM_SCORE_ROUNDS = 5         -- Large timer, with team round wins underneath
HUD_STYLE_TEAM_SCORE_SINGLE = 6         -- Large timer, with single team score underneath
HUD_STYLE_CLOCK_TEAM_SCORE = 7          -- Simple clock, with team scores underneath
HUD_STYLE_CLOCK_TEAM_SCORE_ROUNDS = 8   -- Simple clock, with team round wins underneath
HUD_STYLE_CLOCK_TEAM_SCORE_SINGLE = 9   -- Simple clock, with single team score underneath
HUD_STYLE_CLOCK_ALIVE = 10              -- Simple clock, with number of alive players underneath
HUD_STYLE_CLOCK_TIMER_ALIVE = 11        -- Simple clock, with game timer attached + number of alive players underneath

-- These should match cl_hud
local c_pos = 72
local seg = 36
local radius = 48
local round_circle = draw.CirclePoly(c_pos, c_pos, radius, seg)
local round_circle_shadow = draw.CirclePoly(c_pos+3, c_pos+3, radius, seg)
local TIME_ICON = Material("fluffy/time.png", "noclamp smooth")

-- COMPONENTS
function GM:GetRoundTimeRemaining()
    local RoundTime = GetGlobalFloat('RoundStart')
    if !RoundTime then return end
    local RoundMax = GAMEMODE.RoundTime or 60
    if GAMEMODE:GetRoundState() == 'PreRound' then
        RoundMax = GAMEMODE.RoundCooldown or 5
    end
    return math.max(RoundMax - (CurTime() - RoundTime), 0), RoundMax
end

function GM:GetGameTimeRemaining()
    local GameTime = GetGlobalFloat('GameStartTime')
    if !GameTime then return end
    return (GameTime + GAMEMODE.GameTime) - CurTime()
end

function GM:GetGameTimeRemainingFormatted()
    local time_left = GAMEMODE:GetGameTimeRemaining()
    if time_left > 0 then
        return string.FormattedTime(time_left, '%02i:%02i')
    else
        return "Overtime!"
    end
end

function GM:GetTimeRemaining()
    if GAMEMODE.RoundType == 'timed' or GAMEMODE.RoundType == 'timed_endless' then
        return GAMEMODE:GetGameTimeRemaining()
    else
        return GAMEMODE:GetRoundTimeRemaining()
    end
end

function GM:GetRoundInfo()
    local round = GAMEMODE:GetRoundNumber()
	local rmax = GAMEMODE.RoundNumber or 5

    local round_message = "Round " .. round .. " / " .. rmax, "FS_24"
    if round == rmax then round_message = "Final Round!" end
    return round_message
end

-- Clock component
-- Used in styles 1, 2, 7, and 8
function GM:DrawClock(text)
    -- Draw the circle shadow
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.DrawPoly(round_circle_shadow)

    if text then
        -- Calculate the size of the text to adapt the box
        surface.SetFont('FS_24')
        local w = surface.GetTextSize(text)
    
        -- Draw the box with sizing information determined above
        local rect_height = 32
        local rect_width = w + 80
        surface.SetDrawColor(GAMEMODE.HColDark)
        surface.DrawRect(c_pos, c_pos - rect_height/2, rect_width, rect_height + 3)
        surface.SetDrawColor(GAMEMODE.HColLight)
        surface.DrawRect(c_pos, c_pos - rect_height/2, rect_width, rect_height)

        GAMEMODE:DrawShadowText(text, 'FS_24', c_pos+52, c_pos+2, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Draw the top layer of the circle
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.HColLight)
    surface.DrawPoly(round_circle)

    -- Calculate time remaining
	local t, tmax = GAMEMODE:GetRoundTimeRemaining()
    
    -- Draw background icon
    local icon_size = 40
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.SetMaterial(TIME_ICON)
    surface.DrawTexturedRect(c_pos - (icon_size/2), c_pos - (icon_size/2), icon_size, icon_size)
    
    -- Draw the arc (if applicable)
    if !GAMEMODE.FastHUDConvar:GetBool() and t != 0 and tmax > 0 then
        draw.NoTexture()
        draw.Arc(c_pos, c_pos, 42, 10, math.Round((t/tmax * -360) + 90), 90, 8, GAMEMODE.FCol1)
    end
    
    -- Draw the time text
    GAMEMODE:DrawShadowText(math.ceil(t), 'FS_40', c_pos, c_pos, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Timer block component
-- Used in styles 3, 4, 5, 6
function GM:DrawTimer()
    draw.RoundedBox(8, c_pos-48, c_pos-48, 128, 48+3, GAMEMODE.HColDark)
    draw.RoundedBox(8, c_pos-48, c_pos-48, 128, 48, GAMEMODE.HColLight)
    GAMEMODE:DrawShadowText(GAMEMODE:GetGameTimeRemainingFormatted(), 'FS_32', c_pos+16, c_pos-22, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function GM:DrawTeamScores(func)
    -- Draw divider
    surface.SetDrawColor(color_white)
    surface.DrawRect(c_pos - 48, c_pos - 2, 128, 2)

    -- Draw team boxes
    local red_col = team.GetColor(TEAM_RED)
    local blue_col = team.GetColor(TEAM_BLUE)
    local red_shadow = Color(red_col.r - 35, red_col.g - 35, red_col.b - 35)
    local blue_shadow = Color(blue_col.r - 35, blue_col.g - 35, blue_col.b - 35)
    local score_h = 36

    draw.RoundedBoxEx(8, c_pos-48, c_pos, 64, score_h+2, red_shadow, false, false, true, false)
    draw.RoundedBoxEx(8, c_pos-48, c_pos, 64, score_h, red_col, false, false, true, false)
    draw.RoundedBoxEx(8, c_pos+16, c_pos, 64, score_h+2, blue_shadow, false, false, false, true)
    draw.RoundedBoxEx(8, c_pos+16, c_pos, 64, score_h, blue_col, false, false, false, true)

    GAMEMODE:DrawShadowText(func(TEAM_RED), 'FS_40', c_pos-16, c_pos + score_h/2 + 2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    GAMEMODE:DrawShadowText(func(TEAM_BLUE), 'FS_40', c_pos+48, c_pos + score_h/2 + 2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function GM:DrawTeamClockScores(func)
    local red_col = team.GetColor(TEAM_RED)
    local blue_col = team.GetColor(TEAM_BLUE)
    local red_shadow = Color(red_col.r - 35, red_col.g - 35, red_col.b - 35)
    local blue_shadow = Color(blue_col.r - 35, blue_col.g - 35, blue_col.b - 35)
    local score_h = 36

    draw.RoundedBoxEx(8, c_pos-radius, c_pos + 56, radius, score_h+2, red_shadow, true, false, true, false)
    draw.RoundedBoxEx(8, c_pos-radius, c_pos + 56, radius, score_h, red_col, true, false, true, false)
    draw.RoundedBoxEx(8, c_pos, c_pos + 56, radius, score_h+2, blue_shadow, false, true, false, true)
    draw.RoundedBoxEx(8, c_pos, c_pos + 56, radius, score_h, blue_col, false, true, false, true)

    GAMEMODE:DrawShadowText(func(TEAM_RED), 'FS_32', c_pos - 24, c_pos + score_h/2 + 58, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    GAMEMODE:DrawShadowText(func(TEAM_BLUE), 'FS_32', c_pos + 24, c_pos + score_h/2 + 58, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Handler functions for the different HUD styles
GM.HUDStyleFuncs = {}

GM.HUDStyleFuncs[HUD_STYLE_DEFAULT] = function()
    if GAMEMODE:GetRoundState() == 'EndRound' then return end
    GAMEMODE:DrawClock(GAMEMODE:GetRoundInfo())
end

GM.HUDStyleFuncs[HUD_STYLE_TIMER] = function()
    if GAMEMODE:GetRoundState() == 'EndRound' then return end
    if GAMEMODE.RoundType != 'timed' and GAMEMODE.RoundType != 'timed_endless' then return end
    GAMEMODE:DrawClock(GAMEMODE:GetGameTimeRemainingFormatted())
end

GM.HUDStyleFuncs[HUD_STYLE_TIMER_ONLY] = function()
    GAMEMODE:DrawTimer()

    -- Draw the round number (if applicable)
    if GAMEMODE.RoundType == 'timed' then
        draw.RoundedBoxEx(8, c_pos-48, c_pos-3, 128, 32+3, GAMEMODE.HColDark, false, false, true, true)
        draw.RoundedBoxEx(8, c_pos-48, c_pos-2, 128, 32, GAMEMODE.HColLight, false, false, true, true)
        
        local round = GAMEMODE:GetRoundNumber()
        draw.SimpleText('Round ' .. round, "FS_24", c_pos + 16, c_pos + 15, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

GM.HUDStyleFuncs[HUD_STYLE_TEAM_SCORE] = function()
    GAMEMODE:DrawTimer()
    GAMEMODE:DrawTeamScores(team.GetRoundScore)
end

GM.HUDStyleFuncs[HUD_STYLE_TEAM_SCORE_ROUNDS] = function()
    GAMEMODE:DrawTimer()
    GAMEMODE:DrawTeamScores(team.GetScore)
end

GM.HUDStyleFuncs[HUD_STYLE_TEAM_SCORE_SINGLE] = function()
    GAMEMODE:DrawTimer()

    -- Draw divider
    surface.SetDrawColor(color_white)
    surface.DrawRect(c_pos - 48, c_pos - 2, 128, 2)

    -- Draw blue team score underneath
    local blue_col = team.GetColor(TEAM_BLUE)
    local blue_shadow = Color(blue_col.r - 35, blue_col.g - 35, blue_col.b - 35)
    local score_h = 36
    draw.RoundedBoxEx(8, c_pos-48, c_pos, 128, score_h+2, blue_shadow, false, false, true, true)
    draw.RoundedBoxEx(8, c_pos-48, c_pos, 128, score_h, blue_col, false, false, true, true)
    GAMEMODE:DrawShadowText(team.GetRoundScore(TEAM_BLUE), 'FS_40', c_pos, c_pos + score_h/2 + 2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

GM.HUDStyleFuncs[HUD_STYLE_CLOCK_TEAM_SCORE] = function()
    if GAMEMODE:GetRoundState() == 'EndRound' then return end
    GAMEMODE:DrawClock(GAMEMODE:GetRoundInfo())
    GAMEMODE:DrawTeamClockScores(team.GetRoundScore)
end

GM.HUDStyleFuncs[HUD_STYLE_CLOCK_TEAM_SCORE_ROUNDS] = function()
    if GAMEMODE:GetRoundState() == 'EndRound' then return end
    GAMEMODE:DrawClock(GAMEMODE:GetRoundInfo())
    GAMEMODE:DrawTeamClockScores(team.GetScore)
end

GM.HUDStyleFuncs[HUD_STYLE_CLOCK_TEAM_SCORE_SINGLE] = function()
    if GAMEMODE:GetRoundState() == 'EndRound' then return end
    GAMEMODE:DrawClock(GAMEMODE:GetRoundInfo())

    -- Draw blue team score underneath
    local blue_col = team.GetColor(TEAM_BLUE)
    local blue_shadow = Color(blue_col.r - 35, blue_col.g - 35, blue_col.b - 35)
    local score_h = 36
    draw.RoundedBox(8, c_pos-48, c_pos + 56, radius*2, score_h+2, blue_shadow, false, false, false, true)
    draw.RoundedBox(8, c_pos-48, c_pos + 56, radius*2, score_h, blue_col, false, false, false, true)
    GAMEMODE:DrawShadowText(team.GetRoundScore(TEAM_BLUE), 'FS_40', c_pos, c_pos + score_h/2 + 2 + 56, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

GM.HUDStyleFuncs[HUD_STYLE_CLOCK_ALIVE] = function()
    if GAMEMODE:GetRoundState() == 'EndRound' then return end
    GAMEMODE:DrawClock(GAMEMODE:GetRoundInfo())

    local alive
    local blue_col
    if GAMEMODE.TeamBased then
        alive = GAMEMODE:GetTeamLivingPlayers(TEAM_BLUE)
        blue_col = team.GetColor(TEAM_BLUE)
    else
        alive = GAMEMODE:GetNumberAlive(TEAM_UNASSIGNED)
        blue_col = GAMEMODE.HColLight
    end

    -- Draw blue team score underneath
    local blue_shadow = Color(blue_col.r - 35, blue_col.g - 35, blue_col.b - 35)
    local score_h = radius
    
    draw.RoundedBox(8, c_pos-48, c_pos + 56, radius*2, score_h+2, blue_shadow, false, false, false, true)
    draw.RoundedBox(8, c_pos-48, c_pos + 56, radius*2, score_h, blue_col, false, false, false, true)
    GAMEMODE:DrawShadowText(alive, 'FS_32', c_pos, c_pos + score_h + 56 - 14, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    GAMEMODE:DrawShadowText('Alive', 'FS_20', c_pos, c_pos + score_h + 56, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

GM.HUDStyleFuncs[HUD_STYLE_CLOCK_TIMER_ALIVE] = function()
    if GAMEMODE:GetRoundState() == 'EndRound' then return end
    GAMEMODE:DrawClock(GAMEMODE:GetGameTimeRemainingFormatted())

    local alive
    local blue_col
    if GAMEMODE.TeamBased then
        alive = GAMEMODE:GetTeamLivingPlayers(TEAM_BLUE)
        blue_col = team.GetColor(TEAM_BLUE)
    else
        alive = GAMEMODE:GetNumberAlive(TEAM_UNASSIGNED) or 0
        blue_col = GAMEMODE.HColLight
    end

    -- Draw blue team score underneath
    local blue_shadow = Color(blue_col.r - 35, blue_col.g - 35, blue_col.b - 35)
    local score_h = radius
    
    draw.RoundedBox(8, c_pos-48, c_pos + 56, radius*2, score_h+2, blue_shadow, false, false, false, true)
    draw.RoundedBox(8, c_pos-48, c_pos + 56, radius*2, score_h, blue_col, false, false, false, true)
    GAMEMODE:DrawShadowText(alive, 'FS_32', c_pos, c_pos + score_h + 56 - 14, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    GAMEMODE:DrawShadowText('Alive', 'FS_20', c_pos, c_pos + score_h + 56, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

-- Draw the state of the round, including time and round number etc.
-- This is in the top left corner
function GM:DrawRoundState()
    local GAME_STATE = GAMEMODE:GetRoundState()
    -- Draw a notification if not enough players are in the game
    if GAME_STATE == 'GameNotStarted' then
        GAMEMODE:DrawShadowText('Waiting for Players...', 'FS_40', 4,4, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        return
    end

    -- Draw a warmup timer if the game is starting soon
    if GAME_STATE == 'Warmup' then
        local start_time = GetGlobalFloat('WarmupTime', CurTime())
        local t = GAMEMODE.WarmupTime - (CurTime() - start_time)
        GAMEMODE:DrawShadowText('Round starting in ' .. math.ceil(t) .. '...', 'FS_40', 4,4, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        return
    end

    -- Figure out what HUD style to use
    local hudstyle = GAMEMODE.HUDStyle
    if isfunction(hudstyle) then hudstyle = hudstyle() end
    if not hudstyle then hudstyle = HUD_STYLE_DEFAULT end

    -- Pass it off to one of the below functions
    GAMEMODE.HUDStyleFuncs[hudstyle]()
end