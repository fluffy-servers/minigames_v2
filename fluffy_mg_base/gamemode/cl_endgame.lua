--[[
	This file is in charge of the end game panel
	The end game panel is currently a bit of a disaster
	The key parts of the panel are:
	 - Experience and level up display
	 - Map vote screen
	 - Stats / leaderboard overview
--]]

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
        end
        
        if GAMEMODE.CurrentVote and GAMEMODE.CurrentVote == i then
            map_panel.Selected = true
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
    local w = ScrW()
    local h = ScrH()
    frame:SetSize(w, h)
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:MakePopup()
    frame:SetPopupStayAtBack(true)
    frame:SetKeyboardInputEnabled(false)
    frame.CurrentScreen = "End of Game"
    
    function frame:Paint(w, h)
        --Derma_DrawBackgroundBlur( self, self.m_fCreateTime ) -- cool blur
        
        -- Draw simple white box with bottom bar
        local bar_h = 0
        surface.SetDrawColor(GAMEMODE.FCol1)
        surface.DrawRect(0, 0, w, h-bar_h)
        surface.SetDrawColor(GAMEMODE.FCol2)
        surface.DrawRect(0, h-bar_h, w, bar_h)
    end
    GAMEMODE.EndGamePanel = frame
    
    local sw = frame:GetWide()
    
    local scroll_panel = vgui.Create('DPanel', frame)
    scroll_panel:SetPos(0, 0)
    scroll_panel:SetSize(sw*3, frame:GetTall())
    function scroll_panel:Paint()
    
    end
    frame.ep = scroll_panel
    
    local test = vgui.Create("Screen_Experience", scroll_panel)
    test:SetPos(0, 0)
    GAMEMODE.ExperienceScreen = test
    
    local test2 = vgui.Create("Screen_Maps", scroll_panel)
    test2:SetPos(sw, 0)
    GAMEMODE.MapVoteScreen = test2
    
    local test3 = vgui.Create("Screen_Scoreboard", scroll_panel)
    test3:SetPos(sw*2, 0)
    GAMEMODE.ScoreboardScreen = test3
    
    local function inQuad(fraction, beginning, change)
        if fraction < 0.5 then
            return change * (2*fraction^2) + beginning
        else
            return change * (-1 + (4-2*fraction)*fraction) + beginning
        end
    end
    
    local anim = Derma_Anim("EaseInQuad", scroll_panel, function(p, a, delta, data)
        p:SetPos( inQuad(delta, 0, -sw), 0 )
    end)
    
    local anim2 = Derma_Anim("EaseInQuad", scroll_panel, function(p, a2, delta, data)
        p:SetPos( inQuad(delta, -sw, -sw), 0 )
    end)
    
    function scroll_panel:TriggerMapVote()
        anim:Start(1)
        frame.CurrentScreen = 'MapVote'
    end
    
    function scroll_panel:TriggerScoreboard()
        anim2:Start(1)
        frame.CurrentScreen = 'Scoreboard'
    end
    
    scroll_panel.Think = function(self)
        if anim:Active() then anim:Run() end
        if anim2:Active() then anim2:Run() end
    end
    
    frame.CurrentScreen = 'Experience'
end

-- Open up the end game panel when the server says the game has ended
net.Receive("MinigamesGameEnd", function( len, ply )
    GAMEMODE:OpenEndGamePanel()
end )

-- Get the map vote options information from the server
net.Receive("SendMapVoteTable", function()
    GAMEMODE.VotingOptions = net.ReadTable()
    GAMEMODE.MapVoteScreen:SetVotes(GAMEMODE.VotingOptions)
end)

-- Get the stats report information from the server
net.Receive("SendExperienceTable", function()
    GAMEMODE.StatsReport = net.ReadTable()
    if GAMEMODE.ExperienceScreen then
        GAMEMODE.ExperienceScreen:ProcessXP(GAMEMODE.StatsReport)
    end
end)