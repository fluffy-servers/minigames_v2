AddCSLuaFile('cl_init.lua')
AddCSLuaFile('init.lua')
AddCSLuaFile('ply_extension.lua')
AddCSLuaFile('tables.lua')

include('shared.lua')

function GM:PlayerLoadout(ply)
    ply:StripWeapons()

    if ply:Team() == TEAM_BLUE then
        ply:Give('weapon_propkilla')
        ply:SetWalkSpeed(250)
        ply:SetRunSpeed(300)
    elseif ply:Team() == TEAM_RED then
        ply.SwapTime = 0
        ply.AttackTime = 0
        ply.Speed = 10
        ply:SpawnProp(100)
    end
end

-- Modified in Poltergeist to stop map cleanups
function GM:PreStartRound()
    local round = GetGlobalInt('RoundNumber', 0 )
    -- End the game if enough rounds have been played
    if round >= GAMEMODE.RoundNumber then
        GAMEMODE:EndGame()
        return
    end
    
    if GAMEMODE.TeamBased then
        GAMEMODE.TeamKills = nil
    end
    
    -- Set global round data
    SetGlobalInt('RoundNumber', round + 1 )
    SetGlobalString( 'RoundState', 'PreRound' )
	SetGlobalFloat( 'RoundStart', CurTime() )
    hook.Call('PreRoundStart')
    
    -- Respawn everybody & freeze them until the round actually starts
    for k,v in pairs( player.GetAll() ) do
        v:Spawn()
        v:Freeze( true )
    end
    
    -- Start the round after a short cooldown
    timer.Simple(GAMEMODE.RoundCooldown, function() GAMEMODE:StartRound() end)
end

function GM:SpawnProps()
    for k,v in pairs(ents.FindByClass('prop_spawner')) do
        v:SpawnProp()
    end
end

hook.Add('Think', 'SpawnPoltergeistProps', function()
    local lasttime = GAMEMODE.LastSpawnTime or 0
    if CurTime() - lasttime > 1 then
        GAMEMODE:SpawnProps()
        GAMEMODE.LastSpawnTime = CurTime()
    end
end)


-- Pick player models
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        ply:SetModel( "models/props_junk/wood_crate001a.mdl" )
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Stop Poltergeists from exploding
function GM:CanPlayerSuicide(ply)
    return true
end

-- Fix a spawning bug for Poltergeists
hook.Add('RoundStart', 'FixGhostBug', function()
    for k,v in pairs(team.GetPlayers(TEAM_RED )) do
        v:Spawn()
    end
end)

function GM:EntityTakeDamage(ent, dmginfo)
    local attacker = dmginfo:GetAttacker()

    if not ent:IsPlayer() then
        dmginfo:SetDamageForce(dmginfo:GetDamageForce() * 20)
        if ent:GetOwner() and ent:GetOwner():IsValid() then
            -- When a prop is attacked, forward the damage to the owner
            if IsValid(attacker) and attacker:IsPlayer() then
                ent:EmitSound(table.Random(GAMEMODE.PropHit))

                -- Fake the damage info
                local ply = ent:GetOwner()
                ply:SetHealth(ply:Health() - dmginfo:GetDamage())
                if ply:Health() < 1 then
                    ent:SetOwner(NULL)

                    ply:EmitSound(table.Random(GAMEMODE.PropHit))
                    ply:KillSilent()
                    ply:KillProp(dmginfo:GetDamageForce())
                    GAMEMODE:DoPlayerDeath(ply, attacker, dmginfo)
                    GAMEMODE:PlayerDeath(ply, dmginfo:GetInflictor(), attacker)
                end
            end

            return true
        end
    elseif ent:Alive() then
        -- Check if the attacker is a prop
        -- If so, set the true attacker to be the prop pilot (if applicable)
        if string.find(attacker:GetClass(), "prop_phys") then
            if attacker:GetOwner() and attacker:GetOwner():IsValid() then
                dmginfo:SetAttacker(attacker:GetOwner())
            else
                -- Disable propkilling, only props with pilots can do damage
                return true
            end
        end
    end
end