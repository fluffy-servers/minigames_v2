--[[
    VGUI element for an extendable scoreboard row
    This is designed to be used and extended for use anywhere where a player row is needed
    Scoreboard, end game screen, team menu, etc.
--]]
local name_color_funcs = {}
name_color_funcs['G'] = function(name, cd)
    local new = {}

    -- Do a cool gradient
    for i=1,#name do
        local char = name[i]
        local n = i/(#name)

        local r = cd[1] + (cd[4] - cd[1]) * n
        local g = cd[2] + (cd[5] - cd[2]) * n
        local b = cd[3] + (cd[6] - cd[3]) * n
        table.insert(new, Color(r, g, b))
        table.insert(new, char)
    end

    return new
end

name_color_funcs['H'] = function(name, cd)
    local new = {}

    -- Do a cool rainbow effect
    for i=1,#name do
        local char = name[i]
        local n = (i-1)/(#name)

        local col = HSVToColor(cd[1] + (cd[2]-cd[1]) *n, 1, 1)
        table.insert(new, col)
        table.insert(new, char)
    end

    return new
end

name_color_funcs['M'] = function(name, cd)
    local new = {}

    local stops = math.floor(#cd/3) - 1
    local size = 1/stops

    for i=1,#name do
        local char = name[i]
        local n = (i-1)/#name

        for i=1,stops do
            local s = i/stops

            if n <= s then
                -- Use the sth stop of the gradient
                local stop = (i-1)*3
                local sn = (size - (s - n))/size

                local r = cd[stop+1] + (cd[stop+4] - cd[stop+1]) * sn
                local g = cd[stop+2] + (cd[stop+5] - cd[stop+2]) * sn
                local b = cd[stop+3] + (cd[stop+6] - cd[stop+3]) * sn

                table.insert(new, Color(r, g, b))
                table.insert(new, char)
                break
            end
        end
    end

    return new
end


PANEL = {}

PANEL.Icons = {
    ["gold"] = Material('icon16/medal_gold_2.png'),
    ["silver"] = Material('icon16/medal_silver_2.png'),
    ["bronze"] = Material('icon16/medal_bronze_2.png'),

    ["star"] = Material('icon16/star.png'),
    ["admin"] = Material('icon16/shield.png'),
    ["dev"] = Material('icon16/wrench.png'),
    ["user"] = Material('icon16/user_gray.png'),
    ["donor"] = Material('icon16/heart.png'),
    ["map"] = Material('icon16/map.png'),
    ["bot"] = Material('icon16/cog.png')
}

PANEL.UserIcons = {
    ["76561198067202125"] = 'dev',
    ["76561198087419337"] = 'map'
}

PANEL.Modules = {
    ["ping"] = {
        function(p) return p:Ping() end,
        'Ping'
    },

    ['deaths'] = {
        function(p) return p:Deaths() end,
        'Deaths'
    },

    ['score'] = {
        function(p) return p:Frags() end,
        'Score'
    },

    ['level'] = {
        function(p) return p:GetLevel() end,
        'Level'
    }
}

function PANEL:GetRankIcon(ply)
	local rank = ply:GetUserGroup()
    if self.UserIcons[ply:SteamID64()] then
        return self.UserIcons[ply:SteamID64()]
    elseif ply:IsAdmin() then
        return 'admin'
    elseif ply:GetNWBool('Donor', false) then
        return 'donor'
    elseif ply:IsBot() then
        return 'bot'
    end
    
	return 'user'
end

function PANEL:GetShortName(ply, len)
    return string.sub(ply:Nick() or '<disconnected>', 1, len or 16)
end

function PANEL:DrawPlayerName(ply, x, y)
    local cd = ply:GetNWString('NameColor', nil) 
    local name = self:GetShortName(ply, 20)
    local tbl = {name}
    if cd and cd != '' and cd != ' ' then
        local mode = cd[1]
        cd = string.sub(cd, 2)
        cd = string.Split(cd, ',')
        if name_color_funcs[mode] then tbl = name_color_funcs[mode](name, cd) end
    end

    -- Draw name shadow
    local xx = x
    local c = GAMEMODE.FCol2
    for k,v in pairs(tbl) do
        if IsColor(v) then
            c = v
            continue
        end
        local w = draw.SimpleText(v, 'FS_32', xx, y, c)
        xx = xx + w
    end
end

function PANEL:Init()
    self.AvatarButton = self:Add('DButton')
    self.AvatarButton:SetText('')
    self.AvatarButton:SetSize(48, 48)
    self.AvatarButton:SetPos(2, 2)
    self.AvatarButton.DoClick = function() self.Player:ShowProfile() end
    self.AvatarButton.Paint = function() end

    self.Avatar = vgui.Create('AvatarCircle', self.AvatarButton)
    self.Avatar:Dock(FILL)
    self.Avatar:SetMouseInputEnabled(false)
    self.Avatar:SetDrawLevel(false)

    local parent = self
    function self.Avatar:PaintOver(w, h)
        if not GAMEMODE.Medals then return end
        if not IsValid(parent.Player) then return end
        if parent.Player:Frags() < 1 then return end

        local medal = nil
        if GAMEMODE.Medals[1] == parent.Player then
            medal = 'gold'
        elseif GAMEMODE.Medals[2] == parent.Player then
            medal = 'silver'
        elseif GAMEMODE.Medals[3] == parent.Player then
            medal = 'bronze'
        end

        if medal then
            local mat = parent.Icons[medal]
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(2, 0, 16, 16)
        end
    end

    self.CurrentModules = {}
    self:SetHeight(54)
end

function PANEL:SetPlayer(ply)
    self.Player = ply
    self.Avatar:SetPlayer(self.Player, 64)
end

function PANEL:AddModule(type)
    if self.Modules[type] then
        table.insert(self.CurrentModules, self.Modules[type])
    end
end

function PANEL:AddRawFunction(func)
    table.insert(self.CurrentModules, {func})
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
    local rank = self.Icons[self:GetRankIcon(self.Player)]
    if rank then
	    surface.SetDrawColor(color_white)
	    surface.SetMaterial(rank)
	    surface.DrawTexturedRect(54, 18, 16, 16)
    end

    -- Draw player name
    self:DrawPlayerName(self.Player, 76, 12)
	-- draw.SimpleText(self:GetShortName(self.Player, 20), 'FS_32', 76, 12, GAMEMODE.FCol2)

    -- Other information is handled in a wack fashion
    for k,v in pairs(self.CurrentModules) do
        local xx = w - 32 - (k-1)*64

        if v[2] then
            draw.SimpleText(v[1](self.Player), 'FS_32', xx, 2, GAMEMODE.FCol2, TEXT_ALIGN_CENTER)
            draw.SimpleText(v[2], 'FS_20', xx, 32, GAMEMODE.FCol3, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(v[1](self.Player), 'FS_56', w - 40, h/2 + 1, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
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