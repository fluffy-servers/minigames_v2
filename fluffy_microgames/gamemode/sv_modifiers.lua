-- Award survival bonuses to any living players
function GM:SurvivalBonus(victim, attacker, dmg)
    for k,v in pairs(player.GetAll()) do
        if v == victim then continue end
        if v.Spectating or not v:Alive() or v:Team() == TEAM_SPECTATOR then continue end
        
        v:AddFrags(1)
    end
end

-- Make crowbars knock players back instead of doing damage
function GM:CrowbarKnockback(ent, dmg)
    if not ent:IsPlayer() then return true end
    if not dmg:GetAttacker():IsPlayer() then return end
    
    dmg:SetDamage(0)
    local v = dmg:GetDamageForce()
    ent:SetVelocity(v * 35)
end

-- Players can't stop moving for the first 5 seconds
function GM:RunFiveSeconds()
    if CurTime() < GAMEMODE.ModifierStart + 1.5 then return end
    if CurTime() > GAMEMODE.ModifierStart + 5 then return end

    for k,v in pairs(player.GetAll()) do
        if not v:Alive() or v.Spectating then continue end
        if v:GetVelocity():LengthSqr() < 5000 then
            v:Kill()
        end
    end
end

GM.DiscColors = {
    {"Red", Color(255, 0, 0)},
    {"Orange", Color(255, 100, 0)},
    {"Yellow", Color(255, 255, 0)},
    {"Green", Color(0, 255, 0)},
    {"Light Blue", Color(0, 255, 255)},
    {"Dark Blue", Color(0, 0, 255)},
    {"Purple", Color(100, 0, 255)},
    {"Pink", Color(255, 0, 255)}
}

local modifier_properties = {
    ['Initialize'] = true,
    ['Loadout'] = true,
    ['WinCheck'] = true,
    ['Cleanup'] = true,
    ['PlayerFinish'] = true,
    ['Think'] = true,
    ['CanStart'] = true,
    ['GetWinningPlayer'] = true
}

-- Set up a new modifier
function GM:SetupModifier(modifier)
    -- Check that we satisfy the minimum players
    if modifier.MinPlayers and GAMEMODE:NumNonSpectators() < modifier.MinPlayers then
        GAMEMODE:NewModifier()
        return
    end

    -- Check that we satisfy the maximum players
    if modifier.MaxPlayers and GAMEMODE:NumNonSpectators() > modifier.MaxPlayers then
        GAMEMODE:NewModifier()
        return
    end

    -- Check custom start conditions if applicable
    if modifier.CanStart then
        if not modifier:CanStart() then
            GAMEMODE:NewModifier()
            return
        end
    end

    -- Handle regions
    local region_accept = GAMEMODE:HandleRegion(modifier)
    if not region_accept then
        GAMEMODE:NewModifier()
        return
    end

    -- Call the initialize function for the modifier
    if modifier.Initialize then
        modifier:Initialize()
    end
    
    -- Call the player function for the modifier
    if modifier.Loadout then
        for k,v in pairs(player.GetAll()) do
            modifier:Loadout(v)
        end
    end
    
    -- Register any hooks related to this modifier
    GAMEMODE.ModifierHooks = {}
    for k,func in pairs(modifier) do
        if type(func) == 'function' and not modifier_properties[k] then
            hook.Add(k, modifier.Name, function(...) return func(modifier, ...) end)
            table.insert(GAMEMODE.ModifierHooks, k)
        end
    end

    -- Add a countdown if requested
    if modifier.Countdown then
        local time = modifier.RoundTime or GAMEMODE.RoundTime
        timer.Simple(time - 3, function()
            GAMEMODE:CountdownAnnouncement(3)
        end)
    end

    GAMEMODE.LastThink = CurTime()
    GAMEMODE.ModifierStart = CurTime()
end

-- Handle region switching for specific modifiers
function GM:HandleRegion(modifier)
    -- Check the region
    -- If there are no markers for this region, bail out
    -- If the region isn't generic, respawn everyone
    local region = modifier.Region
    if not modifier.Region or modifier.Region == 'generic' then return true end

    -- If multiple regions are specified, pick one at random from the table
    if type(region) == 'table' then
        region = table.Random(region)
        if region == 'generic' then return true end
    end

    -- Abort the gamemode if the region is not in this map
    if not GAMEMODE:HasRegion(region) then
        return false
    end

    -- Respawn everyone in the new region
    GAMEMODE.CurrentRegion = region
    for k,v in pairs(player.GetAll()) do
        v:Spawn()
    end
    return true
end

-- Cleanup after a modifier
function GM:TeardownModifier(modifier)
	-- Call any cleanup conditions in the subgame
    if modifier.Cleanup then
        modifier:Cleanup()
    end

    -- Cleanup all players
    for k,v in pairs(player.GetAll()) do
        v:StripWeapons()
        v:StripAmmo()
        v:SetRunSpeed(300)
        v:SetWalkSpeed(200)
        v:SetMoveType(2)
        v:SetHealth(100)
        v:SetMaxHealth(100)
        v:SetJumpPower(200)
        hook.Call('PlayerSetModel', GAMEMODE, v)
        
		-- Win conditions / points / cleanup etc.
        if modifier.PlayerFinish then
            modifier:PlayerFinish(v)
        end
    end

	-- Remove any subgame hooks
    print('Removing hooks...')
    print(GAMEMODE.ModifierHooks)
    if GAMEMODE.ModifierHooks then
        for k,v in pairs(GAMEMODE.ModifierHooks) do
            print('Removing', v, modifier.Name)
            hook.Remove(v, modifier.Name)
        end
        GAMEMODE.ModifierHooks = nil
    end

    -- Restore everyone back to the generic region
    if GAMEMODE.CurrentRegion then
        GAMEMODE.CurrentRegion = 'generic'

        for k,v in pairs(player.GetAll()) do
            v:Spawn()
        end
    end
end

-- Basic function to get the player with the most frags
function GM:GetWinningPlayer(modifier)
    -- Return modifier behaviour if it exists
    if modifier.GetWinningPlayer then
        return modifier:GetWinningPlayer()
    end

    -- Check for a lone survivor, and return them
    if GAMEMODE:GetNumberAlive() <= 1 then
        for k,v in pairs( player.GetAll() ) do
            if v:Alive() and not v.Spectating then
                return v
            end
        end
    end
    
    -- Otherwise, loop through all players and return the one with the most frags
    local bestscore = 0
    local bestplayer = nil
    for k,v in pairs(player.GetAll()) do
        local frags = v:GetMScore()
        if frags > bestscore then
            bestscore = frags
            bestplayer = v
        end
    end
    return bestplayer
end

-- Think hook with built-in delay
hook.Add('Think', 'ModifierThinkLoop', function()
    if GAMEMODE:GetRoundState() != 'InRound' then return end

    if GAMEMODE.CurrentModifier.Think then
        if CurTime() < GAMEMODE.LastThink + (GAMEMODE.CurrentModifier.ThinkTime or 0) then return end
        GAMEMODE.LastThink = CurTime()
        GAMEMODE.CurrentModifier.Think()
    end
end)

function GM:CheckRoundEnd()
    -- Abort rounds if everyone dies
    if GAMEMODE:GetNumberAlive() == 0 then
        GAMEMODE:EndRound(nil)
    end

    -- Handle elimination if the modifier has it enabled
    local modifier = GAMEMODE.CurrentModifier
    if modifier.Elimination then
        if GAMEMODE:GetNumberAlive() <= 1 then
            for k,v in pairs(player.GetAll()) do
                if v:Alive() and !v.Spectating then
                    GAMEMODE:EndRound(v)
                    return
                end
            end
            GAMEMODE:EndRound(nil)
        end
    end
end

-- Load all the modifiers from the files
-- This has to be outside of a function
-- Blame Garry not me
GM.Modifiers = {}
print('Loading Microgames modifiers...')
for _, file in pairs(file.Find("gamemodes/fluffy_microgames/gamemode/modifiers/*.lua", "GAME")) do
    local k = string.Replace(file, ".lua", "")
    print('Loading', k)
    
    MOD = {}
    include("modifiers/" .. file)
    GM.Modifiers[k] = MOD
end

-- Clear global variable once this process is done
MOD = nil