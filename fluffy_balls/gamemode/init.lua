AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function GM:PlayerLoadout(ply)
    ply:StripAmmo()
    ply:StripWeapons()
    ply:Give("weapon_smg1")
	ply:Give("weapon_shotgun")
    ply:GiveAmmo(512, "SMG1", true)
	ply:GiveAmmo(512, "Buckshot", true)
end

function GM:CollectBall(ply)
	local balls = ply:GetNWInt("Balls", 0)
	ply:SetNWInt("Balls", balls+1)
	GAMEMODE:AddStatPoints(ply, 'total_balls', 1)
	
	local hp = ply:Health()
	ply:SetHealth(hp + 10)
	
	if hp >= 90 then
		ply:SetHealth(100)
	end
end

-- Death function
function GM:DoPlayerDeath(ply, attacker, dmginfo)
    -- Always make the ragdoll
    ply:CreateRagdoll()
    
    local balls = ply:GetNWInt("Balls", 0)
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
    ply:SetNWInt("Balls", 0)
    
    -- Play a funny death sound
    if GAMEMODE.DeathSounds then
        local gender = GAMEMODE:DetermineModelGender(ply:GetModel())
        local sound = GAMEMODE:GetRandomDeathSound(gender)
        ply:EmitSound(sound)
    end

    -- Do not count deaths unless in round
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, 'deaths', 1)
    
    -- Delegate this to each gamemode (defaults are provided lower down for reference)
    GAMEMODE:HandlePlayerDeath(ply, attacker, dmginfo)
    
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
end

hook.Add('RoundStart', 'ResetBalls', function()
	for k,v in pairs(player.GetAll()) do
		v:SetNWInt("Balls", 0)
	end
end )

-- Basic function to get the player with the most frags
function GM:GetWinningPlayer()
    -- Doesn't really make sense in Team gamemodes
    -- if GAMEMODE.TeamBased then return nil end
    
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