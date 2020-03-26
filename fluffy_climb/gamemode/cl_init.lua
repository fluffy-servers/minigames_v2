include('shared.lua')

function GM:PostDrawTranslucentRenderables()
    local goal = GetGlobalInt('ClimbHeight', 0)
    if goal > 1000 then
        render.SetColorMaterial()
        render.DrawQuadEasy(Vector(0, 0, goal), Vector(0, 0, 1), 4096, 4096, Color(0, 255, 0, 150), 0)
        render.DrawQuadEasy(Vector(0, 0, goal), Vector(0, 0, -1), 4096, 4096, Color(0, 255, 0, 150), 0)
    end
    
    if not GAMEMODE:InRound() then return end
    render.SetColorMaterial()
    render.DrawQuadEasy(Vector(0, 0, GAMEMODE:GetLavaHeight()), Vector(0, 0, 1), 4096, 4096, Color(255, 0, 0, 150), 0)
    render.DrawQuadEasy(Vector(0, 0, GAMEMODE:GetLavaHeight()), Vector(0, 0, -1), 4096, 4096, Color(255, 0, 0, 150), 0)
end