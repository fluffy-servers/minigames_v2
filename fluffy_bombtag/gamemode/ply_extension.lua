-- This file adds some functions to the Player metatable
local meta = FindMetaTable("Player")
if (!meta) then return end 

-- Set whether this player is the carrier or not
-- Adjusts movement speed accordingly
function meta:SetCarrier(bool)
	self:SetNWBool("Carrier", bool)
	
	if bool then
		self:SetWalkSpeed(500)
		self:SetRunSpeed(500)
		self:SetJumpPower(400)
	else
		self:SetWalkSpeed(300)
		self:SetRunSpeed(300)
		self:SetJumpPower(300)
	end
end

-- Returns whether this player currently has the bomb
function meta:IsCarrier()
	return self:GetNWBool("Carrier", false)
end

function meta:Explode()
	local ed = EffectData()
	ed:SetOrigin(self:GetPos())
	util.Effect("Explosion", ed, true, true)
	util.BlastDamage(self:GetWeapon('bt_bomb') or self, self, self:GetPos(), 500, 200)
end

-- Set the time remaining on the bomb
function meta:SetTime(time)
	self:SetNWInt("Time", time)
end

-- Get how much time is remaining on the bomb
function meta:GetTime()
	return self:GetNWInt("Time", 0)
end

-- Add a certain amount of time to the bomb
function meta:AddTime(num)
	self:SetNWInt("Time", self:GetTime() + num)
	
	if self:GetTime() <= 0 then
		self:Explode()
	end
end

function meta:SetBomb(bomb)
	self.Bomb = bomb
end

function meta:GetBomb()
	return self.Bomb
end