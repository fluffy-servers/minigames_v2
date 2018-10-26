local PANEL = {}

local sounds = {
    "vo/coast/odessa/male01/nlo_cheer01.wav",
    "vo/coast/odessa/male01/nlo_cheer02.wav",
    "vo/coast/odessa/male01/nlo_cheer03.wav",
    "vo/coast/odessa/male01/nlo_cheer04.wav",
    "vo/coast/odessa/female01/nlo_cheer01.wav",
    "vo/coast/odessa/female01/nlo_cheer02.wav",
    "vo/coast/odessa/female01/nlo_cheer03.wav",
}

function PANEL:Init()
    local w = self:GetParent():GetWide()
    local h = self:GetParent():GetTall()
    self:SetSize(w/3, h)
    
    self.CurrentXP = LocalPlayer():GetExperience()
    self.MaxXP = LocalPlayer():GetMaxExperience()
    self.Level = LocalPlayer():GetLevel()
    
    self.TargetXP = self.CurrentXP
    self.XPMessage = ""
end

function PANEL:Paint(w, h)
    local tw = draw.SimpleText(self.Level, "FS_128", w/2, h/3, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    draw.SimpleText("Level", "FS_40", w/2, h/3 - 24, GAMEMODE.FCol2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    
    self.CurrentXP = math.Approach(self.CurrentXP, self.TargetXP, FrameTime()*25)
    if self.CurrentXP == self.MaxXP then
        self:LevelUp()
    end
    local percentage = math.Clamp(self.CurrentXP/self.MaxXP, 0, 1)
    
    local bar_h = 32
    draw.RoundedBox(16, w/4, 2*h/3, w/2, bar_h, GAMEMODE.FCol3)
    draw.RoundedBox(16, w/4, 2*h/3, math.Clamp(w/2 * percentage, 24, w/2), bar_h, GAMEMODE.FCol2)
    
    draw.SimpleText(self.XPMessage, "FS_32", w/4 + 16, 2*h/3, GAMEMODE.FCol2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText(math.floor(percentage*100) .. "%", "FS_32", w/4 + 16, 2*h/3 + bar_h/2 + 2, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:PaintOver(w, h)
    if self.LevelledUp then
        if not self.Confetti then
            self.Confetti = {}
            for i = 1, w/3 do
                local piece = {}
                piece.x = i * 3 + math.random(-8, 8)
                piece.y = h + 32
                piece.vx = 0
                piece.vy = math.random(-800, -100)
                piece.ax = math.random(-20, 20)
                piece.ay = 300
                piece.ang = math.random(0, 6)
                piece.angv = math.random(-1, 1)
                piece.c = HSVToColor(math.random(360), 1, 1)
                table.insert(self.Confetti, piece)
            end
        else
            for k,p in pairs(self.Confetti) do
                p.vx = p.vx + p.ax * FrameTime()
                p.vy = p.vy + p.ay * FrameTime()
                p.x = p.x + p.vx * FrameTime()
                p.y = p.y + p.vy * FrameTime()
                p.ang = p.ang + p.angv
                draw.NoTexture()
                surface.SetDrawColor(p.c)
                surface.DrawTexturedRectRotated(p.x, p.y, 12, 20, p.ang)
            end
        end
    end
end

function PANEL:AddXP(amount, reason)
    if self.TargetXP > self.CurrentXP then
        self.CurrentXP = self.TargetXP
    end
    self.TargetXP = self.CurrentXP + amount
    self.XPMessage = "+" .. amount .. "XP: " .. reason
    
    local percentage = math.Clamp(self.TargetXP/self.MaxXP, 0, 1)
    local pitch = 150 + (percentage*100)
    LocalPlayer():EmitSound('ambient/alarms/warningbell1.wav', 75, pitch)
end

function PANEL:LevelUp()
    self.Level = self.Level + 1
    self.CurrentXP = 0
    self.TargetXP = 0
    self.LevelledUp = true
    
    local sound = table.Random(sounds)
    LocalPlayer():EmitSound(sound, 75, math.random(100, 125))
end

-- ambient/alarms/warningbell1.wav
-- ambient/levels/canals/windchine1.wav
-- buttons/blip1.wav

vgui.Register("Screen_Experience", PANEL, "Panel")