local meta = FindMetaTable("Player")
if not meta then return end

-- Spawn the player as a prp with a given health
function meta:SpawnProp(health)
    if not GAMEMODE:InRound() then return end

    local prop = ents.Create("prop_physics")
    prop:SetPos(self:GetPos() + Vector(0, 0, 50))
    prop:SetModel(table.Random(GAMEMODE.PropModels))
    prop:Spawn()
    prop:SetHealth(health)

    timer.Simple(1/60, function()
        self:SetProp(prop)
    end)
end

-- Set the prop of a palyer
function meta:SetProp(prop)
    if not IsValid(prop) then return end

    -- Prepare spectating
    self:Spectate(OBS_MODE_CHASE)
    self:SpectateEntity(prop)
    self:SetPos(prop:GetPos())
    self:SetNWEntity("Prop", prop)
    prop:SetOwner(self)
end

-- Get the current prop
function meta:GetProp()
    return self:GetNWEntity("Prop", NULL)
end

-- Poltergeists: Player death hook
hook.Add('PlayerDeath', 'PoltergeistDeath', function(ply)
    if ply:Team() != TEAM_RED then return end

end)

hook.Add('Move', 'GhostMove', function(ply, mv)
    if ply:Team() != TEAM_RED then return end

    local prop = ply:GetProp()
    if not prop or not IsValid(prop) then return end

    local phys = prop:GetPhysicsObject()
    if not phys or not phys:IsValid() then return end

    ply:SetPos(prop:GetPos())

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
end)