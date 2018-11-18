function GM:CreateHelpPanel()
    if IsValid(GAMEMODE.MinigamesHelpPanel) then return end
    
    local f = vgui.Create('DFrame')
    f:SetTitle('')
    f:SetSize(480, 640)
    f:Center()
    function f:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, 64, Color(47, 54, 64))
        draw.RoundedBox(0, 0, 64, w, h-64, Color(53, 59, 72))
        draw.SimpleText(GAMEMODE.Name, 'FS_B64', 4, 0, GAMEMODE.FCol1)
    end
    f:MakePopup()
    
    local help = vgui.Create('DLabel', f)
    help:SetSize(480, 496)
    help:SetPos(0, 80)
    help:SetText(GAMEMODE.HelpText)
    help:SetFont('FS_16')
    help:SetTextColor(GAMEMODE.FCol1)
    help:SetWrap(true)
    help:SetContentAlignment(7)
    
    local team_panel = vgui.Create('DPanel', f)
    team_panel:SetSize(480, 64)
    team_panel:SetPos(0, 576)
    
    local num = #team.GetAllTeams()
    if GAMEMODE.TeamBased then
        local tw = 480/3
        for id, t in pairs(team.GetAllTeams()) do
            if id == TEAM_CONNECTING or id == TEAM_UNASSIGNED then continue end
            
            local teamp = vgui.Create('DButton', team_panel)
            teamp:SetSize(tw, 64)
            teamp:Dock(LEFT)
            teamp:SetText(team.GetName(id))
            teamp:SetTextColor(GAMEMODE.FCol1)
            teamp:SetFont('FS_B40')
            local c = team.GetColor(id)
            if id == TEAM_SPECTATOR then
                c = Color(251, 197, 49)
            end
            
            function teamp:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, c)
            end
            
            function teamp:DoClick()
                f:Close()
                RunConsoleCommand('changeteam', id)
            end
            
        end
    else
        --local spectate = vgui.Create('DButton', team_panel)
        --spectate:SetSize(160, 64)
        --spectate:SetPos(0, 0)
        
        local play = vgui.Create('DButton', team_panel)
        play:SetSize(480, 64)
        play:SetText('Play!')
        play:SetTextColor(GAMEMODE.FCol1)
        play:SetFont('FS_B40')
        function play:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(76, 209, 55))
        end
        
        function play:DoClick()
            f:Close()
        end
    end
    
    GAMEMODE.MinigamesHelpPanel = f
end

concommand.Add('minigames_info', function()
    GAMEMODE:CreateHelpPanel()
end)