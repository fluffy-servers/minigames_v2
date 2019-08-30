AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
include('sv_levelgen.lua')

-- Nobody wins in Climb ?
-- Used to override default functionality on FFA round end
function GM:GetWinningPlayer()
    return nil
end

-- No weapons
function GM:PlayerLoadout(ply)
    ply:SetJumpPower(250)
    ply:SetWalkSpeed(250)
    ply:SetRunSpeed(250)
end

-- Remove fall damage
function GM:GetFallDamage(ply, vel)
    return 0
end

-- Calculations to check player scoring based on height
function GM:PlayerTick(ply)
    if GetGlobalString('RoundState') != 'InRound' then return end
    
    local z = ply:GetPos().z
    if not z then return end
    if not ply:Alive() or ply.Spectating then return end
    if not ply.BestHeight then ply.BestHeight = 0 end
    
    if z > GAMEMODE.CurrentHeight then
        GAMEMODE:ClimbVictory(ply)
    elseif z > ply.BestHeight then
        ply.BestHeight = z
    elseif z < GAMEMODE:GetLavaHeight() then
        ply:Kill()
    end
end

hook.Add('PreRoundStart', 'GenerateClimbLevel', function()
    -- Generate the level
    local height = GAMEMODE:GenerateLevel()
    GAMEMODE.CurrentHeight = height
    SetGlobalInt('ClimbHeight', height)
    
    -- Reset best heights
    for k,v in pairs(player.GetAll()) do
        v.BestHeight = nil
    end
end)

-- Add scoring based on height at the end of a round
-- Takes the best height, rounds down to the nearest 10% and adds 1 point per 10%
-- eg. 48% -> 40% -> 4 points
hook.Add('RoundEnd', 'ClimbHeightPoints', function()
    for k,v in pairs(player.GetAll()) do
        if v.BestHeight then
            local ratio = v.BestHeight/GAMEMODE.CurrentHeight
            local p = math.Clamp(math.floor(ratio * 100), 0, 100)
            v:AddStatPoints('Distance', p)
            v:AddFrags(math.floor(p/10))
        end
        
        if v:Alive() and not v.Spectating then
            v:AddFrags(1)
            v:AddStatPoints('Survived Rounds', 1)
        end
    end
end)

-- Function to be called when a player wins the round
-- This should only occur for the first player to reach the top
function GM:ClimbVictory(ply)
    if GetGlobalString('RoundState') != 'InRound' then return end
    
    ply:AddFrags(3)
    ply.BestHeight = GAMEMODE.CurrentHeight
    GAMEMODE:EndRound(ply)
    
    GAMEMODE:EntityCameraAnnouncement(ply, GAMEMODE.RoundCooldown or 5)
end

-- Register XP for Paintball
hook.Add('RegisterStatsConversions', 'AddClimbStatConversions', function()
    GAMEMODE:AddStatConversion('Distance', 'Distance Climbed', 0.01)
end)