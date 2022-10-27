local function applySkin(b)
  if not b or (b and b.rillyClean) then return end

  --icon
  local icon = b.Icon
  if consolidated then
    if select(1,UnitFactionGroup("player")) == "Alliance" then
      icon:SetTexture(select(3,GetSpellInfo(61573)))
    elseif select(1,UnitFactionGroup("player")) == "Horde" then
      icon:SetTexture(select(3,GetSpellInfo(61574)))
    end
  end

  icon:SetTexCoord(0.1,0.94,0.1,0.94)

  --border
  local border = b:CreateTexture("AuraBorder", "BACKGROUND", nil, -7)
  border:SetTexture("Interface\\AddOns\\RillyCleanUI\\media\\textures\\aura-border")
  border:SetDrawLayer("OVERLAY")

  if b.Border then
    border:SetVertexColor(b.Border:GetVertexColor())
    b.Border:Hide()
  else
    border:SetVertexColor(0,0,0)
  end

  border:SetAllPoints(icon)
  b.border = border

  b.duration:SetDrawLayer("OVERLAY")

  --set button styled variable
  b.rillyClean = true
end

local function updateAuras(self)
  local auras = self.auraFrames

  --loop on all active buff buttons
  for index, aura in ipairs(auras) do
    --apply skin
    applySkin(aura)
  end
end

hooksecurefunc(BuffFrame, "UpdateAuraButtons", updateAuras)
hooksecurefunc(DebuffFrame, "UpdateAuraButtons", updateAuras)
