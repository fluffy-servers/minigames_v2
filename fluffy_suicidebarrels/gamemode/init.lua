AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Appropiate weapon stuff
function GM:PlayerLoadout( ply )
    if ply:Team() == TEAM_BLUE then
        ply:GiveAmmo( 1800, "pistol", true )
        ply:Give( "weapon_barrel_killa" )
        
        ply:SetWalkSpeed( 200 )
        ply:SetRunSpeed( 250 )
    elseif ply:Team() == TEAM_RED then
        ply:StripWeapons()
        ply.NextTaunt = CurTime() + 1
        ply.NextBoom = CurTime() + 2
        --ply:SetViewOffset( Vector( 0, 0, 64 ) )
        
        ply:SetWalkSpeed( 300 )
        ply:SetRunSpeed( 175 )
    end
end

-- Pick player models
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        ply:SetModel( "models/props_c17/oildrum001_explosive.mdl" )
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Make suicide barrels go boom when they die
hook.Add('PlayerDeath', 'SuicideBarrelsDeath', function( ply )
    if ply:Team() == TEAM_RED then
        local boom = ents.Create( "env_explosion" )
        boom:SetPos( ply:GetPos() ) 
        boom:SetOwner( ply )
        boom:Spawn()
        boom:SetKeyValue( "iMagnitude", "150" ) 
        boom:Fire( "Explode", 0, 0 ) 
    end
end )

-- Humans can still commit suicide
-- Barrels are terrifying, after all
function GM:CanPlayerSuicide(ply)
   if ply:Team() == TEAM_RED then return false end
   
   return true
end

-- Actually makes the barrel explode
hook.Add('KeyPress', 'SuicideBarrelBoom', function( ply, key )
    if ply:Team() == TEAM_RED and key == IN_ATTACK then
        if !ply:Alive() then return end
        if ply.NextBoom and CurTime() >= ply.NextBoom then
            ply.NextBoom = nil
            
            timer.Simple( .5, function() if IsValid( ply ) and ply:Alive() then ply:EmitSound( "Grenade.Blip" ) end end )
            timer.Simple( 1, function() if IsValid( ply ) and ply:Alive() then ply:EmitSound( "Grenade.Blip" ) end end )
            timer.Simple( 1.5, function() if IsValid( ply ) and ply:Alive() then ply:EmitSound( "Weapon_CombineGuard.Special1" ) end end )
            timer.Simple( 2, function() if IsValid( ply ) and ply:Alive() and ply:Team() == TEAM_RED then ply:Kill() end end )
        end
    elseif ply:Team() == TEAM_RED and key == IN_ATTACK2 then
        if !ply:Alive() then return end
        if ply.NextTaunt and CurTime() > ply.NextTaunt then
            ply.NextTaunt = CurTime() + 1
            ply:EmitSound( "vo/npc/male01/behindyou01.wav", 100, 140 )
        end
    end
end )

-- Scoring for Suicide Barrels
function GM:HandlePlayerDeath(ply, attacker, dmginfo) 
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
    
    if attacker:Team() == TEAM_RED then
        -- Barrel killed human
        attacker:AddFrags(5)
        GAMEMODE:AddStatPoints(attacker, 'humans_killed', 1)
    elseif attacker:Team() == TEAM_BLUE then
        -- Human killed barrel
        attacker:AddFrags(1)
        GAMEMODE:AddStatPoints(attacker, 'barrels_killed', 1)
    end
end

-- Track survived rounds
function GM:StatsRoundWin(winners)
    if winners == TEAM_BLUE then
        for k,v in pairs(team.GetPlayers(TEAM_BLUE)) do
            if v:Alive() then
                GAMEMODE:AddStatPoints(v, 'survived_rounds', 1)
            end
        end
    end
end