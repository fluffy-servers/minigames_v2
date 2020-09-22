DeriveGamemode("fluffy_mg_base")
GM.Name = "Paintball"
GM.Author = "FluffyXVI"
GM.HelpText = [[
    Eliminate the other team or get the most kills!
    This is a fast-paced team deathmatch.
    
    Collect the weapons scattered around the map!
    
    When you are knocked out, you will have to rush back to spawn.
    If you are knocked out too many times, you will be eliminated.
]]
GM.TeamBased = true -- Is the gamemode FFA or Teams?
GM.RoundTime = 150
GM.RoundNumber = 7
GM.Elimination = false
GM.TeamSurvival = false
GM.LifeTimer = 5
GM.CanSuicide = false

function GM:Initialize()
end

GM.WeaponSpawners = {
    ["spawns"] = {
        ["1"] = {"paint_knife", "paint_smg"},
        ["2"] = {"paint_shotgun", "paint_grenade_wep"},
        ["3"] = {"paint_crossbow", "paint_bazooka"},
    },
    ["ammo"] = {
        ["paint_shotgun"] = {"Buckshot", 12},
        ["paint_bazooka"] = {"RPG_Round", 3},
        ["paint_smg"] = {"SMG1", 60},
        ["paint_crossbow"] = {"SniperRound", 5},
        ["paint_grenade_wep"] = {"Grenade", 3},
    }
}