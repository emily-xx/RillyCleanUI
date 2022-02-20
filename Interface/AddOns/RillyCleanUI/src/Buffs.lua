local function applySkin(b)
  if not b or (b and b.rillyClean) then return end

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

  local border, icon = applyRillyCleanButtonSkin(b)

  if tempenchant then
    border:SetVertexColor(0.7,0,1)
  elseif not debuff then
    border:SetVertexColor(0,0,0)
  end

  if consolidated then
    if select(1,UnitFactionGroup("player")) == "Alliance" then
      icon:SetTexture(select(3,GetSpellInfo(61573)))
    elseif select(1,UnitFactionGroup("player")) == "Horde" then
      icon:SetTexture(select(3,GetSpellInfo(61574)))
    end
  end

  -- duration
  b.duration:ClearAllPoints()
  b.duration:SetPoint("TOP", b, "BOTTOM", 0, 0)

  -- count
  b.count:ClearAllPoints()
  b.count:SetPoint("CENTER",0,0)

  -- Set button styled variable
  b.rillyClean = true
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
        applySkin(button)
      end
    end
end

local function updateDebuffAnchors(buttonName,index)
    local button = _G[buttonName..index]
    if not button then return end

    --apply skin
    applySkin(button)
end


hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", updateAllBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", updateDebuffAnchors)
