-- Climb
-- Players must climb onto a prop to survive
MOD = {
    name = 'Climb',
    subtext = 'Get on a prop!',
    time = 10,
    
    func_player = function(ply)
        ply:Give('weapon_crowbar')
    end,
    
	-- Spawn a random number of washing machines
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
	
	-- Verify a player is standing on a prop
    func_check = function(ply)
        local tr = util.TraceHull({
            start = ply:GetPos() + Vector(0, 0, 24),
            endpos = ply:GetPos() - Vector(0, 0, 128),
            mins = Vector(-16, -16, -16),
            maxs = Vector(16, 16, 16),
            filter = function( ent ) return ent:GetClass() == "prop_physics" end
        })
        
        if not IsValid(tr.Entity) or tr.HitWorld then
            if not ply.Spectating and ply:Alive() then ply:Kill() end
        elseif ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
    end,
    
    hooks = {EntityTakeDamage = function(ent, dmg) GAMEMODE:CrowbarKnockback(ent, dmg) end}
}