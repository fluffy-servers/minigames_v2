--[[
    Handles the map and gamemode rotation system
    Map icons are delivered via. webserver
--]]

-- List of gamemodes in rotation
-- This sanity checks the keys provided in the rotation file + provides nice names
GM.VoteGamemodes = {
    ['fluffy_assassination'] = {'Assassination', 'Team DM'},
    ['fluffy_balls'] = {'Ballz', 'FFA'},
    ['fluffy_bombtag'] = {'Bomb Tag', 'FFA'},
    ['fluffy_climb'] = {'Climb', 'FFA'},
    ['fluffy_cratewars'] = {'Crate Wars', 'Team DM'},
    ['fluffy_ctf'] = {'Capture the Flag', 'Team DM'},
    ['fluffy_deathmatch'] = {'Deathmatch [Beta]', 'FFA'},
    ['fluffy_dodgeball'] = {'Dodgeball', 'Team DM'},
    ['fluffy_duckhunt'] = {'Duck Hunt', 'Hunter vs Hunted'},
    ['fluffy_freezetag'] = {'Freeze Tag', 'Team DM'},
    ['fluffy_gungame'] = {'Gun Game', 'FFA'},
    ['fluffy_infection'] = {'Infection [Beta]', 'Hunted vs Hunted'},
    ['fluffy_junkjoust'] = {'Junk Joust', 'FFA'},
    ['fluffy_kingmaker'] = {'Kingmaker', 'FFA'},
    ['fluffy_laserdance'] = {'Laser Dance', 'FFA'},
    ['fluffy_microgames'] = {'Microgames', 'FFA'},
    ['fluffy_mortar'] = {'Mortar Wars', 'Team DM'},
    ['fluffy_oitc'] = {'One in the Chamber', 'Team DM'},
    ['fluffy_paintball'] = {'Paintball', 'Team DM'},
    ['fluffy_pitfall'] = {'Pitfall', 'FFA'},
    ['fluffy_poltergeist'] = {'Poltergeist', 'Hunter vs Hunted'},
    ['fluffy_shotguns'] = {'Super Shotguns', 'Team DM'},
    ['fluffy_sniperwars'] = {'Sniper Wars', 'Team DM'},
    ['fluffy_spectrum'] = {'Spectrum', 'FFA'},
    ['fluffy_stalker'] = {'Stalker', 'Hunter vs Hunted'},
    ['fluffy_suicidebarrels'] = {'Suicide Barrels', 'Hunter vs Hunted'},
}


-- List of maps in rotation
local pvp_maps = {'pvp_hexagons', 'pvp_rainbow2', 'pvp_warehouse_v2', 'pvp_fincity', 'pvp_flyingfish', 'pvp_swampmaze', 'pvp_lasertag_arena_v2', 'pvp_smugglestruggle_version2', 'gm_passo_v2', 'pvp_fortfantastic_v1', 'pvp_rivertown_day'}
local pvp_maps_team = {'pvp_hexagons', 'pvp_rainbow2', 'pvp_warehouse_v2', 'pvp_swampmaze', 'pvp_flyingfish', 'pvp_fincity', 'pvp_smugglestruggle_version2', 'gm_passo_v2', 'pvp_fortfantastic_v1'}

GM.VoteMaps = {
    fluffy_sniperwars = {'sw_towers', 'sw_stairs_v3', 'sw_iceberg_small', 'sw_grassy', 'sw_doublestronghold_v4'},
    fluffy_poltergeist = {'pg_bigtower', 'pg_stairs'},
    fluffy_duckhunt = {'dh_gauntlet_v2', 'dh_aroundtheblock_v2', 'dh_runforyourlife_v2'},
    fluffy_suicidebarrels = {'sb_snowfall', 'sb_yellobox', 'sb_killingrooms', 'sb_shrecksagons_b2'},
    fluffy_dodgeball = {'db_arena_v3', 'db_terminus_v4', 'db_bunkerchunker_v2', 'db_dreamscape_v5'},
    fluffy_pitfall = {'pf_ocean'},
    fluffy_incoming = {'inc_duo', 'inc_linear', 'inc_rectangular'},
    fluffy_bombtag = {'bt_rainbow', 'bt_museum', 'bt_canal', 'bt_yeoldearena_v2', 'bt_reactor', 'bt_courtyard_kerfuffle'},
    fluffy_laserdance = {'ld_toxic', 'ld_rainbow', 'ld_test', 'ld_discus_fix', 'ld_furina'},
	fluffy_cratewars = {'cw_bricks', 'cw_boxingring'},
	fluffy_balls = pvp_maps,
	fluffy_oitc = pvp_maps_team,
    fluffy_infection = {'pvp_rivertown_day', 'pvp_hexagons', 'pvp_fincity'},
    fluffy_kingmaker = pvp_maps,
    fluffy_gungame = pvp_maps,
    fluffy_microgames = {'microgames_arena_b4'},
    fluffy_climb = {'climb_prototype', 'climb_spacejump'},
    fluffy_paintball = {'pb_ratrun_v1', 'pb_paintballarena_v1'},
    fluffy_ctf = {'ctf_prototype3'},
    fluffy_shotguns = {'sg_bang_v1', 'sg_towerattack_v1', 'sg_overpassdefence_v1'},
    fluffy_junkjoust = {'jj_foul_v1', 'jj_pumpkinpatch_b2'},
    fluffy_spectrum = pvp_maps,
    fluffy_freezetag = pvp_maps_team,
    fluffy_assassination = pvp_maps_team,
}

-- Variables to keep track of voting
GM.VotingTime = false
GM.CurrentVoteTable = {}
GM.VotingResults = {}
GM.RTV = {}
GM.RTVCount = GM.RTVCount or 0

-- Network strings
util.AddNetworkString('SendMapVoteTable')
util.AddNetworkString('MapVoteSendVote')

-- Generate the voting 'queue' of six options
function GM:GenerateVotingQueue()
    local gamemodes = table.Keys(GAMEMODE.VoteMaps)
    local options = {}
    local current_map = game.GetMap()

    if #gamemodes > 6 then
        -- Option A (most common): if we have more than 6 gamemodes, pick 6 gamemodes
        -- We have the flexibility here to ensure we don't repeat gamemodes
        local selected_gamemodes = table.Shuffle(gamemodes)
        for k, v in pairs(selected_gamemodes) do
            if v == GAMEMODE_NAME then continue end
            local map = table.Random(GAMEMODE.VoteMaps[v])
            table.insert(options, {v, map})
            if #options == 6 then break end
        end
    elseif #gamemodes == 6 then
        -- Option B: if we have exactly 6 gamemodes, then we simply pick a map for each gamemode
        -- This means we will see the current gamemode again, but that's fine in this case
        -- If the current gamemode has more than one map, we'll pick a new map
        for k, v in pairs(gamemodes) do
            if v == GAMEMODE_NAME then
                if #GAMEMODE.VoteMaps[v] == 1 then
                    -- Only one map for the current gamemode
                    table.insert(options, {v, current_map})
                else
                    -- Ensure we don't get duplicate maps on the same gamemode
                    local map = current_map
                    while map == current_map do
                        map = table.Random(GAMEMODE.VoteMaps[v])
                    end
                    table.insert(options, {v, current_map})
                end
            else
                local map = table.Random(GAMEMODE.VoteMaps[v])
                table.insert(options, {v, map})
            end
        end
    else
        -- Option C: if we have less than 6 gamemodes, then we pick 6 maps at random
        -- Avoid playing exactly the same thing twice in a row
        -- This *will* crash if there's less than 6 maps but that's a risk I'm willing to take
        while #options < 6 do
            local gm = table.Random(gamemodes)
            local map = table.Random(GAMEMODE.VoteMaps[gm])
            if gm == GAMEMODE_NAME and map == current_map then continue end
            table.insert(options, {gm, map})
        end
    end

    return options
end

function GM:PrettifyVoteTable(t)
    local pretty = {}
    for _, v in pairs(t) do
        v[1] = GAMEMODE.VoteGamemodes[v[1]][1]
        table.insert(pretty, v)
    end

    return pretty
end

-- Start the voting process
function GM:StartVoting()
    -- Generate and save a voting queue
    local options = GAMEMODE:GenerateVotingQueue()
    GAMEMODE.CurrentVoteTable = options
    
    -- Send to clients
    net.Start('SendMapVoteTable')
        net.WriteTable(GAMEMODE:PrettifyVoteTable(options))
    net.Broadcast()
    
    -- Handle the stats queue
    for k,v in pairs(player.GetAll()) do
        local tbl = v:ConvertStatsToExperience()
        local tbl2 = GAMEMODE:GenerateStatisticsTable()
        net.Start('SendExperienceTable')
            net.WriteTable(tbl)
            net.WriteTable(tbl2)
        net.Send(v)
        v:ProcessLevels()
        v:UpdateStatsToDB()
    end
    
    -- 15 seconds of voting time
    timer.Simple(30, function() GAMEMODE:EndVote() end)
end

-- Count the votes cast by a player
function GM:CountVote(ply, vote)
    if type(vote) != "number" then return end
    if vote < 1 or vote > 6 then return end
    GAMEMODE.VotingResults[ply] = vote
end

-- Player has cast a vote, count it
net.Receive('MapVoteSendVote', function(len, ply)
    local vote = net.ReadInt(8)
    GAMEMODE:CountVote(ply, vote)
end)

-- Pick a winner from the results
function GM:PickWinningVote()
    local results = {}
    for i=1,6 do results[i] = 0 end

    for k,v in pairs(GAMEMODE.VotingResults) do
        if v > 6 then continue end
        results[v] = results[v] + 1
    end
    return table.GetWinningKey(results)
end

-- End the vote
function GM:EndVote()
    -- Get the winner
    local winner = GAMEMODE.CurrentVoteTable[GAMEMODE:PickWinningVote()]
    local winning_gamemode = winner[1]
    local winning_map = winner[2]
    
    -- Change the gamemode and map
    game.ConsoleCommand('gamemode ' .. winning_gamemode .. '\n')
    timer.Simple(5, function() game.ConsoleCommand('changelevel ' .. winning_map .. '\n') end)
end

-- Rock the vote logic function
function GM:RockTheVote(ply)
    if !IsValid(ply) then return end
    if #GAMEMODE.CurrentVoteTable >= 1 then return end
    
    if player.GetCount() == 1 then
        GAMEMODE.RTVCount = 100
        ply:ChatPrint('Vote to skip map passed since you are alone')
        timer.Simple(3, function()
            GAMEMODE:EndGame()
        end)
        
        return
    end
    
	local voted = false
	if !GAMEMODE.RTV[ply] then
		GAMEMODE.RTV[ply] = true
		GAMEMODE.RTVCount = (GAMEMODE.RTVCount or 0) + 1
		
		local c = GAMEMODE.RTVCount
		local t = player.GetCount()
		local m = math.ceil(player.GetCount() * 0.5)
		if c >= m then
			for k,v in pairs(player.GetAll()) do
				v:ChatPrint('Vote to skip map passed!')
			end
            
            timer.Simple(3, function()
                GAMEMODE:EndGame()
            end)
		else
			for k,v in pairs(player.GetAll()) do
				v:ChatPrint(ply:Nick() .. ' has voted to skip the map.')
				v:ChatPrint(m - c .. ' more votes are needed.')
			end
		end
	else
		ply:ChatPrint('You have already voted to skip the map!')
	end
end

hook.Add('PlayerDisconnected', 'RemoveRTVVotes', function(ply)
	if GAMEMODE.RTV[ply] then
		GAMEMODE.RTV[ply] = nil
		GAMEMODE.RTVCount = (GAMEMODE.RTVCount or 1) - 1
	end
end)

hook.Add('PlayerSay', 'TrackRTV', function(ply, txt)
	if txt == '!rtv' or txt == '/rtv' then
        GAMEMODE:RockTheVote(ply)
        return ""
	end
end)