AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('prop_list.lua')
include('shared.lua')
include('sv_props.lua')
include('sv_gravgun.lua')

-- Handle everything to do with starting the build phase
function GM:StartBuildPhase()
    GAMEMODE.ROUND_PHASE = "BUILDING"
    timer.Simple(100, function() GAMEMODE:EndBuildPhase() end)
end

hook.Add('RoundStart', 'BuildingStart', function()
    GAMEMODE:StartBuildPhase()
end)

-- Finish up the build phase & start the fighting phase
function GM:EndBuildPhase()
    -- Freeze all the props
    -- Reset the loadouts
    local ent = ents.FindByName("separator")[1]
    SafeRemoveEntity(ent)
    
    for k,v in pairs(ents.FindByClass("func_fw_propfield")) do
        SafeRemoveEntity(v)
    end
    -- Remove any barriers & spawn the flags
    
    GAMEMODE.ROUND_PHASE = "FIGHTING"
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