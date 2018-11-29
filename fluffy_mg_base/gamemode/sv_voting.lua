--[[
    Handles the map and gamemode rotation system
    Map icons are delivered via. webserver
--]]

-- List of gamemodes in rotation
GM.VoteGamemodes = {
    {'fluffy_sniperwars', 'Sniper Wars', 'Team DM'},
    {'fluffy_poltergeist', 'Poltergeist', 'Hunter vs Hunted'},
    {'fluffy_duckhunt', 'Duck Hunt', 'Hunter vs Hunted'},
    {'fluffy_suicidebarrels', 'Suicide Barrels', 'Hunter vs Hunted'},
    --{'fluffy_dodgeball', 'Dodgeball', 'Team DM'},
    {'fluffy_pitfall', 'Pitfall', 'FFA Elimination'},
    {'fluffy_incoming', 'Incoming!', 'Free For All'},
    {'fluffy_bombtag', 'Bomb Tag', 'FFA Elimination'},
    {'fluffy_laserdance', 'Laser Dance', 'Free For All'},
	  {'fluffy_balls', 'Ballz', 'Free For All'},
	  --{'fluffy_cratewars', 'Crate Wars', 'Free For All'},
	  {'fluffy_oitc', 'One in the Chamber', 'Team DM'},
    --{'fluffy_balloons', 'Balloons', 'Free For All'},
    --{'fluffy_shootingrange', 'Shooting Range', 'Team DM'},
    --{'fluffy_infection', 'Infection', 'Hunter vs Hunted'},
    {'fluffy_gungame', 'Gun Game', 'FFA'},
    --{'fluffy_kingmaker', 'Kingmaker', 'FFA'},
    --{'fluffy_fortwars', 'Fort Wars', 'Team DM'},
}

-- List of maps in rotation
local pvp_maps = {'pvp_battleground', 'pvp_hexagons', 'pvp_rainbow2'}
local pvp_maps_team = {'pvp_hexagons', 'pvp_rainbow2'}

GM.VoteMaps = {
    fluffy_sniperwars = {'sw_towers', 'sw_stairs_v2'},
    fluffy_poltergeist = {'pg_bigtower', 'pg_stairs'},
    fluffy_duckhunt = {'dh_gauntlet_v2', 'dh_nolookingback_v2', 'dh_aroundtheblock_v2', 'dh_runforyourlife_v2'},
    fluffy_suicidebarrels = {'sb_snowfall', 'sb_yellobox', 'sb_darkwood_b3', 'sb_killingrooms', 'sb_storage_v3'},
    fluffy_dodgeball = {'db_arena_t1', 'db_terminus_v3'},
    fluffy_pitfall = {'pf_ocean', 'pf_midnight_v1'},
    fluffy_incoming = {'inc_duo', 'inc_linear'},
    fluffy_bombtag = {'bt_diamond', 'bt_rainbow', 'bt_plaza_v2', 'bt_museum'},
    fluffy_laserdance = {'ld_toxic', 'ld_rainbow', 'ld_test', 'ld_cloudy'},
	fluffy_cratewars = {'cw_spaceslide', 'cw_cloudy', 'cw_bricks'},
	fluffy_balls = pvp_maps,
	fluffy_oitc = pvp_maps,
    fluffy_balloons = {'bl_skyoasis', 'bl_spaceage', 'bl_cloudy'},
    fluffy_shootingrange = {'cb_cylinder', 'cb_split'},
    fluffy_infection = pvp_maps,
    fluffy_kingmaker = pvp_maps,
    fluffy_gungame = pvp_maps_team,
    fluffy_fortwars = {'fw_battlefield'},
}

-- Variables to keep track of voting
GM.VotingTime = false
GM.CurrentVoteTable = {}
GM.VotingResults = {}

-- Network strings
util.AddNetworkString('SendMapVoteTable')
util.AddNetworkString('MapVoteSendVote')

-- Table shuffle stolen from TTT
-- Nice Fisher-Yates implementation, from Wikipedia
local rand = math.random
local table = table
function table.Shuffle(t)
  local n = #t

  while n > 2 do
    -- n is now the last pertinent index
    local k = rand(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end

  return t
end

-- Generate the voting 'queue' of six options
function GM:GenerateVotingQueue()
    -- Copy the gamemodes & shuffle
    local vote = table.Copy(GAMEMODE.VoteGamemodes)
    table.Shuffle(vote)
    vote = {vote[1], vote[2], vote[3], vote[4], vote[5], vote[6]}
    
    -- Add a map to each gamemode
    for k,v in pairs(vote) do
        local gamemode = v[1]
        local map = table.Random(GAMEMODE.VoteMaps[gamemode])
        table.insert(v, map)
    end
    
    return vote
end

-- Start the voting process
function GM:StartVoting()
    -- Generate and save a voting queue
    local options = GAMEMODE:GenerateVotingQueue()
    GAMEMODE.CurrentVoteTable = options
    
    -- Send to clients
    net.Start('SendMapVoteTable')
        net.WriteTable(options)
    net.Broadcast()
    
    -- Handle the stats queue
    for k,v in pairs(player.GetAll()) do
        local tbl = v:ConvertStatsToExperience()
        net.Start('SendExperienceTable')
            net.WriteTable(tbl)
        net.Send(v)
        v:ProcessLevels()
    end
    
    -- 30 seconds of voting time
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
end )

-- Pick a winner from the results
function GM:PickWinningVote()
    local results = {}
    results[1] = 0
    results[2] = 0
    results[3] = 0
    results[4] = 0
    results[5] = 0
    results[6] = 0
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
    local winning_map = winner[4]
    
    -- Change the gamemode and map
    game.ConsoleCommand('gamemode ' .. winning_gamemode .. '\n')
    timer.Simple(5, function() game.ConsoleCommand('changelevel ' .. winning_map .. '\n') end)
end