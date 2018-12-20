include('shared.lua')

hook.Add('HUDPaint', 'DrawFlagMarkers', function()
    if not GAMEMODE.FlagMarkers or #GAMEMODE.FlagMarkers < 1 then
        GAMEMODE.FlagMarkers = ents.FindByClass('ctf_*_marker')
    end
    
    for k,v in pairs(GAMEMODE.FlagMarkers) do
        if not IsValid(v) then
            GAMEMODE.FlagMarkers = nil
            return
        end
        v:Draw()
    end
end)