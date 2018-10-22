AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function GM:PlayerLoadout( ply )
	ply:StripAmmo()
	ply:StripWeapons()
	ply:Give("balloon_revolver")
end

function GM:SpawnBalloon()
	local spawnents = ents.FindByClass('balloon_spawner')
	if #spawnents == 0 then return end
	local type = "balloon_base"
	if math.random() > 0.97 then
		type = "balloon_star"
	elseif math.random() > 0.85 then
		type = "balloon_heart"
	end
	table.Random(spawnents):SpawnBalloon(type)
end

function GM:PopBalloon(ply, points, type)
	local score = ply:GetNWInt("Balloons", 0)
	ply:SetNWInt("Balloons", score + points)
end

hook.Add('RoundStart', 'PrepareCratePhase', function()
	for k,v in pairs(player.GetAll()) do
		v:SetNWInt("Balloons", 0)
	end
end )

-- Prop
BalloonSpawnTimer = 0
local Delay = 0.5
hook.Add("Tick", "TickBalloonSpawn", function()
    if GetGlobalString('RoundState') != 'InRound' then return end
	
	if BalloonSpawnTimer < CurTime() then
		BalloonSpawnTimer = CurTime() + Delay
		GAMEMODE:SpawnBalloon()
	end
end )

function GM:EntityTakeDamage(target, dmginfo)
	if target:IsPlayer() then dmginfo:SetDamage(0) return end
end

-- Basic function to get the player with the most frags
function GM:GetWinningPlayer()
    -- Doesn't really make sense in Team gamemodes
    -- if GAMEMODE.TeamBased then return nil end
    
    -- Loop through all players and return the one with the most balls
    local bestscore = 0
    local bestplayer = nil
    for k,v in pairs( player.GetAll() ) do
        local frags = v:GetNWInt("Balloons", 0)
        if frags > bestscore then
            bestscore = frags
            bestplayer = v
        end
    end
    
    -- Return the winner! Yay!
    return bestplayer
end