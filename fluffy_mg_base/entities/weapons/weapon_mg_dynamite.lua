SWEP.Base = 'weapon_mg_sck_base'
SWEP.HoldType = "grenade"

if CLIENT then
	SWEP.Slot = 4
	SWEP.SlotPos = 0
	
	SWEP.IconLetter = '4'
	SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("weapon_mg_dynamite", "HL2MPTypeDeath", "4", Color(255, 80, 0, 255))
end

SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true

SWEP.WorldModel = "models/weapons/w_grenade.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.ViewModelBoneMods = {
    ["ValveBiped.Grenade_body"] = { scale = Vector(0.326, 0.326, 0.326), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
 
SWEP.VElements = {
    ["dynamite"] = { type = "Model", model = "models/dav0r/tnt/tnt.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(0.657, -0.401, -5.705), angle = Angle(0, 0, 0), size = Vector(0.458, 0.458, 0.458), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
 
SWEP.WElements = {
    ["dynamite"] = { type = "Model", model = "models/dav0r/tnt/tnt.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.164, 1.86, -4.199), angle = Angle(18.398, 10.642, -4.481), size = Vector(0.458, 0.458, 0.458), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:Initialize()
    return self.BaseClass.Initialize(self)
end