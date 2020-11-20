include("shared.lua")
GM.ScoringPaneEnabled = true

function GM:ScoringPaneScore(ply)
    return ply:GetNWInt("KingPoints", 0)
end

hook.Add("PreDrawHalos", "DrawKingHalo", function()
    local king = GetGlobalEntity("KingPlayer")
    if not IsValid(king) then return end
    local pcolor = king:GetPlayerColor()
    local color = Color(pcolor[1] * 255, pcolor[2] * 255, pcolor[3] * 255)

    halo.Add({king}, color, 2, 2, 2, true, true)
end)

-- Draw BIG label above the King
-- Being the best comes at a price
hook.Add("HUDPaint", "DrawKingNotice", function()
    if not GetConVar("cl_drawhud"):GetBool() then return end
    if GAMEMODE:GetRoundState() == "GameNotStarted" then return end
    local king = GetGlobalEntity("KingPlayer")

    if IsValid(king) and king ~= LocalPlayer() then
        local p = king:GetPos() + king:OBBCenter() + Vector(0, 0, 50)
        p = p:ToScreen()
        GAMEMODE:DrawShadowText("King!", "FS_32", p.x, p.y, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    elseif LocalPlayer():GetNWBool("IsKing", false) or king == LocalPlayer() then
        local x = ScrW() / 2
        local y = ScrH() - 88
        GAMEMODE:DrawShadowText("You are the King!", "FS_32", x, y, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    else
        local x = ScrW() / 2
        local y = ScrH() - 88
        GAMEMODE:DrawShadowText("Get a kill to become King!", "FS_32", x, y, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
end)