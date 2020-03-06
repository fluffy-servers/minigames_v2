include('shared.lua')

-- Draw a halo around whoever has the bomb
hook.Add('PreDrawHalos', 'DrawBombHalo', function()
    for k,v in pairs(player.GetAll()) do
        if v:IsCarrier() then
            local pcolor = v:GetPlayerColor()
            local color = Color(pcolor[1]*255, pcolor[2]*255, pcolor[3]*255)
            halo.Add({v}, color, 2, 2, 2, true, true)
            return
        end
    end
end)