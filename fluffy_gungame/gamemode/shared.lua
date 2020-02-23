DeriveGamemode('fluffy_mg_base')

GM.Name = 'Gun Game'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Free for all deathmatch with constantly changing weapons
    Every 2 kills you get a new weapon!
    
    First person to complete every weapon wins the round
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.Elimination = false
GM.WinBySurvival = false

GM.RoundNumber = 3      -- How many rounds?
GM.RoundTime = 240      -- Seconds each round lasts for

GM.ThirdpersonEnabled = true

-- List of weapons to rotate through
GM.Progression = {
    'weapon_ar2',
    'weapon_rpg',
    'weapon_crossbow',
    
    'weapon_mg_smg',
    'weapon_mg_shotgun',
    'weapon_357',
    
    'weapon_mg_pistol',
    'weapon_crowbar',
}

-- Weapon icons to display on the sidebar
GM.WeaponIcons = {'2', '3', '1', '/', '0', '.', '-', '6', '6'}