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
    ply:SetRunSpeed(500)
    ply:SetWalkSpeed(300)
    ply:SetMaxHealth(100)
end

function GM:MakeKing(ply)
    ply:SetMaxHealth(250)
    ply:SetHealth(250)
    ply:SetJumpPower(500)
    ply:SetRunSpeed(1000)
    ply:SetWalkSpeed(1000)
end

-- Death function
function GM:DoPlayerDeath(ply, attacker, dmginfo)
    -- Always make the ragdoll
    ply:CreateRagdoll()
    
    -- Play a funny death sound
    if GAMEMODE.DeathSounds then
        local gender = GAMEMODE:DetermineModelGender(ply:GetModel())
        local sound = GAMEMODE:GetRandomDeathSound(gender)
        ply:EmitSound(sound)
    end
    
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
    
    -- If the attacker is the King
    if attacker:GetNWBool('IsKing', false) then
        attacker:SetNWInt('KingFrags', attacker:GetNWInt('KingFrags', 0) + 1)
        attacker:AddFrags(1)
        attacker:AddStatPoints('KingFrags', 1)
    end
    
    -- If the deceased is the King
    if ply:GetNWBool('IsKing', false) then
        ply:SetNWBool('IsKing', false)
        attacker:SetNWBool('IsKing', true)
        attacker:SetNWInt('KingFrags', attacker:GetNWInt('KingFrags', 0) + 1)
        attacker:AddFrags(1)
        attacker:AddStatPoints('KingEliminations', 1)
        GAMEMODE:MakeKing(attacker)
    end
    
    -- Do not count deaths unless in round
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, 'deaths', 1)
    
    -- Delegate this to each gamemode (defaults are provided lower down for reference)
    GAMEMODE:HandlePlayerDeath(ply, attacker, dmginfo)
end

hook.Add('RoundStart', 'ResetBalls', function()
	for k,v in pairs(player.GetAll()) do
		v:SetNWInt("KingFrags", 0)
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
        local frags = v:GetNWInt("KingFrags")
        if frags > bestscore then
            bestscore = frags
            bestplayer = v
        end
    end
    
    -- Return the winner! Yay!
    return bestplayer
end