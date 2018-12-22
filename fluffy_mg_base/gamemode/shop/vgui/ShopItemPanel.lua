print('aa')

local icons = {}
icons['paintable'] = Material('icon16/palette.png')
icons['equipped'] = Material('icon16/tick.png')

local rarity_colors = {}
rarity_colors[1] = Color(52, 152, 219)
rarity_colors[2] = Color(0, 119, 181)
rarity_colors[3] = Color(150, 70, 165)
rarity_colors[4] = Color(200, 65, 50)
rarity_colors[5] = Color(220, 150, 0)

local rarity_names = {}
rarity_names[1] = "Common"
rarity_names[2] = "Uncommon"
rarity_names[3] = "Rare"
rarity_names[4] = "Epic"
rarity_names[5] = "Legendary"

local PANEL = {}

function PANEL:Init()
	self:SetSize( 128, 128 )
    self:SetText('')
end

-- Branch handler -> pass off to the below functions for icon generation
function PANEL:Ready()
    local ITEM = self.ITEM
    if not ITEM then
        -- uh oh
        
    end
    
    -- Decide what function to use
    if ITEM.Type == 'crate' then
        self:CrateIcon(ITEM)
    elseif ITEM.Type == 'paint' then
        self:PaintIcon(ITEM)
    elseif ITEM.Type == 'tracer' then
        self:TracerIcon(ITEM)
    elseif ITEM.Type == 'trail' then
        self:TrailIcon(ITEM)
    else
        self:WearableIcon(ITEM)
    end
    
    -- Pass click handlers up the chain
    if IsValid(self.icon) then
        function self.icon:DoClick()
            self:GetParent():DoClick()
        end
    end
end

function PANEL:CrateIcon(ITEM)
    self.icon = vgui.Create('DModelPanel', self)
    self.icon:Dock(FILL)
    self.icon:SetModel('models/props_junk/cardboard_box003a.mdl')
    self.icon.Entity:SetAngles(Angle(0, 90, 0))
    self.icon:SetCamPos(Vector( 0, 48, 20))
    self.icon:SetFOV(60)
    self.icon:SetLookAt(Vector( 0, 0, -10 ))
    
    function self.icon:LayoutEntity() return end
end

function PANEL:PaintIcon(ITEM)
	self.icon = vgui.Create("DModelPanel", self )
	self.icon:Dock(FILL)
	self.icon:SetModel( "models/paintcan/paint_can.mdl" )
	self.icon:SetCamPos(Vector( 0, 32, 24 ))
	self.icon:SetFOV(60)
	self.icon:SetLookAt(Vector( 0, 0, -10 ))
	self.icon:SetColor(ITEM.Color or color_white)
    
    function self.icon:LayoutEntity() return end
end

function PANEL:TracerIcon(ITEM)
	self.icon = vgui.Create("DModelPanel", self )
	self.icon:Dock(FILL)
	self.icon:SetModel('models/weapons/c_357.mdl')
	self.icon.Entity:SetPos(Vector( -22, 0, -5 ))
	self.icon.Entity:SetAngles(Angle(0, 0, 0))
	self.icon:SetCamPos(Vector( 0, 40, 0 ))
	self.icon:SetFOV(20)
	self.icon:SetLookAt(Vector( 0, 0, -10 ))

	function self.icon:LayoutEntity() return end
end

function PANEL:TrailIcon(ITEM)
    local off = 24
	self.icon = vgui.Create("DButton", self )
    self.icon:Dock(FILL)
    self.icon:SetText('')
	self.icon.Material = Material(ITEM.Material)
	self.icon.uv = 0
    
	function self.icon:Paint(w, h)
        -- Set color if paintable
		if ITEM.Color then
			surface.SetDrawColor(ITEM.Color)
		else
			surface.SetDrawColor(color_white)
		end
        
        -- Draw the trail
		surface.SetMaterial(self.Material)
		surface.DrawTexturedRectUV(off/2, 0, w-off, h-off, 0, self.uv, 1, self.uv+1)
		
        -- Scroll the trail if in the right category
		if IsValid(SHOP.InventoryPanel) then
			if !self:IsHovered() and SHOP.InventoryPanel.Category == 'Trails' then
				self.uv = self.uv + FrameTime() * 0.5
				if self.uv > 1 then
					self.uv = 0
				end
			end
		end
	end
end

function PANEL:WearableIcon(ITEM)

end

-- Clicking handler to open up the menu
function PANEL:DoClick()
    local ITEM = self.ITEM
    if not ITEM then return end
    
    local Menu = DermaMenu()
    local rarity_color = rarity_colors[ITEM.Rarity or 1]
	local rarity_box = Menu:AddOption(rarity_names[ITEM.Rarity or 1])
	rarity_box:SetTextColor(color_white)
	rarity_box:SetIcon("icon16/star.png")
	rarity_box.Paint = function(self, w, h ) end
	rarity_box.PaintOver = function(self, w, h ) end
	Menu.Paint = function( self, w, h )
		derma.SkinHook( "Paint", "Menu", self, w, h )
		draw.RoundedBox( 0, 1, 1, w-2, 21, rarity_color )
	end
    
    if ITEM.Type == 'crate' then
        -- Add unbox button
        Menu:AddOption("Unbox", function() SHOP.RequestUnbox(key) end ):SetIcon("icon16/box.png")
    elseif ITEM.Type == 'paint' then
        -- Add no buttons :(
    else
        -- Add equip button
        Menu:AddOption("Equip", function() SHOP.RequestEquip(key) end ):SetIcon("icon16/wrench.png")
    end
    
    -- Add paint button
    if ITEM.Paintable then
        Menu:AddOption("Select Paint", function() SHOP.OpenPaintBox(key) end ):SetIcon("icon16/palette.png")
    end
    
    Menu:Open()
end

-- Dark background
function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(47, 54, 64))
end

-- Name bar & relevant icons
function PANEL:PaintOver(w, h)
    local ITEM = self.ITEM
    if not ITEM then return end

    -- Draw the name bar
    local color = rarity_colors[ITEM.Rarity or 1]
    draw.RoundedBoxEx(8, 0, h-24, w, 24, color, false, false, true, true)
    draw.SimpleText(ITEM.Name or '?', "FS_I16", w/2, h - (24/2), Color(236, 240, 241), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Draw any icons
    local yy = 2
end

vgui.Register("ShopItemPanel", PANEL, "DButton")