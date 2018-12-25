AddCSLuaFile('cl_inventory.lua')
AddCSLuaFile('cl_render.lua')
AddCSLuaFile('vgui/ShopItemPanel.lua')
AddCSLuaFile('vgui/ShopMirror.lua')

include('sv_equip.lua')
include('sv_inventory.lua')

util.AddNetworkString('SHOP_RequestItemAction')
util.AddNetworkString('SHOP_NetworkInventory')
util.AddNetworkString('SHOP_BroadcastEquip')

-- Open the shop on client when F4 is pressed
function GM:ShowSpare2(ply)
    ply:ConCommand('minigames_shop')
end