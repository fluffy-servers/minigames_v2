AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:Give('snowball_cannon')
end

-- Get the number of currently frozen players on a given team
function GM:GetFrozenPlayers(t)
    local num = 0
    for k,v in pairs(team.GetPlayers(t)) do
        if v:IsIceFrozen() then num = num + 1 end
    end
end

function GM:CheckVictory()
    -- Todo
end

-- Custom damage hook to handle freezeing
function GM:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if not ent:Alive() then return end
    
    if ent:IsIceFrozen() then 
        return 
    else
        dmg:SetDamage(0)
    end
    
    local attacker = dmg:GetAttacker()
    if attacker:Team() != ent:Team() then
        -- Freeze!
        ent:SetHealth(1)
        ent:AddDeaths(1)
        ent:IceFreeze()
        
        attacker:AddFrags(1)
        GAMEMODE:CheckVictory()
    end
end

-- Unfreeze players when E is pressed
hook.Add('PlayerUse', 'FreezeTagUse', function(ply, ent)
    -- Check for players on the same team
    if not ent:IsPlayer() then return end
    if ent:Team() != ply:Team() then return end
    
    -- Unfreeze the player
    if ent:IsIceFrozen() then
        ent:Thaw()
    end
end)

local meta = FindMetaTable('Player')

function meta:Thaw()
    self:Freeze(false)
    
    self:SetMaterial()
    self:SetColor(color_white)
    self:SetHealth(100)
    
    self:SetNWBool('Frozen', false)
end

function meta:IceFreeze()
    self:Freeze(true)
    
    self:SetMaterial('models/debug/debugwhite')
    self:SetColor(Color(171, 209, 243))
    
    self:SetNWBool('Frozen', true)
end

function meta:IsIceFrozen()
    return self:GetNWBool('Frozen', false)
end