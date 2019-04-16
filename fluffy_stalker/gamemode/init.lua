AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Player loadout function
-- Gives weapons to the human teams
-- Makes the Stalker invisible and sets HP
function GM:PlayerLoadout(ply)
    if ply:Team() == TEAM_RED then
        -- Stalker loadout here
        ply:SetColor(Color(255, 255, 255, 15))
        local hp = 150 + math.Clamp(team.NumPlayers(TEAM_BLUE), 1, 16) * 10
        ply:SetHealth(hp)
        ply:SetMaxHealth(hp)
    elseif ply:Team() == TEAM_BLUE then
        -- Reset colour
        ply:SetColor(color_white)
        
        -- Pick from one of three random loadouts
        if math.random() > 0.8 then
            ply:Give('weapon_shotgun')
            ply:Give('weapon_pistol')
        elseif math.random() > 0.4 then
            ply:Give('weapon_smg1')
            ply:Give('weapon_pistol')
        else
            ply:Give('weapon_pistol')
        end
    end
end

-- Set player models for the Stalker
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        --ply:SetModel('models/player/soldier_stripped.mdl')
    else
        ply:SetModel('models/player/combine_soldier_prisonguard.mdl')
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Stop any form of team swapping in this gamemode
-- Teams are rigorously chosen before the round starts
hook.Add('PlayerCanJoinTeam', 'StopTeamSwap', function(ply, team)
    if team != TEAM_SPECTATOR then return false end
end)

-- Movement tricks for the Stalker
-- This includes super jumping and the ability to stick to walls
hook.Add('KeyPress', 'StalkerMovementTricks', function(ply, key)
    if ply:Team() != TEAM_RED then return end
    
    if key == IN_SPEED then
        if ply:OnGround() and (ply.JumpTime or 0) < CurTime() then
            -- Jump into the air
            local jump = ply:GetAimVector() * 200 + Vector(0, 0, 300)
            ply:SetVelocity(jump)
            ply.JumpTime = CurTime() + 1
        else
            -- Stick to walls check
            local tr = util.TraceLine(util.GetPlayerTrace(ply))
            if tr.HitPos:DistToSqr(ply:GetShootPos()) < 2500 and not ply:OnGround() then
                ply:SetMoveType(MOVETYPE_NONE)
            elseif ply:GetMoveType() == MOVETYPE_NONE then
                ply:SetMoveType(MOVETYPE_WALK)
                ply:SetLocalVelocity(ply:GetAimVector() * 200)
            end
        end
    elseif key == IN_JUMP and ply:GetMoveType() == MOVETYPE_NONE then
        -- Unstick from walls
        ply:SetMoveType(MOVETYPE_WALK)
        ply:SetLocalVelocity(Vector(0, 0, 50))
    end
end

-- Stop Hunters from switching back to the other team
hook.Add('PlayerCanJoinTeam', 'StopHunterSwap', function(ply, team)
    local current_team = ply:Team()
    if current_team == GAMEMODE.HunterTeam then
        return false
    end 
end)