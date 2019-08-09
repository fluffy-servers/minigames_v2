include('shared.lua')

local wepchain = {
    '2', '3', '1', '/', '0', '.', '-', '6', '6'
}
surface.CreateFont('GunGameFont', { font='HL2MP', size=32 })
surface.CreateFont('GunGameFontBig', { font='HL2MP', size=72 })

-- The scoreboard is borrowed from the old GG
-- This does NOT use the one found in the base gamemode

ScoreRefreshPlayers = timer.Create('RefreshPlayers', 3, 0, function()
    if !ScorePane then return end
    local scores = {}
    for k,v in pairs(player.GetAll()) do
        local score = v:GetNWInt('GG_Progress', 0)
        table.insert(scores, {v, score})
    end
    table.sort(scores, function(a, b) return a[2] > b[2] end)
    
    ScorePane:Clear()
    local count = ScrW()*0.5 / 68
    count = math.floor(count)
    
    local n = math.min(#scores, count)
    local xx = ScrW()*0.25 - (n*34)
    
    for k,v in pairs(scores) do
        if k > count then return end
        ScorePane:CreatePlayer(v[1], xx)
        xx = xx + 68
    end
end)

function CreateScoringPane()
    local Frame = vgui.Create('DPanel')
    Frame:SetSize(ScrW() * 0.5, 96)
    Frame:SetPos(ScrW() * 0.25, ScrH() - 72)
    
    function Frame:CreatePlayer(ply, x)
        local p = vgui.Create('DPanel', Frame)
        p:SetPos(x, 0)
        p:SetSize(64, 64)
        function p:Paint()
            local icons = wepchain
            if GetGlobalString('GunGame_Mode') == 'css' then icons = wepchain_css end
            local ggfont = 'GunGameFont'
            
            local score = ply:GetNWInt('GG_Progress', 0)
            score = math.floor(score/2) + 1
            draw.SimpleText(icons[score], ggfont, 32, 40, color_white, TEXT_ALIGN_CENTER)
        end
        
        local Avatar = vgui.Create('AvatarImage', p)
        Avatar:SetSize(36, 36)
        Avatar:SetPos(14, 0)
        Avatar:SetPlayer(ply, 64)
    end
    
    function Frame:Paint()
    
    end
    ScorePane = Frame
end

hook.Add('HUDPaint', 'GungameCoolHUD', function()
    if !IsValid(ScorePane) then CreateScoringPane() end
    local current = math.floor(LocalPlayer():GetNWInt('GG_Progress', 0) / 2) + 1
    local icons = wepchain
    if GetGlobalString('GunGame_Mode') == 'css' then icons = wepchain_css end
    local ggfont = 'GunGameFontBig'
    
    for i=1,#icons - 1 do
        if i==current then
            draw.SimpleText(icons[i], ggfont, 80, 96 + i*48, Color(0, 255, 0), TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(icons[i], ggfont, 52, 96 + i*48, color_white, TEXT_ALIGN_CENTER)
        end
    end
end)