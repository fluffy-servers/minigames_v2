function GM:GenerateSpawns()
    GAMEMODE.ZombieSpawns = ents.FindByClass('info_player_zombie')
    GAMEMODE.ZombieSpawns = table.Add(GAMEMODE.ZombieSpawns, ents.FindByClass('info_player_terrorist'))
end

function GM:GetZombieSpawns()
    if not GAMEMODE.ZombieSpawns then
        GAMEMODE:GenerateSpawns()
    end
    return GAMEMODE.ZombieSpawns
end

function GM:CreateZombie(ztype)
    if #ents.FindByClass('npc_*') >= 50 then return end
    
    local spawn = table.Random(GAMEMODE:GetZombieSpawns())
    if not IsValid(spawn) then
        GAMEMODE:GenerateSpawns()
        return
    end
    
    local pos = spawn:GetPos()
    local zombie = ents.Create(ztype)
    zombie:SetPos(pos)
    zombie:Spawn()
    print('made a zombie!')
end

GM.Waves = {
    {'npc_zo_base', 'npc_zo_base', 'npc_zo_base'},
    {'npc_zo_base', 'npc_zo_base', 'npc_zombie_fast', 'npc_skeleton'},
    {'npc_zo_base', 'npc_zombie_fast', 'npc_zombie_fast', 'npc_skeleton'},
    {'npc_zombie_fast', 'npc_zombie_boom', 'npc_skeleton', 'npc_skeleton'},
    {'npc_zombie_boom', 'npc_zombie_corpse', 'npc_skeleton', 'npc_skeleton_mini'},
    {'npc_zombie_boom', 'npc_zombie_corpse', 'npc_skeleton_mini', 'npc_skeleton_mini'},
    {'npc_skeleton', 'npc_skeleton', 'npc_skeleton_mini', 'npc_skeleton_gold'},
    {'npc_zombie_corpse', 'npc_zombie_corpse', 'npc_zombie_boom', 'npc_zombie_shadow'},
    {'npc_skeleton_gold', 'npc_skeleton_gold', 'npc_zombie_fast', 'npc_zombie_fast'},
    {'npc_zombie_shadow', 'npc_zombie_shadow', 'npc_skeleton_gold', 'npc_skeleton_gold'},
}

function GM:WaveScaler(wave)
    if wave <= 3 then
        return 3
    elseif wave <= 6 then
        return 4
    else
        return 6
    end
end

hook.Add('Think', 'ZombieTimer', function()
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    
    if not GAMEMODE.WaveTimer then GAMEMODE.WaveTimer = 0 end
    if not GAMEMODE.WaveNumber then GAMEMODE.WaveNumber = 1 end
    
    if GAMEMODE.WaveNumber > #GAMEMODE.Waves then return end
    GAMEMODE.WaveNumber = GAMEMODE.WaveNumber + 1
    
    if GAMEMODE.WaveTimer < CurTime() then
        GAMEMODE:PulseAnnouncement(2, 'Wave ' .. GAMEMODE.WaveNumber, 1)

        GAMEMODE.WaveTimer = CurTime() + 15
        local wave = GAMEMODE.Waves[GAMEMODE.WaveNumber]
        local wavescale = GAMEMODE:WaveScaler(GAMEMODE.WaveNumber)
        local playercount = math.Clamp(team.NumPlayers(TEAM_BLUE), 1, 5)
        
        for wi=1, wavescale do
            timer.Simple(wavescale/10, function()
                for i=1, playercount do
                    local type = table.Random(wave)
                    GAMEMODE:CreateZombie(type)
                end
            end)
        end
    end
end)