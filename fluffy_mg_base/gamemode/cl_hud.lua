--[[
    Welcome to the Minigames HUD v2!
    This file has been pretty much completely made for lots of improvements around the board!
    Note: this HUD isn't the most efficient thing ever created, but the latest updates have improved framerates significantly.
--]]
include('drawarc.lua')

-- Hide default HUD components
local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
    CHudCrosshair = true,
    CHudDamageIndicator = true
}

local HEALTH_ICON = Material("fluffy/health.png", "noclamp smooth")
local TIME_ICON = Material("fluffy/time.png", "noclamp smooth")
local AMMO_ICON = Material("fluffy/ammo.png", "noclamp smooth")

hook.Add("HUDShouldDraw", "FluffyHideHUD", function(name)
	if hide[name] then return false end
end )

-- Main HUD function
-- This calls many of the sub functions below
function GM:HUDPaint()
    -- Obey the convar
    local shouldDraw = GetConVar('cl_drawhud'):GetBool()
    if not shouldDraw then 
		if GAMEMODE:ScoringPaneActive() and IsValid(GAMEMODE.ScorePane) then
			GAMEMODE.ScorePane:Hide()
		end
        
		return 
	end
    
    -- Check team changes (where needed)
    if GAMEMODE.HUDTeamColor then
        if LocalPlayer():Team() != (GAMEMODE.team_cached or nil) then
            GAMEMODE.team_cached = LocalPlayer():Team()
            GAMEMODE:UpdateTeamColors(LocalPlayer():Team())
        end
    end
    
    -- Draw some of the parts
    self:DrawRoundState()

    -- Draw health and ammo if applicable, otherwise draw spectator info
    if LocalPlayer().Spectating then
        self:DrawSpectateState()
    else
        self:DrawHealth()
        self:DrawAmmo()
    end
    
    -- Crosshair - account for third person too
    if LocalPlayer().Thirdperson then
    	local x,y = 0,0
		local tr = LocalPlayer():GetEyeTrace()
		x = tr.HitPos:ToScreen().x
		y = tr.HitPos:ToScreen().y
        self:DrawCrosshair(x, y)
    else
        local tr = LocalPlayer():GetEyeTrace()
        --if (tr.Entity and not tr.Entity:IsPlayer()) or (!tr.Entity) then
            self:DrawCrosshair(ScrW()/2, ScrH()/2)
        --end
    end
	
	-- Scoring pane
	if GAMEMODE:ScoringPaneActive() then
		if !IsValid(GAMEMODE.ScorePane) then 
			GAMEMODE:CreateScoringPane() 
		else
			GAMEMODE.ScorePane:Show()
		end
	elseif IsValid(GAMEMODE.ScorePane) then
        GAMEMODE.ScorePane:Hide()
    end

    -- Hooks! Yay!
    hook.Run("HUDDrawTargetID")
	hook.Run("HUDDrawPickupHistory")
    hook.Run("DrawDeathNotice", 0.85, 0.04)
end

-- Useful function that helps sort out team colors
function GM:UpdateTeamColors(t)
    local name = team.GetName(t)
    if name == 'Spectators' then
        GAMEMODE:UpdateColorSet()
    else
        if t == TEAM_RED then
            GAMEMODE:UpdateColorSet('red')
        elseif t == TEAM_BLUE then
            GAMEMODE:UpdateColorSet('blue')
        else
            -- Last resort, try getting the color from the team name
            name = string.lower(string.Replace(name, ' Team', ''))
            GAMEMODE:UpdateColorSet(name)
        end
    end
end

-- Convenience to draw a circle (uncached)
-- If the same circle is being drawn a lot - use the cached version below
-- This code originally from the wiki - thanks
function draw.Circle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
	for i = 0, seg do
		local a = math.rad((i/seg) * -360)
		table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
	end

	local a = math.rad(0) -- This is needed for non absolute segment counts
	table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })

	surface.DrawPoly(cir)
end

-- Cache a circle polygon to draw later
function draw.CirclePoly(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5 })
	for i = 0, seg do
		local a = math.rad((i/seg) * -360)
		table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 } )
	end

	local a = math.rad(0) -- This is needed for non absolute segment counts
	table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 } )
    return cir
end

-- Circle properties
local c_pos = 72
local seg = 36
local radius = 48

-- Cache the circles
local round_circle = draw.CirclePoly(c_pos, c_pos, radius, seg)
local round_circle_shadow = draw.CirclePoly(c_pos+3, c_pos+3, radius, seg)
local health_circle = draw.CirclePoly(c_pos, ScrH() - c_pos, radius, seg)
local health_circle_shadow = draw.CirclePoly(c_pos, ScrH() - c_pos+3, radius, seg)
local ammo_circle = draw.CirclePoly(ScrW() - c_pos, ScrH() - c_pos, radius, seg)
local ammo_circle_shadow = draw.CirclePoly(ScrW() - c_pos+3, ScrH() - c_pos+3, radius, seg)

-- Convar to disable the fancy arcs
-- This used to be important before, but now it has a lot less impact
local fast_hud = CreateClientConVar("mg_fast_hud", "0", true, false, "Whether to use an optimised HUD. Enable if you have poor performance")

-- Draw the state of the round, including time and round number etc.
-- This is in the top left corner
function GM:DrawRoundState()
    local GAME_STATE = GAMEMODE:GetRoundState()
    -- Draw a notification if not enough players are in the game
    if GAME_STATE == 'GameNotStarted' then
        GAMEMODE:DrawShadowText('Waiting for Players...', 'FS_40', 4,4, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        return
    end

    -- Draw a warmup timer if the game is starting soon
    if GAME_STATE == 'Warmup' then
        local start_time = GetGlobalFloat('WarmupTime', CurTime())
        local t = GAMEMODE.WarmupTime - (CurTime() - start_time)
        GAMEMODE:DrawShadowText('Round starting in ' .. math.ceil(t) .. '...', 'FS_40', 4,4, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        return
    end
    
    -- There are four default round state styles
    -- See the functions below
    -- Gamemodes can pick a HUDStyle to use
    if not GAMEMODE.HUDStyle or GAMEMODE.HUDStyle == 1 then
        GAMEMODE:RoundStateDefault()
    elseif GAMEMODE.HUDStyle == 2 then
        GAMEMODE:RoundStateWithTimer()
    elseif GAMEMODE.HUDStyle == 3 then
        GAMEMODE:RoundStateTimerOnly()
    elseif GAMEMODE.HUDStyle == 4 then
        GAMEMODE:RoundStateTimerTeamRoundScore()
    elseif GAMEMODE.HUDStyle == 5 then
        GAMEMODE:RoundStateTimerTeamScore()
    end
end

-- Default round state
-- Includes a countdown timer for each round + round number indicator
function GM:RoundStateDefault()
    -- Get round information
    local GAME_STATE = GAMEMODE:GetRoundState()
    local RoundTime = GetGlobalFloat('RoundStart')
    
    -- Draw the cool round timer
    if !RoundTime then return end
    if GAME_STATE == 'EndRound' then return end
    
    -- Get some information about the rounds
	local tmax = GAMEMODE.RoundTime or 60
	if GAME_STATE == 'PreRound' then tmax = GAMEMODE.RoundCooldown or 5 end
    local round = GetGlobalInt('RoundNumber') or 1
	local rmax = GAMEMODE.RoundNumber or 5
	
    -- Draw the circle shadow
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.DrawPoly(round_circle_shadow)
    
    -- Calculate the size of the text to adapt the box
    local round_message = "Round " .. round .. " / " .. rmax, "FS_24"
    if round == rmax then round_message = "Final Round!" end
    surface.SetFont('FS_24')
    local w = surface.GetTextSize(round_message)
    
    -- Draw the box with sizing information determined above
    local rect_height = 32
    local rect_width = w + 80
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.DrawRect(c_pos, c_pos - rect_height/2, rect_width, rect_height + 3)
    surface.SetDrawColor(GAMEMODE.HColLight)
    surface.DrawRect(c_pos, c_pos - rect_height/2, rect_width, rect_height)
    
    -- Draw the top layer of the circle
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.HColLight)
    surface.DrawPoly(round_circle)
    
    -- Calculate time remaining
	local t = tmax - (CurTime() - RoundTime)
	if t < 0 then t = 0 end
    
    -- Draw background icon
    local icon_size = 40
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.SetMaterial(TIME_ICON)
    surface.DrawTexturedRect(c_pos - (icon_size/2), c_pos - (icon_size/2), icon_size, icon_size)
    
    -- Draw the arc (if applicable)
    if !fast_hud:GetBool() and t != 0 and tmax > 0 then
        draw.NoTexture()
        draw.Arc(c_pos, c_pos, 42, 10, math.Round((t/tmax * -360) + 90), 90, 8, GAMEMODE.FCol1)
    end
    
    -- Draw the time text
    GAMEMODE:DrawShadowText(math.ceil(t), 'FS_40', c_pos, c_pos, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Draw the round information
    GAMEMODE:DrawShadowText(round_message, 'FS_24', c_pos+52, c_pos+2, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- Display the game timer instead of the round number indicator
function GM:RoundStateWithTimer()
    if GAMEMODE.RoundType != 'timed' and GAMEMODE.RoundType != 'timed_endless' then return end
    
    -- Get round information
    local GAME_STATE = GAMEMODE:GetRoundState()
    local RoundTime = GetGlobalFloat('RoundStart')
    local GameTime = GetGlobalFloat('GameStartTime')

    -- Draw the cool round timer
    if !RoundTime then return end
    if !GameTime then return end
    if GAME_STATE == 'EndRound' then return end
    
    -- Get some information about the rounds
	local tmax = GAMEMODE.RoundTime or 60
	if GAME_STATE == 'PreRound' then tmax = GAMEMODE.RoundCooldown or 5 end
    
    local time_left = (GameTime + GAMEMODE.GameTime) - CurTime()
    local round = GetGlobalInt('RoundNumber') or 1
	local rmax = GAMEMODE.RoundNumber or 5
	
    -- Draw the circle shadow
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.DrawPoly(round_circle_shadow)
    
    -- Calculate the size of the text to adapt the box
    local round_message = string.FormattedTime(time_left, '%02i:%02i')
    if time_left < 1 then round_message = "Overtime!" end
    surface.SetFont('FS_24')
    local w = 64
    
    -- Draw the box with sizing information determined above
    local rect_height = 32
    local rect_width = w + 80
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.DrawRect(c_pos, c_pos - rect_height/2, rect_width, rect_height + 3)
    surface.SetDrawColor(GAMEMODE.HColLight)
    surface.DrawRect(c_pos, c_pos - rect_height/2, rect_width, rect_height)
    
    -- Draw the top layer of the circle
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.HColLight)
    surface.DrawPoly(round_circle)
    
    -- Calculate time remaining
	local t = tmax - (CurTime() - RoundTime)
	if t < 0 then t = 0 end
    
    -- Draw the arc (if applicable)
    if !fast_hud:GetBool() and t != 0 then
        draw.Arc(c_pos, c_pos, 42, 14, math.Round((t/tmax * -360) + 90), 90, 8, GAMEMODE.FCol1)
    end
    
    -- Draw the time text
    GAMEMODE:DrawShadowText(math.ceil(t), 'FS_40', c_pos, c_pos, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Draw the round information
    GAMEMODE:DrawShadowText(round_message, 'FS_24', c_pos+52, c_pos+2, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- Totally redesigned to display the game timer only
-- Uses a square instead of a circle
-- If timed, adds a smaller box underneath to indicate the Round number (no limit)
function GM:RoundStateTimerOnly()
    if GAMEMODE.RoundType != 'timed' and GAMEMODE.RoundType != 'timed_endless' then return end
    
    local GAME_STATE = GAMEMODE:GetRoundState()
    local GameTime = GetGlobalFloat('GameStartTime')
    
    if !GameTime then return end
    --if GAME_STATE == 'EndRound' then return end
    
    local time_left = (GameTime + GAMEMODE.GameTime) - CurTime()
    local round_message = string.FormattedTime(time_left, '%02i:%02i')
    
    -- Draw the box
    draw.RoundedBox(8, c_pos-48, c_pos-48, 128, 48+3, GAMEMODE.HColDark)
    draw.RoundedBox(8, c_pos-48, c_pos-48, 128, 48, GAMEMODE.HColLight)
    
    -- Draw the time text
    if time_left > 0 then
        GAMEMODE:DrawShadowText(round_message, 'FS_32', c_pos+16, c_pos-22, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        GAMEMODE:DrawShadowText('Overtime!', 'FS_24', c_pos+16, c_pos-22, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Draw the round number (if applicable)
    if GAMEMODE.RoundType == 'timed' then
        -- Draw the box
        draw.RoundedBoxEx(8, c_pos-48, c_pos-3, 128, 32+3, GAMEMODE.HColDark, false, false, true, true)
        draw.RoundedBoxEx(8, c_pos-48, c_pos-2, 128, 32, GAMEMODE.HColLight, false, false, true, true)
        
        local round = GetGlobalInt('RoundNumber') or 1
        draw.SimpleText('Round ' .. round, "FS_24", c_pos + 16, c_pos + 15, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- Similar to the above
function GM:RoundStateTimerTeamRoundScore()
    if GAMEMODE.RoundType != 'timed' and GAMEMODE.RoundType != 'timed_endless' then return end
    
    local GAME_STATE = GAMEMODE:GetRoundState()
    local GameTime = GetGlobalFloat('GameStartTime')
    
    if !GameTime then return end
    --if GAME_STATE == 'EndRound' then return end
    
    -- Fancy formatting for the time
    local time_left = (GameTime + GAMEMODE.GameTime) - CurTime()
    local round_message = string.FormattedTime(time_left, '%02i:%02i')
    
    -- Draw the box
    draw.RoundedBoxEx(8, c_pos-48, c_pos-48, 128, 48, GAMEMODE.HColLight, true, true, false, false)
    
    -- Draw the time text
    if time_left > 0 then
        GAMEMODE:DrawShadowText(round_message, 'FS_32', c_pos+16, c_pos-22, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        GAMEMODE:DrawShadowText('Overtime!', 'FS_24', c_pos+16, c_pos-22, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Draw the team boxes
    local red_col = team.GetColor(TEAM_RED)
    local blue_col = team.GetColor(TEAM_BLUE)
    local red_shadow = Color(red_col.r - 35, red_col.g - 35, red_col.b - 35)
    local blue_shadow = Color(blue_col.r - 35, blue_col.g - 35, blue_col.b - 35)
    local score_h = 36
    draw.RoundedBoxEx(8, c_pos-48, c_pos, 64, score_h+2, red_shadow, false, false, true, false)
    draw.RoundedBoxEx(8, c_pos-48, c_pos, 64, score_h, red_col, false, false, true, false)
    draw.RoundedBoxEx(8, c_pos+16, c_pos, 64, score_h+2, blue_shadow, false, false, false, true)
    draw.RoundedBoxEx(8, c_pos+16, c_pos, 64, score_h, blue_col, false, false, false, true)
    
    -- Draw the scores for each team
    GAMEMODE:DrawShadowText(team.GetRoundScore(TEAM_RED), 'FS_40', c_pos-16, c_pos + score_h/2 + 2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    GAMEMODE:DrawShadowText(team.GetRoundScore(TEAM_BLUE), 'FS_40', c_pos+48, c_pos + score_h/2 + 2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Similar to the above, but using overall score rather than round score
function GM:RoundStateTimerTeamScore()
    if GAMEMODE.RoundType != 'timed' and GAMEMODE.RoundType != 'timed_endless' then return end
    
    local GAME_STATE = GAMEMODE:GetRoundState()
    local GameTime = GetGlobalFloat('GameStartTime')
    
    if !GameTime then return end
    --if GAME_STATE == 'EndRound' then return end
    
    -- Fancy formatting for the time
    local time_left = (GameTime + GAMEMODE.GameTime) - CurTime()
    local round_message = string.FormattedTime(time_left, '%02i:%02i')
    
    -- Draw the box
    draw.RoundedBoxEx(8, c_pos-48, c_pos-48, 128, 48, GAMEMODE.HColLight, true, true, false, false)
    
    -- Draw the time text
    if time_left > 0 then
        GAMEMODE:DrawShadowText(round_message, 'FS_32', c_pos+16, c_pos-22, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        GAMEMODE:DrawShadowText('Overtime!', 'FS_24', c_pos+16, c_pos-22, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Draw the team boxes
    local red_col = team.GetColor(TEAM_RED)
    local blue_col = team.GetColor(TEAM_BLUE)
    local red_shadow = Color(red_col.r - 35, red_col.g - 35, red_col.b - 35)
    local blue_shadow = Color(blue_col.r - 35, blue_col.g - 35, blue_col.b - 35)
    local score_h = 36
    draw.RoundedBoxEx(8, c_pos-48, c_pos, 64, score_h+2, red_shadow, false, false, true, false)
    draw.RoundedBoxEx(8, c_pos-48, c_pos, 64, score_h, red_col, false, false, true, false)
    draw.RoundedBoxEx(8, c_pos+16, c_pos, 64, score_h+2, blue_shadow, false, false, false, true)
    draw.RoundedBoxEx(8, c_pos+16, c_pos, 64, score_h, blue_col, false, false, false, true)
    
    -- Draw the scores for each team
    GAMEMODE:DrawShadowText(team.GetScore(TEAM_RED), 'FS_40', c_pos-16, c_pos + score_h/2 + 2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    GAMEMODE:DrawShadowText(team.GetScore(TEAM_BLUE), 'FS_40', c_pos+48, c_pos + score_h/2 + 2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end


-- Draw the health bar
-- Armor is not included -> is there any gamemode that actually uses armor?
function GM:DrawHealth()
    -- Don't draw health for spectators
    if not LocalPlayer():Alive() or LocalPlayer():Team() == TEAM_SPECTATOR then 
        HealthBarHP = 0 
        return 
    end
    
    -- Small animation for the arc
    local hp_max = LocalPlayer():GetMaxHealth() or 100
    if HealthBarHP then
        HealthBarHP = math.Approach(HealthBarHP, LocalPlayer():Health(), 70*FrameTime())
    else
        HealthBarHP = 100
    end
    
    local hp = HealthBarHP
    if hp <= 0 then return end
    
    -- Draw the circle shadow
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.DrawPoly(health_circle_shadow)
    
    -- Calculate the size of the team name text
    -- Then draw a rectangle
    local team_name = team.GetName(LocalPlayer():Team())
    if GAMEMODE.TeamBased and LocalPlayer():Team() != TEAM_CONNECTING then
        surface.SetFont('FS_24')
        local w = surface.GetTextSize(team_name)
        local rect_height = 32
        local rect_width = w + 80
        surface.SetDrawColor(GAMEMODE.HColDark)
        surface.DrawRect(c_pos, ScrH() - c_pos - rect_height/2, rect_width, rect_height + 3)
        surface.SetDrawColor(GAMEMODE.HColLight)
        surface.DrawRect(c_pos, ScrH() - c_pos - rect_height/2, rect_width, rect_height)
    end
    
    -- Draw the top layer of the circle
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.HColLight)
    surface.DrawPoly(health_circle)
    
    -- Draw background icon
    local icon_size = 40
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.SetMaterial(HEALTH_ICON)
    surface.DrawTexturedRect(c_pos - (icon_size/2), ScrH() - c_pos - (icon_size/2), icon_size, icon_size)
    
    -- Draw arc (if applicable)
    if !fast_hud:GetBool() and hp > 0 and hp_max > 0 then
        local ang = (hp/hp_max) * -360
        if ang % 2 == 1 then ang = ang - 1 end
        draw.NoTexture()
        draw.Arc(c_pos, ScrH() - c_pos, 42, 10, math.Round(ang+90), 90, 12, GAMEMODE.FCol1)
    end
    
    -- Draw the health number
    GAMEMODE:DrawShadowText(math.floor(LocalPlayer():Health()), 'FS_40', c_pos, ScrH() - c_pos, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Draw the team name (if applicable)
    if GAMEMODE.TeamBased and LocalPlayer():Team() != TEAM_CONNECTING then
        GAMEMODE:DrawShadowText(team_name, 'FS_24', c_pos+52, ScrH() - c_pos+2, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

-- Draw the ammo
-- Note: secondary ammo is not drawn -> is there any gamemode that actually needs this?
function GM:DrawAmmo()
    -- Check the player is alive and playing the game
    if !LocalPlayer():Alive() then return end
    if GAMEMODE.TeamBased then
        if LocalPlayer():Team() == TEAM_SPECTATOR or LocalPlayer():Team() == TEAM_UNASSIGNED or LocalPlayer():Team() == 0 then return end
    end
    
    -- Grab the current weapon
    local wep = LocalPlayer():GetActiveWeapon()
    if !IsValid(wep) then return end
    if not wep.DrawAmmo then return end
    
    -- Get the ammo information from the gun
    -- There's a lot of unusual cases here that could be handled better in futures
    local ammo = {}
    ammo['PrimaryClip'] = wep:Clip1()
    ammo['SecondaryClip'] = wep:Clip2()
    ammo['PrimaryAmmo'] = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
    ammo['SecondaryAmmo'] = LocalPlayer():GetAmmoCount(wep:GetSecondaryAmmoType())
    ammo['MaxPrimaryClip'] = wep:GetMaxClip1()
    ammo['MaxSecondaryClip'] = wep:GetMaxClip2()
    
    -- Some weapons have a custom ammo display function to calculate this table
    if wep.CustomAmmoDisplay then
        if wep:CustomAmmoDisplay() != nil then 
            ammo = wep:CustomAmmoDisplay()
            if not ammo.Draw then return end
        end
    end
    
    -- Check the ammo table is valid
    if !ammo then return end
    if ammo['PrimaryClip'] == -1 and (ammo['PrimaryAmmo'] or -1) < 1 then return end
    if ammo['PrimaryClip'] == 0 and ammo['PrimaryAmmo'] == 0 then return end
    
    -- Draw the shadow & circle
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.DrawPoly(ammo_circle_shadow)
    surface.SetDrawColor(GAMEMODE.HColLight)
    surface.DrawPoly(ammo_circle)
    
    -- Draw background icon
    local icon_size = 40
    surface.SetDrawColor(GAMEMODE.HColDark)
    surface.SetMaterial(AMMO_ICON)
    surface.DrawTexturedRect(ScrW() - c_pos - (icon_size/2), ScrH() - c_pos - (icon_size/2), icon_size, icon_size)
    
    -- Draw the arc (if applicable)
    if !fast_hud:GetBool() then
        if ammo['MaxPrimaryClip'] and ammo['MaxPrimaryClip'] > -1 then
            -- Calculate the percentage with slight interpolation
            
            -- Make sure the percentage isn't a division by 0
            local p = 0
            if ammo['PrimaryClip'] < ammo['MaxPrimaryClip'] and ammo['MaxPrimaryClip'] > 0 then
                p = ammo['PrimaryClip'] / ammo['MaxPrimaryClip']
            else
                p = 1
            end
            
            -- Slight animation effect
            if ClipPercentage then
                ClipPercentage = math.Approach(ClipPercentage, p, FrameTime())
            else
                ClipPercentage = p
            end
            
            -- Draw the arc
            local ang = ClipPercentage * -360
            draw.NoTexture()
            draw.Arc(ScrW() - c_pos, ScrH() - c_pos, 42, 6, math.Round(ang+90), 90, 12, GAMEMODE.FCol1)
        end
    end
    
    -- If there is a 'reserve' value for this gun, draw clip & ammo
    -- Otherwise, just draw the clip
    if ammo['PrimaryAmmo'] and ammo['PrimaryAmmo'] > -1 and ammo['PrimaryAmmo'] < 1000 and ammo['PrimaryClip'] > -1 then
        -- Clip & ammo
        GAMEMODE:DrawShadowText(ammo['PrimaryClip'], 'FS_40', ScrW() - c_pos, ScrH() - c_pos - 4, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        GAMEMODE:DrawShadowText(ammo['PrimaryAmmo'] or 72, 'FS_20', ScrW() - c_pos, ScrH() - c_pos + 16, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif ammo['PrimaryClip'] != -1 then
        -- Clip1 only
        GAMEMODE:DrawShadowText(ammo['PrimaryClip'], 'FS_60', ScrW() - c_pos, ScrH() - c_pos, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif ammo['PrimaryAmmo'] > 0 then
        GAMEMODE:DrawShadowText(ammo['PrimaryAmmo'], 'FS_60', ScrW() - c_pos, ScrH() - c_pos, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- What about secondary ammo?? :(
    -- Todo: add a check for 'infinite' ammo (I think this is done)
end

-- Create the round end panel with information
-- This a popup at the top of the screen
--[[
function GM:CreateRoundEndPanel(message, tagline)
    surface.PlaySound('friends/friend_join.wav')
    if IsValid(GAMEMODE.RoundEndPanel) then
        GAMEMODE.RoundEndPanel:Remove()
    end
    
    -- Create the panel
    local w = 288
    local h = 64
    local bar_h = 24
    local p = vgui.Create('DPanel')
    p:SetSize(w, h)
    p:SetPos(ScrW()/2 - w/2, -h)
    
    -- Message & tagline handling
    p.Message = message
    p.TagLine = tagline or nil
    if p.TagLine == '' or p.TagLine == ' ' then p.TagLine = nil end
    
    -- Paint the message
    -- Slight sizing changes based on if there is a second line or not
    function p:Paint(w, h)
        if self.TagLine then
            draw.RoundedBoxEx(16, 0, 0, w, h-bar_h, GAMEMODE.FCol2, false, false, false, false)
            draw.RoundedBoxEx(16, 0, h-bar_h, w, bar_h, GAMEMODE.FCol3, false, false, true, true)
            
            draw.SimpleText(self.Message, 'FS_B32', w/2 + 1, 20 + 2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(self.Message, 'FS_B32', w/2, 20, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(self.TagLine, 'FS_20', w/2, h-bar_h+2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        else
            draw.RoundedBoxEx(16, 0, 0, w, h, GAMEMODE.FCol2, false, false, true, true)
            draw.SimpleText(self.Message, 'FS_B32', w/2 + 1, h/2 + 2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(self.Message, 'FS_B32', w/2, h/2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Slide in, wait, slide out
    p:MoveTo(ScrW()/2 - w/2, 0, 1, 0, -1, function(anim, p)
        p:MoveTo(ScrW()/2 - w/2, -h, 1, GAMEMODE.RoundCooldown - 1, -1, function(anim, p) p:Remove() end)
    end)
end
--]]

function GM:CreateRoundEndPanel(message, tagline)
    surface.PlaySound('friends/friend_join.wav')
    if IsValid(GAMEMODE.RoundEndPanel) then
        GAMEMODE.RoundEndPanel:Remove()
    end
    
    local w = ScrW()
    local h = 160
    
    local p = vgui.Create('DPanel')
    p:SetSize(w, h)
    p:SetPos(ScrW(), ScrH()/2 - h/2)
    p.TagLine = tagline or nil
    if p.TagLine == '' or p.TagLine == ' ' then p.TagLine = nil end
    p.Message = message
    
    function p:Paint(w, h)
        local c = Color(0, 0, 0, 200)
        draw.RoundedBoxEx(0, 0, 0, w, h, c, false, false, true, true)
        if self.TagLine then
            GAMEMODE:DrawShadowText(self.Message, 'FS_64', w/2, h/2 - 24, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            GAMEMODE:DrawShadowText(self.TagLine, 'FS_40', w/2, h/2 + 32, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            GAMEMODE:DrawShadowText(self.Message, 'FS_64', w/2, h/2, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    p:MoveTo(0, ScrH()/2 - h/2, 0.75, 0, -1, function(anim, p)
        p:MoveTo(-w, ScrH()/2 - h/2, 0.75, GAMEMODE.RoundCooldown - 1, -1, function(anim, p) p:Remove() end)
    end)
    GAMEMODE.RoundEndPanel = p
end

-- Play a COOL sound when the round ends!
-- Also display the EndGameMessage -> update the look of this soon
net.Receive('EndRound', function()
    local msg = net.ReadString()
    local tagline = net.ReadString()
    GAMEMODE:CreateRoundEndPanel(msg, tagline)
end)

-- Function to determine the variable of the scoring pane
-- Override in gamemodes
function GM:ScoringPaneScore(ply)
	return ply:Frags()
end

-- Function to determine if the scoring pane is enabled or not
-- This is usually always static - but this might be useful to override in some rare cases
function GM:ScoringPaneActive()
    return GAMEMODE.ScoringPaneEnabled
end

-- Sort the scoring pane so the top player is first in the list etc.
function GM:ScoreRefreshSort()
    if !GAMEMODE.ScorePane then return end
    
    -- Sort the table with default implementation
    local scores = {}
    for k,v in pairs(player.GetAll()) do
        local score = GAMEMODE:ScoringPaneScore(v)
        table.insert(scores, {v, score})
    end
    table.sort(scores, function(a, b) return a[2] > b[2] end)
    
    -- Clear the current order
    GAMEMODE.ScorePane:Clear()
    GAMEMODE.ScorePane.scores = scores
    
    -- math stuff
    local count = ScrW()*0.5 / 68
    count = math.floor(count)
    local n = math.min(#scores, count)
    local xx = ScrW()*0.25 - (n*34)
    
    -- Reorder the players in the score panel
    for k,v in pairs(scores) do
        if k > count then return end
        GAMEMODE.ScorePane:CreatePlayer(v[1], xx)
        xx = xx + 68
    end
end

-- Create the scoring pane
function GM:CreateScoringPane()
    if GAMEMODE.ScorePane then
        GAMEMODE.ScorePane:Remove()
    end

    local frame = vgui.Create('DPanel')
    local panel_h = 80
    frame:SetSize(ScrW() * 0.5, panel_h)
    frame:SetPos(ScrW() * 0.25, ScrH() - panel_h)
    
    -- Function to create a blob for each player
    -- This includes the score & avatar
    function frame:CreatePlayer(ply, x)
        local p = vgui.Create('DPanel', frame)
        p:SetPos(x, 0)
        p:SetSize(64, panel_h)
        function p:Paint()
            local score = GAMEMODE:ScoringPaneScore(ply) or 0
            GAMEMODE:DrawShadowText(score, 'FS_32', 32, panel_h - 4, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
        
        local Avatar = vgui.Create('AvatarImage', p)
        Avatar:SetSize(40, 40)
        Avatar:SetPos(12, 0)
        Avatar:SetPlayer(ply, 64)
    end
    
    function frame:Paint()
    
    end
    GAMEMODE.ScorePane = frame
	
    -- Refresh the score panel every 2 seconds
    -- This is a bit expensive hence the infrequency
    -- Scores will update instantly, however the order only changes in this function
	ScoreRefreshPlayers = timer.Create('RefreshPlayers', 2, 0, function()
		GAMEMODE:ScoreRefreshSort()
	end)
end

-- Used for targetID drawing
-- Has a circle with healthbar and avatar
GM.PlayerPanels = {}
function GM:GetPlayerInfoPanel(ply)
    if GAMEMODE.PlayerPanels[ply] then return GAMEMODE.PlayerPanels[ply] end
    local panel = vgui.Create("DPanel")
    panel:SetSize(160, 64)
    panel:SetPaintedManually(true)
    
    -- Create the avatar
    local avatar = vgui.Create('AvatarCircle', panel)
    avatar:SetSize(32, 32)
    avatar:SetPos(16, 16)
    avatar:SetPlayer(ply, 32)
    local last_health = ply:GetMaxHealth() or 100
    
    function panel:Paint(w, h)
        -- Draw a subtle background
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 80))
        
        -- Small animation for the arc
        local hp_max = ply:GetMaxHealth() or 100
        local hp = ply:Health()
        draw.NoTexture()
        
        -- Calculate the color based on team or FFA
        local c = Color(0, 168, 255)
        if GAMEMODE.TeamBased then
            c = team.GetColor(ply:Team())
        else
            local pc = ply:GetPlayerColor()
            c = Color(pc.r*255, pc.g*255, pc.b*255)
        end
        
        -- Circle for the avatar + HP arc
        local poly = poly or draw.CirclePoly(32, 32, 26, 24)
        surface.SetDrawColor(c)
        surface.DrawPoly(poly)
        
        -- HP Arc
        if hp_max > 0 then
            local ang = (hp/hp_max) * -360
            if ang % 2 == 1 then ang = ang - 1 end
            draw.Arc(32, 32, 24, 6, math.Round(ang+90), 90, 12, GAMEMODE.FCol1)
        end
        
        -- Draw username
        local name = ply:Nick()
        draw.SimpleText(name, "FS_24", 64 + 1, 24 + 1, GAMEMODE.FColShadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(name, "FS_24", 64, 24, c, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        GAMEMODE:DrawShadowText(name, 'FS_24', 64, 24, c, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Draw HP number
        hp = math.floor(hp)
        GAMEMODE:DrawShadowText(hp .. 'HP', 'FS_24', 64, 44, c, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Cache & return this panel
    GAMEMODE.PlayerPanels[ply] = panel
    return panel
end

-- Hook to call the above function when a player is looked at
function GM:HUDDrawTargetID()
    -- Spectators only see TargetID in free roam mode
    if LocalPlayer().Spectating and LocalPlayer().SpectateMode != OBS_MODE_ROAMING then
        return
    end

    -- Check if the player is looking at a player
	local tr = util.GetPlayerTrace(LocalPlayer())
	local trace = util.TraceLine(tr)
	if !trace.Hit then return end
	if !trace.HitNonWorld then return end
    if not trace.Entity:IsPlayer() then return end
    
    -- Use the mouse cursor if applicable OR the centre of the screen
    local xx, yy = gui.MousePos()
    if xx == 0 and yy == 0 then
        xx = ScrW()/2
        yy = ScrH()/2
    end
    
    -- Create an infomation panel using the above function
    local panel = GAMEMODE:GetPlayerInfoPanel(trace.Entity)
    panel:SetPos(xx - panel:GetWide()/2, yy - panel:GetTall()/2)
    panel:PaintManual()
end

-- Helper functions to handle drawing spectate state
function GM:DrawSpectateState()
    -- Don't draw for non-spectators (duh)
    if not LocalPlayer().Spectating then return end

    -- Find the name of the target to draw
    -- This will be a player name 99% of the time
    local targetname = 'Free Roam'
    if LocalPlayer().SpectateMode != OBS_MODE_ROAMING then
        local e = LocalPlayer().SpectateTarget
        if e:IsPlayer() then
            targetname = e:Nick() or 'Player'
        else
            targetname = 'Entity'
        end
    end

    -- Draw text
    GAMEMODE:DrawShadowText('Spectating', 'FS_32', 8, ScrH() - 58, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    GAMEMODE:DrawShadowText(targetname, 'FS_64', 8, ScrH(), GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end