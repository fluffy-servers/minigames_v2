EFFECT.BeamMat = Material( "trails/lol" )
EFFECT.Color = Color( 255, 250, 250 )  

function EFFECT:Init( data )
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()

	self.Alpha = 255
	self.Life = 0

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
end

function EFFECT:Think()

	self.Life = self.Life + FrameTime() * 3
	self.Alpha = 255 * ( 1 - self.Life )

	return ( self.Life < 1 )

end

function EFFECT:Render()

	if ( self.Alpha < 1 ) then return end

	render.SetMaterial( self.BeamMat )
	local c = self.Color
	local gap = (self.StartPos - self.EndPos)
	local norm = gap * self.Life

	self.Length = norm:Length()

	render.DrawBeam( self.StartPos, self.EndPos, 12, 1-self.Life, 1-self.Life + gap:Length()/128 , Color( c.r, c.g, c.b, 200 * ( 1 - self.Life ) ) )
end