AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Give players all the ammo they need
function GM:StockAmmo(ply)
    ply:GiveAmmo(1000, 'SMG1', true)
    ply:GiveAmmo(1000, 'Buckshot', true)
    ply:GiveAmmo(1000, 'pistol', true)
    ply:GiveAmmo(1000, 'RPG_Round', true)
    ply:GiveAmmo(1000, 'Grenade', true)
    ply:GiveAmmo(20, 'slam', true)
    ply:GiveAmmo(1000, '357', true)
    ply:GiveAmmo(1000, 'AR2', true)
    ply:GiveAmmo(1000, 'XBowBolt', true)
end

-- Players get a weapon according to how many kills they have so far
function GM:PlayerLoadout(ply)
    local stage = math.floor(ply:GetNWInt('GG_Progress', 0) / 2) + 1
    local kill = nil

    if IsValid(ply:GetActiveWeapon()) then
        kill = ply:GetActiveWeapon():GetClass()
    end

    local prog = GAMEMODE.Progression

    if stage > #prog then
        GAMEMODE:EndRound(ply)

        return
    end

    local wep = prog[stage]
    local last = prog[#prog]
    if ply:HasWeapon(wep) and wep ~= last then return end
    ply:RemoveAllAmmo()
    ply:StripWeapons()
    GAMEMODE:StockAmmo(ply)
    ply:Give(last, true)
    local given = ply:Give(wep)

    if kill ~= last then
        ply:SelectWeapon(wep)
    end
end

-- Reset gungame progression
hook.Add('PreRoundStart', 'ResetGGRank', function()
    for k, v in pairs(player.GetAll()) do
        v:SetNWInt('GG_Progress', 0)
    end
end)

-- Players increase the weapon progression for every kill
function GM:HandlePlayerDeath(ply, attacker, dmginfo)
    if not attacker:IsValid() or not attacker:IsPlayer() then return end -- We only care about player kills from here on

    if attacker == ply then
        attacker:AddFrags(-1)
        attacker:SetNWInt('GG_Progress', math.Clamp(attacker:GetNWInt('GG_Progress') - 1, 0, 100))

        return
    end

    -- Add the frag; track the GG progress
    attacker:AddFrags(GAMEMODE.KillValue)
    GAMEMODE:AddStatPoints(attacker, 'kills', 1)
    attacker:SetNWInt('GG_Progress', attacker:GetNWInt('GG_Progress', 0) + 1)
    GAMEMODE:PlayerLoadout(attacker)
end