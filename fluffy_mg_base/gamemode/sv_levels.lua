local meta = FindMetaTable("Player")

hook.Add('InitPostEntity', 'PrepareLevelStuff', function()
	local db = GAMEMODE:CheckDBConnection()
	GAMEMODE.MinigamesPQueries['getlevel'] = db:prepare("SELECT xp, level FROM minigames_xp WHERE `steamid64` = ?;")
	GAMEMODE.MinigamesPQueries['addnewlevel'] = db:prepare("INSERT INTO minigames_xp VALUES(?, 0, 0);")
	GAMEMODE.MinigamesPQueries['updatelevel'] = db:prepare("UPDATE minigames_xp SET `level` = ?, `xp` = ? WHERE `steamid64` = ?;")
end )

function meta:GetLevel()
    return self:GetNWInt("MGLevel", 0)
end

function meta:SetLevel(level)
    self:SetNWInt("MGLevel", level)
end

function meta:GetExperience()
    return self.MGExperience or 0
end

function meta:SetExperience(xp)
    self.MGExperience = xp
end

function meta:AddExperience(xp)
    local old_xp = self.MGExperience
    self.MGExperience = old_xp + xp
end

function meta:LoadLevelFromDB()
    if not self:SteamID64() or self:IsBot() then return end
    local ply = self
    
    local q = GAMEMODE.MinigamesPQueries['getlevel']
	if not q then return end
    q:setString(1, self:SteamID64())
    
    -- Success function
    function q:onSuccess(data)
        if type(data) == 'table' and #data > 0 then
            -- Load information from DB
            ply:SetLevel(data[1]['level'])
            ply:SetExperience(data[1]['experience'])
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

function meta:UpdateLevelToDB()
    if not self:SteamID64() or self:IsBot() then return end
    local ply = self
    local level = ply:GetLevel()
    local xp = ply:GetExperience()
    if level == 0 and xp == 0 then return end
    
    local q = GAMEMODE.MinigamesPQueries['updatelevel']
    q:setNumber(1, level)
    q:setNumber(2, xp)
    q:setString(3, self:SteamID64())
    
    -- Success function
    function q:onSuccess(data)
        print('success')
    end
    
    -- Print error if any occur (they shouldn't)
    function q:onError(err)
        print(err)
    end
    q:start()
end

hook.Add('PlayerInitialSpawn', 'LoadMinigamesLevelData', function(ply)
    ply:LoadLevelFromDB()
end )