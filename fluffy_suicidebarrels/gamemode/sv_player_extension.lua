-- This file contains the useful code that makes the barrels work properly
local taunts = {"vo/npc/male01/behindyou01.wav", "vo/npc/male01/behindyou02.wav", "vo/npc/male01/watchout.wav", "vo/npc/male01/upthere01.wav", "vo/npc/male01/upthere02.wav", "vo/npc/male01/thehacks01.wav", "vo/npc/male01/strider_run.wav", "vo/npc/male01/runforyourlife01.wav", "vo/npc/male01/runforyourlife02.wav", "vo/npc/male01/runforyourlife03.wav"}

local function explode(ply)
    if not GAMEMODE:InRound() then return end
    if not IsValid(ply) then return end
    if not ply:Alive() or ply.Spectating then return end

    if ply:Team() == TEAM_RED then
        ply:Kill()
    end
end

-- Make suicide barrels go boom when they die
hook.Add('PlayerDeath', 'SuicideBarrelsDeath', function(ply, inflictor, attacker)
    if ply:Team() == TEAM_RED then
        local boom = ents.Create("env_explosion")
        boom:SetPos(ply:GetPos())
        boom:SetOwner(ply)
        boom:Spawn()
        boom:SetKeyValue("iMagnitude", "130")
        boom:Fire("Explode", 0, 0)
        boom.PlayerCause = (attacker or nil)
    end
end)

-- Actually makes the barrel explode
hook.Add('KeyPress', 'SuicideBarrelBoom', function(ply, key)
    if ply:Team() == TEAM_RED and key == IN_ATTACK then
        -- Handle exploding on left click
        if not ply:Alive() then return end

        if ply.NextBoom and CurTime() >= ply.NextBoom then
            ply.NextBoom = nil
            ply:SetWalkSpeed(215)
            -- Play blip sounds then explode
            -- This should probably be improved
            ply:EmitSound("Grenade.Blip")

            timer.Simple(0.450, function()
                if IsValid(ply) and ply:Alive() then
                    ply:EmitSound("Grenade.Blip")
                end
            end)

            timer.Simple(0.900, function()
                if IsValid(ply) and ply:Alive() then
                    ply:EmitSound("Grenade.Blip")
                end
            end)

            timer.Simple(1.350, function()
                if IsValid(ply) and ply:Alive() then
                    ply:EmitSound("Weapon_CombineGuard.Special1")
                end
            end)

            timer.Simple(1.800, function()
                explode(ply)
            end)
        end
    elseif ply:Team() == TEAM_RED and key == IN_ATTACK2 then
        -- Handle taunts on right click
        if not ply:Alive() then return end

        if ply.NextTaunt and CurTime() > ply.NextTaunt then
            ply.NextTaunt = CurTime() + 1
            ply:EmitSound(table.Random(taunts), 100, 140)
        end
    end
end)