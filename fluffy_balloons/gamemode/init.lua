AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Stat to XP conversions
GM.StatConversions['balloons_popped'] = {'Balloons Popped', 0.05}
GM.StatConversions['balloon_score'] = {'Total Score', 0}

-- Give players the balloon revolver on spawn
function GM:PlayerLoadout( ply )
	ply:StripAmmo()
	ply:StripWeapons()
	ply:Give("balloon_revolver")
end

-- Spawn a balloon at a random spawning entity
function GM:SpawnBalloon()
	local spawnents = ents.FindByClass('balloon_spawner')
	if #spawnents == 0 then return end
	-- Star Balloons  03%
	-- Heart Balloons 12%
	-- Basic Balloons 85%
	local type = "balloon_base"
	if math.random() > 0.97 then
		type = "balloon_star"
	elseif math.random() > 0.85 then
		type = "balloon_heart"
	end
	table.Random(spawnents):SpawnBalloon(type)
end

-- Award score to players when balloons are popped
function GM:PopBalloon(ply, points, type)
	local score = ply:GetNWInt("Balloons", 0)
	ply:SetNWInt("Balloons", score + points)
    ply:AddStatPoints('balloons_popped', 1)
    ply:AddStatPoints('balloon_score', points)
end

-- Reset balloon scores before round starts
hook.Add('PreRoundStart', 'PrepareBalloonPhase', function()
	for k,v in pairs(player.GetAll()) do
		v:SetNWInt("Balloons", 0)
	end
end )

-- Spawn balloons every so often
BalloonSpawnTimer = 0
local Delay = 0.5
hook.Add("Tick", "TickBalloonSpawn", function()
    if GetGlobalString('RoundState') != 'InRound' then return end
	
	if BalloonSpawnTimer < CurTime() then
		BalloonSpawnTimer = CurTime() + Delay
		GAMEMODE:SpawnBalloon()
	end
end )

-- Players can't take damage from each other in this gamemode
function GM:EntityTakeDamage(target, dmginfo)
	if target:IsPlayer() then dmginfo:SetDamage(0) return end
end

-- Basic function to get the player with the most balloons
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