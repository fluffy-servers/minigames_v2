MOD.Name = 'Musical Chairs'

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
    local max = GAMEMODE:NumNonSpectators() - 1
    local number = GAMEMODE:PlayerScale(0.8, 1, max) + math.random(-2, 1)
    number = math.Clamp(number, 1, max)
    local positions = GAMEMODE:GetRandomLocations(number, 'crate')

    for i=1,number do
        local pos = positions[i] + Vector(0, 0, 64)
        spawnChair(pos)
    end
end

function MOD:Initialize()
    GAMEMODE:Announce("Don't stop moving!")
    timer.Create("MusicalChairsTimer", 5, 1, function()
        spawnChairs()
        GAMEMODE:Announce("Musical Chairs", "Get in a chair, quick!")
    end)
end

function MOD:Cleanup()
    timer.Destroy("MusicalChairsTimer")
end

function MOD:PlayerFinish(ply)
    if ply:InVehicle() then
        local chair = ply:GetVehicle()
        ply:AddFrags(1)
        ply:ExitVehicle()

        if IsValid(chair) then
            chair:Remove()
        end
    elseif GAMEMODE:GetNumberAlive() >= 2 then
        ply:Kill()
    end
end

MOD.ThinkTime = 0.1
function MOD:Think()
    if CurTime() < GAMEMODE.ModifierStart + 1.5 then return end
    if CurTime() > GAMEMODE.ModifierStart + 5 then return end

    for k,v in pairs(player.GetAll()) do
        if not v:Alive() or v.Spectating then continue end
        if v:GetVelocity():LengthSqr() < 5000 then
            v:Kill()
        end
    end
end