--[[
    Draw the scoreboard
--]]

function GM:CreateScoreboard(force)
    if IsValid(GAMEMODE.Scoreboard) and not force then return end
    local scoreboard = vgui.Create("DFrame")
    scoreboard:SetSize(700, ScrH() - 200)
    scoreboard:Center()
    scoreboard:SetTitle("")
    scoreboard:ShowCloseButton(false)
    scoreboard.players = {}

    function scoreboard:Paint(w, h)
        -- Draw the top bar with server information
        draw.RoundedBoxEx(16, 0, 0, w, 32, GAMEMODE.FCol2, true, true, false, false)
        GAMEMODE:DrawShadowText(GetHostName(), "FS_24", 12, 4, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1)
        GAMEMODE:DrawShadowText(player.GetCount() .. " / " .. game.MaxPlayers(), "FS_24", w - 12, 4, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1)
        draw.RoundedBoxEx(16, 0, 32, w, h - 32, GAMEMODE.FCol1, false, false, true, true)

        -- Draw team information, if applicable
        -- This will show the team rounds won if applicable
        -- For gamemodes with one round (eg. Sniper Wars) it will show the score from that round only
        if GAMEMODE.TeamBased and GAMEMODE.ShowTeamScoreboard then
            draw.RoundedBox(8, 32, 36, 256, 48, team.GetColor(TEAM_BLUE))
            GAMEMODE:DrawShadowText(team.GetName(TEAM_BLUE), "FS_32", 40, 60, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.RoundedBox(8, 412, 36, 256, 48, team.GetColor(TEAM_RED))
            GAMEMODE:DrawShadowText(team.GetName(TEAM_RED), "FS_32", 660, 60, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

            if GAMEMODE.RoundType == "timed_endless" then
                GAMEMODE:DrawShadowText(team.GetRoundScore(TEAM_BLUE), "FS_48", 272, 60, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                GAMEMODE:DrawShadowText(team.GetRoundScore(TEAM_RED), "FS_48", 424, 60, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            else
                GAMEMODE:DrawShadowText(team.GetScore(TEAM_BLUE), "FS_48", 272, 60, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                GAMEMODE:DrawShadowText(team.GetScore(TEAM_RED), "FS_48", 424, 60, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end

    function scoreboard:Appear()
        self:SetSize(700, ScrH() - 200)
        self:MakePopup()
        self:SlideDown(0.25)
    end

    function scoreboard:Disappear()
        self:SlideUp(0.25)
        self:SetMouseInputEnabled(false)
    end

    function scoreboard:Think()
        for k, v in pairs(player.GetAll()) do
            if IsValid(self.players[v]) then continue end
            local row = vgui.Create("ScoreboardRow")
            row:SetPlayer(v)
            row:Dock(TOP)
            row:DockMargin(12, 4, 12, 0)
            row:AddModule("ping")
            row:AddModule("deaths")
            row:AddModule("score")
            self.PlayerList:AddItem(row)
            self.players[v] = row
        end
    end

    scoreboard.PlayerList = vgui.Create("DScrollPanel", scoreboard)
    scoreboard.PlayerList:SetSize(scoreboard:GetWide(), scoreboard:GetTall() - 32)

    if GAMEMODE.TeamBased and GAMEMODE.ShowTeamScoreboard then
        scoreboard.PlayerList:SetPos(0, 92)
    else
        scoreboard.PlayerList:SetPos(0, 32)
    end

    GAMEMODE.Scoreboard = scoreboard

    return scoreboard
end

function GM:UpdateMedals()
    local count = player.GetCount()
    local num = 3

    if count <= 4 then
        num = 2
    elseif count <= 2 then
        num = 1
    end

    GAMEMODE.Medals = GAMEMODE:GetTopPlayers(num)

    return GAMEMODE.Medals
end

function GM:ScoreboardShow()
    if not IsValid(GAMEMODE.Scoreboard) then
        GAMEMODE:CreateScoreboard()
    end

    GAMEMODE:UpdateMedals()

    if not GAMEMODE.Scoreboard:IsVisible() then
        GAMEMODE.Scoreboard:Appear()
    end

    GAMEMODE.Scoreboard:SetKeyboardInputEnabled(false)
end

function GM:ScoreboardHide()
    if IsValid(GAMEMODE.Scoreboard) and GAMEMODE.Scoreboard:IsVisible() then
        GAMEMODE.Scoreboard:Disappear()
    end
end