local random_weapons = {}
random_weapons['shotgun'] = function(p)
    p:Give('weapon_shotgun')
    p:GiveAmmo(20, 'Buckshot')
end

random_weapons['smg'] = function(p)
    p:Give('weapon_smg1')
    p:GiveAmmo(60, 'SMG1')
end

random_weapons['ar2'] = function(p)
    p:Give('weapon_ar2')
    p:GiveAmmo(100, 'AR2')
end

random_weapons['357'] = function(p)
    p:Give('weapon_357')
    p:GiveAmmo(10, '357')
end

random_weapons['pistol'] = function(p)
    p:Give('weapon_pistol')
    p:GiveAmmo(60, 'Pistol')
end

random_weapons['crossbow'] = function(p)
    p:Give('weapon_crossbow')
    p:GiveAmmo(10, 'XBowBolt')
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

local function SurvivalBonus(victim, attacker, dmg)
    for k,v in pairs(player.GetAll()) do
        if v == victim then continue end
        if v.Spectating or not v:Alive() or v:Team() == TEAM_SPECTATOR then continue end
        
        v:AddFrags(1)
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

GM.Modifiers = {}
GM.Modifiers['combineballs'] = {
    name = 'Combine Balls',
    subtext = 'Like Dodgeball but much much worse',
    func_player = function(ply)
        ply:Give('weapon_ar2')
        ply:StripAmmo()
        ply:SetAmmo(0, 'AR2')
        ply:GetWeapon('weapon_ar2'):SetClip1(0)
        ply:GiveAmmo(50, 'AR2AltFire')
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

GM.Modifiers['speedy'] = {
    name = 'Speedy',
    subtext = 'Think fast. Move faster.',
    func_player = function(ply)
        ply:SetRunSpeed(600)
        ply:SetWalkSpeed(400)
        PickRandomWeapons(CurTime(), 1)(ply)
    end
}

GM.Modifiers['grenades'] = {
    name = 'Sticky Grenades',
    subtext = 'Just to clarify: the grenades aren\'t sticky.',
    func_player = function(ply)
        ply:SetRunSpeed(1)
        ply:SetWalkSpeed(1)
        ply:SetJumpPower(1)
        ply:Give('weapon_frag')
        ply:GiveAmmo(100, 'Grenade')
    end
}

GM.Modifiers['glass'] = {
    name = 'Glass Cannon',
    subtext = 'One shot. One kill.',
    func_player = function(ply)
        PickRandomWeapons(CurTime(), 1)(ply)
        ply:SetMaxHealth(1)
        ply:SetHealth(1)
    end 
}

GM.Modifiers['mini'] = {
    name = 'Mini Me',
    subtext = 'Good things come in small packages',
    func_player = function(ply)
        PickRandomWeapons(CurTime(), 1)(ply)
        
        ply:SetModelScale(0.25)
        ply:SetHull(Vector(-8, -8, 0), Vector(8, 8, 18))
        ply:SetHullDuck(Vector(-8, -8, 0), Vector(8, 8, 9))
        ply:SetViewOffset(Vector(0, 0, 16))
        ply:SetViewOffsetDucked(Vector(0, 0, 8))
        
        ply:SetMaxHealth(30)
        ply:SetHealth(30)
    end,
    
    func_finish = function(ply)
        ply:SetModelScale(1)
        ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 72))
        ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 36))
        ply:SetViewOffset(Vector(0, 0, 64))
        ply:SetViewOffsetDucked(Vector(0, 0, 28))
    end,
}

GM.Modifiers['rocketjump'] = {
    name = 'Rocket Jump',
    subtext = 'Do not use the rockets to jump.',
    func_player = function(ply)
        ply:Give('weapon_rpg')
        ply:SetRunSpeed(1)
        ply:SetWalkSpeed(1)
        ply:SetJumpPower(500)
    end
}

GM.Modifiers['oitc'] = {
    name = 'One In The Chamber',
    subtext = 'Use it wisely.',
    func_player = function(ply)
        ply:Give('weapon_357')
        ply:StripAmmo()
        ply:SetAmmo(0, '357')
        ply:GetWeapon('weapon_357'):SetClip1(1)
        ply:SetMaxHealth(1)
        ply:SetHealth(1)
    end,
    
    hooks = {
        DoPlayerDeath = function(victim, attacker, dmg)
            if not attacker:IsPlayer() then return end
            if attacker == victim then return end
            attacker:GiveAmmo(1, '357')
        end
    }
}

GM.Modifiers['stunstick'] = {
    name = 'This is the Police',
    subtext = 'It\'s beating time!',
    func_player = function(ply)
        ply:SetModel('models/player/police.mdl')
        ply:Give('weapon_stunstick')
    end,
}

GM.Modifiers['knife'] = {
    name = 'Knife Battle',
    subtext = 'Stabby stab stab!',
    func_player = function(ply)
        ply:Give('weapon_mg_knife')
    end,
}

GM.Modifiers['crowbar'] = {
    name = 'Crowbar Wars',
    subtext = 'The red colour hides the blood',
    func_player = function(ply)
        ply:Give('weapon_crowbar')
    end,
}

GM.Modifiers['snipers'] = {
    name = 'Sniper Wars',
    subtext = 'Hope you\'re good at dodging!',
    time = 10,
    func_init = function()
        local spawns = table.Shuffle(ents.FindByClass('marker_ground'))
        local number = math.Clamp(player.GetCount() + math.random(-2, 2), 2, #spawns)
        for i=1,number do
            local sniper = ents.Create('npc_sniper')
            sniper:SetAngles(Angle(0, math.random(360), 0))
            sniper:SetPos(spawns[i]:GetPos())
            sniper:Spawn()
        end
    end,
    
    func_check = function(ply)
        if ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
    end,
    
    hooks = {DoPlayerDeath = SurvivalBonus}
}

GM.Modifiers['rollermines'] = {
    name = 'Roller Mines',
    subtext = 'Rolling balls of DEATH',
    func_init = function()
        local spawns = table.Shuffle(ents.FindByClass('marker_ground'))
        local number = math.Clamp(player.GetCount() + math.random(1, 3), 2, #spawns)
        for i=1,number do
            local mine = ents.Create('npc_rollermine')
            mine:SetPos(spawns[i]:GetPos() + Vector(0, 0, 48))
            mine:Spawn()
        end
    end,
    
    func_player = function(ply)
        ply:SetMaxHealth(1)
        ply:SetHealth(1)
    end,
    
    func_check = function(ply)
        if ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
    end,
    
    hooks = {DoPlayerDeath = SurvivalBonus}
}

GM.Modifiers['hacks'] = {
    name = 'Stop Hacking!',
    subtext = 'Watch the skies!',
    func_init = function()
        local spawns = table.Shuffle(ents.FindByClass('marker_sky'))
        local number = math.floor(math.Clamp(player.GetCount()*1.5 + math.random(1, 3), 4, #spawns))
        for i=1,number do
            local hack = ents.Create('npc_manhack')
            hack:SetPos(spawns[i]:GetPos() - Vector(0, 0, 32))
            hack:Spawn()
        end
    end,
    
    func_player = function(ply)
        ply:SetMaxHealth(10)
        ply:SetHealth(10)
    end,
    
    func_check = function(ply)
        if ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
    end,
    
    hooks = {DoPlayerDeath = SurvivalBonus}
}

GM.Modifiers['dodgeball'] = {
    name = 'Dodgeball',
    subtext = 'Physics based death',
    func_init = function()
        local spawns = table.Shuffle(ents.FindByClass('marker_ground'))
        local number = math.Clamp(player.GetCount() + math.random(-3, 0), math.random(1, 2), #spawns)
        for i=1,number do
            local ball = ents.Create('db_dodgeball')
            ball:SetPos(spawns[i]:GetPos() + Vector(0, 0, 32))
            ball:Spawn()
        end
    end,
    
    func_player = function(ply)
        ply:Give('weapon_physcannon')
    end,
    
    hooks = {
        GravGunOnPickedUp = function(ply, ent)
            if ent:GetClass() == 'db_dodgeball' then
                ent:SetNWVector('RColor', ply:GetPlayerColor())
            end
        end,
        
        EntityTakeDamage = function(ent, dmg)
            if ent:IsPlayer() then
                if dmg:GetInflictor():GetClass() == 'db_dodgeball' then
                    dmg:SetDamageType(DMG_DISSOLVE)
                end
            end
        end,
    }
}

GM.Modifiers['crate'] = {
    name = 'Crate Time',
    subtext = 'Break a crate OR DIE',
    func_init = function()
        local spawns = table.Shuffle(ents.FindByClass('marker_sky'))
        local number = math.Clamp(player.GetCount() + math.random(-1, 3), 3, #spawns)
        for i=1,number do
            local crate = ents.Create('prop_physics')
            crate:SetPos(spawns[i]:GetPos() + Vector(0, 0, 32))
            crate:SetModel('models/props_junk/wood_crate001a.mdl')
            crate:Spawn()
        end
    end,
    
    func_player = function(ply)
        ply:Give('weapon_crowbar')
        ply.BrokeCrate = false
    end,
    
    func_check = function(ply)
        if not ply.BrokeCrate then
            if not ply.Spectating and ply:Alive() then ply:Kill() end
        elseif ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
        ply.BrokeCrate = nil
    end,
    
    hooks = {
        EntityTakeDamage = function(ent, dmg)
            if ent:IsPlayer() then return false end
        end,
        
        PropBreak = function(ply)
            ply.BrokeCrate = true
        end,
    }
}

GM.Modifiers['climb'] = {
    name = 'Climb',
    subtext = 'Get on a prop!',
    time = 10,
    func_init = function()
        local spawns = table.Shuffle(ents.FindByClass('marker_sky'))
        local number = math.Clamp(player.GetCount() + math.random(-3, 2), 3, #spawns)
        for i=1,number do
            local crate = ents.Create('prop_physics')
            crate:SetPos(spawns[i]:GetPos() - Vector(0, 0, 32))
            crate:SetModel('models/props_c17/FurnitureWashingmachine001a.mdl')
            crate:Spawn()
        end
    end,

    func_check = function(ply)
        local tr = util.TraceLine({
            start = ply:GetPos(),
            endpos = ply:GetPos() - Vector(0, 0, 128),
            filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
        })
        
        if not IsValid(tr.Entity) or tr.HitWorld then
            if not ply.Spectating and ply:Alive() then ply:Kill() end
        elseif ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
    end,
}