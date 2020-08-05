
local lightblue = Color(0, 168, 255)
local darkblue = Color(0, 151, 230)
local white = Color(241, 242, 246)
local offwhite = Color(223, 228, 234)
local gray = Color(220, 221, 225)

function GM:CreateInfoFrame2()
    local w = ScrW() * 0.75
    local h = ScrH() * 0.75
    local header_h = 56
    local footer_h = 40

    local f = vgui.Create('DFrame')
    f:SetTitle('')
    f:SetSize(w, h)
    f:Center()
    f:MakePopup()
    f:ShowCloseButton(false)
    f:SetDraggable(false)
    f.CreationTime = CurTime()

    local name = GAMEMODE.Name
    if isfunction(name) then name = name() end

    function f:Paint(w, h)
        Derma_DrawBackgroundBlur(self, self.CreationTime)

        -- Draw header basics
        -- Buttons can get added here later
        draw.RoundedBoxEx(8, 0, 0, w, header_h, lightblue, true, true, false, false)
    end

    -- Add a gamemode/discord advertisement
    surface.SetFont('FS_L40')
    local wide = math.max(128, surface.GetTextSize(name) + 24)
    local discord_ad = vgui.Create('DButton', f)
    discord_ad:SetSize(wide, header_h)
    discord_ad:SetPos(0, 0)
    discord_ad:SetText('')

    function discord_ad:Paint(w, h)
        GAMEMODE:DrawShadowText('Minigames', 'FS_L24', 10, 2, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1)
        GAMEMODE:DrawShadowText(name, 'FS_L40', 8, 18, white)
    end

    function discord_ad:DoClick()
        gui.OpenURL('https://discord.gg/UdMTckn')
    end

    local header_buttons = {
        {
            ["name"] = "Help",
            ["func"] = GAMEMODE.HelpPanel
        },

        {
            ["name"] = "Team",
            ["func"] = GAMEMODE.TeamPanel
        },

        {
            ["name"] = "Items",
            ["func"] = GAMEMODE.ItemsPanel
        },
    }

    -- Add all other header buttons
    local xx = wide
    for k, v in pairs(header_buttons) do
        local name = v['name']

        if name == 'Items' then
            if not LocalPlayer():IsAdmin() then continue end
        end

        local wide = surface.GetTextSize(name) + 24

        local b = vgui.Create('DButton', f)
        b:SetSize(wide, header_h)
        b:SetPos(xx, 0)
        b:SetText('')

        function b:Paint(w, h)
            local c = lightblue
            if self:IsHovered() or (f.SelectedButton == name) then c = darkblue end

            draw.RoundedBox(0, 0, 0, w, h, c)
            GAMEMODE:DrawShadowText(name, 'FS_L40', w/2, h+2, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end

        function b:DoClick()
            GAMEMODE:OpenInfoOption(v['name'], v['func'])
        end

        xx = xx + wide
    end

    -- Add close button
    local close = vgui.Create('DButton', f)
    close:SetSize(48, header_h)
    close:SetPos(w - 48, 0)
    close:SetText('')

    function close:Paint(w, h)
        if GAMEMODE.TeamBased and (LocalPlayer():Team() == TEAM_UNASSIGNED or LocalPlayer():Team() == TEAM_CONNECTING) then return end
        GAMEMODE:DrawShadowText('x', 'FS_L24', w/2, 2, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1)
    end

    function close:DoClick()
        if GAMEMODE.TeamBased and (LocalPlayer():Team() == TEAM_UNASSIGNED or LocalPlayer():Team() == TEAM_CONNECTING) then return end
        f:Close()
    end
    f.CloseButton = close

    -- Build the bottom bar
    local bottom_bar = vgui.Create('DPanel', f)
    bottom_bar:SetSize(w, footer_h)
    bottom_bar:SetPos(0, h - footer_h)

    function bottom_bar:Paint(w, h)
        DisableClipping(true)
        draw.RoundedBoxEx(8, 0, 4, w, h, darkblue, false, false, true, true)
        draw.RoundedBoxEx(8, 0, 0, w, h, lightblue, false, false, true, true)
        DisableClipping(false)
    end
    f.BottomBar = bottom_bar

    -- Build the content panel
    local content = vgui.Create('DPanel', f)
    content:SetSize(w, h - header_h - footer_h)
    content:SetPos(0, header_h)
    function content:Paint(w, h)
        surface.SetDrawColor(white)
        surface.DrawRect(0, 0, w, h)
    end

    f.ContentPanel = content

    GAMEMODE.MinigamesInfoPanel = f
    return f
end

function GM:GetInfoFrame()
    if IsValid(GAMEMODE.MinigamesInfoPanel) then
        return GAMEMODE.MinigamesInfoPanel
    else
        return GAMEMODE:CreateInfoFrame2()
    end
end

function GM:OpenInfoOption(name, func)
    local frame = GAMEMODE:GetInfoFrame()
    -- Clear old selection
    frame.ContentPanel:Clear()
    frame.BottomBar:Clear()

    -- Set new selection
    frame.SelectedButton = name
    func()
end

function GM:HelpPanel()
    local frame = GAMEMODE:GetInfoFrame()
    local panel = frame.ContentPanel
    local bottom = frame.BottomBar

    local name = GAMEMODE.Name
    if isfunction(name) then name = name() end

    local helptext = GAMEMODE.HelpText
    if isfunction(helptext) then helptext = helptext() end

    -- Create the MOTD display
    local motd = vgui.Create('DHTML', panel)
    motd:Dock(FILL)
    motd:OpenURL('https://www.fluffyservers.com/guide/minigames.html')
    motd:Call('UpdateGamemodeName("' .. name .. '")')
    motd:Call('UpdateGamemodeDesc("' .. string.Replace(helptext, '\n', '</p><p>') .. '")')

    -- Create the play button OR a choose team button
    local play_button = vgui.Create('DButton', bottom)
    play_button:SetWide(128)
    play_button:Dock(RIGHT)
    play_button:SetText('')
    play_button.Paint = function(self, w, h)
        DisableClipping(true)
        draw.RoundedBoxEx(8, 0, 4, w, h, Color(68, 189, 50), false, false, false, true)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(76, 209, 55), false, false, false, true)
        GAMEMODE:DrawShadowText(self.Message or 'Play!', 'FS_32', w/2, h/2 + 2, motd_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
        DisableClipping(false)
    end

    if GAMEMODE.TeamBased and (not GAMEMODE.TeamSurvival) and (GAMEMODE.PlayerChooseTeams) then
        play_button:SetWide(192)
        play_button.Message = 'Choose Team'

        function play_button:DoClick()
            GAMEMODE:OpenInfoOption('Team', GAMEMODE.TeamPanel)
        end
    else
        function play_button:DoClick()
            GAMEMODE:GetInfoFrame():Close()
        end
    end
end

function GM:TeamPanel()
    -- Quick check to pass it over to the FFA panel
    -- If this gamemode has *chooseable* teams then use THIS panel
    -- Otherwise use the generic playing/spectating version
    if not GAMEMODE.TeamBased or GAMEMODE.TeamSurvival or (not GAMEMODE.PlayerChooseTeams) then
        GAMEMODE:TeamPanelFFA()
        return
    end

    local frame = GAMEMODE:GetInfoFrame()
    local panel = frame.ContentPanel
    local bottom = frame.BottomBar

    -- numbers
    local teams = team.GetAllTeams()
    local total_wide = panel:GetWide()
    local team_wide = total_wide / (table.Count(teams) - 3)

    -- Create a panel for each team
    local i = 0
    for k,v in pairs(team.GetAllTeams()) do
        if k == TEAM_UNASSIGNED or k == TEAM_CONNECTING or k == TEAM_SPECTATOR then continue end

        -- Make a panel for each team
        local team_panel = vgui.Create('DPanel', panel)
        team_panel:SetWide(team_wide)
        team_panel:SetTall(panel:GetTall() - 48)
        team_panel:SetPos(team_wide * i, 0)

        function team_panel:Paint(w, h)
            draw.SimpleText(team.GetName(k), 'FS_32', w/2, 24, team.GetColor(k), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(offwhite)
            -- Side lines
            surface.DrawLine(0, 0, 0, h)
            surface.DrawLine(1, 0, 1, h)
            surface.DrawLine(w, 0, w, h)
            surface.DrawLine(w - 1, 0, w - 1, h)

            -- Bottom line
            surface.DrawLine(0, h-1, w, h-1)
            surface.DrawLine(0, h-2, w, h-2)
        end

        -- Scoreboard of all current players in the team
        local scoreboard = vgui.Create('DScrollPanel', team_panel)
        scoreboard:SetSize(team_wide * 0.95, team_panel:GetTall() - 64)
        scoreboard:SetPos(team_wide * 0.025, 48)
        scoreboard.players = {}
        
        function scoreboard:Paint(w, h)
            draw.RoundedBox(8, 0, 0, w, h, offwhite)
        end

        function scoreboard:Think()
            for _,v in pairs(team.GetPlayers(k)) do
                if IsValid(self.players[v]) then continue end

                local row = vgui.Create('ScoreboardRow')
                row:SetPlayer(v)
                row:Dock(TOP)
                row:DockMargin(12, 4, 12, 0)
                row:AddModule('deaths')
                row:AddModule('score')
                self:AddItem(row)
                self.players[v] = row

                function row:Think()
                    if self.Player:Team() != k then
                        self:Remove()
                    end
                end
            end
        end

        -- Put a hidden button over the whole panel
        -- This allows players to change teams easily
        local team_button = vgui.Create('DButton', team_panel)
        team_button:Dock(FILL)
        team_button:SetText('')
        team_button.Paint = nil

        function team_button:DoClick()
            RunConsoleCommand('changeteam', k)
        end

        -- Make sure panels move further over
        i = i + 1
    end

    -- Create the button for spectating
    -- This also displays round start time if needed
    local spectate_button = vgui.Create('DButton', panel)
    spectate_button:SetSize(total_wide, 48)
    spectate_button:SetPos(0, panel:GetTall() - 48)
    spectate_button:SetText('')
    
    function spectate_button:Paint(w, h)
        surface.SetDrawColor(gray)
        surface.DrawRect(0, 0, w, h)

        local num_spectators = #team.GetPlayers(TEAM_SPECTATOR)
        if GAMEMODE:GetRoundState() == 'GameNotStarted' or GAMEMODE:GetRoundState() == 'Warmup' then
            local GAME_STATE = GAMEMODE:GetRoundState()
            local message = ''
            if GAME_STATE == 'GameNotStarted' then
                message = 'Waiting for players...'
            elseif GAME_STATE == 'Warmup' then
                local start_time = GetGlobalFloat('WarmupTime', CurTime())
                local t = GAMEMODE.WarmupTime - (CurTime() - start_time)
                message = 'Starting in ' .. math.ceil(t) .. '...'
            end

            GAMEMODE:DrawShadowText(num_spectators .. ' spectating', 'FS_32', w/4, h/2, motd_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            GAMEMODE:DrawShadowText(message, 'FS_32', 3*(w/4), h/2, motd_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            GAMEMODE:DrawShadowText(num_spectators .. ' spectating', 'FS_32', w/2, h/2, motd_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
        end
    end

    function spectate_button:DoClick()
        RunConsoleCommand('changeteam', TEAM_SPECTATOR)
    end

    -- Create the play button
    local play_button = vgui.Create('DButton', bottom)
    play_button:SetWide(128)
    play_button:Dock(RIGHT)
    play_button:SetText('')

    function play_button:Paint(w, h)
        if GAMEMODE.TeamBased and LocalPlayer():Team() == TEAM_UNASSIGNED then return end

        DisableClipping(true)
        draw.RoundedBoxEx(8, 0, 4, w, h, Color(68, 189, 50), false, false, false, true)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(76, 209, 55), false, false, false, true)
        GAMEMODE:DrawShadowText(self.Message or 'Play!', 'FS_32', w/2, h/2 + 2, motd_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
        DisableClipping(false)
    end

    function play_button:DoClick()
        if GAMEMODE.TeamBased and LocalPlayer():Team() == TEAM_UNASSIGNED then return end
        frame:Close()
    end
end

-- FFA team panel is *similar* to the basic team panel
-- Instead of listing all teams it instead displays Playing/Spectating
-- Take care not to mess this up for gamemodes where players can't pick teams!
function GM:TeamPanelFFA()
    local frame = GAMEMODE:GetInfoFrame()
    local panel = frame.ContentPanel
    local bottom = frame.BottomBar

    -- numbers
    local total_wide = panel:GetWide()
    local team_wide = total_wide / 2

    -- Create a panel for each team
    local i = 0
    for k,v in pairs({TEAM_UNASSIGNED, TEAM_SPECTATOR}) do
        -- Make a panel for each team
        local team_panel = vgui.Create('DPanel', panel)
        team_panel:SetWide(team_wide)
        team_panel:SetTall(panel:GetTall())
        team_panel:SetPos(team_wide * i, 0)

        local name = 'Players'
        if v == TEAM_SPECTATOR then name = 'Spectators' end
        local color = Color(0, 168, 255)

        function team_panel:Paint(w, h)
            draw.SimpleText(name, 'FS_32', w/2, 24, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(offwhite)
            -- Side lines
            surface.DrawLine(0, 0, 0, h)
            surface.DrawLine(1, 0, 1, h)
            surface.DrawLine(w, 0, w, h)
            surface.DrawLine(w - 1, 0, w - 1, h)

            -- Bottom line
            surface.DrawLine(0, h-1, w, h-1)
            surface.DrawLine(0, h-2, w, h-2)
        end

        -- Scoreboard of all current players in the team
        local scoreboard = vgui.Create('DScrollPanel', team_panel)
        scoreboard:SetSize(team_wide * 0.95, team_panel:GetTall() - 64)
        scoreboard:SetPos(team_wide * 0.025, 48)
        scoreboard.players = {}
        
        function scoreboard:Paint(w, h)
            draw.RoundedBox(8, 0, 0, w, h, offwhite)
        end

        function scoreboard:Think()
            for _,ply in pairs(player.GetAll()) do
                if IsValid(self.players[ply]) then continue end
                if v == TEAM_SPECTATOR and ply:Team() != TEAM_SPECTATOR then continue end
                if v != TEAM_SPECTATOR and ply:Team() == TEAM_SPECTATOR then continue end

                local row = vgui.Create('ScoreboardRow')
                row:SetPlayer(ply)
                row:Dock(TOP)
                row:DockMargin(12, 4, 12, 0)
                row:AddModule('deaths')
                row:AddModule('score')
                self:AddItem(row)
                self.players[ply] = row

                function row:Think()
                    if v == TEAM_SPECTATOR and not ply:Team() == TEAM_SPECTATOR then 
                        self:Remove()
                        return
                    end

                    if v != TEAM_SPECTATOR and ply:Team() == TEAM_SPECTATOR then 
                        self:Remove() 
                        return 
                    end
                end
            end
        end

        -- Put a hidden button over the whole panel
        -- This allows players to change teams easily
        local team_button = vgui.Create('DButton', team_panel)
        team_button:Dock(FILL)
        team_button:SetText('')
        team_button.Paint = nil

        function team_button:DoClick()
            RunConsoleCommand('changeteam', v)
        end

        -- Make sure panels move further over
        i = i + 1
    end
    
    -- Create the play button
    local play_button = vgui.Create('DButton', bottom)
    play_button:SetWide(128)
    play_button:Dock(RIGHT)
    play_button:SetText('')

    function play_button:Paint(w, h)
        DisableClipping(true)
        draw.RoundedBoxEx(8, 0, 4, w, h, Color(68, 189, 50), false, false, false, true)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(76, 209, 55), false, false, false, true)
        GAMEMODE:DrawShadowText(self.Message or 'Play!', 'FS_32', w/2, h/2 + 2, motd_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
        DisableClipping(false)
    end

    function play_button:DoClick()
        frame:Close()
    end
end

function GM:ItemsPanel()
    local frame = GAMEMODE:GetInfoFrame()
    local display = frame.ContentPanel
    SHOP:OpenInventory(display)
end

-- Concommands to open these panels on server instruction
concommand.Add('mg_info', function()
    GAMEMODE:OpenInfoOption('Help', GAMEMODE.HelpPanel)
end)

concommand.Add('mg_team', function()
    GAMEMODE:OpenInfoOption('Team', GAMEMODE.TeamPanel)

    --[[
    if GAMEMODE.TeamBased and (not GAMEMODE.TeamSurvival) and (GAMEMODE.PlayerChooseTeams) then
        GAMEMODE:OpenInfoOption('Team', GAMEMODE.TeamPanel)
    else
        GAMEMODE:OpenInfoOption('Help', GAMEMODE.HelpPanel)
    end
    ]]--
end)

concommand.Add('mg_inventory', function()
    if not LocalPlayer():IsAdmin() then return end
    GAMEMODE:OpenInfoOption('Items', GAMEMODE.ItemsPanel)
end)