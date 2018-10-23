-- Valid playermodels
GM.ValidModels = {
    male01 = "models/player/Group01/male_01.mdl",
    male02 = "models/player/Group01/male_02.mdl",
    male03 = "models/player/Group01/male_03.mdl",
    male04 = "models/player/Group01/male_04.mdl",
    male05 = "models/player/Group01/male_05.mdl",
    male06 = "models/player/Group01/male_06.mdl",
    male07 = "models/player/Group01/male_07.mdl",
    male08 = "models/player/Group01/male_08.mdl",
    male09 = "models/player/Group01/male_09.mdl",
    
    female01 = "models/player/Group01/female_01.mdl",
    female02 = "models/player/Group01/female_02.mdl",
    female03 = "models/player/Group01/female_03.mdl",
    female04 = "models/player/Group01/female_04.mdl",
    female05 = "models/player/Group01/female_05.mdl",
    female06 = "models/player/Group01/female_06.mdl",
}

-- Colors for FFA
-- Todo: remove ugly ones
GM.FFAColors = {
    Color(255, 195, 18),
    Color(247, 159, 31),
    Color(196, 229, 56),
    Color(163, 203, 56),
    Color(18, 203, 196),
    Color(18, 137, 167),
    Color(253, 167, 223),
    Color(217, 128, 250),
    Color(237, 76, 103),
    Color(181, 52, 113),
    Color(238, 90, 36),
    Color(234, 32, 39),
    Color(0, 148, 50),
    Color(0, 98, 102),
    Color(6, 82, 221),
    Color(27, 20, 100),
    Color(153, 128, 250),
    Color(87, 88, 187),
    Color(131, 52, 113),
    Color(111, 30, 81),
}

-- Stop suicide in some gamemodes
function GM:CanPlayerSuicide()
    return self.CanSuicide
end

-- Convert the playermodel name into a model
function GM:TranslatePlayerModel(name, ply)
    if GAMEMODE.ValidModels[name] != nil then
        return GAMEMODE.ValidModels[name]
    elseif ply.TemporaryModel then
        return ply.TemporaryModel
    else
        ply.TemporaryModel = table.Random(GAMEMODE.ValidModels)
        return ply.TemporaryModel
    end
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
            ply.FFAColor = table.Random(GAMEMODE.FFAColors)
            local c = Vector(ply.FFAColor.r/255, ply.FFAColor.g/255, ply.FFAColor.b/255)
            ply:SetPlayerColor(c)
        end
    end
end