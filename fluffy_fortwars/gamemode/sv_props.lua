-- Remove props on physgun reload
function GM:OnPhysgunReload(physgun, ply)
    local ent = ply:GetEyeTrace().Entity
    if ent:GetClass() != "prop_physics" then return end
    
    local owner = ent:GetNWInt("Owner", nil)
    if ent:IsValid() and (ply == owner or owner == nil) then
        ent:Remove()
        ply:EmitSound('ui/buttonclickrelease.wav')
    end
end

-- Function to allow players to spawn props
function GM:SpawnProp(ply, model)
    -- Make sure it's a valid time to spawn props
    if GAMEMODE.ROUND_PHASE != "BUILDING" then return end
    if !ply:Alive() or ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then return end
    if ply:GetNWInt('Props', 0) >= GAMEMODE.MaxProps then
        return
    end
    
    local trace = ply:GetEyeTrace()
    
    -- Check the model is in the allowed list
    local allowed = false
    local price = 0
    for k,v in pairs(GAMEMODE.PropList) do
        print(model, v[1])
        if model == v[1] then
            price = v[2]
            allowed = true
            break
        end
    end
    if !allowed then
        return
    end
    
    -- Spawn the prop
    local prop = ents.Create('prop_physics')
    if not IsValid(prop) then return end
    prop:SetSkin(math.random(0, 10))
    prop:SetModel(model)
    prop:SetColor(team.GetColor(ply:Team()))
    prop:SetNWEntity('Owner', ply)
    ply:SetNWInt('Props', ply:GetNWInt('Props', 0) + 1)
    
    -- Do some wacky position stuff
    local normal = trace.Normal
    local ang = normal:Angle()
    prop:SetAngles( Angle(0, ang.y, 0) )
    
    local hitpos = trace.HitPos
    local fp = hitpos - (trace.HitNormal*512)
    fp = hitpos + prop:GetPos() - prop:NearestPoint(fp)
    prop:SetPos(fp)
    prop:Spawn()
    
    local phys = prop:GetPhysicsObject()
    if IsValid(phys) then
        local hp = math.floor(phys:GetMass())
        prop:SetNWInt("Health", hp)
        prop:SetNWInt("MaxHealth", hp)
        prop:SetHealth(hp*5)
    end
    prop:PrecacheGibs()
end

-- Concommand for spawning props
local function Spawn(ply, cmd, args)
    GAMEMODE:SpawnProp(ply, args[1])
end
concommand.Add("fw_spawn", Spawn)

function GM:RemoveProps(ply)
    if ply:GetNWInt('Props', 0) == 0 then return end
    for k,v in pairs(ents.FindByClass("prop_physics")) do
        if v:GetNWEntity('Owner') == ply then
            v:Remove()
        end
    end
    ply:SetNWInt('Props', 0)
end

-- Concommand for removing props
local function RemoveProps(ply, cmd, args)
    if GAMEMODE.ROUND_PHASE != "BUILDING" then return end
    GAMEMODE:RemoveProps(ply)
end
concommand.Add("fw_remove", RemoveProps)

function GM:PhysgunPickup(ply, ent)
    return (ent:GetClass() == "prop_physics")
end

-- TODO: Health properties for props
-- Kinda important to do but hey what you can do
function GM:EntityTakeDamage(target, dmginfo)
    if target:GetClass() == "prop_physics" then
        local hp = target:GetNWInt("Health", 0)
        local new_hp = hp - dmginfo:GetDamage()
        if new_hp < 0 then
            target:SetNWInt("Health", new_hp)
        else
            target:GibBreakClient(dmginfo:GetDamageForce())
        end
    elseif target:IsPlayer() then
        if GAMEMODE.ROUND_PHASE == "BUILDING" then dmginfo:SetDamage(0) return end
    end
end