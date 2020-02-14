--[[
    Clientside core file
	This mostly just registers fonts and colors
	Most other HUD stuff is in the other client files
--]]

-- Include useful files
include('shared.lua')
include('cl_endgame.lua')
include('cl_hud.lua')
include('cl_crosshair.lua')
include('cl_thirdperson.lua')
include('cl_playerpanel.lua')
include('cl_scoreboard.lua')
include('cl_announcements.lua')
include('cl_killfeed.lua')

include('vgui/avatar_circle.lua')
include('vgui/MapVotePanel.lua')

-- Register universal fonts
-- Coolvetica
surface.CreateFont("FS_16", {
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

--[[
    Universal Colors
    Colors are defined in this file for use across the Minigames HUD
    Users can switch colorsets through console command
    Blue is the default & recommended
]]--

local possible_colors = {
    blue = {Color(0, 168, 255), Color(0, 151, 230)},
    red = {Color(255, 77, 77), Color(255, 56, 56)},
    yellow = {Color(251, 197, 49), Color(225, 177, 44)},
    green = {Color(76, 209, 55), Color(68, 189, 50)},
    purple = {Color(156, 136, 255), Color(140, 122, 230)},
    pink = {Color(255, 159, 243), Color(243, 104, 224)},
    cyan = {Color(0, 210, 211), Color(1, 163, 164)},
    orange = {Color(230, 126, 34), Color(211, 84, 0)},
    dark = {Color(39, 60, 117), Color(25, 42, 86)}
}

-- Default is blue
-- This changes based on team in some gamemodes
GM.HColLight = Color(0, 168, 255)
GM.HColDark = Color(0, 151, 230)

-- Default is blue
GM.FCol1 = Color(245, 246, 250)
GM.FCol2 = Color(0, 168, 255)
GM.FCol3 = Color(0, 151, 230)
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

-- Concommand to update colors! Yay for choice!
concommand.Add("minigames_hud_color", function( ply, cmd, args )
    GAMEMODE:UpdateColorSet(args[1])
end )