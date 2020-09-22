AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Appropiate weapon stuff
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()

    if ply:Team() == TEAM_BLUE then
        -- Survivors
        -- ply:Give('weapon_mg_pistol')
        -- ply:Give('weapon_mg_smg')
        -- ply:Give('weapon_mg_shotgun')
        ply:Give('inf_shotgun')
        ply:Give('inf_magnum')
        ply:Give('inf_smg')
        ply:Give('inf_adrenaline')
        ply:GiveAmmo(80, 'Pistol', true)
        ply:GiveAmmo(2400, 'Buckshot', true)
        ply:GiveAmmo(1024, 'SMG1', true)
        GAMEMODE:SetHumanSpeed(ply)
        GAMEMODE:SetAdrenalineFOV(ply, 0)
        ply:SetBloodColor(BLOOD_COLOR_RED)
        ply:SetJumpPower(200)
    elseif ply:Team() == TEAM_RED then
        -- Infected
        -- Initial infected are stronger but slower
        local color = team.GetColor(TEAM_RED)
        ply:SetPlayerColor(Vector(color.r / 255, color.g / 255, color.b / 255))
        ply:SetBloodColor(BLOOD_COLOR_GREEN)

        if ply.InitialHunter then
            ply:SetMaxHealth(85)
            ply:SetHealth(85)
        else
            ply:SetMaxHealth(50)
            ply:SetHealth(50)
        end

        ply:SetRunSpeed(400)
        ply:SetWalkSpeed(400)
        ply:SetJumpPower(300)
        ply:Give('weapon_fists')
    end
end

function GM:SetHumanSpeed(ply)
    ply:SetRunSpeed(275)
    ply:SetWalkSpeed(275)
end

function GM:SetAdrenalineFOV(ply, fov)
    print(ply, fov)
    ply.adrenaline_fov = fov
    ply:SetFOV(fov, 0.5)
end

hook.Add('PlayerSwitchWeapon', 'AdrenalineWeaponSwitch', function(ply, old, new)
    if ply.adrenaline_fov then
        ply:SetFOV(ply.adrenaline_fov, 0)
    end
end)

-- Pick player models
function GM:PlayerSetModel(ply)
    if ply:Team() == TEAM_RED then
        if ply.InitialHunter then
            ply:SetModel("models/player/zombie_classic.mdl")
        else
            ply:SetModel("models/player/zombie_fast.mdl")
        end
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Humans can stil commit suicide
function GM:CanPlayerSuicide(ply)
    if ply:Team() == TEAM_RED then return false end

    return true
end

-- Track survived rounds
function GM:StatsRoundWin(winners)
    if winners == TEAM_BLUE then
        for k, v in pairs(team.GetPlayers(TEAM_BLUE)) do
            if v:Alive() then
                GAMEMODE:AddStatPoints(v, 'survived_rounds', 1)
            end
        end
    end
end

-- Buff fists
hook.Add('EntityTakeDamage', 'BuffFists', function(target, dmg)
    local wep = dmg:GetInflictor()

    if wep:GetClass() == 'player' then
        wep = wep:GetActiveWeapon()
    end

    if wep:GetClass() == 'weapon_fists' then
        dmg:ScaleDamage(20)
        dmg:SetDamageForce(dmg:GetDamageForce() * 50)
    end
end)