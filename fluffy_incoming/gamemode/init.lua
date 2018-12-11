AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
include('sv_maps.lua')

-- Nobody wins in Incoming ?
function GM:GetWinningPlayer()
    return nil
end

-- No weapons
function GM:PlayerLoadout( ply )

end

function GM:EndingPoint()
    return GAMEMODE.MapInfo[game.GetMap()].endpos
end

GM.CurrentPropsCategory = 'Both'

-- Prop
INCPropSpawnTimer = 0

hook.Add("Tick", "TickPropSpawn", function()
    if GetGlobalString('RoundState') != 'InRound' then return end
    local data = GAMEMODE.DefaultProps[GAMEMODE.CurrentPropsCategory]
    local props = data.models
    local delay = data.delay or 2
	if ( INCPropSpawnTimer < CurTime() ) then
		for k, v in pairs( ents.FindByClass('inc_prop_spawner') ) do
			local ent = ents.Create( "prop_physics" )
			ent:SetModel(props[math.random(1, #props)])
			ent:SetPos( v:GetPos() )
			ent:Spawn()
			ent:GetPhysicsObject():SetMass( 40000 )
            
            if data.func then
                data.func(ent)
            end
		end
        
        INCPropSpawnTimer = CurTime() + delay
	end
end )

-- Randomly pick a group of props
hook.Add('PreRoundStart', 'IncomingPropsChange', function()
    local category = table.Random( table.GetKeys( GAMEMODE.DefaultProps ) )
    GAMEMODE.CurrentPropsCategory = category
    
    for k,v in pairs(player.GetAll()) do
        v.BestDistance = nil
    end
end )

function GM:GetDistanceToEnd(ply)
    local endpos = GAMEMODE:EndingPoint()
    local distance = ply:GetPos():Distance(endpos)
    local maxdist = GAMEMODE.MapInfo[game.GetMap()].distance
    local percent = 1 - (distance / maxdist)
    if percent < 0 then return end
    
    if ply.BestDistance then
        if percent > ply.BestDistance then
            ply.BestDistance = percent
        end
    else
        ply.BestDistance = percent
    end
end

-- Get a % of how close the player got to the ending
-- This is used for better scoring than all-or-nothing
hook.Add('DoPlayerDeath', 'IncomingDistanceCheck', function(ply)
    GAMEMODE:GetDistanceToEnd(ply)
end)

hook.Add('RoundEnd', 'IncomingDistancePoints', function()
    for k,v in pairs(player.GetAll()) do
        GAMEMODE:GetDistanceToEnd(v)
        if v.BestDistance then
            local p = math.floor(v.BestDistance * 100)
            v:AddStatPoints('IncomingDistance', p)
            v:AddFrags(math.floor(p/10))
        end
    end
end)

function GM:IncomingVictory(ply)
    ply:AddFrags(3)
    ply.BestDistance = 1
    GAMEMODE:EndRound(ply)
end

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