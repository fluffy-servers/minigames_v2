DeriveGamemode('fluffy_mg_base')

GM.Name = 'GTV'
GM.Author = 'FluffyXVI'

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.Elimination = false
GM.WinBySurvival = false

GM.RoundNumber = 5      -- How many rounds?
GM.RoundTime = 120      -- Seconds each round lasts for

GM.ThirdpersonEnabled = true

function GM:Initialize()

end

hook.Add( "SetupMove", "TestBetterMovement", function( ply, mv, cmd )
    local ang = Angle(0,90,0)
    mv:SetMoveAngles(ang)
end )