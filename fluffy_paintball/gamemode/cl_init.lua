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