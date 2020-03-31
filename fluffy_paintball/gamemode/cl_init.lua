include('shared.lua')

-- Simple colour correction table
local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0.1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

-- Ghost visual effects
hook.Add('RenderScreenspaceEffects', 'GhostEffects', function()
    if not LocalPlayer():GetNWBool('IsGhost', false) then return end
    
    -- Calculate the % of time left
    local maxtime = LocalPlayer():GetNWFloat('GhostTime')
    local starttime = LocalPlayer():GetNWFloat('GhostStart')
    local timeleft = maxtime - (CurTime() - starttime)
    local p = 1 - math.Clamp(timeleft/GAMEMODE.LifeTimer, 0, 1)
    
    -- Adjust the colour based on time left
    tab['$pp_colour_brightness'] = -0.15 * p
    tab['$pp_colour_colour'] = 0.15 - 0.15*p
    DrawColorModify(tab)
end)

-- Display the message when the player is a ghost
hook.Add('HUDPaint', 'GhostMessage', function()
    if not LocalPlayer():Alive() or LocalPlayer().Spectating then return end
    if not LocalPlayer():GetNWBool('IsGhost', false) then return end
    draw.SimpleText('Go back to your spawn!', "FS_40", ScrW()/2+1, ScrH() - 72+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP) -- shadow
	draw.SimpleText('Go back to your spawn!', "FS_40", ScrW()/2, ScrH() - 72, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    
    -- Draw the time remaining
    local maxtime = LocalPlayer():GetNWFloat('GhostTime')
    local starttime = LocalPlayer():GetNWFloat('GhostStart')
    local tinfo = string.FormattedTime(maxtime - (CurTime() - starttime))
    local timeleft = string.format('%02i:%02i', tinfo.s, tinfo.ms)
    draw.SimpleText(timeleft, "FS_32", ScrW()/2, ScrH() - 32+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP) -- shadow
    draw.SimpleText(timeleft, "FS_32", ScrW()/2, ScrH() - 32, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end)

-- Draw the state of the round, including time and round number etc.
-- This is in the top left corner
-- Override in Paintball for our own super duper custom one
function GM:DrawRoundState()
    local GAME_STATE = GAMEMODE:GetRoundState()
    -- Only draw this if the game hasn't yet started
    if GAME_STATE == 'GameNotStarted' then
        draw.SimpleText('Waiting For Players...', "FS_40", 4+1, 4+2, GAMEMODE.FColShadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) -- shadow
		draw.SimpleText('Waiting For Players...', "FS_40", 4, 4, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        return
    end
    
    -- Draw spectating message on bottom (very rare)
    if LocalPlayer():Team() == TEAM_SPECTATOR then
        draw.SimpleText('You are spectating', "FS_40", ScrW()/2+1, ScrH() - 32+2, GAMEMODE.FColShadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) -- shadow
		draw.SimpleText('You are spectating', "FS_40", ScrW()/2, ScrH() - 32, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    local RoundTime = GetGlobalFloat('RoundStart')
    
    -- Fancy formatting for the time
    local tmax = GAMEMODE.RoundTime or 60
	if GAME_STATE == 'PreRound' then tmax = GAMEMODE.RoundCooldown or 5 end
    
    local time_left = tmax - (CurTime() - RoundTime)
    local round_message = string.FormattedTime(time_left, '%02i:%02i')
    
    -- Draw the box
    local xx = 24
    local yy = 24
    local c_pos = 72
    draw.RoundedBoxEx(8, xx, yy, 128, 32, GAMEMODE.FCol2, true, true, false, false)
    
    -- Draw the time
    if time_left > 0 then
        draw.SimpleText(round_message, "FS_32", xx + 64, yy + 18 + 1, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- shadow
        draw.SimpleText(round_message, "FS_32", xx + 64, yy + 18, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText('Round Over!', "FS_24", xx + 64, yy + 18 + 1, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- shadow
        draw.SimpleText('Round Over!', "FS_24", xx + 64, yy + 18, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    yy = yy + 32
    
    -- Draw the round number box
    draw.RoundedBoxEx(0, xx, yy-1, 128, 24+3, GAMEMODE.FCol3, false, false, true, true)
    draw.RoundedBoxEx(0, xx, yy, 128, 24, GAMEMODE.FCol2, false, false, true, true)
    
    local rmax = GAMEMODE.RoundNumber or 5
    local round = GetGlobalInt('RoundNumber', 0)
    local round_message = "Round " .. round .. " / " .. rmax, "FS_24"
    if round == rmax then round_message = "Final Round!" end
    
    local round = GetGlobalInt('RoundNumber') or 1
    draw.SimpleText(round_message, "FS_24", xx + 64, yy+14, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    yy = yy + 25
    
    -- Draw the team boxes
    local red_col = team.GetColor(TEAM_RED)
    local blue_col = team.GetColor(TEAM_BLUE)
    local red_shadow = Color(red_col.r - 35, red_col.g - 35, red_col.b - 35)
    local blue_shadow = Color(blue_col.r - 35, blue_col.g - 35, blue_col.b - 35)
    local score_h = 46
    draw.RoundedBoxEx(8, xx, yy, 64, score_h+2, red_shadow, false, false, true, false)
    draw.RoundedBoxEx(8, xx, yy, 64, score_h, red_col, false, false, true, false)
    draw.RoundedBoxEx(8, xx+64, yy, 64, score_h+2, blue_shadow, false, false, false, true)
    draw.RoundedBoxEx(8, xx+64, yy, 64, score_h, blue_col, false, false, false, true)
    xx = xx + 32
    
    -- Draw the scores for each team
    local red_kills = GetGlobalInt('1TeamKills', 0)
    local blue_kills = GetGlobalInt('2TeamKills', 0)
    draw.SimpleText(red_kills, "FS_32",  xx, yy + 16 + 1, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- shadow
    draw.SimpleText(red_kills, "FS_32",  xx, yy + 16, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(blue_kills, "FS_32", xx+64, yy + 16 + 1, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- shadow
    draw.SimpleText(blue_kills, "FS_32", xx+64, yy + 16, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Draw the round wins for each team
    local red_score = team.GetScore(1)
    local blue_score = team.GetScore(2)
    draw.SimpleText(red_score .. ' wins', "FS_16",  xx, yy + 36 + 1, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- shadow
    draw.SimpleText(red_score .. ' wins', "FS_16",  xx, yy + 36, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(blue_score .. ' wins', "FS_16", xx+64, yy + 36 + 1, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- shadow
    draw.SimpleText(blue_score .. ' wins', "FS_16", xx+64, yy + 36, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end