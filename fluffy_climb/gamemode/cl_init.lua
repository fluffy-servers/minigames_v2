include('shared.lua')

function GM:PostDrawTranslucentRenderables()
    render.SetColorMaterial()
    render.DrawQuadEasy(Vector(0, 0, GAMEMODE:GetLavaHeight()), Vector(0, 0, 1), 4096, 4096, Color(255, 0, 0, 150), 0)
    render.DrawQuadEasy(Vector(0, 0, GAMEMODE:GetLavaHeight()), Vector(0, 0, -1), 4096, 4096, Color(255, 0, 0, 150), 0)
    
    local goal = GetGlobalInt('ClimbHeight', 0)
    render.SetColorMaterial()
    render.DrawQuadEasy(Vector(0, 0, goal), Vector(0, 0, 1), 4096, 4096, Color(0, 255, 0, 150), 0)
    render.DrawQuadEasy(Vector(0, 0, goal), Vector(0, 0, -1), 4096, 4096, Color(0, 255, 0, 150), 0)
end