DeriveGamemode("fluffy_mg_base")
GM.Name = "Incoming!"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    Race to the top of the slope!
    Avoid all the falling props!
    
    First person to reach the top wins.
    Points are given based on distance travelled.
]]
GM.TeamBased = false -- Is the gamemode FFA or Teams?
GM.Elimination = false
GM.RoundNumber = 10 -- How many rounds?
GM.RoundTime = 90 -- Seconds each round lasts for
GM.ThirdpersonEnabled = true
GM.DeathSounds = true

function GM:Initialize()
end

function GM:EndingPoint()
    if SERVER then
        local p = GetGlobalVector("WinningPosition", Vector(-1, -1, -1))
        if p ~= Vector(-1, -1, -1) then
            return p
        else
            local win = ents.FindByClass("*_winners_area")[1]
            if not win then
                ErrorNoHalt("No winning area in map!")
                return
            end

            local mins, maxs = win:GetModelBounds()
            local point = (mins+maxs)/2
            SetGlobalVector("WinningPosition", point)
            return point
        end
    else
        return GetGlobalVector("WinningPosition", nil)
    end
end