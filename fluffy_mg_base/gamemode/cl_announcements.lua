--[[
    Clientside announcements library
    Contains some local functions for drawing fancy text
    Announcements here are triggered on the server and then displayed here for information
    Currently contains the following announcement types:
        - Countdown
		- Pulse
		- Pulse w/ subtext
--]]
-- Draw text that can be scaled
-- Useful for cool animations without creating lost of different font sizes
local function drawScaledText(x, y, text, font, color, scale)
    -- Setup the matrix
    local mat = Matrix()
    mat:Translate(Vector(x, y))
    mat:Scale(Vector(scale, scale))
    mat:Translate(-Vector(x, y))
    -- Get the size of the text
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(text)
    -- Push matrices and draw the text
    render.PushFilterMag(TEXFILTER.ANISOTROPIC)
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    cam.PushModelMatrix(mat)
    draw.SimpleText(text, font, x - tw / 2, y - th / 2, color)
    cam.PopModelMatrix()
    render.PopFilterMag()
    render.PopFilterMin()
end

-- Draw text that can be rotated
local function drawRotatedText(x, y, text, font, color, ang)
    -- Get the size of the text
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(text)
    -- Setup the matrix
    local mat = Matrix()
    mat:Translate(Vector(x, y))
    mat:SetAngles(Angle(0, ang, 0))
    mat:Translate(-Vector(x, y))
    -- Push matrices and draw the text
    render.PushFilterMag(TEXFILTER.ANISOTROPIC)
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    cam.PushModelMatrix(mat)
    draw.SimpleText(text, font, x - tw / 2, y - th / 2, color)
    cam.PopModelMatrix()
    render.PopFilterMag()
    render.PopFilterMin()
end

-- Draw text that is a combination of the above two functions
local function drawRotatedScaledText(x, y, text, font, color, ang, scale)
    -- Get the size of the text
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(text)
    -- Setup the matrix
    local mat = Matrix()
    mat:Translate(Vector(x, y))
    mat:SetAngles(Angle(0, ang, 0))
    mat:Scale(Vector(scale, scale))
    mat:Translate(-Vector(x, y))
    -- Push matrices and draw the text
    render.PushFilterMag(TEXFILTER.ANISOTROPIC)
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    cam.PushModelMatrix(mat)
    draw.SimpleText(text, font, x - tw / 2, y - th / 2, color)
    cam.PopModelMatrix()
    render.PopFilterMag()
    render.PopFilterMin()
end

local location_functions = {
    ["center"] = function(w, h) return w / 2, h / 2 end,
    ["top"] = function(w, h) return w / 2, 64 end,
    ["bottom"] = function(w, h) return w / 2, h - 64 end
}

-- Create a countdown announcement
-- Counts down in the middle of the screen before displaying the endtext
function GM:CountdownAnnouncement(length, endtext, location, endsound, ticksound)
    local test = vgui.Create("DPanel")
    test:SetSize(ScrW(), ScrH())
    test:Center()
    test:NoClipping(true)
    local lasttick = CurTime()
    local number = length
    local finished = false

    if ticksound then
        surface.PlaySound(ticksound)
    end

    function test:GetCountdownInfo()
        if finished then return 1, endtext end
        local timeleft = lasttick - CurTime() + 1

        if timeleft < 0 then
            timeleft = 1
            lasttick = CurTime()
            number = number - 1

            if number < 1 then
                finished = true

                if endsound then
                    surface.PlaySound(endsound)
                end

                timer.Simple(1, function()
                    self:Remove()
                end)
            else
                if ticksound then
                    surface.PlaySound(ticksound)
                end
            end
        end

        return timeleft, number
    end

    function test:Paint(w, h)
        local s, num = self:GetCountdownInfo()
        local x, y = location_functions[location](w, h)
        drawScaledText(x + 2, y + 2, tostring(num), "FS_64", GAMEMODE.FColShadow, s + 0.25)
        drawScaledText(x, y, tostring(num), "FS_64", GAMEMODE.FCol1, s + 0.25)
    end
end

-- Creates a pulse announcement
-- Simple announcement that zooms in before zooming out quickly
function GM:PulseAnnouncement(duration, text, size, location, sound)
    if sound then
        surface.PlaySound(sound)
    end

    local test = vgui.Create("DPanel")
    test:SetSize(ScrW(), ScrH())
    test:Center()
    test:NoClipping(true)
    local starttime = CurTime()
    local midtime = starttime + duration / 2
    local scale = 1

    function test:GetScalingInfo()
        if CurTime() < midtime then
            scale = size - (midtime - CurTime()) / duration
        else
            scale = size + (midtime - CurTime()) * 4
        end

        if scale < 0 then
            self:Remove()

            return
        end
    end

    function test:Paint(w, h)
        self:GetScalingInfo()
        local x, y = location_functions[location](w, h)
        drawScaledText(x + 2, y + 2, text, "FS_64", GAMEMODE.FColShadow, scale)
        drawScaledText(x, y, text, "FS_64", GAMEMODE.FCol1, scale)
    end
end

-- Creates a pulse announcement
-- Simple announcement that zooms in before zooming out quickly
-- This variation has a larger line followed by a smaller line
function GM:PulseAnnouncementTwoLine(duration, text, subtext, size, location, sound)
    if sound then
        surface.PlaySound(sound)
    end

    local test = vgui.Create("DPanel")
    test:SetSize(ScrW(), ScrH())
    test:Center()
    test:NoClipping(true)
    local starttime = CurTime()
    local midtime = starttime + duration / 2
    local scale = 1

    function test:GetScalingInfo()
        if CurTime() < midtime then
            scale = size - (midtime - CurTime()) / duration
        else
            scale = size + (midtime - CurTime()) * 4
        end

        if scale < 0 then
            self:Remove()

            return
        end
    end

    function test:Paint(w, h)
        self:GetScalingInfo()
        local x, y = location_functions[location](w, h)
        y = y - 32 -- Slight offset for two lines
        drawScaledText(x + 2, y + 2, text, "FS_64", GAMEMODE.FColShadow, scale)
        drawScaledText(x, y, text, "FS_64", GAMEMODE.FCol1, scale)
        drawScaledText(x + 2, y + 48, subtext, "FS_32", GAMEMODE.FColShadow, scale)
        drawScaledText(x, y + 46, subtext, "FS_32", GAMEMODE.FCol1, scale)
    end
end

-- Net handler to parse announcements
net.Receive('MinigamesAnnouncement', function()
    local tbl = net.ReadTable()
    if not tbl.type then return end

    if tbl.type == 'countdown' then
        GAMEMODE:CountdownAnnouncement(tbl.length or 5, tbl.endtext or "", tbl.location, tbl.endsound, tbl.ticksound)
    elseif tbl.type == 'pulse' then
        if not tbl.text then return end
        local duration = tbl.duration or 5
        GAMEMODE:PulseAnnouncement(duration, tbl.text, tbl.size or 1.5, tbl.location, tbl.sound)
    elseif tbl.type == 'pulse_subtext' then
        if not tbl.text then return end
        GAMEMODE:PulseAnnouncementTwoLine(tbl.length or 5, tbl.text, tbl.subtext or '', tbl.size or 1.25, tbl.location, tbl.sound)
    end
end)