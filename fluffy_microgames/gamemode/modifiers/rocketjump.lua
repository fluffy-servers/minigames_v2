MOD.Name = "Rocket Jump!"
MOD.Countdown = true
MOD.SurviveValue = 2

local function spawnPlatforms()
    local number = GAMEMODE:PlayerScale(0.3, 2, 25) + math.random(0, 2)
    local positions = GAMEMODE:GetRandomLocations(number, "sky")

    for i = 1, number do
        local pos = positions[i]
        local ent = ents.Create("prop_physics")
        ent:SetPos(pos)
        ent:SetModel("models/props_phx/construct/metal_angle360.mdl")
        ent:Spawn()
        ent:GetPhysicsObject():EnableMotion(false)
    end
end

function MOD:Initialize()
    spawnPlatforms()
    GAMEMODE:Announce("Rocket Jump!", "Land on a platform")
end

function MOD:Loadout(ply)
    ply:Give("weapon_rpg")
    ply:GiveAmmo(10, "RPG_Round")
end

function MOD:EntityTakeDamage(ply, dmg)
    dmg:SetDamage(0)
    ply:SetVelocity(dmg:GetDamageForce() * 0.0225)
end

function MOD:PlayerFinish(ply)
    local ground = ply:GetGroundEntity()

    if IsValid(ground) and ground:GetModel() == "models/props_phx/construct/metal_angle360.mdl" then
        ply:AwardWin(true)
    else
        ply:Kill()
    end
end