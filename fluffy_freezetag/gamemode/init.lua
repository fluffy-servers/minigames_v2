AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:Give('snowball_cannon')
end

-- Ensure nobody stays frozen between rounds
hook.Add('PreRoundStart', 'ResetFrozenness', function()
    for k,v in pairs(player.GetAll()) do
        v:Thaw()
    end
end)

-- Thaw corpses
hook.Add('DoPlayerDeath', 'ThawCorpses', function(ply)
    ply:Thaw()
end)

-- Get the number of currently frozen players on a given team
function GM:GetFrozenPlayers(t)
    local num = 0
    for k,v in pairs(team.GetPlayers(t)) do
        if v:IsIceFrozen() then num = num + 1 end
    end
    
    return num
end

-- Check for victory conditions when a player gets frozen
-- If the number of frozen players is more than the number of living players then there's an issue
function GM:CheckVictory()
    if GAMEMODE:GetTeamLivingPlayers(1) - GAMEMODE:GetFrozenPlayers(1) < 1 then
        GAMEMODE:EndRound(2)
    elseif GAMEMODE:GetTeamLivingPlayers(2) - GAMEMODE:GetFrozenPlayers(2) < 1 then
        GAMEMODE:EndRound(1)
    end
end

-- Custom damage hook to handle freezeing
function GM:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if not ent:Alive() then return end
    
    local attacker = dmg:GetAttacker()
    if not attacker:IsPlayer() then return end
    
    -- No damage in this gamemode
    if ent:IsIceFrozen() then
        dmg:SetDamage(0)
        return 
    end
    
    local amount = dmg:GetDamage()
    if ent:Health() - amount <= 0 then
        if attacker:Team() != ent:Team() then
            -- Freeze!
            dmg:SetDamage(0)
            ent:SetHealth(1)
            ent:AddDeaths(1)
            ent:IceFreeze()
            
            attacker:AddFrags(1)
            attacker:AddStatPoints('Enemies Frozen', 1)
            GAMEMODE:CheckVictory()
            
            net.Start('PlayerKilledByPlayer')
                net.WriteEntity(ent)
                net.WriteString('snowball_cannon')
                net.WriteEntity(attacker)
            net.Broadcast()
        end
    end
end

-- Unfreeze players when E is pressed
hook.Add('PlayerUse', 'FreezeTagUse', function(ply, ent)
    -- Check for players on the same team
    if not ent:IsPlayer() then return end
    if ent:Team() != ply:Team() then return end
    
    -- Unfreeze the player
    if ent:IsIceFrozen() and not ply:IsIceFrozen() then
        ent:Thaw()
        ply:AddStatPoints('Allies Thawed', 1)
    end
end)

local meta = FindMetaTable('Player')

function meta:Thaw()
    self:SetWalkSpeed(250)
    self:SetRunSpeed(500)
    self:SetJumpPower(200)
    
    self:SetMaterial()
    self:SetColor(color_white)
    self:SetHealth(100)
    GAMEMODE:PlayerLoadout(self)
    
    self:SetNWBool('Frozen', false)
end

function meta:IceFreeze()
    self:SetWalkSpeed(10)
    self:SetRunSpeed(10)
    self:SetJumpPower(1)
    
    self:SetMaterial('models/debug/debugwhite')
    self:SetColor(Color(199, 236, 238))
    self:StripWeapons()
    
    self:SetNWBool('Frozen', true)
    
    -- Very briefly freeze the player to prevent sprint bug
    self:Freeze(true)
    timer.Simple(0.5, function()
        if IsValid(self) then self:Freeze(false) end
    end)
end

-- Register XP for Freeze Tag
hook.Add('RegisterStatsConversions', 'AddFreezeTagStatConversions', function()
    GAMEMODE:AddStatConversion('Allies Thawed', 'Allies Thawed', 1)
    GAMEMODE:AddStatConversion('Enemies Frozen', 'Enemies Frozen', 0.5)
end)