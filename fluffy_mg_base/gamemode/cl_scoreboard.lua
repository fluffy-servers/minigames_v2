--[[
    This file was originally not part of the gamemode
    It has not been adapted to use GM: functions yet
	This file is a bit of messy
	I'll get around to reworking it one day I promise
--]]
include('vgui/avatar_circle.lua')

-- Cache icons
local fs_icons = {}
fs_icons['medal_gold'] = Material('icon16/medal_gold_2.png')
fs_icons['medal_silver'] = Material('icon16/medal_silver_2.png')
fs_icons['medal_bronze'] = Material('icon16/medal_bronze_2.png')

fs_icons['star'] = Material('icon16/star.png')
fs_icons['admin'] = Material('icon16/shield.png')
fs_icons['dev'] = Material('icon16/wrench.png')
fs_icons['user'] = Material('icon16/user_gray.png')
fs_icons['donor'] = Material('icon16/heart.png') 
fs_icons['map'] = Material('icon16/map.png')
fs_icons['bot'] = Material('icon16/cog.png')

local fs_users = {}
fs_users['76561198067202125'] = 'dev'
fs_users['76561198087419337'] = 'map'

fluffy_scoreboard = nil

-- Rank icons and other convienent functions
local function GetRankIcon(ply)
	local rank = ply:GetUserGroup()
    if fs_users[ply:SteamID64()] then
        return fs_users[ply:SteamID64()]
    elseif ply:IsAdmin() then
        return 'admin'
    elseif ply:GetNWBool('Donor', false) then
        return 'donor'
    elseif ply:IsBot() then
        return 'bot'
    end
    
	return 'user'
end

-- Useful function to shorten names
local function GetShortName(ply, len)
	return string.sub(ply:Nick() or '<disconnected>', 1, len or 16)
end

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
	end
	
    -- Slide out animation
	function fluffy_scoreboard:Disappear()
		self:SlideUp(0.5)
	end
    
    -- Add rows of any players that aren't on the scoreboard yet
	function fluffy_scoreboard:Think()
		for k, v in pairs(player.GetAll()) do
			if IsValid(self.players[v]) then continue end
			self.players[v] = self:CreatePlayerRow(v)
			self.PlayerList:AddItem(self.players[v])
		end
	end
	
    -- Create a player row for a given player
	function fluffy_scoreboard:CreatePlayerRow(ply)
		if !IsValid(self.PlayerList) then return end
		
        -- Row panel
		local row = vgui.Create('DPanel')
		row.Player = ply
		row:Dock(TOP)
		row:SetHeight(52)
		row:DockMargin(12, 4, 12, 0)
		row:SetZPos(4 + ply:EntIndex())
		
        -- Add the avatar
		row.Avatar = row:Add('AvatarCircle')
        if IsValid(row.Avatar) then
            row.Avatar.Avatar:SetPlayer(ply, 64) -- Don't ask
            row.Avatar:SetPos(2, 2)
            row.Avatar:SetSize(48, 48)
        end
		
        -- Display the medals for this player
		function row:PaintOver(w, h)
			local ply = row.Player
			surface.SetDrawColor(color_white)
            local medal_mat = nil
            
            -- Determine the medal material
            if fluffy_scoreboard.medals[1] == ply then medal_mat = fs_icons['medal_gold'] end
            if fluffy_scoreboard.medals[2] == ply then medal_mat = fs_icons['medal_silver'] end
            if fluffy_scoreboard.medals[3] == ply then medal_mat = fs_icons['medal_bronze'] end
            
            -- Draw the medal
            if medal_mat then
            	surface.SetMaterial(medal_mat)
				surface.DrawTexturedRect(2, 0, 16, 16)
            end
		end
        
        -- Paint information on the row
		function row:Paint(w, h)
            if !IsValid(self.Player) then return end
			draw.RoundedBox(8, 0, 0, w, h, Color(230, 230, 230, 255))
            
            -- Draw rank icon
			surface.SetDrawColor(color_white)
			surface.SetMaterial(fs_icons[GetRankIcon(self.Player)])
			surface.DrawTexturedRect(54, 18, 16, 16)
            
            -- Draw player name
			draw.SimpleText(GetShortName(self.Player, 20), 'FS_32', 76, 12, GAMEMODE.FCol2)
			
            -- Draw team information
			if GAMEMODE.TeamBased then
				local pt = self.Player:Team()
				draw.SimpleText(team.GetShortName(pt), 'FS_24', 400, 6, team.GetColor(pt), TEXT_ALIGN_CENTER)
				draw.SimpleText('Team', 'FS_16', 400, 32, GAMEMODE.FCol3, TEXT_ALIGN_CENTER)
			end
			
            -- Draw the score
			draw.SimpleText(self.Player:Frags(), 'FS_32', 475, 2, GAMEMODE.FCol2, TEXT_ALIGN_CENTER)
			draw.SimpleText('Score', 'FS_16', 475, 32, GAMEMODE.FCol3, TEXT_ALIGN_CENTER)
			
            -- Draw the deaths
			draw.SimpleText(self.Player:Deaths(), 'FS_32', 550, 2, GAMEMODE.FCol2, TEXT_ALIGN_CENTER)
			draw.SimpleText('Deaths', 'FS_16', 550, 32, GAMEMODE.FCol3, TEXT_ALIGN_CENTER)
			
            -- Draw the ping
			if self.Player:IsBot() then
				draw.SimpleText('BOT', 'FS_24', 625, 6, GAMEMODE.FCol2, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(self.Player:Ping(), 'FS_32', 625, 2, GAMEMODE.FCol2, TEXT_ALIGN_CENTER)
			end
			draw.SimpleText('Ping', 'FS_16', 625, 32, GAMEMODE.FCol3, TEXT_ALIGN_CENTER)
		end
		
        -- Shuffle the row in the list depending on the score
		function row:Think()
			if !IsValid(self.Player) then
				self:SetZPos(9999)
				self:Remove()
				return
			end
			if !IsValid(fluffy_scoreboard) then
				self:Remove()
				return
			end
			self:SetZPos((self.Player:Frags() * -50) + self.Player:EntIndex())
		end
        
        -- Return the newly created row object
		return row
	end
	
    -- Create the playerlist for the scoregboard
	fluffy_scoreboard.PlayerList = vgui.Create('DScrollPanel', fluffy_scoreboard)
	fluffy_scoreboard.PlayerList:SetSize(700, ScrH() - 232)
    if GAMEMODE.TeamBased and GAMEMODE.ShowTeamScoreboard then
        fluffy_scoreboard.PlayerList:SetPos(0, 92)
    else
        fluffy_scoreboard.PlayerList:SetPos(0, 32)
    end
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