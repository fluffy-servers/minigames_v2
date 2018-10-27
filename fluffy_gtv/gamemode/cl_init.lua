include('shared.lua')

GM.MaxCameraHeight = 800
GM.PlayerRingSize = 64

local ang = Angle(0,90,0)
local viewtab = {["angles"] = Angle(90,0,-90)}
local refoffset = Vector(0,0,GM.MaxCameraHeight)
local poffset = Vector(0,0,GM.MaxCameraHeight)
local tracetab = {}
tracetab.mask = CONTENTS_SOLID
tracetab.mins = Vector(-16,-16,-16)
tracetab.maxs = Vector(16,16,16)
local lasttrace = 0

function GM:CalcView( ply, origin, angles, fov )
	local ent = GetViewEntity()
    local tracetab = {}
	tracetab.start = origin
	tracetab.endpos = origin+refoffset
	viewtab.origin = origin+poffset
	if !ent:IsValid() || ((LocalPlayer():Team() == TEAM_SPECTATOR) && (LocalPlayer():GetObserverMode() != OBS_MODE_CHASE)) then
		return self.BaseClass:CalcView(ply, origin, angles, fov)
	end
	tracetab.filter = ent
	local tr = util.TraceHull(tracetab)
	if ent:IsPlayer() && ent:Alive() then
		poffset.z = math.Approach(poffset.z,tr.HitPos.z-tracetab.start.z,(CurTime()-lasttrace)*1200)
	end
	lasttrace = CurTime()
	viewtab.fov = math.Clamp((GAMEMODE.MaxCameraHeight-poffset.z)/5,75,120)
    viewtab.drawviewer = true
	return viewtab
end

local cx, cy = 0
function GM:CreateMove( cmd )
	local ang = cmd:GetViewAngles()
    print(ang.x, ang.y)
    ang.x = 0
    local a = math.rad(ang.y+90)
    cx = math.sin(a)
    cy = math.cos(a)
	cmd:SetViewAngles( ang )
    return
end

-- Main HUD function
function GM:HUDPaint()
    -- Obey the convar
    local shouldDraw = GetConVar('cl_drawhud'):GetBool()
    if !shouldDraw then return end
    
    -- Draw some of the parts
    self:DrawRoundState()
    self:DrawHealth()
    self:DrawAmmo()

    if LocalPlayer():Alive() then
        self:DrawCrosshair(ScrW()/2 + cx*100, ScrH()/2 + cy*100)
        surface.DrawLine(ScrW()/2, ScrH()/2, ScrW()/2 + cx*384, ScrH()/2 + cy*384 )
    end
    
    -- Hooks! Yay!
    hook.Run( "HUDDrawTargetID" )
	hook.Run( "HUDDrawPickupHistory" )
    hook.Run( "DrawDeathNotice", 0.85, 0.04 )
end

local CircleMat = Material("sprites/sent_ball")
local rendercol = Color(255,255,255,200)

function GM:DrawPlayerRing( pl )
	if ( !IsValid( pl ) ) then return end
	if ( !pl:Alive() ) then return end
	
	local trace = {}
	trace.start 	= pl:GetPos() + Vector(0,0,50)
	trace.endpos 	= trace.start + Vector(0,0,-300)
	trace.filter 	= pl
	
	local tr = util.TraceLine( trace )
	
	if not tr.HitWorld then
		tr.HitPos = pl:GetPos()
	end
	local col = pl:GetPlayerColor() --we don't want to make a copy, more efficient this way since we know how to NOT fuck it up
    
	if col then
		rendercol.r = col[1]*255 --using an existing color object saves us 60xNumberOfPlayers or howevermany color objects a second for GC to handle!
		rendercol.g = col[2]*255
		rendercol.b = col[3]*255
	else
		rendercol.r = 255
		rendercol.g = 255
		rendercol.b = 255
	end
	render.SetMaterial( CircleMat )

	local fwd1 = pl:GetAimVector()
	fwd1.z = 0
	fwd1:Normalize()
	local rt = tr.HitNormal:Cross(fwd1)
	local fwd = rt:Cross(tr.HitNormal)
	rt = rt*GAMEMODE.PlayerRingSize*-0.5
	fwd = fwd*GAMEMODE.PlayerRingSize*0.5
	cam.Start3D(EyePos(),EyeAngles())
		render.DrawQuad(tr.HitPos+tr.HitNormal+fwd-rt,tr.HitPos+tr.HitNormal+fwd+rt,tr.HitPos+tr.HitNormal-fwd+rt,tr.HitPos+tr.HitNormal-fwd-rt, rendercol)
	cam.End3D()
    
	//render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, GAMEMODE.PlayerRingSize, GAMEMODE.PlayerRingSize, rendercol , pl:GetAimVector():Angle().y)	
end
hook.Add( "PostPlayerDraw", "DrawRings", function(p) GAMEMODE:DrawPlayerRing(p) end )