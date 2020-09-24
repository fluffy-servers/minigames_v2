AddCSLuaFile("cl_inventory.lua")
AddCSLuaFile("cl_render.lua")
AddCSLuaFile("cl_images.lua")
AddCSLuaFile("vgui/ShopItemPanel.lua")
AddCSLuaFile("vgui/ShopMirror.lua")
include("sv_equip.lua")
include("sv_inventory.lua")
include("sv_unboxing.lua")
util.AddNetworkString("SHOP_RequestItemAction")
util.AddNetworkString("SHOP_NetworkInventory")
util.AddNetworkString("SHOP_BroadcastEquip")
util.AddNetworkString("SHOP_NetworkEquipped")
util.AddNetworkString("SHOP_InventoryChange")
util.AddNetworkString("SHOP_AnnounceUnbox")

-- Open the shop on client when F4 is pressed
function GM:ShowSpare2(ply)
    ply:ConCommand("mg_inventory")
end