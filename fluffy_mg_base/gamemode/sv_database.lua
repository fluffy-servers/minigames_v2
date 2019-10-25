-- Database configuration is stored in db_config
-- This means I can upload this file to github or whatever without leaking my DB password
include('db_config.lua')

GM.MinigamesPQueries = {}
CreateConVar('mg_db_enabled', 1, FCVAR_NONE, 'Should the Minigames DB be enabled?')

function GM:CheckDBConnection()
	if not GAMEMODE then return end
    if not GetConVar('mg_db_enabled'):GetBool() then return end
	
    if !GAMEMODE.MinigamesDB then
        if !mysqloo then print('no mysqloo? oh no') return end
        GAMEMODE.MinigamesDB = mysqloo.connect(GAMEMODE.DB_IP, GAMEMODE.DB_USERNAME, GAMEMODE.DB_PASSWORD, GAMEMODE.DB_DATABASE)
        
        GAMEMODE.MinigamesDB:connect()
        GAMEMODE.MinigamesDB.onconnectionfailed = function()
            
        end
    end
    
    return GAMEMODE.MinigamesDB
end

function GM:CreateDBTables()
    local db = GAMEMODE:CheckDBConnection()
    if not db then return end
    print('Starting table creation...')
    
    local q1 = db:query([[CREATE TABLE minigames_xp (
    steamid64 VARCHAR(64),
    xp INT,
    level INT,
    PRIMARY KEY (steamid64)
    );]])
    q1:start()
    
    local q2 = db:query([[CREATE TABLE stats_minigames_new (
        steamid64 VARCHAR(64),
        gamemode VARCHAR(64),
        category VARCHAR(64),
        points INT,
        PRIMARY KEY (steamid64)
    );]])
    q2:start()
    
    local q3 = db:query([[CREATE TABLE minigames_inventory (
        steamid64 VARCHAR(64),
        inventory TEXT,
        equipped TEXT,
        PRIMARY KEY (steamid64)
    );]])
    
    print('Created tables')
end