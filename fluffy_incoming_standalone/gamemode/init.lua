AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

INCMaps = {}
-- Default model list
DefaultProps = {}
DefaultProps['Geometric'] = {
	"models/clannv/incoming/box/box1.mdl",
	"models/clannv/incoming/box/box2.mdl",
	"models/clannv/incoming/box/box3.mdl",
	
	"models/clannv/incoming/cone/cone1.mdl",
	"models/clannv/incoming/cone/cone2.mdl",
	"models/clannv/incoming/cone/cone3.mdl",
	
	"models/clannv/incoming/cylinder/cylinder1.mdl",
	"models/clannv/incoming/cylinder/cylinder2.mdl",
	"models/clannv/incoming/cylinder/cylinder3.mdl",
	
	"models/clannv/incoming/hexagon/hexagon1.mdl",
	"models/clannv/incoming/hexagon/hexagon2.mdl",
	"models/clannv/incoming/hexagon/hexagon3.mdl",
	
	"models/clannv/incoming/pentagon/pentagon1.mdl",
	"models/clannv/incoming/pentagon/pentagon2.mdl",
	"models/clannv/incoming/pentagon/pentagon3.mdl",
	
	"models/clannv/incoming/sphere/sphere1.mdl",
	"models/clannv/incoming/sphere/sphere2.mdl",
	"models/clannv/incoming/sphere/sphere3.mdl",
	
	"models/clannv/incoming/triangle/triangle1.mdl",
	"models/clannv/incoming/triangle/triangle2.mdl",
	"models/clannv/incoming/triangle/triangle3.mdl"
}
CurrentPropsCategory = 'Geometric'

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

function GM:PickPlayerColor(p)
    local c = HSVToColor( math.random(360), 1, 1 )
    p.PlayerColor = Vector(c.r/255, c.g/255, c.b/255)
end

function GM:PlayerSetModel(ply)
    ply:SetModel( table.Random(GAMEMODE.ValidModels) )
    
    if ply.PlayerColor then
        ply:SetPlayerColor(ply.PlayerColor)
    else
        GAMEMODE:PickPlayerColor(ply)
        ply:SetPlayerColor(ply.PlayerColor)
    end
end

-- No weapons
function GM:PlayerLoadout( ply )

end

-- Prop
INCPropSpawnTimer = 0
local Delay = 2
hook.Add("Tick", "TickPropSpawn", function()
    local Props = DefaultProps[ CurrentPropsCategory ]
	if ( INCPropSpawnTimer < CurTime() ) then
		for k, v in pairs( ents.FindByClass( INCMaps["SpawnEntity"] or 'inc_prop_spawner' ) ) do
			INCPropSpawnTimer = CurTime() + Delay
			local Ent = ents.Create("prop_physics")
			Ent:SetModel( Props[ math.random( 1, #Props ) ] )
			Ent:SetPos( v:GetPos() )
			Ent:Spawn()
			Ent:GetPhysicsObject():SetMass(40000)
		end
	end
end )


-- Network resources
function IncludeResFolder( dir )
	local files = file.Find( dir.."*", "GAME" )
	local FindFileTypes = 
	{
		".mdl",
		".vmt",
		".vtf",
		".dx90",
		".dx80",
		".phy",
		".sw",
		".vvd",
		".wav",
		".mp3",
	}
	
	for k, v in pairs( files ) do
		for k2, v2 in pairs( FindFileTypes ) do
			if ( string.find( v, v2 ) ) then
				resource.AddFile( dir .. v )
			end
		end
	end
end

IncludeResFolder( "materials/models/clannv/incoming/" )
IncludeResFolder( "models/clannv/incoming/box/" )
IncludeResFolder( "models/clannv/incoming/cone/" )
IncludeResFolder( "models/clannv/incoming/cylinder/" )
IncludeResFolder( "models/clannv/incoming/hexagon/" )
IncludeResFolder( "models/clannv/incoming/pentagon/" )
IncludeResFolder( "models/clannv/incoming/sphere/" )
IncludeResFolder( "models/clannv/incoming/triangle/" )