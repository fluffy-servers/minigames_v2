function GM:RegisterPowerUp(key, tbl)
    if not GAMEMODE.PowerUps then GAMEMODE.PowerUps = {}
    if not GAMEMODE.PowerUpTypes then GAMEMODE.PowerUpTypes = {} end
    GAMEMODE.PowerUps[key] = tbl
end

function GM:GetPowerUp(key)
    if not GAMEMODE.PowerUps then return false end
    if not GAMEMODE.PowerUpTypes then return false end
    return GAMEMODE.PowerUps[key]
end

function GM:GetPowerUpTypes()
    if not GAMEMODE.PowerUpTypes then 
        return {}
    else
        return GAMEMODE.PowerUpTypes
    end
end

hook.Add('Initialize', 'InitCallPowerUps', function()
    hook.Call('RegisterPowerUps')
end)

--[[
GM.PowerUps['shotgun'] = {
    Time = 10,
    OnCollect = function(ply)
        ply:Give('weapon_shotgun')
    end,
    
    OnFinish = function(ply)
        ply:StripWeapon('weapon_shotgun')
    end,
    Text = 'Shotgun!',
}

GM.PowerUps['flight'] = {
    Time = 5,
    OnCollect = function(ply)
        ply:SetMoveType(4)
        ply:SetPos( ply:GetPos() + Vector(0, 0, 32))
    end,
    OnFinish = function(ply)
        ply:SetMoveType(2)
    end,
    Text = 'Flight!',
}

GM.PowerUpTypes = {'shotgun', 'flight'}
--]]

function GM:PowerUpExpire(ply)
    if not ply.ActivePowerUp then return end
    local type = ply.ActivePowerUp
    GAMEMODE.PowerUps[type].OnFinish(ply)
    ply.ActivePowerUp = nil
end

function GM:PowerUpApply(ply, type)
    if not GAMEMODE.PowerUps[type] then return end
    ply.ActivePowerUp = type
    
    GAMEMODE.PowerUps[type].OnCollect(ply)
    
    timer.Simple(GAMEMODE.PowerUps[type].Time, function()
        GAMEMODE:PowerUpExpire(ply)
    end)
end

hook.Add('PlayerDeath', 'RemovePowerUpsOnDeath', function(ply)
    if ply.ActivePowerUp then
        local type = ply.ActivePowerUp
        GAMEMODE.PowerUps[type].OnFinish(ply)
        ply.ActivePowerUp = nil
    end
end)