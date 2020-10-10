-- Generate and save images of all Minigames items
SHOP.GeneratingImages = nil

local function NextImageGeneration()
    SHOP.GeneratingImages.index = SHOP.GeneratingImages.index + 1

    -- Generated all items, finish up!
    if SHOP.GeneratingImages.index > #SHOP.GeneratingImages.items then
        SHOP.GeneratingImages.panel:Remove()
        SHOP.GeneratingImages = nil

        return
    end

    -- Remove last icon
    if SHOP.GeneratingImages.panel then
        SHOP.GeneratingImages.panel:Remove()
    end

    -- Create new icon
    local name = SHOP.GeneratingImages.items[SHOP.GeneratingImages.index]
    local ITEM = SHOP.VanillaItems[name]
    SHOP.GeneratingImages.name = name
    local panel = vgui.Create("ShopItemPanel")
    panel:SetPos(16, 16)
    panel.key = key
    panel.ITEM = ITEM
    panel:Ready()
    SHOP.GeneratingImages.panel = panel
    SHOP.GeneratingImages.screenshot = true
end

local function StartImageGeneration()
    file.CreateDir("shop_images")
    print("Starting icon generation...")
    local item_names = table.GetKeys(SHOP.VanillaItems)

    SHOP.GeneratingImages = {
        index = 0,
        screenshot = false,
        items = item_names,
        panel = nil,
        name = nil
    }

    timer.Simple(1, function()
        NextImageGeneration()
    end)
end

concommand.Add("minigames_generate_item_icons", StartImageGeneration)

hook.Add("PostRender", "ShopGenerateImages", function()
    if not SHOP.GeneratingImages then return end
    if not SHOP.GeneratingImages.screenshot then return end
    SHOP.GeneratingImages.screenshot = false

    local data = render.Capture({
        format = "png",
        x = 16,
        y = 16,
        w = 128,
        h = 128,
        alpha = false
    })

    file.Write("shop_images/" .. SHOP.GeneratingImages.name .. ".png", data)
    NextImageGeneration()
end)