--[[
    Functions related to the player
    Stuff like playermodels, FFA colors, etc.
--]]

-- Stop suicide in some gamemodes
function GM:CanPlayerSuicide()
    return self.CanSuicide
end

-- Playermodels
function GM:PlayerSetModel(ply)
	local cl_playermodel = ply:GetInfo("cl_playermodel")
	local modelname = GAMEMODE:TranslatePlayerModel(cl_playermodel, ply)
	util.PrecacheModel( modelname )
	ply:SetModel( modelname )
    
    -- Set player colors
	if GAMEMODE.TeamBased then
		local color = team.GetColor( ply:Team() )
		ply:SetPlayerColor( Vector( color.r/255, color.g/255, color.b/255 ) )
        
        if ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED or state == 'GameNotStarted' then
            self:PlayerSpawnAsSpectator( ply )
            return
        end
	else
        if ply.FFAColor then
            local c = Vector(ply.FFAColor.r/255, ply.FFAColor.g/255, ply.FFAColor.b/255)
            ply:SetPlayerColor(c)
        else
            ply.FFAColor = HSVToColor(math.random(360), 1, 1)
            local c = Vector(ply.FFAColor.r/255, ply.FFAColor.g/255, ply.FFAColor.b/255)
            ply:SetPlayerColor(c)
        end
    end
end

-- Select a spawn entity for the player
-- Edited from base gamemode
function GM:PlayerSelectSpawn( pl )
	if self.TeamBased then
		local ent = self:PlayerSelectTeamSpawn( pl:Team(), pl )
		if ( IsValid( ent ) ) then return ent end
	end

	-- Save information about all of the spawn points
	-- in a team based game you'd split up the spawns
	if !IsTableOfEntitiesValid( self.SpawnPoints ) then
        if #ents.FindByClass("info_player_start") > 2 and !self.TeamBased then
            -- If there's plenty of info_player_starts, only use these in FFA gamemodes
            self.LastSpawnPoint = 0
            self.SpawnPoints = ents.FindByClass( "info_player_start" )
        else
            self.LastSpawnPoint = 0
            self.SpawnPoints = ents.FindByClass( "info_player_start" )
            self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
            self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
            self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
            self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
            self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
        end
	end

	local Count = table.Count( self.SpawnPoints )
	if Count == 0 then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil
	end
	local ChosenSpawnPoint = nil
    
	-- Try to work out the best, random spawnpoint
	for i = 1, Count do
		ChosenSpawnPoint = table.Random( self.SpawnPoints )
		if ( IsValid( ChosenSpawnPoint ) && ChosenSpawnPoint:IsInWorld() ) then
			if ( ( ChosenSpawnPoint == pl:GetVar( "LastSpawnpoint" ) || ChosenSpawnPoint == self.LastSpawnPoint ) && Count > 1 ) then continue end
			if ( hook.Call( "IsSpawnpointSuitable", GAMEMODE, pl, ChosenSpawnPoint, i == Count ) ) then
				self.LastSpawnPoint = ChosenSpawnPoint
				pl:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
				return ChosenSpawnPoint
			end
		end
	end

	return ChosenSpawnPoint
end