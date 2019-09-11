local meta = FindMetaTable( "Player" )
if (!meta) then return end 

-- Spawn the player as a prop with a given health
function meta:SpawnProp( health )
	local prop = ents.Create( "prop_physics" )
	prop:SetPos( self:GetPos() + Vector(0,0,50) )
	prop:SetModel( table.Random( GAMEMODE.PropModels ) )
	prop:Spawn()
	prop:SetHealth( health )

    timer.Simple( 1/60, function() self:SetProp( prop ) end )
end

-- Set the prop of the player
function meta:SetProp( prop )
	-- Cool transfer effect
	if self:GetProp() and self:GetProp():IsValid() then
		local ed = EffectData()
		ed:SetEntity( self:GetProp() )
		util.Effect( "prop_morph", ed, true, true )
	
		prop:SetHealth( self:GetProp():Health() )
		self:GetProp():SetOwner( nil )
	end

    if !IsValid( prop ) then return end
    
	-- Prepare spectate mode
	self:Spectate( OBS_MODE_CHASE )
	self:SpectateEntity( prop )
	self:SetPos( prop:GetPos() )
	self:SetNWEntity( "Prop", prop )
	prop:SetOwner( self )
    
	-- Calculate health of the prop
    local phys = prop:GetPhysicsObject()
    if not phys or not phys:IsValid() then return end
    local mass = phys:GetMass() or 50
    local hp = math.Clamp(math.floor(mass), 25, 300)
    prop:SetHealth(hp)
    self:SetHealth(hp)
    self:SetMaxHealth(hp)
	
	-- Another cool transfer effect
	local ed = EffectData()
	ed:SetEntity( prop )
	util.Effect( "prop_possessed", ed, true, true )
end

-- Get the current prop of the player
function meta:GetProp()
	return self:GetNWEntity( "Prop", NULL )
end

-- Player death hooks for Poltergeists
hook.Add('PlayerDeath', 'PoltergeistDeath', function( ply )
    if ply:Team() == TEAM_RED then
		-- Emit sound
        ply:EmitSound( Sound( table.Random( GAMEMODE.DieSounds ) ), 100, 130 )
    
        local prop = ply:GetProp()
        if prop and prop:IsValid() then
            prop:SetOwner()
            local low, high = prop:WorldSpaceAABB()
        
			-- Play effect
            local ed = EffectData()
            ed:SetOrigin( low )
            ed:SetStart( high )
            ed:SetMagnitude( prop:BoundingRadius() )
            util.Effect( "prop_die", ed, true, true )
			
			-- Break and remove the prop
            prop:Fire( "break", 1, 0.01 )
            timer.Simple( 1, function( prop ) if prop and prop:IsValid() then prop:Remove() end end, prop )
        end
    end
end )

-- Hook for Poltergeist movement
hook.Add('Move', 'GhostMove', function( ply, mv )
    if ply:Team() != TEAM_RED then return end
    
	local prop = ply:GetProp()
	if not prop or not prop:IsValid() then return end
	
	local phys = prop:GetPhysicsObject()
	if not phys or not phys:IsValid() then return end
	
	ply:SetPos( prop:GetPos() )
	
	-- Calculate forward/backward movement
	if ply:KeyDown( IN_FORWARD ) then
		phys:ApplyForceCenter( ply:GetAimVector() * phys:GetMass() * ply.Speed )
	elseif ply:KeyDown( IN_BACK ) then
		phys:ApplyForceCenter( ply:GetAimVector() * phys:GetMass() * -ply.Speed )
	end
	
	-- Calculate movement angle
	local ang = ply:GetAimVector():Angle()
	ang.y = ang.y + 90
	
	-- Handle jump & left/right movement
	if ply:KeyDown( IN_JUMP ) then
		phys:ApplyForceCenter( Vector(0,0,1) * phys:GetMass() * ply.Speed * 1.5 )
	elseif ply:KeyDown( IN_MOVELEFT ) then
		phys:ApplyForceCenter( ang:Forward() * phys:GetMass() * ply.Speed )
	elseif ply:KeyDown( IN_MOVERIGHT ) then
		ang.y = ang.y + 180
		phys:ApplyForceCenter( ang:Forward() * phys:GetMass() * ply.Speed )
	end

end )

-- Extra controls for Poltergeists
hook.Add('KeyPress', 'GhostExtraControls', function( ply, key )
    if !ply:Alive() then return end
    if ply:Team() != TEAM_RED then return end
    
	-- Change props on reload
	if key == IN_RELOAD and ply.SwapTime < CurTime() then
		local closest = 9000
		local choice = ply:GetProp()
        local prop = ply:GetProp():GetPos()
		
		-- Find the closest prop
		for k,v in pairs( ents.FindByClass( "prop_phys*" ) ) do
			if v:GetPos():Distance( prop ) < 250 and ply:GetProp() != v and not v:GetOwner():IsValid() then
				if v:GetPos():Distance( ply:GetPos() ) < closest then
					closest = v:GetPos():Distance( ply:GetPos() )
					choice = v
				end
			end
		end
		
		-- Transfer to the new prop
		if choice != ply:GetProp() then
			ply:EmitSound( Sound( table.Random( GAMEMODE.ChangeSounds ) ), 100, 130 )
			ply:SetProp( choice )
			ply.SwapTime = CurTime() + 5
		end
		
	end
    
	-- Taunting
    if !ply.TauntTime then return end
    if ( key == IN_SPEED and ply.TauntTime < CurTime() ) then
		ply:EmitSound( Sound( table.Random( GAMEMODE.TauntSounds ) ), 100, 130 )
		ply.TauntTime = CurTime() + 3
	end
end )

-- Attack controls for Poltergeists
hook.Add('KeyPress', 'GhostAttackControls', function(ply, key)
    if !ply:Alive() then return end
    if ply:Team() != TEAM_RED then return end
    
    if key == IN_ATTACK then
        if not ply.NextAttack then ply.NextAttack = 0 end
        if ply.NextAttack < CurTime() then
            -- Dash attack
            local prop = ply:GetProp()
            if not prop or not prop:IsValid() then return end
	
            local phys = prop:GetPhysicsObject()
            if not phys or not phys:IsValid() then return end
            
            prop:EmitSound('ambient/machines/machine1_hit1.wav')
            
            phys:SetVelocityInstantaneous( ply:GetAimVector() * 5000 )
            ply.NextAttack = CurTime() + 5
        end
        
    elseif key == IN_ATTACK2 then
		-- Handle exploding
        if ply.Exploding then return end
        
        ply.Exploding = true
        ply:EmitSound( 'Weapon_CombineGuard.Special1' )
        timer.Simple( 1, function() if IsValid( ply ) and ply:Alive() and ply:Team() == TEAM_RED then 
            ply:Kill() 
            ply.Exploding = false
            
            local prop = ply:GetProp()
            if not prop or not prop:IsValid() then return end
            
			-- Create the explosion effect
            local boom = ents.Create( "env_explosion" )
            boom:SetPos( prop:GetPos() ) 
            boom:SetOwner( ply )
            boom:Spawn()
            boom:SetKeyValue( "iMagnitude", "125" ) 
            boom:Fire( "Explode", 0, 0 ) 
        end end )
    end
end)