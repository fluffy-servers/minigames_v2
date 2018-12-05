local random_weapons = {}
random_weapons['shotgun'] = function(p)
    p:Give('weapon_shotgun')
    p:GiveAmmo(20, 'Buckshot')
end

local cache_seed = nil
local cache = nil

local function PickRandomWeapons(seed, num)
    if cache_seed and seed == cache_seed then
        return cache
    else
        cache = table.Random(random_weapons)
        cache_seed = seed
        return cache
    end
end

GM.Modifiers = {}
GM.Modifiers['shotguns'] = {
    name = 'Shotguns',
    subtext = 'pew pew pew',
    func_player = function(ply)
        ply:Give('weapon_shotgun')
        ply:GiveAmmo(20, 'Buckshot')
    end
}

GM.Modifiers['flight'] = {
    name = 'Flight',
    subtext = 'Gravity is on lunch break',
    func_player = function(ply)
        PickRandomWeapons(CurTime(), 1)(ply)
        ply:SetMoveType(4)
    end
}