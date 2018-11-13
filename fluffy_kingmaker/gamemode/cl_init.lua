include('shared.lua')

GM.ScoringPaneEnabled = true

function GM:ScoringPaneScore(ply)
	return ply:GetNWInt("KingFrags", 0)
end

-- Draw BIG label above the King
-- Being the best comes at a price
function GM:PostPlayerDraw(ply)
    if not ply:GetNWBool("IsKing", false) then return end
    
    local p = ply:GetPos() + Vector(0, 0, 64)
    p = p:ToScreen()
    
    draw.SimpleText("King!", "FS_32", x+1, y+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("King!", "FS_32", x, y, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add('HUDPaint', 'DrawKingNotice', function()
    if not LocalPlayer():GetNWBool("IsKing", false) then return end
    
    local x = ScrW()/2
    local y = ScrH() - 112
    draw.SimpleText("You are the King!", "FS_32", x+1, y+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("You are the King!", "FS_32", x, y, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)