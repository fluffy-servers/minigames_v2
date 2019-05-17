-- Generate the spawns list
-- By default merges 'info_player_zombie' and 'info_player_terrorist'
function GM:GenerateSpawns()
    GAMEMODE.ZombieSpawns = ents.FindByClass('info_player_zombie')
    GAMEMODE.ZombieSpawns = table.Add(GAMEMODE.ZombieSpawns, ents.FindByClass('info_player_terrorist'))
end

-- Return the list of zombie spawns
-- Will generate if it does not exist
function GM:GetZombieSpawns()
    if not GAMEMODE.ZombieSpawns then
        GAMEMODE:GenerateSpawns()
    end
    return GAMEMODE.ZombieSpawns
end

-- Create a given zombie entity at a random spawn
function GM:CreateZombie(ztype)
    -- Limit of 50 zombies at one time
    if #ents.FindByClass('npc_*') >= 50 then return end
    
    -- Pick a random spawn from the table (or generate it)
    local spawn = table.Random(GAMEMODE:GetZombieSpawns())
    if not IsValid(spawn) then
        GAMEMODE:GenerateSpawns()
        return
    end
    
    -- Create a zombie at the position
    local pos = spawn:GetPos()
    local zombie = ents.Create(ztype)
    zombie:SetPos(pos)
    zombie:Spawn()
end

-- Definition of the different zombie types that spawn in each wave
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
GM.WaveMax = 10

-- Wave scaling
-- Higher waves have more zombies - this function helps determine that slightly
function GM:WaveScaler(wave)
    if wave <= 3 then
        return 3
    elseif wave <= 6 then
        return 4
    else
        return 6
    end
end

-- Spawn a wave of zombies
function GM:SpawnWave(number)
    -- Announce the wave to all players
    GAMEMODE:PulseAnnouncement(2, 'Wave ' .. number, 1)
    
    -- Scaling and other stuff for wave data
    local wavescale = GAMEMODE:WaveScaler(number)
    local playercount = math.Clamp(team.NumPlayers(TEAM_BLUE), 1, 5)
    local wave = GAMEMODE.Waves[number]
    
    -- Setup the timers
    -- Messy I know but hey
    for wi=1, wavescale do
        timer.Simple(wavescale/10, function()
            -- Create a random zombie for each player (max of 5)
            for i=1, playercount do
                local type = table.Random(wave)
                GAMEMODE:CreateZombie(type)
            end
        end)
    end
end

-- Handle the zombie wave spawning timer
hook.Add('Think', 'ZombieTimer', function()
    -- Only spawn zombies during a wave
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    
    -- Default values are 0
    if not GAMEMODE.WaveTimer then GAMEMODE.WaveTimer = 0 end
    if not GAMEMODE.WaveNumber then GAMEMODE.WaveNumber = 0 end
    if GAMEMODE.WaveNumber >= GAMEMODE.WaveMax then return end

    -- Spawn waves if the timer has hit
    if CurTime() > GAMEMODE.WaveTimer then
        GAMEMODE.WaveTimer = CurTime() + 15
        GAMEMODE.WaveNumber = GAMEMODE.WaveNumber + 1
        GAMEMODE:SpawnWave(GAMEMODE.WaveNumber)
    end
end)