ENT.Type = "point"

function ENT:KeyValue(key, value)
	if key == "region" then
		self.Region = value
	elseif key == "type" then
        self.MarkerType = value
    end
end