--[[
    Clientside crosshair library
    Creates the convars that are in charge of the crosshairs
    Also adds the crosshair editor
--]]

-- Custom crosshair convars
local crosshair_outlined = CreateClientConVar("crosshair_outlined", 1, true, false)
local crosshair_image = CreateClientConVar("crosshair_image", "crosshair012.png", true, false)
local crosshair_scale = CreateClientConVar("crosshair_scale", 1, true, false, "Crosshair scale")
local crosshair_r = CreateClientConVar("crosshair_r", 255, true, false, "Crosshair red component (0-255)")
local crosshair_g = CreateClientConVar("crosshair_g", 255, true, false, "Crosshair green component (0-255)")
local crosshair_b = CreateClientConVar("crosshair_b", 255, true, false, "Crosshair blue component (0-255)")
local crosshair_a = CreateClientConVar("crosshair_a", 255, true, false, "Crosshair alpha component (0-255)")

-- Draw crosshair
local crosshair_mat = Material('crosshair_outline/crosshair012.png', 'noclamp smooth') 

-- Main function to actually draw the crosshair on the screen
-- To draw in center of screen: DrawCrossHair(ScrW()/2, ScrH()/2)
function GM:DrawCrosshair(x, y, size, force, color)
    local wep = LocalPlayer():GetActiveWeapon()
    if not force then
        if not LocalPlayer():Alive() or LocalPlayer():Team() == TEAM_SPECTATOR then return end
        if GAMEMODE.CoolTransition != nil then return end
        if IsValid(GAMEMODE.RoundEndPanel) then return end
        if not IsValid(wep) then return end
    end
    
    local crosshair_enabled = GetConVar('crosshair')
    
    -- Check crosshair is enabled
    if !crosshair_enabled:GetBool() then return end

    -- Scale the crosshair
    if not size then 
        size = 36 * math.Clamp(crosshair_scale:GetFloat() or 1, 0, 2)
        if size < 1 then return end
    end
    
    -- Verify image
    local image = crosshair_image:GetString()
    if not string.match(image, 'crosshair%d%d%d.png') then
        image = 'crosshair001.png'
        crosshair_image:SetString(image)
    end
    
    -- Verify number
    local crosshair_num = tonumber(string.sub(image, 10, 12))
    if crosshair_num < 1 or crosshair_num > 200 then
        image = 'crosshair001.png'
        crosshair_image:SetString(image)
    end
    
    -- Get mode
    local mode
    if crosshair_outlined:GetBool() then mode = 'crosshair_outline/' else mode = 'crosshair_white/' end
    
    -- Update material if the image has changed
    local mat_name = string.sub(crosshair_mat:GetString('$basetexture'), 7)
    if mat_name != (mode .. string.sub(image, 0, -5)) then
        crosshair_mat = Material(mode .. image, 'noclamp smooth')
    end

    if wep.DrawCrosshair != false or force then
        draw.NoTexture()
        surface.SetDrawColor(color_white)
        surface.SetMaterial(crosshair_mat)
        if color then
            surface.SetDrawColor(color)
        else
            -- Apply color convars
            local r = math.Clamp(crosshair_r:GetInt(), 0, 255)
            local g = math.Clamp(crosshair_g:GetInt(), 0, 255)
            local b = math.Clamp(crosshair_b:GetInt(), 0, 255)
            local a = math.Clamp(crosshair_a:GetInt(), 0, 255)
            
            local c = Color(r, g, b, a)
            surface.SetDrawColor(c)
        end
        surface.SetAlphaMultiplier(1)
        surface.DrawTexturedRect(x - size/2, y - size/2, size, size)
    end
end

-- Open up the crosshair editing panel
function GM:OpenCrosshairEditor()
    local frame = vgui.Create('DFrame')
    frame:SetSize(280, 512)
    frame:SetPos(128, 64)
    frame:SetTitle('')
    function frame:Paint(w, h)
        Derma_DrawBackgroundBlur(self, self.m_fCreateTime)
        
        local bar_h = 24
        surface.SetDrawColor(GAMEMODE.FCol2)
        surface.DrawRect(0, 0, w, bar_h)
        surface.SetDrawColor(GAMEMODE.FCol1)
        surface.DrawRect(0, bar_h, w, h-bar_h)
        
        draw.SimpleText('Crosshair Editor', 'FS_24', 8, 1, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    frame:MakePopup()
    
    -- Preview box
    local c_preview = vgui.Create("DPanel", frame)
    c_preview:SetSize(128, 128)
    c_preview:SetPos(76, 40)
    function c_preview:PaintOver(w, h)
        GAMEMODE:DrawCrosshair(w/2, h/2, nil, true)
    end
    
    -- Checkbox for outlined state
    local outline = vgui.Create("DCheckBox", frame)
    outline:SetPos(76, 184)
    function outline:OnChange(b)
        crosshair_outlined:SetBool(b)
    end
    outline:SetValue(crosshair_outlined:GetBool())
    
    -- Label for the outlined checkbox
    local outline_label = vgui.Create("DLabel", frame)
    outline_label:SetPos(76 + 20, 182)
    outline_label:SetText("Outlined?")
    outline_label:SetTextColor(GAMEMODE.FCol2)
    
    -- Slider for the crosshair scale
    -- I personally hate how this looks but it works
    local scale = vgui.Create("DNumSlider", frame)
    scale:SetSize(256, 16)
    scale:SetPos(12, 216)
    scale:SetText("Scale")
    scale.Label:SetTextColor(GAMEMODE.FCol2)
    scale:SetConVar("crosshair_scale")
    scale:SetMin(0)
    scale:SetDecimals(1)
    scale:SetMax(2)
    
    -- Color picker for the crosshair
    -- The default convar function for this does bad things with alpha values
    -- Hence the custom ValueChanged convar setting
    local c_picker = vgui.Create("DColorMixer", frame)
    c_picker:SetSize(256, 120)
    c_picker:SetPos(12, 248)
    c_picker:SetPalette(false)
    c_picker:SetAlphaBar(true)
    c_picker:SetWangs(true)
    function c_picker:ValueChanged(col)
        crosshair_r:SetInt(col.r)
        crosshair_g:SetInt(col.g)
        crosshair_b:SetInt(col.b)
        crosshair_a:SetInt(col.a)
    end
    -- Load the users current color and apply it to the picker
    local r = math.Clamp(crosshair_r:GetInt(), 0, 255)
    local g = math.Clamp(crosshair_g:GetInt(), 0, 255)
    local b = math.Clamp(crosshair_b:GetInt(), 0, 255)
    local a = math.Clamp(crosshair_a:GetInt(), 0, 255)
    c_picker:SetColor(Color(r, g, b, a))
    
    -- Scrollable list for crosshair panels
    local list_scroll = vgui.Create('DScrollPanel', frame)
    list_scroll:SetSize(256, 120)
    list_scroll:SetPos(12, 384)
    local icon_list = vgui.Create('DIconLayout', list_scroll)
    icon_list:Dock(FILL)
    icon_list:SetSpaceX(2)
    icon_list:SetSpaceY(2)
    
    -- Add all 200 crosshair images
    for i = 1, 200 do
        local p = icon_list:Add('DPanel')
        p:SetSize(44, 44)
        local b = vgui.Create('DButton', p)
        b:Dock(FILL)
        b:SetText('')
        
        b.n = string.format("%03d", i)
        b.Material = Material('crosshair_outline/crosshair' .. b.n .. '.png', 'noclamp')
        function b:PaintOver(w, h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(self.Material)
            surface.DrawTexturedRect(4, 4, 36, 36)
        end
        
        function b:DoClick()
            local c = 'crosshair' .. self.n .. '.png'
            crosshair_image:SetString(c)
        end
    end
end

-- Add the concommand to open the crosshair editor
concommand.Add("mg_crosshair_editor", function(ply, cmd, args)
    if not CLIENT then return end -- ??? why
    GAMEMODE:OpenCrosshairEditor()
end)