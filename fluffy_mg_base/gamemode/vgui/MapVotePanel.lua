local PANEL = {}

function PANEL:Init()
    print("init")
end

function PANEL:AddChildren(width, height)
    local width = self:GetWide()
    local height = self:GetTall()
    local p = self
    -- Create the icon for each map
    -- The icon is loaded from the Fluffy Servers website
    local map_icon = vgui.Create("DHTML", self)
    map_icon:SetPos(0, 0)
    map_icon:SetSize(width, width)

    function map_icon:SetImage(map)
        local url = "http://fluffyservers.com/mg/maps/" .. map .. ".jpg"
        self:SetHTML([[<style>body{margin:0;padding:0;}</style><img src="]] .. url .. [[" style="width:100%;height:100%;">]])
    end

    -- Wait until options are sent, then load the icon
    function map_icon:Think()
        if not p.Options then return end
        local map = p.Options[4]
        if not map then return end
        -- Set the image
        self:SetImage(map)
        self.Think = nil
    end

    function map_icon:PaintOver(w, h)
        local gamemode = "gamemode"
        local map = "map"

        if p.Options then
            gamemode = p.Options[2] or "gamemode"
            map = p.Options[4] or "map"
            map = string.Split(map, "_")[2]
        end

        draw.SimpleText(gamemode, "FS_L32", w - 3, h - 28 - 1, GAMEMODE.FColShadow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(gamemode, "FS_L32", w - 4, h - 28 - 2, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(map, "FS_L40", w - 3, h - 1, GAMEMODE.FColShadow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(map, "FS_L40", w - 4, h - 2, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

        --print(GAMEMODE.CurrentVote, p.Index)
        if GAMEMODE.CurrentVote and p.Index and GAMEMODE.CurrentVote == p.Index then
            draw.SimpleText("✓", "FS_L40", w - 3, h - 56 - 1, GAMEMODE.FColShadow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("✓", "FS_L40", w - 4, h - 56 - 2, GAMEMODE.FCol1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end
    end

    local map_button = vgui.Create("DButton", self)
    map_button:SetText("")
    map_button:SetSize(width, width)

    function map_button:Paint()
        return
    end

    function map_button:DoClick()
        LocalPlayer():EmitSound("ambient/alarms/warningbell1.wav", 75, math.random(140, 180))
        p:SendVote()
    end
end

function PANEL:SetIndex(i)
    self.Index = i
end

function PANEL:SetOptions(options)
    -- Index 2: gamemode
    -- Index 3: gamemode description
    -- Index 4: map
    self.Options = options
    PrintTable(self.Options)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, w, GAMEMODE.FCol2)
end

function PANEL:SendVote()
    if not self.Index then return end
    if self.Index == 0 then return end
    net.Start("MapVoteSendVote")
    net.WriteInt(self.Index, 8)
    net.SendToServer()
    GAMEMODE.CurrentVote = self.Index
end

vgui.Register("MapVotePanel", PANEL, "Panel")