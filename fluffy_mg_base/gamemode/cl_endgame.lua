-- Open up the end of game panel
-- This is a pretty complicated thing -> maybe split into more functions one day?
-- I blame derma personally
function GM:CreateMapVotePanel()
    local frame = GAMEMODE.EndGamePanel
    if not IsValid(frame) then return end
    frame.CurrentScreen = "Map Vote"
    frame.ep:Clear()
    local change_button = frame.change_button
    
    -- This section creates the 4 cards for the mapvote
    -- Do the calculations to make them sized nicely
    local w = frame:GetWide()
    local h = frame:GetTall()
    local n = 4
    local margin = 32
    local padding = 24
    local panel_w = ( w - margin*2 - (n-1)*padding ) / n
    local image_w = panel_w - 32
    local panel_h = (h-32-48)
    local vote_panels = {}
    
    -- The big loop
    for i =1,n do
        -- Create a panel
        local map_panel = vgui.Create('DPanel', frame.ep)
        map_panel:SetSize(panel_w, panel_h)
        map_panel:SetPos(margin + (panel_w+padding)*(i-1), 16)
        map_panel.index = i
        function map_panel:Paint(w, h)
            DisableClipping(true)
            draw.RoundedBox(16, -1, -1, w+4, h+5, GAMEMODE.FCol3) -- Draw the outline/shadow effect
            DisableClipping(false)
            
            draw.RoundedBox(16, 0, 0, w, h, GAMEMODE.FCol1)
            draw.RoundedBox(0, 16, 16, image_w, image_w, GAMEMODE.FCol2)
            
            -- Draw the text on the card
            -- Account for some placeholder text in the few milliseconds before the voting options arrive
            local options = GAMEMODE.VotingOptions
            if not options then
                draw.SimpleText('[map]', 'FS_32', w/2, image_w + 32, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText('[gamemode]', 'FS_40', w/2, image_w + 96, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText('[desc]', 'FS_24', w/2, image_w + 140, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            else
                draw.SimpleText(options[i][4] or '[map]', 'FS_32', w/2, image_w + 32, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText(options[i][2] or '[gamemode]', 'FS_40', w/2, image_w + 96, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText(options[i][3] or '[desc]', 'FS_24', w/2, image_w + 140, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
            
            -- Draw a cool check mark on the current vote
            if self.Selected then
                draw.SimpleText('✓', 'FS_64', w - 28, h - 32, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        
        if GAMEMODE.CurrentVote and GAMEMODE.CurrentVote == i then
            map_panel.Selected = true
        end
        
        -- Create the icon for each map
        -- The icon is loaded from the Fluffy Servers website
        local map_icon = vgui.Create('DHTML', map_panel)
        map_icon:SetPos(16, 16)
        map_icon:SetSize(image_w, image_w)
        function map_icon:SetImage(map)
            local url = 'http://fluffyservers.com/mg/maps/' .. map .. '.jpg'
            self:SetHTML([[<style>body{margin:0;padding:0;}</style><img src="]] .. url .. [[" style="width:100%;height:100%;">]])
        end
        -- Wait until options are sent, then load the icon
        function map_icon:Think()
            local options = GAMEMODE.VotingOptions
            if not options then return end
            local map = options[i][4]
            if not map then return end
            
            -- Set the image
            self:SetImage(map)
            self.Think = nil
        end
            
        
        -- Create the vote button on each panel
        local vote_button = vgui.Create('DButton', map_panel)
        vote_button:SetFont('FS_32')
        vote_button:SetText('')
        vote_button:SetSize(128, 48)
        vote_button:SetPos(0, panel_h-48)
        function vote_button:Paint(w, h)
            local c = GAMEMODE.FCol3
            if self:IsHovered() then c = GAMEMODE.FCol2 end
            draw.SimpleText('Vote!', 'FS_32', w/2, h/2, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        -- Cast the vote and enable the scoreboard button
        function vote_button:DoClick()
            LocalPlayer():EmitSound('ambient/alarms/warningbell1.wav', 75, 160)
            net.Start('MapVoteSendVote')
                net.WriteInt(i, 8)
            net.SendToServer()
            GAMEMODE.CurrentVote = i
            for k, v in pairs(vote_panels) do
                if k == i then v.Selected = true else v.Selected = false end
            end
            change_button:SetEnabled(true)
        end
        
        table.insert(vote_panels, map_panel)
    end
    
    change_button:SetText("Scoreboard")
    function change_button:DoClick()
        GAMEMODE:CreateScoreboardPanel()
    end
end

function GM:CreateItemDropPanel()

end

function GM:CreateScoreboardPanel()
    local frame = GAMEMODE.EndGamePanel
    if not IsValid(frame) then return end
    frame.CurrentScreen = "Scoreboard"
    frame.ep:Clear()
    local change_button = frame.change_button
    
    change_button:SetText("Map Vote")
    change_button:SetEnabled(true)
    function change_button:DoClick()
        GAMEMODE:CreateMapVotePanel()
    end
    
    local w = frame:GetWide()
    local h = frame.ep:GetTall()
    local stats_panel = vgui.Create('DPanel', frame.ep)
    stats_panel:SetSize(w/2, h)

    local scoreboard_panel = vgui.Create('DPanel', frame.ep)
    scoreboard_panel:SetSize(w/2, h)
    scoreboard_panel:SetPos(w/2, 0)
    
    local my_stats = GAMEMODE.StatsReport[LocalPlayer()] or {}
    for k,v in pairs(my_stats) do
        local lbl = vgui.Create('DLabel', stats_panel)
        lbl:Dock(TOP)
        lbl:DockMargin(4, 0, 0, 0)
        lbl:SetColor(color_black)
        lbl:SetText(k .. ": " .. v)
    end
end

function GM:CreateLevelUpPanel()
    local frame = GAMEMODE.EndGamePanel
    frame.CurrentScreen = "Level Up"
end

function GM:OpenEndGamePanel()
    local frame = vgui.Create('DFrame')
    local w = ScrW() * 0.8
    local h = ScrH() * 0.8
    frame:SetSize(w, h)
    frame:Center()
    frame:SetTitle("")
    frame:SetBackgroundBlur(true)
    frame:MakePopup()
    frame.CurrentScreen = "End of Game"
    
    function frame:Paint(w, h)
        Derma_DrawBackgroundBlur( self, self.m_fCreateTime ) -- cool blur
        
        -- Draw simple white box with bottom bar
        local bar_h = 48
        surface.SetDrawColor(GAMEMODE.FCol1)
        surface.DrawRect(0, 0, w, h-bar_h)
        surface.SetDrawColor(GAMEMODE.FCol2)
        surface.DrawRect(0, h-bar_h, w, bar_h)
        
        draw.SimpleText(self.CurrentScreen, 'FS_B40', 8, h-(bar_h/2), GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    GAMEMODE.EndGamePanel = frame
    
    -- Button to go to the scoreboard once voting is complete
    local change_button = vgui.Create('DButton', frame)
    change_button:SetTextColor(color_white)
    change_button:SetFont('FS_B40')
    change_button:SetText('Next Panel')
    change_button:SetSize(180, 48)
    change_button:SetPos(w-180, h-48)
    change_button:SetTextInset(8, 0)
    change_button:SetContentAlignment(4)
    change_button:SetEnabled(false)
    function change_button:Paint(w, h)
        if self:IsEnabled() then
            if self:IsHovered() then
                surface.SetDrawColor(GAMEMODE.FCol3)
            else
                surface.SetDrawColor(GAMEMODE.FCol2)
            end
            surface.DrawRect(0, 0, w, h)
        
            draw.SimpleText('→', 'FS_B32', w-20, h/2 - 6, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            surface.SetDrawColor(GAMEMODE.FCol3)
            surface.DrawRect(0, 0, w, h)
        end
    end
    frame.change_button = change_button
    
    local edit_panel = vgui.Create('DPanel', frame)
    edit_panel:SetPos(0, 0)
    edit_panel:SetSize(frame:GetWide(), frame:GetTall() - 48)
    frame.ep = edit_panel
    
    GAMEMODE:CreateMapVotePanel()
end

-- Open up the end game panel when the server says the game has ended
net.Receive("MinigamesGameEnd", function( len, ply )
    GAMEMODE:OpenEndGamePanel()
end )

-- Get the map vote options information from the server
net.Receive("SendMapVoteTable", function()
    GAMEMODE.VotingOptions = net.ReadTable()
end)

-- Get the stats report information from the server
net.Receive("SendStatsReport", function()
    GAMEMODE.StatsReport = net.ReadTable()
end)