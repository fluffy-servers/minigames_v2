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
    ent:SetVelocity(v * 100)
end

local modifier_properties = {
    ['Initialize'] = true,
    ['Loadout'] = true,
    ['WinCheck'] = true,
    ['Cleanup'] = true,
    ['PlayerFinish'] = true,
    ['Think'] = true,
}

-- Set up a new modifier
function GM:SetupModifier(modifier)
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

    GAMEMODE.LastThink = CurTime()
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
    if GAMEMODE.ModifierHooks then
        for k,v in pairs(GAMEMODE.ModifierHooks) do
            hook.Remove(k, modifier.Name)
        end
        GAMEMODE.ModifierHooks = nil
    end
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