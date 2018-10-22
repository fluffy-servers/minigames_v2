AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

AddCSLuaFile('player_class/class_ghost.lua')

include('shared.lua')
include( "ply_extension.lua" ) 
include( "tables.lua" )

function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    
    if ply:Team() == TEAM_BLUE then
        ply:Give( "weapon_propkilla" )
        
        ply:SetWalkSpeed( 250 )
        ply:SetRunSpeed( 300 )
    elseif ply:Team() == TEAM_RED then
        ply.SwapTime = 0
        ply.TauntTime = 0
        ply.Speed = 10
        
        ply:SpawnProp( 100 )
        --ply:Give("weapon_prop_boost")
    end
end

--[[ Called for round setup time ]]--
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
    timer.Simple( GAMEMODE.RoundCooldown, function() GAMEMODE:StartRound() end )
end

function GM:SpawnProps()
    for k,v in pairs(ents.FindByClass('prop_spawner')) do
        v:SpawnProp()
    end
end

hook.Add('InitPostEntity', 'PopulateStartingProps', function()
    -- Spawn some initial props to populate the map at the very start
    for i = 1,10 do
        timer.Simple(i*2, function() GAMEMODE:SpawnProps() end)
    end
end )

function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        ply:SetModel( "models/props_junk/wood_crate001a.mdl" )
    else
        ply:SetModel( 'models/player/Group01/male_09.mdl' )
    end
end

function GM:CanPlayerSuicide(ply)
   if ply:Team() == TEAM_RED then return false end
   
   return true
end

hook.Add('PlayerDeath', 'PoltergeistDeath', function( ply )
    if ply:Team() == TEAM_RED then
        ply:EmitSound( Sound( table.Random( GAMEMODE.DieSounds ) ), 100, 130 )
    
        local prop = ply:GetProp()
        
        if prop and prop:IsValid() then
        
            prop:SetOwner()
            local low, high = prop:WorldSpaceAABB()
        
            local ed = EffectData()
            ed:SetOrigin( low )
            ed:SetStart( high )
            ed:SetMagnitude( prop:BoundingRadius() )
            util.Effect( "prop_die", ed, true, true )
        
            prop:Fire( "break", 1, 0.01 )
            timer.Simple( 1, function( prop ) if prop and prop:IsValid() then prop:Remove() end end, prop )
        end
    end
end )

hook.Add('RoundStart', 'FixGhostBug', function()
    for k,v in pairs( team.GetPlayers( TEAM_RED ) ) do
        v:Spawn()
    end
end )

hook.Add('Move', 'GhostMove', function( ply, mv )
    if ply:Team() != TEAM_RED then return end
    
	local prop = ply:GetProp()
	if not prop or not prop:IsValid() then return end
	
	local phys = prop:GetPhysicsObject()
	if not phys or not phys:IsValid() then return end
	
	ply:SetPos( prop:GetPos() )
	
	if ply:KeyDown( IN_FORWARD ) then
		phys:ApplyForceCenter( ply:GetAimVector() * phys:GetMass() * ply.Speed )
	elseif ply:KeyDown( IN_BACK ) then
		phys:ApplyForceCenter( ply:GetAimVector() * phys:GetMass() * -ply.Speed )
	end
	
	local ang = ply:GetAimVector():Angle()
	ang.y = ang.y + 90
	
	if ply:KeyDown( IN_JUMP ) then
		phys:ApplyForceCenter( Vector(0,0,1) * phys:GetMass() * ply.Speed * 1.5 )
	elseif ply:KeyDown( IN_MOVELEFT ) then
		phys:ApplyForceCenter( ang:Forward() * phys:GetMass() * ply.Speed )
	elseif ply:KeyDown( IN_MOVERIGHT ) then
		ang.y = ang.y + 180
		phys:ApplyForceCenter( ang:Forward() * phys:GetMass() * ply.Speed )
	end

end )

hook.Add('KeyPress', 'GhostExtraControls', function( ply, key )
    if !ply:Alive() then return end
    if ply:Team() != TEAM_RED then return end
    
	if key == IN_RELOAD and ply.SwapTime < CurTime() then
		local closest = 9000
		local choice = ply:GetProp()
        local prop = ply:GetProp():GetPos()
		
		for k,v in pairs( ents.FindByClass( "prop_phys*" ) ) do
			if v:GetPos():Distance( prop ) < 250 and ply:GetProp() != v and not v:GetOwner():IsValid() then
				if v:GetPos():Distance( ply:GetPos() ) < closest then
					closest = v:GetPos():Distance( ply:GetPos() )
					choice = v
				end
			end
		end
		
		if choice != ply:GetProp() then
			ply:EmitSound( Sound( table.Random( GAMEMODE.ChangeSounds ) ), 100, 130 )
			ply:SetProp( choice )
			ply.SwapTime = CurTime() + 5
		end
		
	end
    
    if !ply.TauntTime then return end
    if ( key == IN_SPEED and ply.TauntTime < CurTime() ) then
		ply:EmitSound( Sound( table.Random( GAMEMODE.TauntSounds ) ), 100, 130 )
		ply.TauntTime = CurTime() + 3
	end
end )

hook.Add('KeyPress', 'GhostAttackControls', function(ply, key)
    if !ply:Alive() then return end
    if ply:Team() != TEAM_RED then return end
    
    if key == IN_ATTACK then
        if not ply.NextAttack then ply.NextAttack = 0 end
        if ply.NextAttack < CurTime() then
            -- Attack code
            local prop = ply:GetProp()
            if not prop or not prop:IsValid() then return end
	
            local phys = prop:GetPhysicsObject()
            if not phys or not phys:IsValid() then return end
            
            prop:EmitSound('ambient/machines/machine1_hit1.wav')
            
            phys:SetVelocityInstantaneous( ply:GetAimVector() * 5000 )
            ply.NextAttack = CurTime() + 5
        end
        
    elseif key == IN_ATTACK2 then
        if ply.Exploding then return end
        
        ply.Exploding = true
        ply:EmitSound( 'Weapon_CombineGuard.Special1' )
        timer.Simple( 1, function() if IsValid( ply ) and ply:Alive() and ply:Team() == TEAM_RED then 
            ply:Kill() 
            ply.Exploding = false
            
            local prop = ply:GetProp()
            if not prop or not prop:IsValid() then return end
            
            local strength = 40 + math.Clamp(100-ply:GetMaxHealth(), 0, 100)
            
            local boom = ents.Create( "env_explosion" )
            boom:SetPos( prop:GetPos() ) 
            boom:SetOwner( ply )
            boom:Spawn()
            boom:SetKeyValue( "iMagnitude", strength ) 
            boom:Fire( "Explode", 0, 0 ) 
        end end )
    end
end)

function GM:EntityTakeDamage( ent, dmginfo )
	local attacker = dmginfo:GetAttacker()
	if not ent:IsPlayer() then
		if ent:GetOwner() and ent:GetOwner():IsValid() then
			if dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():IsPlayer() then
				ent:EmitSound( Sound( table.Random( GAMEMODE.PropHit ) ) )
				ent:GetOwner():SetHealth( ent:GetOwner():Health() - dmginfo:GetDamage() )
				if ent:GetOwner():Health() < 1 then
					ent:EmitSound( Sound( table.Random( GAMEMODE.PropDie ) ) )
					ent:GetOwner():Kill()
				end
			end
			dmginfo:SetDamage( 0 )
		end
		return
	end
	
	if not ent:Alive() then return end
	if string.find( attacker:GetClass(), "prop_phys" ) then
		if attacker:GetOwner() and attacker:GetOwner():IsValid() then
			dmginfo:SetAttacker( attacker:GetOwner() ) 
		end
	end
end

