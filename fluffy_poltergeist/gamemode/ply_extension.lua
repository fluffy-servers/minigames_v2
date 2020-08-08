local meta = FindMetaTable("Player")
if not meta then return end

-- Possess a prop, or spawn a new one
function meta:PossessProp(health)
    if CLIENT then return end
    if not GAMEMODE:InRound() then return end

    -- Five attempts to find a prop without an owner
    local props = ents.FindByClass("prop_physics")
    local found = false
    for i=1,5 do
        local test = table.Random(props)
        if not IsValid(test:GetOwner()) then
            found = test
            break
        end
    end

    -- Posess the found prop or spawn a new one
    if found then
        found:SetHealth(health)
        timer.Simple(1/60, function()
            self:SetProp(found)
        end)
    else
        self:SpawnProp(health)
    end
end

-- Spawn the player as a prp with a given health
function meta:SpawnProp(health)
    if CLIENT then return end
    if not GAMEMODE:InRound() then return end

    local prop = ents.Create("prop_physics")
    prop:SetPos(self:GetPos() + Vector(0, 0, 50))
    prop:SetModel(table.Random(GAMEMODE.PropModels))
    prop:Spawn()

    -- Small props have only half health to compensate
    if prop:GetPhysicsObject():GetMass() < 100 then
        health = math.floor(health / 2)
    end
    prop:SetHealth(health)
    self:SetMaxHealth(health)
    self:SetHealth(health)

    timer.Simple(1/60, function()
        self:SetProp(prop)
    end)
end

-- Set the prop of a playyer
function meta:SetProp(prop)
    if CLIENT then return end
    if not GAMEMODE:InRound() then return end
    if not IsValid(prop) then return end

    -- Reset previous prop (if applicable)
    if IsValid(self:GetProp()) then
        self:GetProp():SetOwner(nil)
    end

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

-- Kill prop (eg. upon death)
function meta:KillProp(force)
    local prop = self:GetProp()
    if not IsValid(prop) then return end

    prop:GibBreakClient(force)
    prop:Remove()
    self:SetNWEntity("Prop", NULL)
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
	if ply:KeyDown(IN_FORWARD) then
		phys:ApplyForceCenter(ply:GetAimVector() * phys:GetMass() * ply.Speed)
	elseif ply:KeyDown(IN_BACK) then
		phys:ApplyForceCenter(ply:GetAimVector() * phys:GetMass() * -ply.Speed)
	end
	
	-- Calculate movement angle
	local ang = ply:GetAimVector():Angle()
	ang.y = ang.y + 90

    -- Handle vertical movement
    if ply:KeyDown(IN_JUMP) then
        phys:ApplyForceCenter(Vector(0, 0, 1) * phys:GetMass() * ply.Speed * 1.5)
    elseif ply:KeyDown(IN_DUCK) then
        phys:ApplyForceCenter(Vector(0, 0, -1) * phys:GetMass() * ply.Speed * 3)
    end

    -- Handle horizontal movement
    if ply:KeyDown(IN_MOVELEFT) then
        phys:ApplyForceCenter(ang:Forward() * phys:GetMass() * ply.Speed)
    elseif ply:KeyDown(IN_MOVERIGHT) then
        ang.y = ang.y + 180
        phys:ApplyForceCenter(ang:Forward() * phys:GetMass() * ply.Speed)
    end
end)

hook.Add('KeyPress', 'GhostExtraControls', function(ply, key)
    if not ply:Alive() then return end
    if ply:Team() != TEAM_RED then return end

    local prop = ply:GetProp()
    if not prop or not IsValid(prop) then return end

    if key == IN_RELOAD and (ply.SwapTime or 0) < CurTime() then
        -- Handle prop swapping
        -- Find the closest prop to the player
        local choice = prop
        local closest = 62501
        for k,v in pairs(ents.FindInSphere(prop:GetPos(), 250)) do
            if v:GetClass() != 'prop_physics' then continue end
            if IsValid(v:GetOwner()) then continue end

            local distance = prop:GetPos():DistToSqr(v:GetPos())
            if distance < closest then
                closest = distance
                choice = v
            end
        end

        -- Switch props
        if choice != prop then
            ply:EmitSound(table.Random(GAMEMODE.ChangeSounds), 100, math.random(110, 140))
            ply:SetProp(choice)
            ply.SwapTime = CurTime() + 5
        else
            ply.SwapTime = CurTime() + 2
        end

    elseif key == IN_ATTACK and (ply.AttackTime or 0) < CurTime() then
        -- Handle dash attack
        local phys = prop:GetPhysicsObject()
        if not phys or not phys:IsValid() then return end

        prop:EmitSound('ambient/machines/machine1_hit1.wav')
        phys:SetVelocityInstantaneous(ply:GetAimVector() * 5000)
        ply.AttackTime = CurTime() + 5
    elseif key == IN_ATTACK2 and (ply.TauntTime or 0) < CurTime() then
        -- Handle taunting
        ply:EmitSound(table.Random(GAMEMODE.TauntSounds), 100, math.random(110, 140))
        ply.TauntTime = CurTime() + 3
    end
end)