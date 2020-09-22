AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Give the player the gravity gun
function GM:PlayerLoadout(ply)
    ply:Give("weapon_physcannon")
end

-- Stat points for picking up objects
function GM:GravGunOnPickedUp(ply, ent)
    ply.HoldingProp = true
end

function GM:GravGunOnDropped(ply, ent)
    ply.HoldingProp = false
end

-- Stat points for throwing
function GM:GravGunPunt(ply, ent)
    local model = ent:GetModel()

    if ply.HoldingProp then
        if model == 'models/props_junk/sawblade001a.mdl' then
            ply:AddStatPoints('Sawblade Tosses', 1)
        else
            ply:AddStatPoints('Props Thrown', 1)
        end
    else
        ply:AddStatPoints('Props Punted', 1)
    end

    ply.HoldingProp = false

    return true
end

-- Tracking held props
hook.Add('PlayerSpawn', 'DropSpawnHook', function(ply)
    ply.HoldingProp = false
end)

-- Double damage
hook.Add('EntityTakeDamage', 'DoubleDamage', function(target, dmginfo)
    if target:IsPlayer() then
        dmginfo:ScaleDamage(2)

        if dmginfo:GetDamage() < 15 then
            dmginfo:SetDamage(dmginfo:GetDamage() * 3.5)
        elseif dmginfo:GetDamage() > 65 then
            dmginfo:SetDamage(150)
        end
    end
end)

-- Register XP for Junk Joust
hook.Add('RegisterStatsConversions', 'AddJunkJoustStatConversions', function()
    GAMEMODE:AddStatConversion('Props Thrown', 'Props Thrown', 0.15)
    GAMEMODE:AddStatConversion('Props Punted', 'Props Punted', 0.05)
    GAMEMODE:AddStatConversion('Sawblade Tosses', 'Sawblade Tosses', 0.5)
end)