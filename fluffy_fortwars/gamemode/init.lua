AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('prop_list.lua')
include('shared.lua')
include('sv_props.lua')
include('sv_gravgun.lua')

-- Handle everything to do with starting the build phase
function GM:StartBuildPhase()
    for k,v in pairs(player.GetAll()) do
        GAMEMODE:RemoveProps(v)
        v:SetNWInt('Props', 0)
    end
    GAMEMODE.ROUND_PHASE = "BUILDING"
    timer.Simple(95, function() GAMEMODE:CountdownAnnouncement(5, "Fight!") end)
    timer.Simple(100, function() GAMEMODE:EndBuildPhase() end)
    
    GAMEMODE.RoundPoints = {}
end

-- When a round is about to start, prepare the building phase
hook.Add('PreRoundStart', 'BuildingStart', function()
    GAMEMODE:StartBuildPhase()
end)

-- Finish up the build phase & start the fighting phase
function GM:EndBuildPhase()
    GAMEMODE.ROUND_PHASE = "FIGHTING"
    
    -- Remove the barrier
    local ent = ents.FindByName("separator")[1]
    SafeRemoveEntity(ent)
    
    -- Remove any prop forcefields
    for k,v in pairs(ents.FindByClass("func_fw_propfield")) do
        SafeRemoveEntity(v)
    end
    
    -- Loadout all players
    for k,v in pairs(player.GetAll()) do
        GAMEMODE:PlayerLoadout(v)
        local used_props = GAMEMODE.MaxProps - v:GetNWInt('Props')
        v:AddStatPoints('SpawnedProps', used_props)
    end
    
    -- Freeze all physics objects
    for k,v in pairs(ents.FindByClass("prop_physics")) do
        local phys = v:GetPhysicsObject()
        if phys:IsValid() then
            phys:Sleep()
        end
    end
end

-- Loadout the players
-- Different depending on the round phase
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    if GAMEMODE.ROUND_PHASE == "BUILDING" then
        ply:Give("weapon_physgun")
    elseif GAMEMODE.ROUND_PHASE == "FIGHTING" then
        -- weapons here
        ply:Give("weapon_pistol")
        ply:Give("weapon_smg1")
        ply:Give("weapon_shotgun")
        ply:Give("weapon_physcannon")
        
        ply:GiveAmmo(128, "Pistol", true)
        ply:GiveAmmo(256, "Buckshot", true)
        ply:GiveAmmo(512, "SMG1", true)
    end
end

-- Get the flag entity
function GM:GetFlag()
    local flag = ents.FindByClass("fw_flag")[1]
    if !IsValid(flag) then return end
    return flag
end

-- Thinking allocates points for holding the flag
-- That is the important part of the gamemode, after all
local lastcheck = CurTime()
function GM:Think()
    local flag = GAMEMODE:GetFlag()
    if !IsValid(flag) then return end
    
    -- Get whoever is holding the flag
    local holder = flag:GetNWEntity("Carrier", nil)
    if !IsValid(holder) and !holder:IsPlayer() then return end
    if holder:Team() == TEAM_SPECTATOR or holder:Team() == TEAM_UNASSIGNED then return end
    
    -- Add points if held
    if lastcheck < CurTime() then
        if flag:IsPlayerHolding() then
            local held_team = holder:Team()
            if held_team == TEAM_SPECTATOR or holder:Team() == TEAM_UNASSIGNED then return end
            lastcheck = CurTime() + 1
            flag:EmitSound("npc/roller/code2.wav")
            -- Awards points to the team
            team.AddScore(held_team, 1)
            if not GAMEMODE.RoundPoints[held_team] then
                GAMEMODE.RoundPoints[held_team] = 1
            else
                GAMEMODE.RoundPoints[held_team] = GAMEMODE.RoundPoints[held_team] + 1
            end
            -- Awards points to the holder
            holder:AddStatPoints('FlagCarried', 1)
            holder:AddFrags(1)
        else
            flag:SetNWVector("RColor", Vector(1, 1, 1))
            flag:SetNWEntity("Holder", nil)
        end
    end
end

-- Make victories based on the proper scoring
function GM:HandleTeamWin(reason)
    local winners = reason -- Default: set to winning team in certain gamemodes
    local msg = 'The round has ended!'
    
    if !GAMEMODE.RoundPoints[1] then GAMEMODE.RoundPoints[1] = 0 end
    if !GAMEMODE.RoundPoints[2] then GAMEMODE.RoundPoints[2] = 0 end
    
    if GAMEMODE.RoundPoints[1] > GAMEMODE.RoundPoints[2] then
        -- 1 wins
        winners = 1
        msg = team.GetName(1) .. ' win the round!'
    elseif GAMEMODE.RoundPoints[2] > GAMEMODE.RoundPoints[1] then
        -- 2 wins
        winners = 2
        msg = team.GetName(2) .. ' win the round!'
    else
        -- Nobody wins :\
        winners = 0
        msg = 'Draw! Nobody wins.'
    end
    
    return winners, msg
end