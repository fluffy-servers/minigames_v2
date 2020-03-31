--[[
    Serverside announcements library
    Mostly just a net handler
    See cl_announcements.lua for more information
--]]

-- Serverside function for making a countdown announcement
function GM:CountdownAnnouncement(length, endtext, endsound, ticksound)
    local tbl = {
        type = 'countdown',
        length = length,
        endtext = endtext,
        endsound = endsound,
        ticksound = ticksound
    }
    net.Start('MinigamesAnnouncement')
        net.WriteTable(tbl)
    net.Broadcast()
end

-- Serverside function for making a pulse announcement
function GM:PulseAnnouncement(duration, text, size, sound)
    local tbl = {
        type = 'pulse',
        duration = duration,
        sound = sound,
        text = text,
        size = size,
    }
    net.Start('MinigamesAnnouncement')
        net.WriteTable(tbl)
    net.Broadcast()
end

-- Serverside function for making a pulse with subtext announcement
function GM:PulseAnnouncementTwoLine(duration, text, subtext, size, sound)
    local tbl = {
        type = 'pulse_subtext',
        duration = duration,
        sound = sound,
        text = text,
        subtext = subtext,
        size = size,
    }
    net.Start('MinigamesAnnouncement')
        net.WriteTable(tbl)
    net.Broadcast()
end

-- Send a pulse announcement to only one player
function GM:PlayerOnlyAnnouncement(ply, duration, text, size, sound)
    local tbl = {
        type = 'pulse',
        duration = duration,
        sound = sound,
        text = text,
        size = size,
    }
    net.Start('MinigamesAnnouncement')
        net.WriteTable(tbl)
    net.Send(ply)
end

-- Send a pulse announcement to many players
function GM:TableOnlyAnnouncement(recipients, duration, text, size, sound)
    local tbl = {
        type = 'pulse',
        duration = duration,
        sound = sound,
        text = text,
        size = size,
    }
    net.Start('MinigamesAnnouncement')
        net.WriteTable(tbl)
    net.Send(recipients)
end

-- Send an entity camera announcement
function GM:EntityCameraAnnouncement(ent, duration, offset, distance)
    local tbl = {
        ent = ent,
        duration = duration or 5,
        pos = offset,
        dist = distance,
    }
    
    net.Start('CoolTransition')
        net.WriteTable(tbl)
    net.Broadcast()
end

-- Send a cool transition table
-- No checking on this side - be careful!
function GM:CoolTransitionTable(tbl)
    net.Start('CoolTransition')
        net.WriteTable(tbl)
    net.Broadcast()
end

-- Generates a lovely confetti effect
function GM:ConfettiEffect(winners)
    if GAMEMODE.DisableConfetti then return end
    
    -- Sort the winners into a nice table
    local tbl = {}
    if IsEntity(winners) then
        tbl = {winners}
    elseif type(winners) == 'number' then
        tbl = team.GetPlayers(winners)
    elseif type(winners) == 'table' then
        tbl = winners
    end
    
    -- Create confetti for all living winners
    for k,v in pairs(tbl) do
        if not v:IsPlayer() then continue end
        if not v:Alive() then continue end
        
        local effectdata = EffectData()
        effectdata:SetOrigin(v:GetPos())
        util.Effect('win_confetti', effectdata)
    end
end

function GM:ConfettiEffectSingle(ply)
    if GAMEMODE.DisableConfetti then return end

    if not ply:IsPlayer() then return end
    if not ply:Alive() then return end

    local effectdata = EffectData()
    effectdata:SetOrigin(ply:GetPos())
    util.Effect('win_confetti', effectdata)
end