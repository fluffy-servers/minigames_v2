AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function GM:PlayerLoadout( ply )
    ply:Give( 'weapon_platformbreaker' )
    ply:SetWalkSpeed( 350 )
    ply:SetRunSpeed( 360 )
end

function GM:PlayerSelectSpawn( pl )
    local spawns = ents.FindByClass( "info_player_start" )
    if(#spawns <= 0) then return false end
    local selected = table.Random( spawns )
    while selected.spawnUsed do
        selected = table.Random( spawns )
    end
    
    selected.spawnUsed = true
    return selected
end

function GM:GetFallDamage( ply, vel )
    return vel/7
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
    -- Always make the ragdoll
    ply:CreateRagdoll()
    
    -- Do not count deaths unless in round
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, 'deaths', 1)
    
    -- Every living players earns a point
    for k,v in pairs(player.GetAll()) do
        if !v:Alive() or v == ply then continue end
        v:AddFrags(1)
        GAMEMODE:AddStatPoints(v, 'pitfall_score', 1)
    end
end