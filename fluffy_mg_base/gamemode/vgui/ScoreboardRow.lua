--[[
    VGUI element for an extendable scoreboard row
    This is designed to be used and extended for use anywhere where a player row is needed
    Scoreboard, end game screen, team menu, etc.
--]]
local fs_icons = {}
fs_icons['gold'] = Material('icon16/medal_gold_2.png')
fs_icons['silver'] = Material('icon16/medal_silver_2.png')
fs_icons['bronze'] = Material('icon16/medal_bronze_2.png')

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

local modules = {}
modules['ping'] = {
    function(p) return p:Ping() end,
    'Ping'
}

modules['deaths'] = {
    function(p) return p:Deaths() end,
    'Deaths'
}

modules['score'] = {
    function(p) return p:Frags() end,
    'Score'
}

modules['level'] = {
    function(p) return p:GetLevel() end,
    'Level'
}

PANEL = {}

function PANEL:Init()
    self.AvatarButton = self:Add('DButton')
    self.AvatarButton:SetSize(48, 48)
    self.AvatarButton:SetPos(2, 2)
    self.AvatarButton.DoClick = function() self.Player:ShowProfile() end
    self.AvatarButton.Paint = function() end

    self.Avatar = vgui.Create('AvatarCircle', self.AvatarButton)
    self.Avatar:Dock(FILL)
    self.Avatar:SetMouseInputEnabled(false)
    self.Avatar:DrawLevel(false)
    self.Modules = {}

    self:SetHeight(54)
end

function PANEL:SetPlayer(ply)
    self.Player = ply
    self.Avatar:SetPlayer(self.Player, 64)
end

function PANEL:PaintOver(w, h)
    if !self.Medal then return end

    local mat = fs_icons[self.Medal]
    if mat then
        surface.SetMaterial(medal_mat)
        surface.DrawTexturedRect(2, 0, 16, 16)
    end
end

function PANEL:AddModule(type)
    if modules[type] then
        table.insert(self.Modules, modules[type])
    end
end

function PANEL:Paint(w, h)
    if !IsValid(self.Player) then return end

    -- Draw rounded box
    -- This has a subtle tab indicating color
    local tab_h = 2
    local tab_c = Color(230, 230, 230, 255)
    if GAMEMODE.TeamBased then
        tab_c = team.GetColor(self.Player:Team())
    else
        local pcolor = self.Player:GetPlayerColor()
        tab_c = Color(pcolor[1]*255, pcolor[2]*255, pcolor[3]*255)
    end
    draw.RoundedBox(8, 0, 0, w, h, tab_c)
    draw.RoundedBoxEx(8, 0, 0, w, h - tab_h, Color(230, 230, 230, 255), true, true, false, false)

    -- Draw rank icon (if applicable)
    local rank = fs_icons[GetRankIcon(self.Player)]
    if rank then
	    surface.SetDrawColor(color_white)
	    surface.SetMaterial(rank)
	    surface.DrawTexturedRect(54, 18, 16, 16)
    end

    -- Draw player name
	draw.SimpleText(GetShortName(self.Player, 20), 'FS_32', 76, 12, GAMEMODE.FCol2)

    -- Other information is handled in a wack fashion
    for k,v in pairs(self.Modules) do
        local xx = w - 32 - (k-1)*64

        if v[2] then
            draw.SimpleText(v[1](self.Player), 'FS_32', xx, 2, GAMEMODE.FCol2, TEXT_ALIGN_CENTER)
            draw.SimpleText(v[2], 'FS_20', xx, 32, GAMEMODE.FCol3, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(v[1](self.Player), 'FS_56', w - 40, h/2 + 1, GAMEMODE.FCol1, TEXT_ALIGN_CENTER) 
        end
    end
end

function PANEL:Think()
    if !IsValid(self.Player) then
        self:SetZPos(9999)
        self:Remove()
        return
    end

    self:SetZPos((self.Player:Frags() * -50) + self.Player:EntIndex())
end

-- Register this so we can reuse it later
vgui.Register('ScoreboardRow', PANEL)