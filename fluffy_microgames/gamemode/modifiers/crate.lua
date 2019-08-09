-- Crate Time
-- Players must break a crate or lose
MOD = {
    name = 'Crate Time',
    subtext = 'Break a crate OR DIE',
	time = 20,
	-- Spawn a random number of crates
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
    
	-- Players get a crowbar
    func_player = function(ply)
        ply:Give('weapon_crowbar')
        ply.BrokeCrate = false
    end,
    
	-- Players win if and only if they have broken a crate
    func_check = function(ply)
        if not ply.BrokeCrate then
            if not ply.Spectating and ply:Alive() then ply:Kill() end
        elseif ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
        ply.BrokeCrate = nil
    end,
    
	-- Check for crate breaking
    hooks = {
        EntityTakeDamage = function(ent, dmg)
            if ent:IsPlayer() then return true end
        end,
        
        PropBreak = function(ply)
            ply.BrokeCrate = true
        end,
    }
}