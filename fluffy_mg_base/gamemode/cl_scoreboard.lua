--[[
    This file was originally not part of the gamemode
    It has not been adapted to use GM: functions yet
	This file is a bit of messy
	I'll get around to reworking it one day I promise
--]]
fluffy_scoreboard = nil

-- Rank icons and other convienent functions


-- Update the position of the medals
-- 1-2 players = 1 medal
-- 2-3 players = 2 medals
-- 4+  players = 3 medals
local function UpdateMedals()
	if !IsValid(fluffy_scoreboard) then return end
	
    -- yeah look this code hurts me too
	local tbl = player.GetAll()
	local count = #tbl
    -- Sort the table based on score
	table.sort(tbl, function(a, b) return a:Frags()*-50 + a:EntIndex() < b:Frags()*-50 + b:EntIndex() end)
    
    -- Slice the table depending on number of players
	if count <= 2 then
		tbl = { tbl[1] }
	elseif count <= 4 then
		tbl = { tbl[1], tbl[2] }
	else
		tbl = { tbl[1], tbl[2], tbl[3] }
	end
	fluffy_scoreboard.medals = tbl
end

-- Main component for the scoreboard
function CreateFluffyScoreboard()
    -- Create the scoreboard frame
	fluffy_scoreboard = vgui.Create('DFrame')
	fluffy_scoreboard:SetSize(700, ScrH() - 200)
	fluffy_scoreboard:SetPos(ScrW()/2 - 350, 100)
	fluffy_scoreboard:SetTitle('')
	fluffy_scoreboard:ShowCloseButton(false)
	fluffy_scoreboard.players = {}
	local gametype = (GAMEMODE.TeamBased and GAMEMODE.ShowTeamScoreboard)
	
	function fluffy_scoreboard:Paint(w, h)
        -- Draw the top bar with player information
		draw.RoundedBoxEx(16, 0, 0, w, 32, GAMEMODE.FCol2, true, true, false, false)
		draw.SimpleText(GetHostName(), 'FS_24', 12, 4, GAMEMODE.FCol1)
		draw.SimpleText(player.GetCount() .. ' / ' .. game.MaxPlayers(), 'FS_24', w - 12, 4, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT)
		draw.RoundedBoxEx(16, 0, 32, w, h-32, GAMEMODE.FCol1, false, false, true, true)
        
        -- Draw team information if applicable
        -- Todo: maybe display better team scoring information
        if GAMEMODE.TeamBased and GAMEMODE.ShowTeamScoreboard then
            draw.RoundedBox(8, 32, 36, 256, 52, team.GetColor(TEAM_BLUE))
            draw.SimpleText(team.GetName(TEAM_BLUE), 'FS_32', 40, 36, GAMEMODE.FCol1)
            --draw.SimpleText('Kills: ' .. team.TotalFrags(TEAM_BLUE), 'FS_16', 40, 60, GAMEMODE.FCol1)
            draw.SimpleText(team.GetScore(TEAM_BLUE), 'FS_60', 284, 60, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            
            draw.RoundedBox(8, 412, 36, 256, 52, team.GetColor(TEAM_RED))
            draw.SimpleText(team.GetName(TEAM_RED), 'FS_32', 660, 36, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT)
            --draw.SimpleText('Kills: ' .. team.TotalFrags(TEAM_RED), 'FS_16', 660, 60, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT)
            draw.SimpleText(team.GetScore(TEAM_RED), 'FS_60', 416, 60, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
	end
	
    -- Slide in animation
	function fluffy_scoreboard:Appear()
		self:SetSize(700, ScrH() - 200)
		self:SlideDown(0.5)
        self:MakePopup()
	end
	
    -- Slide out animation
	function fluffy_scoreboard:Disappear()
		self:SlideUp(0.5)
        fluffy_scoreboard:SetMouseInputEnabled(false)
	end
    
    -- Add rows of any players that aren't on the scoreboard yet
	function fluffy_scoreboard:Think()
		for k, v in pairs(player.GetAll()) do
			if IsValid(self.players[v]) then continue end
			local row = vgui.Create('ScoreboardRow')
			row:SetPlayer(v)
			row:Dock(TOP)
			row:DockMargin(12, 4, 12, 0)
			row:AddModule('ping')
			row:AddModule('deaths')
			row:AddModule('score')
			self.PlayerList:AddItem(row)

			self.players[v] = row
		end
	end
	
    -- Create the playerlist for the scoregboard
	fluffy_scoreboard.PlayerList = vgui.Create('DScrollPanel', fluffy_scoreboard)
	fluffy_scoreboard.PlayerList:SetSize(700, ScrH() - 232)
    if GAMEMODE.TeamBased and GAMEMODE.ShowTeamScoreboard then
        fluffy_scoreboard.PlayerList:SetPos(0, 92)
    else
        fluffy_scoreboard.PlayerList:SetPos(0, 32)
    end
    
    fluffy_scoreboard:MakePopup()
end

-- Display scoreboard
hook.Add("ScoreboardShow", "FluffyScoreboardShow", function()
	if !IsValid(fluffy_scoreboard) then
		CreateFluffyScoreboard()
	end
	UpdateMedals()
	
	if !fluffy_scoreboard:IsVisible() then fluffy_scoreboard:Appear() end
	fluffy_scoreboard:SetKeyboardInputEnabled(false)
	return false
end)

-- Hide scoreboard
hook.Add("ScoreboardHide", "FluffyScoreboardHide", function()
	if IsValid(fluffy_scoreboard) then
		if fluffy_scoreboard:IsVisible() then fluffy_scoreboard:Disappear() end
	end
	return false
end)