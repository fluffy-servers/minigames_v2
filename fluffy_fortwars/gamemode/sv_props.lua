-- Remove props on physgun reload
function GM:OnPhysgunReload(physgun, ply)
    local ent = ply:GetEyeTrace().Entity
    local owner = ent:GetNWInt("Owner", nil)
    if ent:IsValid() and (ply == owner or owner == nil) then
        ent:Remove()
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
    prop:SetNWEntity('Owner', ply)
    ply:SetNWInt('Props', ply:GetNWInt('Props', 0) + 1)
    
    -- Do some wacky position stuff
    local normal = trace.Normal
    local ang = normal:Angle()
    prop:SetAngles( Angle(0, ang.y, 0) )
    
    local hitpos = trace.HitPos
    local fp = hitpost - (trace.HitNormal*512)
    fp = hitpos + prop:GetPos() - prop:NearestPoint(fp)
    prop:SetPos(fp)
end

-- Concommand for spawning props
local function Spawn(ply, cmd, args)
    GAMEMODE:SpawnProp(ply, args[1])
end
concommand.Add("fw_spawn", Spawn)

-- Concommand for removing props
local function RemoveProps(ply, cmd, args)
    if GAMEMODE.ROUND_PHASE != "BUILDING" then return end
    if ply:GetNWInt('Props', 0) == 0 then return end
    for k,v in pairs(ents.FindByClass("prop_physics")) do
        if v:GetNWEntity('Owner') == ply then
            v:Remove()
        end
    end
    ply:SetNWInt('Props', 0)
end
concommand.add("fw_remove", RemoveProps)

-- TODO: Health properties for props
-- Kinda important to do but hey what you can do