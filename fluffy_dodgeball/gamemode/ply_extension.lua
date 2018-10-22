local meta = FindMetaTable("Player")

function meta:ResetScore()
    self:UpgradeBalls(0)
end

function meta:UpgradeBalls(num)
    if !num or num > 10 then return end
    
    -- Default ball
    if num == 0 then
        self:SetBallType( GAMEMODE.Balls[1] )
        local gun = self:GetActiveWeapon()
        if IsValid(gun) then
            gun:SetMaxAmmo(2)
            gun:SetFireDelay(0.5)
        end
        
        return
    end
    
    -- Find all weapons with the current level
    local tbl = {}
    for k,v in pairs(GAMEMODE.Balls) do
        if v.Kills == num then
            table.insert(tbl, v)
        end
    end
    
    if #tbl < 1 then
        return
    end
    
    -- Pick a random one & apply it
    local balltype = table.Random(tbl)
    self:SetBallType(balltype)
    self:EmitSound('weapons/physgun_off.wav')
    
    -- Apply changes to gun
    local gun = self:GetActiveWeapon()
    if IsValid(gun) then
        gun:SetMaxAmmo(balltype.Ammo)
        gun:SetFireDelay(balltype.ROF)
    end
end

function meta:SetBallType(ball)
    self.BallType = ball
end

function meta:GetBallType()
    return self.BallType or GAMEMODE.Balls[1]
end