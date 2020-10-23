--[[
    Handle everything to do with the killfeed
    This is blatantly stolen from the base gamemode, so apologies for the terrible naming
--]]

-- These are our kill icons
local Color_Icon = Color(255, 80, 0, 255)
local NPC_Color = Color(250, 50, 50, 255)
killicon.AddFont("prop_physics", "HL2MPTypeDeath", "9", Color_Icon)
killicon.AddFont("weapon_smg1", "HL2MPTypeDeath", "/", Color_Icon)
killicon.AddFont("weapon_357", "HL2MPTypeDeath", ".", Color_Icon)
killicon.AddFont("weapon_ar2", "HL2MPTypeDeath", "2", Color_Icon)
killicon.AddFont("crossbow_bolt", "HL2MPTypeDeath", "1", Color_Icon)
killicon.AddFont("weapon_shotgun", "HL2MPTypeDeath", "0", Color_Icon)
killicon.AddFont("rpg_missile", "HL2MPTypeDeath", "3", Color_Icon)
killicon.AddFont("npc_grenade_frag", "HL2MPTypeDeath", "4", Color_Icon)
killicon.AddFont("weapon_pistol", "HL2MPTypeDeath", "-", Color_Icon)
killicon.AddFont("prop_combine_ball", "HL2MPTypeDeath", "8", Color_Icon)
killicon.AddFont("grenade_ar2", "HL2MPTypeDeath", "7", Color_Icon)
killicon.AddFont("weapon_stunstick", "HL2MPTypeDeath", "!", Color_Icon)
killicon.AddFont("npc_satchel", "HL2MPTypeDeath", "*", Color_Icon)
killicon.AddFont("npc_tripmine", "HL2MPTypeDeath", "*", Color_Icon)
killicon.AddFont("weapon_crowbar", "HL2MPTypeDeath", "6", Color_Icon)
killicon.AddFont("weapon_physcannon", "HL2MPTypeDeath", ",", Color_Icon)

local Deaths = {}
local function StringifyID(id)
    if isstring(id) then
        if id == "" then return "" end

        return "#" .. id
    end

    local p = Entity(id)
    if not IsValid(p) then return "???" end
    return p:Name()
end

-- Hooks for taking in deaths
net.Receive("PlayerKilledByPlayer", function()
    local victim = net.ReadEntity()
    local inflictor = net.ReadString()
    local attacker = net.ReadEntity()

    if attacker == LocalPlayer() and GetConVar("mg_killsound_enabled"):GetBool() then
        GAMEMODE:PlayKillSound()
    end

    if not IsValid(attacker) or not IsValid(victim) then return end
    GAMEMODE:AddDeathNotice2(attacker, inflictor, victim)
end)

net.Receive("PlayerKilledSelf", function()
    local victim = net.ReadEntity()
    if not IsValid(victim) then return end
    GAMEMODE:AddDeathNotice2(nil, "suicide", victim)
end)

net.Receive("PlayerKilled", function()
    local victim = net.ReadEntity()
    local inflictor = net.ReadString()
    local attacker = StringifyID(net.ReadString())
    if not IsValid(victim) then return end
    GAMEMODE:AddDeathNotice2(attacker, inflictor, victim)
end)

-- Ignore NPC deaths - only handle players
-- apologies in advance if an NPC gamemode is ever made
function GM:AddDeathNotice2(attacker, inflictor, victim)
    local Death = {}
    Death.time = CurTime()
    Death.icon = inflictor

    if isstring(attacker) then
        Death.left = attacker
        Death.color1 = table.Copy(NPC_Color)
    elseif IsValid(attacker) and attacker:IsPlayer() then
        Death.left = attacker:Name()
        local pc = attacker:GetPlayerColor()

        if not pc then
            Death.color1 = table.Copy(team.GetColor(attacker:Team()))
        else
            Death.color1 = Color(pc[1] * 255, pc[2] * 255, pc[3] * 255)
        end
    else
        Death.color1 = table.Copy(NPC_Color)

        if IsValid(attacker) then
            Death.left = tostring(attacker)
        else
            Death.left = nil
        end
    end

    if IsValid(victim) and victim:IsPlayer() then
        Death.right = victim:Name()
        local pc = victim:GetPlayerColor()

        if not pc then
            Death.color2 = table.Copy(team.GetColor(victim:Team()))
        else
            Death.color2 = Color(pc[1] * 255, pc[2] * 255, pc[3] * 255)
        end
    else
        Death.color2 = table.Copy(NPC_Color)

        if IsValid(victim) then
            Death.left = tostring(victim)
        else
            Death.right = nil
        end
    end

    if Death.left == Death.right then
        Death.left = nil
        Death.icon = "suicide"
    end

    table.insert(Deaths, Death)
end

local function DrawDeath(x, y, death, hud_deathnotice_time)
    local w, h = killicon.GetSize(death.icon)
    if not w or not h then return end
    local fadeout = (death.time + hud_deathnotice_time) - CurTime()
    local alpha = math.Clamp(fadeout * 255, 0, 255)
    death.color1.a = alpha
    death.color2.a = alpha
    killicon.Draw(x, y, death.icon, alpha)

    -- Draw the attacker
    if death.left then
        draw.SimpleText(death.left, "ChatFont", x - (w / 2) - 16, y, death.color1, TEXT_ALIGN_RIGHT)
    end

    -- Draw the victim
    draw.SimpleText(death.right, "ChatFont", x + (w / 2) + 16, y, death.color2, TEXT_ALIGN_LEFT)

    return y + h * 0.70
end

function GM:DrawDeathNotice(x, y)
    if not GetConVar("cl_drawhud"):GetBool() then return end
    local hud_deathnotice_time = GetConVar("mg_deathnotice_time"):GetFloat()
    x = x * ScrW()
    y = y * ScrH()

    -- Draw the deaths
    for k, death in pairs(Deaths) do
        if death.time + hud_deathnotice_time > CurTime() then
            if death.lerp then
                x = x * 0.3 + death.lerp.x * 0.7
                y = y * 0.3 + death.lerp.y * 0.7
            end

            death.lerp = death.lerp or {}
            death.lerp.x = x
            death.lerp.y = y
            y = DrawDeath(x, y, death, hud_deathnotice_time)
        end
    end

    -- Clear the entire table once everything is expired
    for k, death in pairs(Deaths) do
        if death.time + hud_deathnotice_time > CurTime() then return end
    end

    Deaths = {}
end

function GM:PlayKillSound()
    sound.Play(GetConVar("mg_killsound_sound"):GetString(), LocalPlayer():GetPos(), 75, math.random(120, 140))
end