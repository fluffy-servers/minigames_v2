AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('prop_list.lua')
include('shared.lua')
include('sv_props.lua')

-- Handle everything to do with starting the build phase
function GM:StartBuildPhase()

end

-- Finish up the build phase & start the
function GM:EndBuildPhase()

end

function GM:PlayerLoadout(ply)
    if GAMEMODE.ROUND_PHASE == "BUILDING" then
        ply:StripWeapons()
        ply:Give("weapon_physgun")
    end
end