
local lightblue = Color(0, 168, 255)
local darkblue = Color(0, 151, 230)
local white = Color(255, 255, 255)

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

    function f:Paint(w, h)
        Derma_DrawBackgroundBlur(self, self.CreationTime)

        -- Draw header basics
        -- Buttons can get added here later
        draw.RoundedBoxEx(8, 0, 0, w, header_h, lightblue, true, true, false, false)
    end

    -- Add a gamemode/discord advertisement
    surface.SetFont('FS_L40')
    local wide = math.max(128, surface.GetTextSize(GAMEMODE.Name) + 24)
    local discord_ad = vgui.Create('DButton', f)
    discord_ad:SetSize(wide, header_h)
    discord_ad:SetPos(0, 0)
    discord_ad:SetText('')

    function discord_ad:Paint(w, h)
        GAMEMODE:DrawShadowText('Minigames', 'FS_L24', 10, 2, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1)
        GAMEMODE:DrawShadowText(GAMEMODE.Name, 'FS_L40', 8, 18, white)
    end

    function discord_ad:DoClick()
        gui.OpenURL('https://discord.gg/rMy4nH5')
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

        --[[{
            ["name"] = "Player",
            ["func"] = GAMEMODE.HelpPanel
        },

        {
            ["name"] = "Config",
            ["func"] = GM.HelpPanel
        }
        ]]--
    }

    -- Add all other header buttons
    local xx = wide
    for k, v in pairs(header_buttons) do
        local name = v['name']
        -- Skip the team category in FFA gamemodes
        if name == 'Team' then
            if not GAMEMODE.TeamBased or GAMEMODE.TeamSurvival or not GAMEMODE.PlayerChooseTeams then
                continue
            end
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
        if GAMEMODE.TeamBased and LocalPlayer():Team() == TEAM_UNASSIGNED then return end
        GAMEMODE:DrawShadowText('x', 'FS_L24', w/2, 2, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1)
    end

    function close:DoClick()
        if GAMEMODE.TeamBased and LocalPlayer():Team() == TEAM_UNASSIGNED then return end
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

    -- Create the MOTD display
    local motd = vgui.Create('DHTML', panel)
    motd:Dock(FILL)
    motd:OpenURL('https://www.fluffyservers.com/guide/minigames.html')
    motd:Call('UpdateGamemodeName("' .. GAMEMODE.Name .. '")')
    motd:Call('UpdateGamemodeDesc("' .. string.Replace(GAMEMODE.HelpText, '\n', '</p><p>') .. '")')

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
    local frame = GAMEMODE:GetInfoFrame()
    local panel = frame.ContentPanel
    local bottom = frame.BottomBar

    local teams = team.GetAllTeams()
    local total_wide = panel:GetWide()
    local team_wide = total_wide / (table.Count(teams) - 3)

    for k,v in pairs(team.GetAllTeams()) do
        if k == TEAM_UNASSIGNED or k == TEAM_CONNECTING or k == TEAM_SPECTATOR then continue end

        print(k, team_wide)
        local team_panel = vgui.Create('DButton', panel)
        team_panel:SetWide(team_wide)
        team_panel:Dock(LEFT)
        team_panel:SetText('')

        function team_panel:Paint()

        end

        function team_panel:DoClick()
            print(k)
        end
    end
end