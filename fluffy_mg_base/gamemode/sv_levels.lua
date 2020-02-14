--[[
    Serverside handling of levels
    This includes the database interface for XP
--]]

-- Prepare some prepared queries to make database stuff faster and more secure
hook.Add('InitPostEntity', 'PrepareLevelStuff', function()
	local db = GAMEMODE:CheckDBConnection()
    if not db then return end
	GAMEMODE.MinigamesPQueries['getlevel'] = db:prepare("SELECT xp, level FROM minigames_xp WHERE `steamid64` = ?;")
	GAMEMODE.MinigamesPQueries['addnewlevel'] = db:prepare("INSERT INTO minigames_xp VALUES(?, 0, 0);")
	GAMEMODE.MinigamesPQueries['updatelevel'] = db:prepare("UPDATE minigames_xp SET `level` = ?, `xp` = ? WHERE `steamid64` = ?;")
end )

local meta = FindMetaTable("Player")

-- Also note sh_levels.lua which has getters of the below methods

-- Set the level of the player
-- Does NOT automatically save
function meta:SetLevel(level)
    self:SetNWInt("MGLevel", level)
end

-- Add a certain amount of XP to the player
-- Does NOT automatically save
function meta:SetExperience(xp)
    self:SetNWInt("MGExperience", xp)
end

-- Add a certain amount of XP to the player
-- Does NOT automatically save
function meta:AddExperience(xp)
    local old_xp = self:GetNWInt("MGExperience", 0)
    self:SetNWInt("MGExperience", old_xp + xp)
end

-- Load the level and xp from the database
-- This will automatically add blank rows if the player is new
function meta:LoadLevelFromDB()
    if not self:SteamID64() or self:IsBot() then return end
    local ply = self
    
    local db = GAMEMODE:CheckDBConnection()
    if not db then return end
    
    local q = GAMEMODE.MinigamesPQueries['getlevel']
	if not q then return end
    q:setString(1, self:SteamID64())
    
    -- Success function
    function q:onSuccess(data)
        if type(data) == 'table' and #data > 0 then
            -- Load information from DB
            ply:SetLevel(data[1]['level'])
            ply:SetExperience(data[1]['xp'])
        else
            -- Add new blank row into the table
            local q = GAMEMODE.MinigamesPQueries['addnewlevel']
            q:setString(1, ply:SteamID64())
            q:start()
        end
    end
    
    -- Print error if any occur (they shouldn't)
    function q:onError(err)
        print(err)
    end
    q:start()
end

-- Save the level and xp to the database
function meta:UpdateLevelToDB()
    if not self:SteamID64() or self:IsBot() then return end
    local ply = self
    local level = ply:GetLevel()
    local xp = ply:GetExperience()
    if level == 0 and xp == 0 then return end
    
    local db = GAMEMODE:CheckDBConnection()
    if not db then return end
    
    local q = GAMEMODE.MinigamesPQueries['updatelevel']
    if not q then return end
    
    q:setNumber(1, level)
    q:setNumber(2, xp)
    q:setString(3, self:SteamID64())
    
    -- Success function
    function q:onSuccess(data)
        --print('success')
    end
    
    -- Print error if any occur (they shouldn't)
    function q:onError(err)
        print(err)
    end
    q:start()
end

-- Load the player level from database on join
hook.Add('PlayerInitialSpawn', 'LoadMinigamesLevelData', function(ply)
    ply:LoadLevelFromDB()
    ply:LoadStatsFromDB()
end )

-- Complicated methods of converting the various tracked stats to XP below
-- Maximum of 100XP in one round
-- Maximum of 20XP for any given source (except round wins)

-- Add a stat conversion type
-- Note that this WILL override if already exists - use this for good not evil please
function GM:AddStatConversion(type, nicename, value, max)
    if not GAMEMODE.StatConversions then GAMEMODE.StatConversions = {} end
    GAMEMODE.StatConversions[type] = {nicename, value, max or nil}
end

hook.Add('Initialize', 'AddBaseStatConversions', function()
    hook.Call('RegisterStatsConversions')
end)

hook.Add('RegisterStatsConversions', 'AddBaseStatConversions', function()
    GAMEMODE:AddStatConversion('Rounds Won', 'Rounds Won', 0)
    GAMEMODE:AddStatConversion('Rounds Played', 'Thanks for playing!', 1.5)
    GAMEMODE:AddStatConversion('Kills', 'Kills', 1)
    GAMEMODE:AddStatConversion('Last Survivor', 'Last Survivor Bonus', 5)
    GAMEMODE:AddStatConversion('Deaths', 'Deaths', 0)
    GAMEMODE:AddStatConversion('Survived Rounds', 'Rounds Survived', 1)
end)

-- Convert a stat name & score to a table with XP
function GM:ConvertStat(name, points)
    if not GAMEMODE.StatConversions then return end
    if not GAMEMODE.StatConversions[name] then return end
    
    if name == 'RoundWins' then
        -- Adjust round value based on some factors
        local value = 8
        if GAMEMODE.RoundValue then
            value = GAMEMODE.RoundValue
        elseif GAMEMODE.TeamBased then
            value = 5
        end
        
        if not GAMEMODE.TeamBased then
            local score = math.Clamp(points*value, 0, 40)
            return {'Rounds Won', points, score}
        elseif GAMEMODE.TeamBased then
            local score = math.Clamp(points*value, 0, 40)
            return {'Rounds Won', points, score}
        end
    else
        local t = GAMEMODE.StatConversions[name]
        local max = t[3] or 25
        local score = math.Clamp(math.floor(points * t[2]), 0, max)
        return {t[1], points, score}
    end
end

-- Iterate through a player's stats to convert it all to experience
function meta:ConvertStatsToExperience()
    local xp = {}
    local total_xp = 0
    local hit_max = false
    for k,v in pairs(self:GetStatTable()) do
        local s = GAMEMODE:ConvertStat(k, v)
        if not s then print(k) continue end
        -- Limit of 100XP per game
        if (total_xp + s[3] > 100) and (!hit_max) then
            s[3] = 100 - total_xp
            hit_max = true
            table.insert(xp, s)
        elseif (hit_max) then
            s[3] = 0
            table.insert(xp, s)
        else
            table.insert(xp, s)
        end
    end
    
    return xp
end

-- Process a queue of XP serverside
function meta:ProcessLevels()
    local queue = self:ConvertStatsToExperience()
    local new_xp = self:GetExperience()
    local new_level = self:GetLevel()
    local max_xp = self:GetMaxExperience()
    -- Sum up the XP
    for k,v in pairs(queue) do
        local amount = v[3]
        new_xp = new_xp + amount
    end
    
    -- Check level ups!
    if new_xp > max_xp then
        new_xp = new_xp - max_xp
        new_level = new_level + 1
        hook.Run('MinigamesLevelUp', self, new_level)
    end
    
    -- Save changes
    self:SetExperience(new_xp)
    self:SetLevel(new_level)
    timer.Simple(5, function() self:UpdateLevelToDB() end)
end