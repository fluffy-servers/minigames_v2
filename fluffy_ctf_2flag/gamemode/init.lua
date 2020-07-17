AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Triggered when a goal is scored
function GM:ScoreGoal(team, entity)
    if not GAMEMODE:InRound() then return end
    
    local message = nil
    local carrier = entity.LastCarrier
    -- Bonus to the person who scores the capture
    if IsValid(carrier) then
        carrier:AddFrags(3)
        carrier:AddStatPoints('CTFCaptures', 1)
        message = carrier:Nick() .. ' scored the capture'
    end
    
    -- End the round, counting a win for the given team
    GAMEMODE:EndRound(team, message)
end

-- Dissolve any players that get killed with the flag
function GM:EntityTakeDamage(target, dmginfo)
    local inflictor = dmginfo:GetInflictor()
    if inflictor:GetClass() == 'ctf_flag_blue' then
        if target:Team() == TEAM_BLUE then return true end
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetAttacker(inflictor.LastCarrier)
    elseif inflictor:GetClass() == 'ctf_flag_red' then
        if target:Team() == TEAM_RED then return true end
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetAttacker(inflictor.LastCarrier)
    end
    if inflictor:GetClass() == 'ctf_flag' then
        -- Block damage for teammates
        if target:Team() == GetGlobalInt('HoldingTeam', 0) then return true end
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetAttacker(GAMEMODE.LastCarrier)
    end
end

function GM:DoPlayerDeath(ply, attacker, inflictor)
    if ply:HasWeapon('weapon_ctf_flag_red') then
        ply:GetWeapon('weapon_ctf_flag_red'):TossFlag(200)
    end

    if ply:HasWeapon('weapon_ctf_flag_blue') then
        ply:GetWeapon('weapon_ctf_flag_blue'):TossFlag(200)
    end
    
    GAMEMODE.BaseClass:DoPlayerDeath(ply, attacker, inflictor)
end