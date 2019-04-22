include('shared.lua')

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

hook.Add('RenderScreenspaceEffects', 'GhostEffects', function()
    if LocalPlayer():GetNWBool('IsGhost', false) then
        local maxtime = LocalPlayer():GetNWFloat('GhostTime')
        local starttime = LocalPlayer():GetNWFloat('GhostStart')
        local p = math.Clamp((CurTime() - starttime) / maxtime, 0, 1)
        
        --print(p)
        tab['$pp_colour_brightness'] = -0.15 * p
        tab['$pp_colour_colour'] = 0.15 - 0.15*p
        DrawColorModify(tab)
    end
end)