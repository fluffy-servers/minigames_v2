include("shared.lua")

-- Simple colour correction table
local tab = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0.05,
    ["$pp_colour_addb"] = 0.25,
    ["$pp_colour_brightness"] = 0.1,
    ["$pp_colour_contrast"] = 0.8,
    ["$pp_colour_colour"] = 1.25,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0.005,
    ["$pp_colour_mulb"] = 0.02
}

-- Ghost visual effects
hook.Add("RenderScreenspaceEffects", "GhostEffects", function()
    if not LocalPlayer():IsIceFrozen() then return end
    DrawColorModify(tab)
end)

function GM:AdjustMouseSensitivity()
    if LocalPlayer():IsIceFrozen() then
        return 0.15
    else
        return -1
    end
end

-- Display the message when the player is a ghost
hook.Add("HUDPaint", "GhostMessage", function()
    if not LocalPlayer():Alive() or LocalPlayer().Spectating then return end
    if not LocalPlayer():IsIceFrozen() then return end
    draw.SimpleText("Frozen!", "FS_40", ScrW() / 2 + 1, ScrH() - 72 + 2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP) -- shadow
    draw.SimpleText("Frozen!", "FS_40", ScrW() / 2, ScrH() - 72, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end)

-- Render a frozen indicator above teammates
hook.Add("PostPlayerDraw", "DrawFrozenMarkers", function(ply)
    -- Check the player is on the same team and frozen
    if not IsValid(ply) then return end
    if ply == LocalPlayer() then return end
    if ply:Team() ~= LocalPlayer():Team() then return end
    if not ply:IsIceFrozen() then return end
    local pos = ply:GetPos() + Vector(0, 0, 77)
    local ang = LocalPlayer():EyeAngles()
    cam.Start3D2D(pos, Angle(0, ang.y - 90, 90), 0.125)
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    draw.SimpleText("Frozen!", "FS_60", 1, 2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Frozen!", "FS_60", 0, 0, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    render.PopFilterMin()
    cam.End3D2D()
end)

local ice_color = Color(129, 236, 236)

-- Render a halo around frozen teammates
hook.Add("PreDrawHalos", "DrawFrozenHalos", function()
    if not LocalPlayer():Alive() or LocalPlayer().Spectating then return end
    if LocalPlayer():Team() ~= TEAM_RED and LocalPlayer():Team() ~= TEAM_BLUE then return end
    local tbl = {}

    for k, v in pairs(team.GetPlayers(LocalPlayer():Team())) do
        if v:IsIceFrozen() then
            table.insert(tbl, v)
        end
    end

    halo.Add(tbl, ice_color, 2, 2, 2, true, true)
end)