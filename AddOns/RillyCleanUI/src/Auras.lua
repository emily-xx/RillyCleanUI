local backdrop = {
  bgFile = nil,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 32,
  edgeSize = 1,
  insets = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
  },
}

local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
  --apply aura frame texture func
  local function applySkin(b)
    if not b or (b and b.styled) then return end

    --button name
    local name = b:GetName()
    if (name:match("Debuff")) then
      b.debuff = true
    else
      b.buff = true
    end

    --icon
    local icon = _G[name.."Icon"]
    if consolidated then
      if select(1,UnitFactionGroup("player")) == "Alliance" then
        icon:SetTexture(select(3,GetSpellInfo(61573)))
      elseif select(1,UnitFactionGroup("player")) == "Horde" then
        icon:SetTexture(select(3,GetSpellInfo(61574)))
      end
    end

    icon:SetTexCoord(0.1,0.9,0.1,0.9)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    -- icon:SetDrawLayer("BACKGROUND",-8)
    b.icon = icon

    --border
    local border = _G[name.."Border"] or b:CreateTexture(name.."Border", "BACKGROUND", nil, -7)
    border:SetTexture(SQUARE_TEXTURE)
    border:SetTexCoord(0,1,0,1)
    border:SetDrawLayer("BACKGROUND",-7)
    if tempenchant then
      border:SetVertexColor(0.7,0,1)
    elseif not debuff then
      border:SetVertexColor(0,0,0)
    end
    border:ClearAllPoints()
    border:SetAllPoints(b)
    b.border = border

    --shadow
    local back = CreateFrame("Frame", nil, b)
    back:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
    back:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
    back:SetFrameLevel(b:GetFrameLevel() - 1)
    back:SetBackdrop(backdrop)
    back:SetBackdropBorderColor(0,0,0,1)
    b.bg = back
    --set button styled variable
    b.styled = true
  end

  local function updateAuraSkins(self)
    for i = 1, MAX_TARGET_BUFFS do
      b = _G["TargetFrameBuff"..i]
      applySkin(b)
    end

    for i = 1, MAX_TARGET_DEBUFFS do
      b = _G["TargetFrameDebuff"..i]
      applySkin(b)
    end

    for i = 1, MAX_TARGET_BUFFS do
      b = _G["FocusFrameBuff"..i]
      applySkin(b)
    end

    for i = 1, MAX_TARGET_DEBUFFS do
      b = _G["FocusFrameDebuff"..i]
      applySkin(b)
    end
  end

  hooksecurefunc("TargetFrame_UpdateAuras", updateAuraSkins)
end)
