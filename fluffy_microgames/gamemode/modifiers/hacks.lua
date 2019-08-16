-- Stop Hacking!
-- Spawns NPC manhacks, players win by surviving
MOD = {
    name = 'Stop Hacking!',
    subtext = 'Watch the skies!',
	-- Spawn a random amount of manhacks
    func_init = function()
        local spawns = table.Shuffle(ents.FindByClass('marker_sky'))
        local number = math.floor(math.Clamp(player.GetCount()*1.5 + math.random(1, 3), 4, #spawns))
        for i=1,number do
            local hack = ents.Create('npc_manhack')
            hack:SetPos(spawns[i]:GetPos() - Vector(0, 0, 32))
            hack:Spawn()
        end
    end,
    
	-- Players have 10HP
    func_player = function(ply)
        ply:SetMaxHealth(10)
        ply:SetHealth(10)
        ply:Give('weapon_crowbar')
    end,
    
	-- Award a bonus to survivors
    func_check = function(ply)
        if ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
    end,
    hooks = {DoPlayerDeath = SurvivalBonus, EntityTakeDamage = function(ent, dmg) GAMEMODE:CrowbarKnockback(ent, dmg) end}
}