include('shared.lua')

net.Receive('CTFCameraTrigger', function()
    local flag = net.ReadEntity()
    local transition = {}
    transition.ent = flag
    transition.pos = Vector(0, 0, 0)
    
    GAMEMODE:StartCoolTransition(transition)
        
    timer.Simple(GAMEMODE.RoundCooldown, function()
        GAMEMODE:EndCoolTransition()
    end)
end)