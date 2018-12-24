AddCSLuaFile('cl_inventory.lua')
AddCSLuaFile('vgui/ShopItemPanel.lua')
AddCSLuaFile('vgui/ShopMirror.lua')

-- Open the shop on client when F4 is pressed
function GM:ShowSpare2(ply)
    ply:ConCommand('minigames_shop')
end