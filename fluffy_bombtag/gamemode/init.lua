AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
include('ply_extension.lua')

function GM:PlayerLoadout(ply)
    ply:SetCarrier(false)
    ply:Give('bt_punch')
end

-- Get a table of all alive players
function GM:GetAlivePlayers()
    local tbl = {}
    for k,v in pairs(player.GetAll() ) do
        if v:Alive() and v:Team() != TEAM_SPECTATOR and !v.Spectating then table.insert(tbl, v) end
    end
    
    return tbl
end

-- Select a bomber at random
function GM:PickBomber()
	for k,v in pairs( player.GetAll() ) do 
		v:SetCarrier( false )
        v:StripWeapon('bt_bomb')
	end
    
    if #GAMEMODE:GetAlivePlayers() < 2 then return end
	
	local newply = table.Random( GAMEMODE:GetAlivePlayers() )
	newply:SetCarrier( true )
	newply:SetTime(math.random(15, 30))
	newply:StripWeapons()
	newply:Give('bt_bomb')
end

-- Pick a new bomb carrier if the current one dies :(
hook.Add('DoPlayerDeath', 'CheckBomb', function(ply)
    if ply:IsCarrier() then
        timer.Simple(1, function() GAMEMODE:PickBomber() end)
    end
end )

hook.Add('RoundStart', 'PickUnluckyStart', function()
    GAMEMODE:PickBomber()
end )

hook.Add('RoundEnd', 'RemoveSpareBombs', function()
	for k,v in pairs(player.GetAll()) do
		v:StripWeapons()
	end
end )

-- Track survived rounds
function GM:StatsRoundWin(winners)
    for k,v in pairs(player.GetAll()) do
        if v:Alive() and !v.Spectating then
            GAMEMODE:AddStatPoints(v, 'survived_rounds', 1)
        end
    end
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
        if !v:Alive() or v == ply or v.Spectating then continue end
        v:AddFrags(1)
        GAMEMODE:AddStatPoints(v, 'bombtag_score', 1)
    end
end