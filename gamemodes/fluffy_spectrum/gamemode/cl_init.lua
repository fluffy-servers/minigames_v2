include("shared.lua")

-- Halos around your team members
hook.Add("PreDrawHalos", "DrawSpectrumHalos", function()
    if not LocalPlayer():Alive() or LocalPlayer().Spectating then return end
    local players = team.GetPlayers(LocalPlayer():Team())
    local color = team.GetColor(LocalPlayer():Team())
    halo.Add(players, color, 2, 2, 2)
end)