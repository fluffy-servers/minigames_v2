AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Appropriate weapon stuff
function GM:PlayerLoadout(ply)
    if ply:Team() == TEAM_BLUE then
        ply:GiveAmmo(1000, "357", true)
        ply:Give("weapon_357")
        
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(250)
        ply:SetBloodColor(BLOOD_COLOR_RED)
    elseif ply:Team() == TEAM_RED then
		-- Make sure that melons have no weapons
        ply:SetBloodColor(DONT_BLEED)
        ply:StripWeapons()
    end
end

hook.Add('PlayerSpawn', 'SpawnMelons', function(ply)
    if ply:Team() != TEAM_RED then return end
    
    if IsValid(ply.Melon) then ply.Melon:Remove() end
    ply.Melon = ents.Create('yee_melon')
    ply.Melon:SetPlayer(ply)
    ply.Melon:SetPos(ply:GetPos() + VectorRand()*32)
    ply.Melon:Spawn()
    ply.Melon:Activate()
    ply:SetNWEntity('Melon', ply.Melon)
    
    timer.Simple(0.15, function()
        ply:Spectate(OBS_MODE_CHASE)
        ply:SpectateEntity(ply.Melon)
    end)
end)

hook.Add('DoPlayerDeath', 'RemoveMelons', function(ply)
    if IsValid(ply.Melon) then ply.Melon:Destroy() end
end)