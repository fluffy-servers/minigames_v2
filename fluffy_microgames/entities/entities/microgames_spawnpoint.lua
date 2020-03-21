ENT.Type = "point"

function ENT:KeyValue(key, value)
	if key == "region" then
		self.Region = value
	end
end