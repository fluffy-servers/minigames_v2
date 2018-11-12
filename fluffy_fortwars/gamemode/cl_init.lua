include('shared.lua')

local Spawnmenu = nil

-- Create the spawnmenu
function GM:CreateSpawnMenu()
    Spawnmenu = vgui.Create('DFrame')
    local modelH = 64
    Spawnmenu:SetSize(256, 512)
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
            RunConsoleCommand("fw_spawn", v[2])
        end
    end
end

-- Open up the spawning menu if applicable
function GM:OnSpawnMenuOpen()
    local ply = LocalPlayer()
    if !ply:Alive() then return end
    if ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then return end
    -- check round state
    if not Spawnmenu then
        GAMEMODE:CreateSpawnMenu()
    end
    Spawnmenu:SetVisible(true)
    Spawnmenu:SetMouseInputEnabled(true)
    RestoreCursorPosition()
end

-- Close the spawning menu
function GM:OnSpawnMenuClose()
    RememberCursorPosition()
    Spawnmenu:SetVisible(false)
    Spawnmenu:SetMouseInputEnabled(false)
end