include('cl_inventory.lua')
include('vgui/ShopMirror.lua')
include('vgui/ShopItemPanel.lua')

surface.CreateFont('FS_I16', {
    font = 'Roboto',
    size = 16,
})

surface.CreateFont('FS_I24', {
    font = 'Coolvetica',
    size = 24,
    weight = 800,
})

surface.CreateFont('FS_I48', {
    font = 'Roboto',
    size = 48,
    weight = 800,
})

SHOP.Color1 = Color(245, 246, 250)
SHOP.Color2 = Color(220, 221, 225)
SHOP.Color3 = Color(0, 168, 255)
SHOP.Color4 = Color(0, 151, 230)