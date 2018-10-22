include('shared.lua')

local function DrawDodgeLevel( ply )
	if ( !IsValid( ply ) ) then return end
	if ( ply == LocalPlayer() ) then return end -- Don't draw a name when the player is you
	if ( !ply:Alive() ) then return end -- Check if the player is alive

	local Distance = LocalPlayer():GetPos():Distance( ply:GetPos() ) --Get the distance between you and the player

	if ( Distance < 1000 ) then --If the distance is less than 1000 units, it will draw the name

		local offset = Vector( 0, 0, 76 )
		local ang = LocalPlayer():EyeAngles()
		local pos = ply:GetPos() + offset + ang:Up()

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.125 )
			draw.SimpleTextOutlined( 'Level ' .. ply:GetNWInt('BallLevel', 0), "FS_60", 2, 2, team.GetColor( ply:Team() ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0) )
		cam.End3D2D()
	end
end
hook.Add( "PostPlayerDraw", "DrawDodgeballLevel", DrawDodgeLevel )