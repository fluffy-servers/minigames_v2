-- Sniper Wars
-- Spawns NPC sniper entities, players win by surviving
MOD = {
    name = 'Sniper Wars',
    subtext = 'Hope you\'re good at dodging!',
    time = 10,
	-- Spawn a random amount of sniper NPCs
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
    
	-- Award a bonus to survivors
    func_check = function(ply)
        if ply:Alive() and not ply.Spectating then
            ply:AddFrags(2)
        end
    end,
    hooks = {DoPlayerDeath = GM.SurvivalBonus}
}