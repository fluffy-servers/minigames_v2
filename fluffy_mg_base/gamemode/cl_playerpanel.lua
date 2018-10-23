-- what
function GM:OpenPlayerPanel()
    local frame = vgui.Create('DFrame')
    local w = ScrW() * 0.8
    local h = ScrH() * 0.8
    frame:SetSize(w, h)
    frame:SetCenter()
    frame:SetBackgroundBlur(true)
    frame:MakePopup()
end