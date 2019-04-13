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