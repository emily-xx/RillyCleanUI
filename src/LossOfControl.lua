local cleanIconBackdrop = {
  bgFile = SQUARE_TEXTURE,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 0,
  edgeSize = 3,
  insets = {
    left = -2,
    right = -2,
    top = -2,
    bottom = -2
  }
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
   -- Hide red shadow
  select(2,LossOfControlFrame:GetRegions()):SetAlpha(0)
  select(3,LossOfControlFrame:GetRegions()):SetAlpha(0)

  -- Style the icon
  local icon = select(4,LossOfControlFrame:GetRegions())

  styleIcon(icon)
  local iconBack = CreateFrame("Frame", nil, LossOfControlFrame, "BackdropTemplate")
  iconBack:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
  iconBack:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
  iconBack:SetFrameLevel(LossOfControlFrame:GetFrameLevel())
  iconBack.backdropInfo = cleanIconBackdrop
  iconBack:ApplyBackdrop()
  iconBack:SetBackdropBorderColor(0,0,0,1)
  iconBack:SetBackdropColor(0,0,0,1)
end)
