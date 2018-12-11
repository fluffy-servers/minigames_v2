function GM:RegisterPowerup(key, tbl)
    if not GAMEMODE.PowerUps then GAMEMODE.PowerUps = {}
    if not GAMEMODE.PowerUpTypes then GAMEMODE.PowerUpTypes = {} end
    GAMEMODE.PowerUps[key] = tbl
end

hook.Add('Initialize', 'InitCallPowerUps', function()
    hook.Call('RegisterPowerups')
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
    if not ply.ActivePowerup then return end
    local type = ply.ActivePowerup
    GAMEMODE.PowerUps[type].OnFinish(ply)
    ply.ActivePowerup = nil
end

function GM:PowerUpApply(ply, type)
    if not GAMEMODE.PowerUps[type] then return end
    ply.ActivePowerup = type
    
    GAMEMODE.PowerUps[type].OnCollect(ply)
    
    timer.Simple(GAMEMODE.PowerUps[type].Time, function()
        GAMEMODE:PowerUpExpire(ply)
    end)
end

hook.Add('PlayerDeath', 'RemovePowerupsOnDeath', function(ply)
    if ply.ActivePowerup then
        local type = ply.ActivePowerup
        GAMEMODE.PowerUps[type].OnFinish(ply)
        ply.ActivePowerup = nil
    end
end)