-- Register a powerup to the powerups table
-- See sections below for powerup examples
function GM:RegisterPowerUp(key, tbl)
    if not GAMEMODE.PowerUps then GAMEMODE.PowerUps = {} end
    GAMEMODE.PowerUps[key] = tbl
end

-- Get the power up table for a given type
function GM:GetPowerUp(key)
    if not GAMEMODE.PowerUps then return false end
    return GAMEMODE.PowerUps[key]
end

-- Get a list of all currently registered powerup types
function GM:GetPowerUpTypes()
    if not GAMEMODE.PowerUps then return false end
    return table.GetKeys(GAMEMODE.PowerUps)
end

-- Hook to register powerups on server initialization
hook.Add('Initialize', 'InitCallPowerUps', function()
    hook.Call('RegisterPowerUps')
end)

-- Register a few 'default' powerup types
-- Not called automatically! Use in RegisterPowerUps hook in gamemodes
function GM:RegisterDefaultPowerUps()
    GAMEMODE:RegisterPowerUp('speed', {
        Text = 'Super Speed!',
        Time = 10,
        OnCollect = function(ply)
            ply.PrevWalkSpeed = ply:GetWalkSpeed()
            ply.PrevRunSpeed = ply:GetRunSpeed()
            
            ply:SetWalkSpeed(ply.PrevWalkSpeed * 2)
            ply:SetRunSpeed(ply.PrevRunSpeed * 3)
        end,
        OnFinish = function(ply)
            ply:SetWalkSpeed(ply.PrevWalkSpeed)
            ply:SetRunSpeed(ply.PrevRunSpeed)
        end,
    })
    
    GAMEMODE:RegisterPowerUp('lowgrav', {
        Text = 'Low Gravity!',
        Time = 15,
        OnCollect = function(ply)
            ply:SetGravity(0.25)
        end,
        OnFinish = function(ply)
            ply:SetGravity(1)
        end,
    })
end

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
--]]

-- Applied to a player when a powerup expires
function GM:PowerUpExpire(ply)
    if not GAMEMODE.PowerUps then return end
    if not ply.ActivePowerUp then return end
    local type = ply.ActivePowerUp
    GAMEMODE.PowerUps[type].OnFinish(ply)
    ply.ActivePowerUp = nil
end

-- Apply a certain powerup to a player
function GM:PowerUpApply(ply, type, announce)
    if not GAMEMODE.PowerUps then return end
    if not GAMEMODE.PowerUps[type] then return end
    ply.ActivePowerUp = type
    
    GAMEMODE.PowerUps[type].OnCollect(ply)
    
    if announce then
        GAMEMODE:PlayerOnlyAnnouncement(ply, 3, GAMEMODE.PowerUps[type].Text, 1)
    end
    
    timer.Simple(GAMEMODE.PowerUps[type].Time, function()
        GAMEMODE:PowerUpExpire(ply)
    end)
end

-- Can a player get a new powerup
function GAMEMODE:CanHavePowerUp(ply)
    if not GAMEMODE.PowerUps then return false end
    return (ply.ActivePowerUp == nil)
end

-- Hook to remove powerups when a player dies
hook.Add('PlayerDeath', 'RemovePowerUpsOnDeath', function(ply)
    if ply.ActivePowerUp then
        local type = ply.ActivePowerUp
        GAMEMODE.PowerUps[type].OnFinish(ply)
        ply.ActivePowerUp = nil
    end
end)

-- Player metatable versions of some above functions
local meta = FindMetaTable("Player")
function meta:PowerUpApply(type, announce)
    GAMEMODE:PowerUpApply(self, type, announce)
end

function meta:PowerUpExpire()
    GAMEMODE:PowerUpExpire(self)
end

function meta:CanHavePowerUp()
    GAMEMODE:CanHavePowerUp(self)
end