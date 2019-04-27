--[[
	This file defines the info panel that appears at the start of each map
--]]

-- Information & help panel at the start of a game
--[[
function GM:CreateHelpPanel()
    if IsValid(GAMEMODE.MinigamesHelpPanel) then return end
    
    local f = vgui.Create('DFrame')
    f:SetTitle('')
    f:SetSize(480, 640)
    f:Center()
    function f:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, 64, GAMEMODE.FCol2)
        draw.RoundedBox(0, 0, 64, w, h-64, Color(150, 150, 160))--Color(53, 59, 72))
        draw.SimpleText(GAMEMODE.Name, 'FS_L64', 4, 0, GAMEMODE.FCol1)
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
            teamp:SetText('')
            teamp:SetTextColor(GAMEMODE.FCol1)
            teamp:SetFont('FS_B40')
            local c = team.GetColor(id)
            if id == TEAM_SPECTATOR then
                c = Color(251, 197, 49)
            end
            
            function teamp:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, c)
                local name = team.GetName(id) or ''
                draw.SimpleText(name, 'FS_B40', w/2, h/2 - 6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                local num = team.NumPlayers(id) or 0
                draw.SimpleText(num .. ' players', 'FS_B24', w/2, h/2 + 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
            draw.RoundedBox(0, 0, 0, w, h, GAMEMODE.FCol3)
        end
        
        function play:DoClick()
            f:Close()
        end
    end
    
    GAMEMODE.MinigamesHelpPanel = f
end
--]]

local motd_lightblue = Color(0, 168, 255)
local motd_darkblue = Color(0, 151, 230)
local motd_white = Color(245, 246, 250)
function GM:CreateHelpPanel()
    if IsValid(GAMEMODE.MinigamesHelpPanel) then return end
    
    -- Create the frame
    local f = vgui.Create('DFrame')
    f:SetTitle('')
    f:SetSize(ScrW()*0.75, ScrH()*0.75)
    f:Center()
    f:MakePopup()
    f:ShowCloseButton(false)
    f.CreationTime = CurTime()
    
    -- Draw the frame
    f.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, self.CreationTime)
        DisableClipping(true)
        draw.RoundedBox(8, 0, 8, w, h, motd_darkblue)
        draw.RoundedBox(8, 0, 0, w, h, motd_lightblue)
        draw.RoundedBox(0, 0, 64, w, h-112, motd_white)
        
        draw.SimpleText('Fluffy Servers', 'FS_L24', 10, 8, motd_white)
        draw.SimpleText(GAMEMODE.Name, 'FS_L40', 8, 24, motd_white)
        DisableClipping(false)
    end
    
    -- Create a discord button because I'm a sucker for advertising
    if true then
        local discord = vgui.Create('HTML', f)
        discord:SetSize(192, 64)
        discord:SetPos(f:GetWide()-192-4, 0)
        discord:OpenURL('https://www.fluffyservers.com/discord_ad.html')
        
        local discord_button = vgui.Create('DButton', discord)
        discord_button:Dock(FILL)
        discord_button:SetDrawBackground(false)
        discord_button:SetDrawBorder(false)
        discord_button:SetCursor('hand')
        discord_button:SetText('')
        discord_button.DoClick = function(self, w, h)
            gui.OpenURL('https://discord.gg/rMy4nH5')
        end
    end
    
    local motd_html = vgui.Create('DHTML', f)
    motd_html:SetSize(f:GetWide(), f:GetTall() - 112)
    motd_html:SetPos(0, 64)
    motd_html:OpenURL('https://www.fluffyservers.com/guide/minigames.html')
    motd_html:Call('UpdateGamemodeName("' .. GAMEMODE.Name .. '")')
    motd_html:Call('UpdateGamemodeDesc("' .. string.Replace(GAMEMODE.HelpText, '\n', '</p><p>') .. '")')
    
    -- Buttons!
    local play_button = vgui.Create('DButton', f)
    play_button:SetSize(128, 48)
    play_button:SetPos(f:GetWide() - 128, f:GetTall() - 48)
    play_button.Paint = function(self, w, h)
        DisableClipping(true)
        draw.RoundedBoxEx(8, 0, 8, w, h, Color(68, 189, 50), false, false, false, true)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(76, 209, 55), false, false, false, true)
        draw.SimpleText(self.Message or 'Play!', 'FS_32', w/2, h/2 + 2, motd_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end
    play_button:SetText('')
    play_button.DoClick = function()
        f:Close()
    end
    
    -- Add team buttons (if applicable)
    if GAMEMODE.TeamBased and not GAMEMODE.TeamSurvival then
        local tw = 160
        local xx = tw
        if LocalPlayer():Team() == TEAM_CONNECTING or LocalPlayer():Team() == TEAM_UNASSIGNED then
            play_button:Remove()
        else
            play_button.Message = 'Close'
            xx = xx + 128
        end
        for id, t in pairs(team.GetAllTeams()) do
            if id == TEAM_CONNECTING or id == TEAM_UNASSIGNED then continue end
            
            local teamp = vgui.Create('DButton', f)
            teamp:SetSize(tw, 48)
            teamp:SetPos(f:GetWide() - xx, f:GetTall()-48)
            if xx <= tw then
                teamp.Corner = true
            end
            teamp:SetText('')
            teamp:SetTextColor(GAMEMODE.FCol1)
            teamp:SetFont('FS_B40')
            local c = team.GetColor(id)
            if id == TEAM_SPECTATOR then
                c = Color(225, 177, 44)
            end
            
            function teamp:Paint(w, h)
                DisableClipping(true)
                local c_shadow = Color(c.r - 10, c.g-10, c.b-10)
                if self.Corner then
                    draw.RoundedBoxEx(8, 0, 8, w, h, c_shadow, false, false, false, true)
                    draw.RoundedBoxEx(8, 0, 0, w, h, c, false, false, false, true)
                else
                    draw.RoundedBox(0, 0, 8, w, h, c_shadow)
                    draw.RoundedBox(0, 0, 0, w, h, c)
                end
                
                local name = team.GetName(id) or ''
                draw.SimpleText(name, 'FS_32', w/2, h/2 - 6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                local num = team.NumPlayers(id) or 0
                draw.SimpleText(num .. ' players', 'FS_16', w/2, h/2 + 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                DisableClipping(false)
            end
            
            function teamp:DoClick()
                f:Close()
                RunConsoleCommand('changeteam', id)
            end
            
            xx = xx + tw
        end
    end
    
    GAMEMODE.MinigamesHelpPanel = f
end

-- Bind the above panel to a concommand
concommand.Add('minigames_info', function()
    GAMEMODE:CreateHelpPanel()
end)