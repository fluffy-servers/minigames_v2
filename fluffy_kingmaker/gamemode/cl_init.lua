include('shared.lua')

GM.ScoringPaneEnabled = true

function GM:ScoringPaneScore(ply)
	return ply:GetNWInt("KingPoints", 0)
end

hook.Add('PreDrawHalos', 'DrawKingHalo', function()
    local king = GetGlobalEntity("KingPlayer")
    if not IsValid(king) then return end

    local pcolor = king:GetPlayerColor()
    local color = Color(pcolor[1]*255, pcolor[2]*255, pcolor[3]*255)

    halo.Add({king}, color, 2, 2, 2, true, true)
end)

-- Draw BIG label above the King
-- Being the best comes at a price
hook.Add('HUDPaint', 'DrawKingNotice', function()
    local king = GetGlobalEntity("KingPlayer")
    if IsValid(king) and king != LocalPlayer() then
        local p = king:GetPos() + king:OBBCenter() + Vector(0, 0, 50)
        p = p:ToScreen()    
        
        draw.SimpleText("King!", "FS_32", p.x+1, p.y+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("King!", "FS_32", p.x, p.y, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif LocalPlayer():GetNWBool("IsKing", false) || king == LocalPlayer() then
        local x = ScrW()/2
        local y = ScrH() - 112
        draw.SimpleText("You are the King!", "FS_32", x+1, y+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("You are the King!", "FS_32", x, y, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        local x = ScrW()/2
        local y = ScrH() - 112
        draw.SimpleText("Get a kill to become King!", "FS_32", x+1, y+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Get a kill to become King!", "FS_32", x, y, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)