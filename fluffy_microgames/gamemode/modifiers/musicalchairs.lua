MOD.Name = 'Musical Chairs'

MOD.SurviveValue = 2

local function spawnChair(pos)
    local ent = ents.Create('prop_vehicle_prisoner_pod')
    ent:SetModel('models/nova/chair_wood01.mdl')
    ent:SetKeyValue('vehiclescript', 'scripts/vehicles/prisoner_pod.txt')
    ent:SetKeyValue('limitview', 0)
    ent:SetPos(pos)

    ent:Spawn()
    ent:Activate()
end

local function spawnChairs()
    local max = GAMEMODE:GetNumberAlive() - 1
    if max < 1 then max = 1 end

    local number = GAMEMODE:PlayerScale(0.75, 1, max) + math.random(-2, 1)
    number = math.Clamp(number, 1, max)

    local positions = GAMEMODE:GetRandomLocations(number, 'crate')
    for i=1,number do
        local pos = positions[i] + Vector(0, 0, 64)
        spawnChair(pos)
    end
end

local function giveGravityGuns()
    if math.random() < 0.5 then return end
    for k,v in pairs(player.GetAll()) do
        v:Give('weapon_physcannon')
    end
end

function MOD:Initialize()
    spawnChairs()
    giveGravityGuns()
    GAMEMODE:Announce("Musical Chairs", "Get in a chair, quick!")
end

function MOD:PlayerFinish(ply)
    if ply:InVehicle() then
        local chair = ply:GetVehicle()
        ply:AwardWin(true)
        ply:ExitVehicle()
        ply:Spawn()

        if IsValid(chair) then
            chair:Remove()
        end
    elseif ply:Alive() then
        ply:Kill()
    end
end