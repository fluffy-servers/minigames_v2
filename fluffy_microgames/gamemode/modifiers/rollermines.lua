-- Roller Mines
-- Spawns NPC rollermines, players win by surviving
MOD = {
    name = 'Roller Mines',
    subtext = 'Rolling balls of DEATH',
	-- Spawn a random amount of rollermines
    func_init = function()
        local spawns = table.Shuffle(ents.FindByClass('marker_ground'))
        local number = math.Clamp(player.GetCount() + math.random(1, 3), 2, #spawns)
        for i=1,number do
            local mine = ents.Create('npc_rollermine')
            mine:SetPos(spawns[i]:GetPos() + Vector(0, 0, 48))
            mine:Spawn()
        end
    end,
    
	-- Players have 1HP
    func_player = function(ply)
        ply:SetMaxHealth(1)
        ply:SetHealth(1)
        ply:Give('weapon_crowbar')
    end,
    
	-- Award a bonus to survivors
    func_check = function(ply)
        if ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
    end,
    hooks = {DoPlayerDeath = GAMEMODE.SurvivalBonus, EntityTakeDamage = GAMEMODE.CrowbarKnockback}
}