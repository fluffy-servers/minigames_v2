ENT.Type = "point"
ENT.Base = "base_point"

function ENT:KeyValue(key, value)
	if key == "region" then
		self.Region = value
	end
end