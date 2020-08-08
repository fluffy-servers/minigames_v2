AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
include('sv_levelgen.lua')

-- Crowbar to start with
function GM:PlayerLoadout(ply)
    ply:SetJumpPower(250)
    ply:SetWalkSpeed(250)
    ply:SetRunSpeed(250)
end

-- Calculations to check player scoring based on height
function GM:PlayerTick(ply)
    if not GAMEMODE:InRound() then return end
    
    local z = ply:GetPos().z
    if not z then return end
    if not ply:Alive() or ply.Spectating then return end

    if z < GAMEMODE:GetLavaHeight() then
        ply:Kill()
    end
end