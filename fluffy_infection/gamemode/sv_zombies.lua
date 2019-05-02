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

hook.Add('Think', 'ZombieTimer', function()
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    
    if not GAMEMODE.WaveTimer then GAMEMODE.WaveTimer = 0 end
    if GAMEMODE.WaveTimer < CurTime() then
        print('Spawning wave..')
        GAMEMODE.WaveTimer = CurTime() + math.random(15, 30)
        
        for i=1,5 do
            local type = 'npc_zo_base'
            local r = math.random()
            if r > 0.8 then type = 'npc_skeleton_gold' elseif r > 0.5 then type = 'npc_skeleton' end
            GAMEMODE:CreateZombie(type)
        end
    end
end)