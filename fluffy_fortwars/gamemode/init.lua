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
    timer.Simple(100, function() GAMEMODE:EndBuildPhase() end)
end

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
    end
    
    -- Freeze all physics objects
    for k,v in pairs(ents.FindByClass("prop_physics")) do
        local phys = self.Entity:GetPhysicsObject()
        if phys:IsValid() then
            phys:Sleep()
        end
    end
end

function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    if GAMEMODE.ROUND_PHASE == "BUILDING" then
        ply:Give("weapon_physgun")
    elseif GAMEMODE.ROUND_PHASE == "FIGHTING" then
        -- weapons here
        ply:Give("weapon_pistol")
        ply:Give("weapon_physcannon")
    end
end