DeriveGamemode('fluffy_mg_base')

GM.Name = 'Deathmatch'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Description pending
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?

GM.RoundType = 'timed_endless'
GM.EndOnTimeOut = true
GM.GameTime = 360
GM.HUDStyle = HUD_STYLE_TIMER_ONLY

GM.RespawnTime = 1
GM.AutoRespawn = true
GM.SpawnProtection = true -- Spawn protection enabled

GM.WeaponSpawners = {
    ["spawns"] = {
        ["1"] = {'weapon_mg_knife', 'weapon_mg_pistol', 'weapon_mg_smg'},
        ["2"] = {'weapon_mg_shotgun', 'weapon_mg_smg', 'weapon_crossbow', 'weapon_357'},
        ["3"] = {'weapon_mg_sniper', 'weapon_rpg', 'weapon_mg_mortar', 'weapon_frag'}
    },

    ["ammo"] = {
        ['weapon_mg_shotgun'] = {'Buckshot', 12},
        ['weapon_mg_pistol'] = {'Pistol', 12},
        ['weapon_mg_smg'] = {'SMG1', 60},
        ['weapon_crossbow'] = {'XBowBolt', 5},
        ['weapon_357'] = {'357', 12},
        ['weapon_mg_sniper'] = {'Pistol', 12},
        ['weapon_rpg'] = {'RPG_Round', 3},
        ['weapon_mg_mortar'] = {'RPG_Round', 3},
        ['weapon_frag'] = {'Grenade', 3}
    }
}