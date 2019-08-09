-- Dodgeball
-- Players must kill each other with physics dodgeballs
MOD = {
    name = 'Dodgeball',
    subtext = 'Physics based death',
	-- Spawn a random amount of dodgeballs
    func_init = function()
        local spawns = table.Shuffle(ents.FindByClass('marker_ground'))
        local number = math.Clamp(player.GetCount() + math.random(-3, 0), math.random(1, 2), #spawns)
        for i=1,number do
            local ball = ents.Create('db_dodgeball')
            ball:SetPos(spawns[i]:GetPos() + Vector(0, 0, 32))
            ball:Spawn()
            ball:SetNWVector('RColor', Vector(1, 1, 1))
        end
    end,
    
	-- Give players the gravity gun
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