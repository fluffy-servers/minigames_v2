--[[
    Clientside core file
	This mostly just registers fonts and colors
	Most other HUD stuff is in the other client files
--]]

-- Include useful files
include('shared.lua')
include('cl_announcements.lua')
include('cl_chat.lua')
include('cl_crosshair.lua')
include('cl_endgame.lua')
include('cl_hud.lua')
include('cl_killfeed.lua')
include('cl_mapedits.lua')
include('cl_playerpanel.lua')
include('cl_scoreboard.lua')
include('cl_thirdperson.lua')

include('vgui/AvatarCircle.lua')
include('vgui/MapVotePanel.lua')
include('vgui/ScoreboardRow.lua')

-- Register universal fonts
surface.CreateFont("FS_16", {
	font = "Coolvetica",
	size = 16,
})

surface.CreateFont("FS_20", {
	font = "Coolvetica",
	size = 20,
})

surface.CreateFont("FS_24", {
	font = "Coolvetica",
	size = 24,
})

surface.CreateFont("FS_32", {
	font = "Coolvetica",
	size = 32,
})

surface.CreateFont("FS_40", {
	font = "Coolvetica",
	size = 40,
})

surface.CreateFont("FS_48", {
	font = "Coolvetica",
	size = 48,
})

surface.CreateFont("FS_60", {
	font = "Coolvetica",
	size = 48, -- hmmm
})

surface.CreateFont("FS_56", {
	font = "Coolvetica",
	size = 56,
})

surface.CreateFont("FS_64", {
	font = "Coolvetica",
	size = 64,
})

surface.CreateFont("FS_128", {
	font = "Coolvetica",
	size = 128,
})

-- Bebas Kai
surface.CreateFont("FS_B24", {
    font = "Bebas Kai",
    size = 24,
})

surface.CreateFont("FS_B32", {
    font = "Bebas Kai",
    size = 32,
})

surface.CreateFont("FS_B40", {
    font = "Bebas Kai",
    size = 40,
})

surface.CreateFont("FS_B64", {
    font = "Bebas Kai",
    size = 64,
})

surface.CreateFont("FS_B96", {
    font = "Bebas Kai",
    size = 128,
})

-- Lemon/Milk
surface.CreateFont("FS_L24", {
    font = "Lemon/Milk",
    size = 24,
})

surface.CreateFont("FS_L32", {
    font = "Lemon/Milk",
    size = 32,
})

surface.CreateFont("FS_L40", {
    font = "Lemon/Milk",
    size = 40,
})

surface.CreateFont("FS_L48", {
    font = "Lemon/Milk",
    size = 48,
})

surface.CreateFont("FS_L64", {
    font = "Lemon/Milk",
    size = 64,
})

-- Font for CSS Kill Icons
-- Needed for some weapons
surface.CreateFont( "CSKillIcons", {
  font = "csd",
  size = 100,
  weight = 500,
  antialias = false,
})

-- Helper function to draw shadowed text
function GM:DrawShadowText(text, font, x, y, color, horizontal_align, vertical_align, strength)
    if not strength then
        strength = 2
    end

    draw.SimpleText(text, font, x + (strength - 1), y + strength, GAMEMODE.FColShadow, horizontal_align, vertical_align) -- Shadow first, slightly offset
	return draw.SimpleText(text, font, x, y, color, horizontal_align, vertical_align) -- Regular text
end

--[[
    Universal Colors
    Colors are defined in this file for use across the Minigames HUD
    Users can switch colorsets through console command
    Blue is the default & recommended
]]--

local possible_colors = {
    blue = {Color(0, 168, 255), Color(0, 144, 226)},
    red = {Color(252, 92, 101), Color(235, 59, 90)},
    yellow = {Color(254, 211, 48), Color(247, 183, 49)},
    green = {Color(38, 222, 129), Color(32, 191, 107)},
    purple = {Color(165, 94, 234), Color(136, 84, 208)},
    pink = {Color(255, 159, 243), Color(243, 104, 224)},
    cyan = {Color(72, 219, 251), Color(10, 189, 227)},
    orange = {Color(253, 150, 68), Color(250, 130, 49)},
    dark = {Color(39, 60, 117), Color(25, 42, 86)}
}

-- Default is blue
-- This changes based on team in some gamemodes
GM.HColLight = GM.HColLight or possible_colors['blue'][1]
GM.HColDark = GM.HColDark or possible_colors['blue'][2]

-- Default is blue
GM.FCol1 = GM.FCol1 or Color(245, 246, 250)
GM.FCol2 = GM.FCol2 or possible_colors['blue'][1]
GM.FCol3 = GM.FCol3 or possible_colors['blue'][2]
GM.FColShadow = Color(0, 0, 0, 150)

-- Function to update the color set to any in the table
function GM:UpdateColorSet(name)
    if not possible_colors[name] then name = 'blue' end
    GAMEMODE.HColLight = possible_colors[name][1]
    GAMEMODE.HColDark = possible_colors[name][2]
end

-- Function to adjust a colour strength
function draw.ShadeColor(c, strength)
    local strength = strength or 10
    local r = math.Clamp(c.r + strength, 0, 255)
    local g = math.Clamp(c.g + strength, 0, 255)
    local b = math.Clamp(c.b + strength, 0, 255)
    return Color(r, g, b)
end

-- Function to adjust a colour strength that doesn't use math.Clamp
-- Could probably break things if overflow occurs
function draw.ShadeColorFast(c, strength)
    local strength = strength or 10
    return Color(c.r + strength, c.g + strength, c.b + strength)
end

-- Get a short name for a team
function team.GetShortName(id)
    if id == TEAM_SPECTATOR then 
        return 'Spec' 
    else
        return string.Replace(team.GetName(id), " Team", "")
    end
end

-- Handle spectating messages
net.Receive('SpectateState', function()
    local mode = net.ReadInt(8)
    LocalPlayer().SpectateMode = mode
    LocalPlayer().Spectating = false
    LocalPlayer().SpectateTarget = nil

    -- minus one mode disables spectating
    if mode > 0 then
        LocalPlayer().Spectating = true
    end

    -- Load target for all modes except roaming
    if mode > 0 and mode != OBS_MODE_ROAMING then
        LocalPlayer().SpectateTarget = net.ReadEntity()
    end
end)