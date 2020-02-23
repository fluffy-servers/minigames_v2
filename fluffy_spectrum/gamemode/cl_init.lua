include('shared.lua')

GM.PaintSplat = Material('decals/decal_paintsplatterpink001')

/*
-- Paintball effects for every bullet
hook.Add('EntityFireBullets', 'PaintSplatterEffects', function(ent, data)
    if ent:IsWeapon() then
        ent = ent:GetOwner()
    end
    data.Callback = function(attacker, tr, dmg)
	    if tr.HitSky then return end
    
        local c = team.GetColor(ent:Team())
        local s = 0.25 + 0.3*math.random()
        util.DecalEx(GAMEMODE.PaintSplat, tr.HitEntity or game.GetWorld(), tr.HitPos, tr.HitNormal, c, s, s)
    end

    return true
end)
*/