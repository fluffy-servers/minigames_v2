include('shared.lua')

local Spawnmenu = nil

-- Create the spawnmenu
function GM:CreateSpawnMenu()
    Spawnmenu = vgui.Create('DFrame')
    local modelH = 64
    Spawnmenu:SetSize(480, 640)
    Spawnmenu:Center()
    Spawnmenu:SetTitle("Spawner")
    Spawnmenu:SetVisible(false)
    
    local scroll = vgui.Create('DScrollPanel', Spawnmenu)
    scroll:Dock(FILL)
    local list = vgui.Create('DIconLayout', scroll)
    list:Dock(FILL)
    list:SetSpaceY(4)
    list:SetSpaceX(4)
    
    for k,v in pairs(GAMEMODE.PropList) do
        local p = list:Add('SpawnIcon')
        p:SetSize(64, 64)
        p:SetModel(v[1])
        p:SetTooltip(v[2])
        function p:DoClick()
            surface.PlaySound('ui/buttonclickrelease.wav')
            RunConsoleCommand("fw_spawn", v[1])
        end
    end
end

-- Open up the spawning menu if applicable
function GM:OnSpawnMenuOpen()
    local ply = LocalPlayer()
    if !ply:Alive() then return end
    if ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then return end
    -- check round state
    if not IsValid(Spawnmenu) then
        GAMEMODE:CreateSpawnMenu()
    end
    Spawnmenu:SetVisible(true)
    Spawnmenu:SetMouseInputEnabled(true)
    gui.EnableScreenClicker(true)
    RestoreCursorPosition()
end

-- Close the spawning menu
function GM:OnSpawnMenuClose()
    RememberCursorPosition()
    gui.EnableScreenClicker(false)
    Spawnmenu:SetMouseInputEnabled(false)
    Spawnmenu:SetVisible(false)
end

hook.Add('HUDPaint', 'DrawPropInfo', function()
    if !LocalPlayer():Alive() then return end
    local ent = LocalPlayer():GetEyeTrace().Entity
    if IsValid(ent) and ent:GetClass() == "prop_physics" then
        local pos = ent:GetPos():ToScreen()
        local owner = ent:GetNWEntity('Owner')
        if not IsValid(owner) then return end
        local hp = ent:GetNWInt("Health", 0)
        local max_hp = ent:GetNWInt("MaxHealth", 0)
        
        draw.SimpleTextOutlined(owner:Nick(), "Default", pos.x, pos.y - 6, color_white, 1, 1, 1, color_black)
        draw.SimpleTextOutlined(hp .. "/" .. max_hp, "Default", pos.x, pos.y + 6, color_white, 1, 1, 1, color_black)
    end
end)