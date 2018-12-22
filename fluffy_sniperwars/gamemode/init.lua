AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout( ply )
	ply:Give( "sniper_normal" )
	ply:Give( "firearm_p228" )
	--ply:Give( "weapon_translocator" )
    ply:Give( "weapon_mg_knife" )
end

-- Remove fall damage
function GM:GetFallDamage( ply, speed )
    return 0
end

-- Add frags to player & team when someone dies
function GM:HandlePlayerDeath(ply, attacker, dmginfo) 
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
    
    -- Add the frag to scoreboard
    attacker:AddFrags(GAMEMODE.KillValue)
    GAMEMODE:AddStatPoints(attacker, 'kills', 1)

    -- Add the point to the team
    if attacker:Team() != TEAM_RED and attacker:Team() != TEAM_BLUE then return end
    team.AddScore(attacker:Team(), 1)
end

-- Hopefully fix Sniper Wars scoring
function GM:HandleTeamWin(reason)
    local winners = reason -- Default: set to winning team in certain gamemodes
    local msg = 'The round has ended!'
    
    if reason == 'TimeEnd' then
        if team.GetScore(2) < team.GetScore(1) then
            winners = 1
            msg = team.GetName(1) .. ' win the round!'
        elseif team.GetScore(2) > team.GetScore(1) then
            winners = 2
            msg = team.GetName(2) .. ' win the round!'
        else
            winners = 0
            msg = 'Draw! Both teams are tied!'
        end
    end
    
    return winners, msg
end

hook.Add('RegisterPowerUps', 'SniperWarsPowerUps', function()
    GAMEMODE:RegisterPowerUp('give_shotgun', {
        Time = 0,
        OnCollect = function(ply)
            ply:Give('weapon_shotgun')
            ply:GiveAmmo(12, 'BuckShot')
        end,
        Text = 'Shotgun!',
    })
    
    GAMEMODE:RegisterPowerUp('give_revolver', {
        Time = 0,
        OnCollect = function(ply)
            ply:Give('weapon_357')
            ply:GiveAmmo(10, '357')
        end,
        Text = 'Revolver!',
    })
    
    GAMEMODE:RegisterPowerUp('give_rpg', {
        Time = 0,
        OnCollect = function(ply)
            ply:Give('weapon_rpg')
        end,
        Text = 'Revolver!',
    })
end)