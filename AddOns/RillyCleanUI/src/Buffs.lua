local backdrop = {
  bgFile = nil,
  edgeFile = "Interface\\BUTTONS\\WHITE8X8",
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

local function applySkin(b)
  if not b or (b and b.styled) then return end

  local name = b:GetName()

  local tempenchant, consolidated, debuff, buff = false, false, false, false
  if (name:match("TempEnchant")) then
    tempenchant = true
  elseif (name:match("Consolidated")) then
    consolidated = true
  elseif (name:match("Debuff")) then
    debuff = true
  else
    buff = true
  end

  --button
  b:SetSize(32, 32)

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
  border:SetTexture("Interface\\BUTTONS\\WHITE8X8")
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

  --duration
  -- b.duration:ClearAllPoints()
  -- b.duration:SetPoint("TOP",0,0)

  --count
  -- b.count:ClearAllPoints()
  -- b.count:SetPoint("CENTER",0,0)

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

local function updateAllBuffAnchors()
    --variables
    local buttonName  = "BuffButton"
    local numEnchants = BuffFrame.numEnchants
    local numBuffs    = BUFF_ACTUAL_DISPLAY
    local offset      = numEnchants
    local realIndex, previousButton, aboveButton

    --calculate the previous button in case tempenchant or consolidated buff are loaded
    if BuffFrame.numEnchants > 0 then
      previousButton = _G["TempEnchant"..numEnchants]
    end

    if numEnchants > 0 then
      aboveButton = TempEnchant1
    end

    --loop on all active buff buttons
    for index = 1, numBuffs do
      local button = _G[buttonName..index]
      if not button then return end
      if not button.consolidated then
        --apply skin
        if not button.styled then applySkin(button) end
      end
    end
end

local function updateDebuffAnchors(buttonName,index)
    local button = _G[buttonName..index]
    if not button then return end

    --apply skin
    if not button.styled then applySkin(button) end
end


hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", updateAllBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", updateDebuffAnchors)
