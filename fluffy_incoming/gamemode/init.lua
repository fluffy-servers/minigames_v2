AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Nobody wins in Incoming ?
function GM:GetWinningPlayer()
    return nil
end

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

DefaultProps['Vehicles'] = {
    'models/props_vehicles/van001a_physics.mdl',
    'models/props_vehicles/car001a_hatchback.mdl',
    'models/props_vehicles/car001b_hatchback.mdl',
    'models/props_vehicles/car002a_physics.mdl',
    'models/props_vehicles/car002b_physics.mdl',
    'models/props_vehicles/car003a_physics.mdl',
    'models/props_vehicles/car003b_physics.mdl',
    'models/props_vehicles/car004a_physics.mdl',
    'models/props_vehicles/car004b_physics.mdl',
    'models/props_vehicles/car005a_physics.mdl',
    'models/props_vehicles/car005b_physics.mdl',
    'models/props_vehicles/apc001.mdl',
    'models/props_vehicles/trailer001a.mdl',
    'models/props_vehicles/trailer002a.mdl',
    'models/props_vehicles/truck001a.mdl',
    'models/props_vehicles/truck003a.mdl',
}

DefaultProps['Both'] = {
    'models/props_vehicles/van001a_physics.mdl',
    'models/props_vehicles/car001a_hatchback.mdl',
    'models/props_vehicles/car001b_hatchback.mdl',
    'models/props_vehicles/car002a_physics.mdl',
    'models/props_vehicles/car002b_physics.mdl',
    'models/props_vehicles/car003a_physics.mdl',
    'models/props_vehicles/car003b_physics.mdl',
    'models/props_vehicles/car004a_physics.mdl',
    'models/props_vehicles/car004b_physics.mdl',
    'models/props_vehicles/car005a_physics.mdl',
    'models/props_vehicles/car005b_physics.mdl',
    'models/props_vehicles/apc001.mdl',
    'models/props_vehicles/trailer001a.mdl',
    'models/props_vehicles/trailer002a.mdl',
    'models/props_vehicles/truck001a.mdl',
    'models/props_vehicles/truck003a.mdl',
    
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

-- No weapons
function GM:PlayerLoadout( ply )

end

CurrentPropsCategory = 'Both'

-- Prop
INCPropSpawnTimer = 0
local Delay = 2
hook.Add("Tick", "TickPropSpawn", function()
    if GetGlobalString('RoundState') != 'InRound' then return end
    local Props = DefaultProps[ CurrentPropsCategory ]
	if ( INCPropSpawnTimer < CurTime() ) then
		for k, v in pairs( ents.FindByClass( INCMaps["SpawnEntity"] or 'inc_prop_spawner' ) ) do
			INCPropSpawnTimer = CurTime() + Delay
			local Ent = ents.Create( "prop_physics" )
			Ent:SetModel( Props[ math.random( 1, #Props ) ] )
			Ent:SetPos( v:GetPos() )
			Ent:Spawn()
			Ent:GetPhysicsObject():SetMass( 40000 )
		end
	end
end )

hook.Add('PreRoundStart', 'IncomingPropsChange', function()
    local category = table.Random( table.GetKeys( DefaultProps ) )
    CurrentPropsCategory = category
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

hook.Add('Initialize', 'AddIncomingStatConversions', function()
    GAMEMODE:AddStatConversion('Distance', 'Slope Distance', 0.01)
end)

IncludeResFolder( "materials/models/clannv/incoming/" )

IncludeResFolder( "models/clannv/incoming/box/" )
IncludeResFolder( "models/clannv/incoming/cone/" )
IncludeResFolder( "models/clannv/incoming/cylinder/" )
IncludeResFolder( "models/clannv/incoming/hexagon/" )
IncludeResFolder( "models/clannv/incoming/pentagon/" )
IncludeResFolder( "models/clannv/incoming/sphere/" )
IncludeResFolder( "models/clannv/incoming/triangle/" )