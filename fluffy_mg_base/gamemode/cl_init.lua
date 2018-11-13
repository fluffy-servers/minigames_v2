-- Include useful files
include('shared.lua')
include('avatar_circle.lua')
include('cl_endgame.lua')
include('cl_hud.lua')
include('cl_crosshair.lua')
include('cl_thirdperson.lua')
include('cl_playerpanel.lua')
include('cl_scoreboard.lua')
include('cl_announcements.lua')

include('vgui/MapVotePanel.lua')
include('vgui/Screen_Experience.lua')
include('vgui/Screen_Maps.lua')
include('vgui/Screen_Scoreboard.lua')

--[[
    Universal Fonts
]]--
surface.CreateFont( "FS_16", {
	font = "Coolvetica",
	size = 20,
} )
surface.CreateFont( "FS_24", {
	font = "Coolvetica",
	size = 24,
} )
surface.CreateFont( "FS_32", {
	font = "Coolvetica",
	size = 32,
} )
surface.CreateFont( "FS_40", {
	font = "Coolvetica",
	size = 40,
} )
surface.CreateFont( "FS_60", {
	font = "Coolvetica",
	size = 48, -- hmmm
} )
surface.CreateFont( "FS_64", {
	font = "Coolvetica",
	size = 64,
} )
surface.CreateFont( "FS_128", {
	font = "Coolvetica",
	size = 128,
} )

surface.CreateFont( "FS_B24", {
    font = "Bebas Kai",
    size = 24,
})

surface.CreateFont( "FS_B32", {
    font = "Bebas Kai",
    size = 32,
})

surface.CreateFont( "FS_B40", {
    font = "Bebas Kai",
    size = 40,
})

surface.CreateFont( "FS_B64", {
    font = "Bebas Kai",
    size = 64,
})

surface.CreateFont( "FS_B96", {
    font = "Bebas Kai",
    size = 128,
})

--[[
    Universal Colors
    Colors are defined in this file for use across the Minigames HUD
    Users can switch colorsets through console command
    Blue is the default & recommended
]]--

local possible_colors = {
    blue = {Color(0, 168, 255), Color(0, 151, 230)},
    red = {Color(232, 65, 24), Color(194, 54, 22)},
    yellow = {Color(251, 197, 49), Color(225, 177, 44)},
    green = {Color(76, 209, 55), Color(68, 189, 50)},
    purple = {Color(156, 136, 255), Color(140, 122, 230)},
    dark = {Color(39, 60, 117), Color(25, 42, 86)}
}

-- Default is blue
GM.FCol1 = Color(245, 246, 250)
GM.FCol2 = Color(0, 168, 255)
GM.FCol3 = Color(0, 151, 230)
GM.FColShadow = Color(53, 59, 72)

-- Function to update the color set to any in the table
function GM:UpdateColorSet(name)
    if not possible_colors[name] then return end
    GAMEMODE.FCol2 = possible_colors[name][1]
    GAMEMODE.FCol3 = possible_colors[name][2]
end

-- Concommand to update colors! Yay for choice!
concommand.Add("minigames_hud_color", function( ply, cmd, args )
    GAMEMODE:UpdateColorSet(args[1])
end )