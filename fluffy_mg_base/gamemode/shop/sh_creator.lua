--[[
    In-game item creator system
    Previously used to be a standalone addon
]]--

if SERVER then 
    AddCSLuaFile() 
    util.AddNetworkString('ItemCreatorBroadcast')
    
    net.Receive('ItemCreatorBroadcast', function(len, ply)
        -- Function disabled except for singleplayer or superadmins
        if not(game.SinglePlayer() or ply:IsSuperAdmin()) then return end
        
        local item = net.ReadTable()
        net.Start('ItemCreatorBroadcast')
            net.WriteTable(item)
            net.WriteEntity(ply)
        net.Broadcast()
    end)
    
    return
end

SHOP.CreatorEntity = nil
SHOP.CreatorFrame = nil
SHOP.CreatorData = {}

function SHOP.OpenCreatorPanel()
    -- Block this panel unless in singleplayer or a superadmin
    if not(game.SinglePlayer() or ply:IsSuperAdmin()) then return end

    -- Create the frame if not opened already
	if SHOP.CreatorFrame then return end
	local Frame = vgui.Create("DFrame")
	Frame:SetPos(ScrW() - 300, 0)
	Frame:SetSize(300, 640)
	Frame:SetTitle("Minigames Item Creator")
	Frame:SetVisible(true)
	Frame:SetDraggable(false)
	Frame:ShowCloseButton(true)
	Frame:MakePopup()
	
	Frame.OnClose = function()
		SHOP.CreatorFrame = nil
	end
	
    -- Apply the settings of the panel to the entity
	Frame.UpdateInfo = function(self)
		if SHOP.CreatorEntity then
			SHOP.CreatorEntity:Remove()
			SHOP.CreatorData = {}
		end
        
		local mdl = self.Model:GetValue()
		if !mdl or #mdl < 1 then return end
		if !file.Exists(mdl, "GAME") then return end
		SHOP.CreatorData['mdl'] = mdl
		
		SHOP.CreatorData['attach'] = self.Attachment:GetValue()
		SHOP.CreatorData['scale'] = math.Round(math.Clamp(self.Scale:GetValue(), 0, 2), 1)
		SHOP.CreatorData['skin'] = math.Round(math.Clamp(self.Skin:GetValue(), 0, 8), 0)
		SHOP.CreatorData['bg1'] = math.Round(math.Clamp(self.BG1:GetValue(), 0, 8), 0)
		
		SHOP.CreatorData['x'] = math.Round(self.XOffset:GetValue(), 1)
		SHOP.CreatorData['y'] = math.Round(self.YOffset:GetValue(), 1)
		SHOP.CreatorData['z'] = math.Round(self.ZOffset:GetValue(), 1)
		
		SHOP.CreatorData['p'] = math.Round(self.Pitch:GetValue())
		SHOP.CreatorData['r'] = math.Round(self.Roll:GetValue())
		SHOP.CreatorData['yaw'] = math.Round(self.Yaw:GetValue())
        
        SHOP.CreatorData['camera_ang'] = self.Camera:GetValue()
        SHOP.CreatorData['camera_dist'] = self.Camera2:GetValue()
        SHOP.CreatorData['camera_height'] = self.Camera3:GetValue()
		
		local ent = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
		ent:SetNoDraw(true)
		ent:SetSkin(SHOP.CreatorData['skin'])
		
		SHOP.CreatorEntity = ent
	end
	
    -- Generates the code needed to implement the item
    -- Automatically copies the code to the clipboard!
	Frame.GenerateCode = function(self)
		local base = "-- Generated with the ingame creator\nITEM = {}\nITEM.VanillaID = [id here]\nITEM.Name = [name here]\n"
		if not SHOP.CreatorData['mdl'] then return end
		base = base .. "ITEM.Model = '" .. SHOP.CreatorData['mdl'] .. "'\n"
		if not SHOP.CreatorData['attach'] then return end
		base = base .. "ITEM.Attachment = '" .. SHOP.CreatorData['attach'] .. "'\n"
		if SHOP.CreatorData['skin'] and SHOP.CreatorData['skin'] != 0  then
			base = base .. "ITEM.Skin = " .. SHOP.CreatorData['skin'] .. "\n"
		end
		if SHOP.CreatorData['bg1'] and SHOP.CreatorData['bg1'] != 0 then
			base = base .. "ITEM.Bodygroup = " .. SHOP.CreatorData['bg1'] .. "\n"
		end
		
		local modify = "\nITEM.Modify = {\n"
			if SHOP.CreatorData['scale'] and SHOP.CreatorData['scale'] != 1 then
				modify = modify .. "	scale = " .. SHOP.CreatorData['scale'] .. ",\n"
			end
			if SHOP.CreatorData['x'] != 0 or SHOP.CreatorData['y'] != 0 or SHOP.CreatorData['z'] != 0 then
				modify = modify .. "	offset = Vector(" .. SHOP.CreatorData['x'] .. ", " .. SHOP.CreatorData['y'] .. ", " .. SHOP.CreatorData['z'] .. "),\n"
			end
			if SHOP.CreatorData['p'] != 0 or SHOP.CreatorData['yaw'] != 0 or SHOP.CreatorData['r'] != 0 then
				modify = modify .. "	angle = Angle(" .. SHOP.CreatorData['p'] .. ", " .. SHOP.CreatorData['yaw'] .. ", " .. SHOP.CreatorData['r'] .. "),\n"
			end
			
		modify = modify .. "}\n\nSHOP:RegisterHat(ITEM)"
		SetClipboardText(base .. modify)
	end
    
    -- Broadcast the panel settings
    -- Will allow creations to be tested in multiplayer games
    Frame.Broadcast = function()
        if not SHOP.CreatorData then return end
        net.Start('ItemCreatorBroadcast')
            net.WriteTable(SHOP.CreatorData)
        net.SendToServer()
    end
	
    -- Whole bunch of settings panels below this section
    -- I'm too lazy to comment them all
	local ModelLabel = vgui.Create("DLabel", Frame)
	ModelLabel:SetPos(24, 32)
	ModelLabel:SetText("Model Path:")
	
	local Model = vgui.Create("DTextEntry", Frame)
	Model:SetPos(24, 48)
	Model:SetSize(252, 24)
	Model:SetText(SHOP.CreatorData['mdl'] or '')
	Model.OnEnter = function(self)
		Frame:UpdateInfo()
	end
	Frame.Model = Model
	
	local AttachmentLabel = vgui.Create("DLabel", Frame)
	AttachmentLabel:SetPos(24, 72)
	AttachmentLabel:SetText("Attachment:")
	
	local Attachments = vgui.Create("DComboBox", Frame)
	Attachments:SetPos(24, 96)
	Attachments:SetSize(252, 24)
	Attachments:SetValue(SHOP.CreatorData['attach'] or 'eyes')
	Attachments:AddChoice("eyes")
    Attachments:AddChoice("mouth")
    Attachments:AddChoice("chest")
    Attachments:AddChoice("forward")
	Attachments.OnSelect = function(panel, index, value)
		Frame:UpdateInfo()
	end
	Frame.Attachment = Attachments
	
	local ScaleSlider = vgui.Create("DNumSlider", Frame)
	ScaleSlider:SetPos(24, 128)
	ScaleSlider:SetSize(252, 24)
	ScaleSlider:SetText("Scale") 
	ScaleSlider:SetMin(0)
	ScaleSlider:SetMax(2)
	ScaleSlider:SetDecimals(2)
	ScaleSlider:SetValue(SHOP.CreatorData['scale'] or 1)
	ScaleSlider.OnValueChanged = function()
		Frame:UpdateInfo()
	end
	Frame.Scale = ScaleSlider
	
	local XSlider = vgui.Create("DNumSlider", Frame)
	XSlider:SetPos(24, 160)
	XSlider:SetSize(252, 24)
	XSlider:SetText("X Offset") 
	XSlider:SetMin(-10)
	XSlider:SetMax(10)
	XSlider:SetDecimals(1)
	XSlider:SetValue(SHOP.CreatorData['x'] or 0)
	XSlider.OnValueChanged = function()
		Frame:UpdateInfo()
	end
	Frame.XOffset = XSlider
	
	local YSlider = vgui.Create("DNumSlider", Frame)
	YSlider:SetPos(24, 192)
	YSlider:SetSize(252, 24)
	YSlider:SetText("Y Offset") 
	YSlider:SetMin(-10)
	YSlider:SetMax(10)
	YSlider:SetDecimals(1)
	YSlider:SetValue(SHOP.CreatorData['y'] or 0)
	YSlider.OnValueChanged = function()
		Frame:UpdateInfo()
	end
	Frame.YOffset = YSlider
	
	local ZSlider = vgui.Create("DNumSlider", Frame)
	ZSlider:SetPos(24, 224)
	ZSlider:SetSize(252, 24)
	ZSlider:SetText("Z Offset") 
	ZSlider:SetMin(-20)
	ZSlider:SetMax(20)
	ZSlider:SetDecimals(1)
	ZSlider:SetValue(SHOP.CreatorData['z'] or 0)
	ZSlider.OnValueChanged = function()
		Frame:UpdateInfo()
	end
	Frame.ZOffset = ZSlider
	
	local Pitch = vgui.Create("DNumSlider", Frame)
	Pitch:SetPos(24, 272)
	Pitch:SetSize(252, 24)
	Pitch:SetText("Pitch") 
	Pitch:SetMin(-180)
	Pitch:SetMax(180)
	Pitch:SetDecimals(0)
	Pitch:SetValue(SHOP.CreatorData['p'] or 0)
	Pitch.OnValueChanged = function()
		Frame:UpdateInfo()
	end
	Frame.Pitch = Pitch
	
	local Roll = vgui.Create("DNumSlider", Frame)
	Roll:SetPos(24, 304)
	Roll:SetSize(252, 24)
	Roll:SetText("Roll") 
	Roll:SetMin(-180)
	Roll:SetMax(180)
	Roll:SetDecimals(0)
	Roll:SetValue(SHOP.CreatorData['r'] or 0)
	Roll.OnValueChanged = function()
		Frame:UpdateInfo()
	end
	Frame.Roll = Roll
	
	local Yaw = vgui.Create("DNumSlider", Frame)
	Yaw:SetPos(24, 336)
	Yaw:SetSize(252, 24)
	Yaw:SetText("Yaw") 
	Yaw:SetMin(-180)
	Yaw:SetMax(180)
	Yaw:SetDecimals(0)
	Yaw:SetValue(SHOP.CreatorData['yaw'] or 0)
	Yaw.OnValueChanged = function()
		Frame:UpdateInfo()
	end
	Frame.Yaw = Yaw
	
	local Skin = vgui.Create("DNumSlider", Frame)
	Skin:SetPos(24, 400)
	Skin:SetSize(252, 24)
	Skin:SetText("Skin") 
	Skin:SetMin(0)
	Skin:SetMax(8)
	Skin:SetDecimals(0)
	Skin:SetValue(SHOP.CreatorData['skin'] or 0)
	Skin.OnValueChanged = function()
		Frame:UpdateInfo()
	end
	Frame.Skin = Skin
	
	local BG1 = vgui.Create("DNumSlider", Frame)
	BG1:SetPos(24, 432)
	BG1:SetSize(252, 24)
	BG1:SetText("Bodygroup1") 
	BG1:SetMin(0)
	BG1:SetMax(8)
	BG1:SetDecimals(0)
	BG1:SetValue(SHOP.CreatorData['bg1'] or 0)
	BG1.OnValueChanged = function()
		Frame:UpdateInfo()
	end
	Frame.BG1 = BG1
    
    local Camera = vgui.Create('DNumSlider', Frame)
    Camera:SetPos(24, 480)
    Camera:SetSize(252, 24)
    Camera:SetText('C Ang')
    Camera:SetMin(0)
    Camera:SetMax(360)
    Camera:SetDecimals(0)
    Camera:SetValue(SHOP.CreatorData['camera_ang'] or 0)
    Camera.OnValueChanged = function(self)
        SHOP.CreatorData['camera_ang'] = self:GetValue()
    end
    Frame.Camera = Camera
    
    local Camera2 = vgui.Create('DNumSlider', Frame)
    Camera2:SetPos(24, 512)
    Camera2:SetSize(252, 24)
    Camera2:SetText('C Dist')
    Camera2:SetMin(16)
    Camera2:SetMax(128)
    Camera2:SetDecimals(0)
    Camera2:SetValue(SHOP.CreatorData['camera_dist'] or 100)
    Camera2.OnValueChanged = function(self)
        SHOP.CreatorData['camera_dist'] = self:GetValue()
    end
    Frame.Camera2 = Camera2
    
    local Camera3 = vgui.Create('DNumSlider', Frame)
    Camera3:SetPos(24, 544)
    Camera3:SetSize(252, 24)
    Camera3:SetText('C Height')
    Camera3:SetMin(16)
    Camera3:SetMax(128)
    Camera3:SetDecimals(0)
    Camera3:SetValue(SHOP.CreatorData['camera_height'] or 64)
    Camera3.OnValueChanged = function(self)
        SHOP.CreatorData['camera_height'] = self:GetValue()
    end
    Frame.Camera3 = Camera3
	
	local Generate = vgui.Create("DButton", Frame)
	Generate:SetSize(100, 32)
	Generate:SetPos(0, 608)
	Generate:SetText("Generate Code")
	Generate.DoClick = function(self)
		Frame:UpdateInfo()
		Frame:GenerateCode()
		chat.AddText('Code has been copied to clipboard.')
	end
    
    local Broadcast = vgui.Create("DButton", Frame)
	Broadcast:SetSize(100, 32)
	Broadcast:SetPos(100, 608)
	Broadcast:SetText("Broadcast")
	Broadcast.DoClick = function(self)
        Frame:UpdateInfo()
        Frame:Broadcast()
        chat.AddText('Broadcasted your model to other players!')
	end
	
	local Clear = vgui.Create("DButton", Frame)
	Clear:SetSize(100, 32)
	Clear:SetPos(200, 608)
	Clear:SetText("Clear Settings")
	Clear.DoClick = function(self)
		if SHOP.CreatorEntity then
			SHOP.CreatorEntity:Remove()
            SHOP.CreatorEntity = nil
            SHOP.CreatorData = {} 
            Frame:Close()
        end
	end
	
    --[[
	local Broadcast = vgui.Create("DButton", Frame)
	Broadcast:SetSize(75, 75)
	Broadcast:SetPos(150, 565)
	Broadcast:SetText("Broadcast")
	Broadcast.DoClick = function(self)
		Frame:UpdateInfo()
		if LocalPlayer():IsAdmin() then
			chat.AddText('Your creation is now visible to others.')
		end
        
		local ITEM = {}
		ITEM.VanillaID = 'creation' .. math.floor(CurTime())
		ITEM.Name = 'Custom - Test Drive'
		ITEM.Model = CreatorData['mdl']
		ITEM.Attachment = CreatorData['attach']
		ITEM.Modify = {}
			ITEM.Modify['scale'] = CreatorData['scale']
			ITEM.Modify['offset'] = Vector(CreatorData['x'], CreatorData['y'], CreatorData['z'])
			ITEM.Modify['angle'] = Angle(CreatorData['p'], CreatorData['yaw'], CreatorData['r'])
		net.Start("FS_CreatorEquip")
			net.WriteTable(ITEM)
		net.SendToServer()
	end
    --]]
	
    --[[
	local Extra = vgui.Create("DButton", Frame)
	Extra:SetSize(75, 75)
	Extra:SetPos(225, 565)
	Extra:SetText("Spare Button")
	Extra.DoClick = function(self)
		if SHOP.CreatorEntity then
			SHOP.CreatorEntity:Remove()
		end
		SHOP.CreatorEntity = nil
		SHOP.CreatorData = {}
		Frame:UpdateInfo()
		Frame:Close()
	end
    --]]
	
	SHOP.CreatorFrame = Frame
end

-- Allow opening with a concommand
concommand.Add('minigames_item_creator', function() SHOP.OpenCreatorPanel() end)

-- Receive broadcasts on client
net.Receive('ItemCreatorBroadcast', function()
    local ITEM = net.ReadTable()
    local ply = net.ReadEntity()
    if ply == LocalPlayer() then return end
    
    if ply.CreatorItem then
        if IsValid(ply.CreatorItem.entity) then
            SafeRemoveEntity(ply.CreatorItem.entity)
        end
    end
    ply.CreatorItem = ITEM
end)

-- Draw broadcasted items
hook.Add('PostPlayerDraw', 'FS_ItemBroadcast', function(ply)
	if ply == LocalPlayer() then return end
    if not ply.CreatorItem then return end
    
    if not ply.CreatorItem.entity then
        local mdl = ply.CreatorItem['mdl']
        local ent = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
		ent:SetNoDraw(true)
        ply.CreatorItem.entity = ent
    end
    
    local ITEM = ply.CreatorItem
    local ent = ply.CreatorItem.entity
    
	if !ITEM['attach'] then return end
	local attach_id = ply:LookupAttachment(ITEM['attach'])
	if not attach_id then return end
		
	local attach = ply:GetAttachment(attach_id)
	if not attach then return end
	local pos = attach.Pos
	local ang = attach.Ang
	
	ent:SetModelScale(ITEM['scale'])
	pos = pos + (ang:Forward()*ITEM['x']) + (ang:Right()*ITEM['y']) + (ang:Up()*ITEM['z'])
	
	ang:RotateAroundAxis(ang:Right(), ITEM['p'])
	ang:RotateAroundAxis(ang:Forward(), ITEM['r'])
	ang:RotateAroundAxis(ang:Up(), ITEM['yaw'])
	
	ent:SetPos(pos)
    ent:SetAngles(ang)
	ent:DrawModel()
end)

-- Draw the item currently stored in the creator panel
hook.Add('PostPlayerDraw', 'FS_ItemCreator', function(ply)
	if ply != LocalPlayer() then return end
	if !SHOP.CreatorEntity then return end
	
	if !SHOP.CreatorData['attach'] then return end
	local attach_id = ply:LookupAttachment(SHOP.CreatorData['attach'])
	if not attach_id then return end
		
	local attach = ply:GetAttachment(attach_id)
	if not attach then return end
	local pos = attach.Pos
	local ang = attach.Ang
	
	SHOP.CreatorEntity:SetModelScale(SHOP.CreatorData['scale'])
	pos = pos + (ang:Forward()*SHOP.CreatorData['x']) + (ang:Right()*SHOP.CreatorData['y']) + (ang:Up()*SHOP.CreatorData['z'])
	
	ang:RotateAroundAxis(ang:Right(), SHOP.CreatorData['p'])
	ang:RotateAroundAxis(ang:Forward(), SHOP.CreatorData['r'])
	ang:RotateAroundAxis(ang:Up(), SHOP.CreatorData['yaw'])
	
	SHOP.CreatorEntity:SetPos(pos)
    SHOP.CreatorEntity:SetAngles(ang)
	SHOP.CreatorEntity:DrawModel()
end)

-- Allows for adjusting the camera inside the item creator
hook.Add('CalcView', 'CreatorCamera', function(ply, origin, angles, fov)
    if not IsValid(SHOP.CreatorFrame) then return end
    
    local targetpos = ply:GetPos() + Vector(0, 0, SHOP.CreatorData['camera_height'] or 64)
    local distance = SHOP.CreatorData['camera_dist'] or 100

    local goalangles = Angle(0, (SHOP.CreatorData['camera_ang'] or 0) - 180)
    local goalpos = targetpos + (goalangles:Forward() * -distance)
    
    -- Smoothly transition the view
    local view = {}
    view.origin = goalpos--origin + (goalpos - origin) * smooth
    view.angles = goalangles--angles + (goalangles - angles) * smooth
    view.drawviewer = true
    return view
end)