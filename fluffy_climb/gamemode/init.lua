AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
include('sv_levelgen.lua')

-- Nobody wins in Climb ?
-- Used to override default functionality on FFA round end
function GM:GetWinningPlayer()
    return nil
end

-- No weapons
function GM:PlayerLoadout( ply )

end