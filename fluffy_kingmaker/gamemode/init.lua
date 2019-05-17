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
    ply:SetRunSpeed(450)
    ply:SetWalkSpeed(350)
    ply:SetMaxHealth(100)
    ply:SetJumpPower(250)
end

function GM:MakeKing(ply)
    ply:StripWeapons()
    ply:SetMaxHealth(150)
    ply:SetHealth(150)
    ply:SetJumpPower(250)
    ply:SetRunSpeed(575)
    ply:SetWalkSpeed(575)
end

-- Stop regi-sui-cide?
function GM:CanPlayerSuicide(ply)
    return not ply:GetNWBool("IsKing", false)
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
    
    -- If the King dies accidentally, make King up for grabs
    if ply:GetNWBool('IsKing', false) and (attacker == ply or !attacker:IsValid() or !attacker:IsPlayer()) then
        ply:SetNWBool('IsKing', false)
        GAMEMODE:PulseAnnouncement(2, 'Nobody is King!', 1)
        GAMEMODE.CurrentKing = nil
        SetGlobalEntity("KingPlayer", NULL)
        return
    end
    
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
    
    -- If the deceased is the King
    if ply:GetNWBool('IsKing', false) then
        ply:SetNWBool('IsKing', false)
        attacker:SetNWBool('IsKing', true)
        attacker:SetNWInt('KingPoints', attacker:GetNWInt('KingPoints', 0) + 1)
        attacker:AddFrags(1)
        attacker:AddStatPoints('Points', 1)
        attacker:AddStatPoints('Regicide', 1)
        GAMEMODE:MakeKing(attacker)
        GAMEMODE.CurrentKing = attacker
        local name = string.sub(attacker:Nick(), 1, 10)
        GAMEMODE:PulseAnnouncement(2, name .. ' is now King!', 1)
        SetGlobalEntity("KingPlayer", attacker)
    end
    
    -- Similar to above, any kills with no king become king
    if not IsValid(GAMEMODE.CurrentKing) then
        attacker:SetNWBool('IsKing', true)
        attacker:SetNWInt('KingPoints', attacker:GetNWInt('KingPoints', 0) + 1)
        attacker:AddFrags(1)
        attacker:AddStatPoints('Points', 1)
        GAMEMODE:MakeKing(attacker)
        GAMEMODE.CurrentKing = attacker
        local name = string.sub(attacker:Nick(), 1, 10)
        GAMEMODE:PulseAnnouncement(2, name .. ' is now King!', 1)
        SetGlobalEntity("KingPlayer", attacker)
    end
    
    -- Do not count deaths unless in round
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    ply:AddDeaths(1)
    ply:AddStatPoints('Death', 1)
    
    -- Delegate this to each gamemode (defaults are provided lower down for reference)
    GAMEMODE:HandlePlayerDeath(ply, attacker, dmginfo)
end

function GM:HandlePlayerDeath(ply, attacker, dmginfo) 
    -- All is handled above!
end

hook.Add('PreRoundStart', 'ResetKing', function()
	for k,v in pairs(player.GetAll()) do
		v:SetNWInt("KingPoints", 0)
        v:SetNWBool("IsKing", false)
	end
    GAMEMODE.CurrentKing = nil
end )

hook.Add('Think', 'KingTimer', function()
    if GetGlobalString('RoundState') != 'InRound' then return end
    if GAMEMODE.LastKingThink and CurTime() >= GAMEMODE.LastKingThink+1 then
        if IsValid(GAMEMODE.CurrentKing) then
            GAMEMODE.CurrentKing:AddFrags(1)
            GAMEMODE.CurrentKing:SetNWInt('KingPoints', GAMEMODE.CurrentKing:GetNWInt('KingPoints', 0) + 1)
            GAMEMODE.CurrentKing:AddStatPoints('Points', 1)
            GAMEMODE.CurrentKing:EmitSound("npc/roller/code2.wav")
            GAMEMODE.LastKingThink = CurTime()
        end
    elseif not GAMEMODE.LastKingThink then
        GAMEMODE.LastKingThink = CurTime()
    end
end)

-- Basic function to get the player with the most frags
function GM:GetWinningPlayer()
    -- Doesn't really make sense in Team gamemodes
    -- if GAMEMODE.TeamBased then return nil end
    
    -- Loop through all players and return the one with the most balls
    local bestscore = 0
    local bestplayer = nil
    for k,v in pairs( player.GetAll() ) do
        local frags = v:GetNWInt("KingPoints")
        if frags > bestscore then
            bestscore = frags
            bestplayer = v
        end
    end
    
    -- Return the winner! Yay!
    return bestplayer
end

-- Remove fall damage
function GM:GetFallDamage( ply, speed )
    return 0
end

-- Attempt to help with seeing the King through walls
hook.Add('SetupPlayerVisibility', 'KingVisible', function(ply)
    if IsValid(GAMEMODE.CurrentKing) then
        AddOriginToPVS(GAMEMODE.CurrentKing:GetPos())
    end
end )

-- Register XP for Kingmaker
hook.Add('RegisterStatsConversions', 'AddKingmakerStatConversions', function()
    GAMEMODE:AddStatConversion('Points', 'King Score', 0.05)
    GAMEMODE:AddStatConversion('Regicide', 'Regicide', 2)
end)