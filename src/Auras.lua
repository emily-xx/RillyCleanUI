local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
  --apply aura frame texture func
  local function applySkin(b)
    if not b or (b and b.rillyClean) then return end

    --button name
    local name = b:GetName()
    if (name:match("Debuff")) then
      b.debuff = true
    else
      b.buff = true
    end

    --border
    local border, icon = applyRillyCleanButtonSkin(b)

    --icon
    if consolidated then
      if select(1,UnitFactionGroup("player")) == "Alliance" then
        icon:SetTexture(select(3,GetSpellInfo(61573)))
      elseif select(1,UnitFactionGroup("player")) == "Horde" then
        icon:SetTexture(select(3,GetSpellInfo(61574)))
      end
    end

    if tempenchant then
      border:SetBackdropBorderColor(0.7,0,1)
    elseif not debuff then
      border:SetBackdropBorderColor(0,0,0)
    end
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
