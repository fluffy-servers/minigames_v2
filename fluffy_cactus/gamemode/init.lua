AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

resource.AddFile('sound/cactus/cactus.mp3')

include('shared.lua')

hook.Add('PreRoundStart', 'SuicideBarrelsPickBarrel', function()
    -- If team survival pick one player to be a hunter
    if GAMEMODE.TeamSurvival then
        for k,v in pairs( player.GetAll() ) do
            if v:Team() == TEAM_SPECTATOR then continue end
            v:SetTeam( GAMEMODE.SurvivorTeam )
        end
        GAMEMODE:GetRandomPlayer():SetTeam( GAMEMODE.HunterTeam )
    end
end )

function GM:GetFallDamage( ply, speed )
    return 0
end

-- Pick player models
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_CACTUS then
        ply:SetModel( "models/props_lab/cactus.mdl" )
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

function GM:PlayerLoadout(ply)
    if ply:Team() == TEAM_BLUE then
        ply:Give('weapon_vacuum')
    end
end

-- Humans can still commit suicide
-- Barrels are terrifying, after all
function GM:CanPlayerSuicide(ply)
   if ply:Team() == TEAM_CACTUS then return false end
   
   return true
end

function GM:EntityTakeDamage(ent, dmginfo)
    if not IsValid(dmginfo:GetAttacker()) then return end
    if dmginfo:GetAttacker():GetClass() == 'cactus' then return true end
end

hook.Add('PlayerSpawn', 'AssignCactusEntity', function(ply)
    if ply:Team() != TEAM_CACTUS then return end
    
    local empty = GAMEMODE:GetEmptyCacti()
    if #empty < 1 then
        GAMEMODE:SpawnCacti()
        empty = GAMEMODE:GetEmptyCacti()
    end
    
    local cacti = table.Random(empty)
    ply:SetCactus(cacti)
end )

hook.Add('DoPlayerDeath', 'RemoveCactusEntity', function(ply)
    if ply:Team() != TEAM_CACTUS then return end
    
    local cactus = ply:SetNWEntity("cactusobj", ent)
    if IsValid(cactus) then
        cactus:Remove()
    end
end )

function GM:GetEmptyCacti()
    local t = {}
    for k,v in pairs(ents.FindByClass("cactus")) do
        if v.PlayerObj == nil then
            table.insert(t, v)
        end
    end
    return t
end

function GM:CatchCactus(ply, cactus)
    if !IsValid(ply) or !IsValid(cactus) then return end
    
    if IsValid(cactus.PlayerObj) then
        cactus.PlayerObj:TakeDamage(500, ply, ply:GetActiveWeapon())
    end
    
    ply:AddFrags(1)
    
    SafeRemoveEntity(cactus)
end

function GM:SpawnCacti()
    local spawns = ents.FindByClass('info_cactus_spawn')
    
    for k,v in pairs(spawns) do
        local cactus = ents.Create('cactus')
        cactus:SetPos(v:GetPos())
        cactus:SetAngles(Angle(math.Rand(0,360),math.Rand(0,360),math.Rand(0,360)))
        cactus:Spawn()
    end
end

local meta = FindMetaTable( "Player" )
function meta:SetCactus(ent)
    self:SetNWEntity("cactusobj", ent)
    ent.PlayerObj = self
    ent:SetOwner(self)
    
    print(ent:GetPhysicsObject():GetMass())
    
    ent:SetModelScale(5)
    ent:PhysicsInitSphere(12, 'metal')
    ent:GetPhysicsObject():SetMass(3)
end