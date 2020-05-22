MOD.Name = "Rocket Jump!"
MOD.Countdown = true

MOD.SurviveValue = 2
MOD.RoundTime = 20

local function spawnPlatforms()
    local number = GAMEMODE:PlayerScale(0.3, 2, 25) + math.random(0, 2)
    local positions = GAMEMODE:GetRandomLocations(number, 'sky')

    for i=1,number do
        local pos = positions[i]
        local ent = ents.Create("prop_physics")
        ent:SetPos(pos)
        ent:SetModel('models/props_phx/construct/metal_angle360.mdl')
        ent:Spawn()

        ent:GetPhysicsObject():EnableMotion(false)
    end
end

local function spawnInitialSawblades()
    local number = math.floor(GAMEMODE:PlayerScale(1, 3, 10) * 1.5)
    local positions = GAMEMODE:GetRandomLocations(number, 'crate')

    for i=1, number do
        spawnSawblade(positions[i])
    end
end

local function spawnSawblade(position)
    if not position then
        position = GAMEMODE:GetRandomLocations(1, 'crate')[0]
    end

    local saw = ents.Create("prop_physics")
    saw:SetModel("models/props_junk/sawblade001a.mdl")
    saw:SetPos(positions[i] + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 1) * 8)
    saw:Spawn()
end

function MOD:Initialize()
    spawnPlatforms()
    spawnInitialSawblades()
    GAMEMODE:Announce("Build to the top!")
end

MOD.ThinkTime = 1
function MOD:Think()
    spawnSawblade()
end

function MOD:Loadout(ply)
    ply:Give('weapon_physcannon')
end

function MOD:GravGunPunt(ply, ent)
    if not ply:IsPlayer() then return end

    local phys = ent:GetPhysicsObject()
    if phys:IsValid() then
        if phys:IsMotionEnabled() then
            phys:EnableMotion(false)
        else
            phys:EnableMotion(true)
        end
    end
end

function MOD:PlayerFinish(ply)
    local ground = ply:GetGroundEntity()
    if IsValid(ground) and ground:GetModel() == 'models/props_phx/construct/metal_angle360.mdl' then
        ply:AwardWin(true)
    else
        ply:Kill()
    end
end

