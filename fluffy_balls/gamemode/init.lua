AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Players are given a shotgun and an SMG
function GM:PlayerLoadout(ply)
    ply:StripAmmo()
    ply:StripWeapons()
    ply:Give("weapon_mg_pistol")
    ply:Give("weapon_mg_smg")
	ply:Give("weapon_mg_shotgun")
    ply:GiveAmmo(512, "Pistol", true)
    ply:GiveAmmo(512, "SMG1", true)
	ply:GiveAmmo(512, "Buckshot", true)
end

-- Called when a player picks up a ball
function GM:CollectBall(ply)
	local balls = ply:GetNWInt("Balls", 0)
	ply:SetNWInt("Balls", balls+1)
	GAMEMODE:AddStatPoints(ply, 'Balls Collected', 1)
    
    ply:EmitSound('buttons/blip1.wav', 50, math.Clamp(100 + balls*5, 100, 255))
	
	local hp = ply:Health()
	ply:SetHealth(hp + 5)
	
	if hp >= 195 then
		ply:SetHealth(200)
	end
end

-- Death function
function GM:DoPlayerDeath(ply, attacker, dmginfo)
    -- Always make the ragdoll
    ply:CreateRagdoll()
    
    -- Drop up to 15 balls, + up to 4 additional balls
    local balls = math.min(ply:GetNWInt("Balls", 0), 15)
    for i=math.random(-4, 0),balls do
		local b = ents.Create('mg_ball_drop')
		local p = ply:GetPos() + Vector(0, 0, 50)
		local v = Vector( math.random(-40, 40), math.random(-40, 40), math.random(-40, 40) )
		local vel = Vector( math.random(-30, 50), math.random(-30, 50), math.random(-20, 80) )
		b:SetPos(p + v)
		b:SetVelocity(vel)
		b:Spawn()

        local c3 = ply:GetPlayerColor()
        b:SetBallColor(c3)
    end
    
    -- Reduce the amount of player balls
    local new_balls = math.max(ply:GetNWInt("Balls", 0) - balls, 0)
    ply:SetNWInt("Balls", new_balls)
    
    -- Play a funny death sound
    if GAMEMODE.DeathSounds then
        local gender = GAMEMODE:DetermineModelGender(ply:GetModel())
        local sound = GAMEMODE:GetRandomDeathSound(gender)
        ply:EmitSound(sound)
    end

    -- Do not count deaths unless in round
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, 'Deaths', 1)
    
    -- Delegate this to each gamemode (defaults are provided lower down for reference)
    GAMEMODE:HandlePlayerDeath(ply, attacker, dmginfo)
    
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
end

-- Reset the player balls count at the start at each round
hook.Add('RoundStart', 'ResetBalls', function()
	for k,v in pairs(player.GetAll()) do
		v:SetNWInt("Balls", 0)
	end
end )

-- The winning player is the player with the most balls at the end of a round
function GM:GetWinningPlayer()
    -- Loop through all players and return the one with the most balls
    local bestscore = 0
    local bestplayer = nil
    for k,v in pairs( player.GetAll() ) do
        local frags = v:GetNWInt("Balls")
        if frags > bestscore then
            bestscore = frags
            bestplayer = v
        end
    end
    
    -- Return the winner! Yay!
    return bestplayer
end

-- Register XP for Balls
hook.Add('RegisterStatsConversions', 'AddBallsStatConversions', function()
    GAMEMODE:AddStatConversion('Balls Collected', 'Total Balls', 0.05)
end)