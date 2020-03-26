--[[
	This file defines the info panel that appears at the start of each map
--]]

local motd_lightblue = Color(0, 168, 255)
local motd_darkblue = Color(0, 151, 230)
local motd_white = Color(245, 246, 250)
function GM:CreateInfoFrame()
    if IsValid(GAMEMODE.MinigamesInfoPanel) then return end
    
    -- Create the frame for the info panel
    local f = vgui.Create('DFrame')
    f:SetTitle('')
    f:SetSize(ScrW() * 0.75, ScrH() * 0.75)
    f:Center()
    f:MakePopup()
    f:ShowCloseButton(true)
    f.CreationTime = CurTime()
    
    f.Think = function(self)
        local state = GAMEMODE:GetRoundState()
        if state == 'GameNotStarted' then
            f:ShowCloseButton(false)
        else
            f:ShowCloseButton(true)
        end
    end
    
    f.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, self.CreationTime)
        DisableClipping(true)
        local header_h = 64
        local footer_h = 16
        
        draw.RoundedBoxEx(8, 0, 0, w, header_h, motd_lightblue, true, true, false, false)
        draw.RoundedBoxEx(8, 0, header_h, w, h - header_h, motd_white, false, false, true, true)
        
        draw.SimpleText('Fluffy Minigames', 'FS_L32', 8, 0, motd_white)
        DisableClipping(false)
    end
    
    -- Create the different category buttons
    local b_width = 112
    local b_index = 0
    local bInfo = vgui.Create('DButton', f)
    bInfo:SetSize(b_width, 32)
    bInfo:SetPos(b_width*b_index, 32)
    bInfo:SetText('')
    bInfo.Paint = function(self, w, h)
        local c = motd_lightblue
        if self:IsHovered() or self.Selected then c = motd_darkblue end
        
        draw.RoundedBoxEx(0, 0, 0, w, h, c, false, false, false, true)
        draw.SimpleText('Info', 'FS_32', 6, h/2 + 2, motd_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    b_index = b_index + 1
    
    if GAMEMODE.TeamBased then
        local bTeam = vgui.Create('DButton', f)
        bTeam:SetSize(b_width, 32)
        bTeam:SetPos(b_width*b_index, 32)
        bTeam:SetText('')
        bTeam.Paint = function(self, w, h)
            local c = motd_lightblue
            if self:IsHovered() or self.Selected then c = motd_darkblue end
            
            draw.RoundedBoxEx(0, 0, 0, w, h, c, false, false, false, true)
            draw.SimpleText('Team', 'FS_32', 6, h/2 + 2, motd_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        b_index = b_index + 1
    end
    
    local bShop = vgui.Create('DButton', f)
    bShop:SetSize(b_width, 32)
    bShop:SetPos(b_width*b_index, 32)
    bShop:SetText('')
    bShop.Paint = function(self, w, h)
        local c = motd_lightblue
        if self:IsHovered() or self.Selected then c = motd_darkblue end
        
        draw.RoundedBoxEx(0, 0, 0, w, h, c, false, false, false, true)
        draw.SimpleText('Player', 'FS_32', 6, h/2 + 2, motd_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    b_index = b_index + 1
    
    local bDiscord = vgui.Create('DButton', f)
    bDiscord:SetSize(b_width, 32)
    bDiscord:SetPos(b_width*b_index, 32)
    bDiscord:SetText('')
    bDiscord.Paint = function(self, w, h)
        local c = motd_lightblue
        if self:IsHovered() or self.Selected then c = motd_darkblue end
        
        draw.RoundedBoxEx(0, 0, 0, w, h, c, false, false, false, true)
        draw.SimpleText('Discord', 'FS_32', 6, h/2 + 2, motd_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    b_index = b_index + 1
    
    
    GAMEMODE.MinigamesInfoPanel = f
end

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
    if GAMEMODE.TeamBased and (not GAMEMODE.TeamSurvival) and (GAMEMODE.PlayerChooseTeams) then
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