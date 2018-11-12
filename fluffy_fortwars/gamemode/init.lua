AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('prop_list.lua')
include('shared.lua')
include('sv_props.lua')

-- Handle everything to do with starting the build phase
function GM:StartBuildPhase()
    timer.Simple(100, function() GAMEMODE:EndBuildPhase() end)
end

-- Finish up the build phase & start the fighting phase
function GM:EndBuildPhase()
    -- Freeze all the props
    -- Reset the loadouts
    -- Remove any barriers & spawn the flags
end

function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    if GAMEMODE.ROUND_PHASE == "BUILDING" then
        ply:Give("weapon_physgun")
    else
        -- weapons here
        ply:Give("weapon_pistol")
    end
end