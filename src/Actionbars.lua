local function init()
  local dominos = IsAddOnLoaded("Dominos")
  local bartender4 = IsAddOnLoaded("Bartender4")

  -- Function to hide the talking frame
  if not dominos and not bartender4 then
    local function NoTalkingHeads()
      hooksecurefunc(TalkingHeadFrame, "Show", function(self)
        self:Hide()
      end)
    end

    -- Hide stance bar
    -- if (RCUIDB.hideStanceBar and not dominos and not bartender4) then
    --   StanceBarFrame:SetAlpha(0)
    --   RegisterStateDriver(StanceBarFrame, "visibility", "hide")
    -- elseif (not dominos and not bartender4) then
    --   StanceButton1:ClearAllPoints()
    --   local relativeButton = MultiBarBottomLeftButton1
    --   if (not relativeButton) then
    --     relativeButton = ActionButton1
    --   end
    --   StanceButton1:SetPoint("BOTTOMLEFT", relativeButton, "TOPLEFT", 0, 16)
    --   StanceBarRight:Hide()
    -- end

    -- AlertFrame:ClearAllPoints()
    -- AlertFrame:SetPoint("TOP", Screen, "TOP", 0, 0)
    -- AlertFrame.SetPoint = function() end

    -- Hide Talking Head Frame
    if RCUIDB.hideTalkingHeads then
      if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
        NoTalkingHeads()
      else
        local waitFrame = CreateFrame("FRAME")
        waitFrame:RegisterEvent("ADDON_LOADED")
        waitFrame:SetScript("OnEvent", function(self, event, arg1)
          if arg1 == "Blizzard_TalkingHeadUI" then
            NoTalkingHeads()
            waitFrame:UnregisterAllEvents()
          end
        end)
      end
    end

    -- Clean up XP Bar/Azerite Bar appearance
    local statusBars = {
      "SingleBarLargeUpper",
      "SingleBarLarge",
      "SingleBarSmall",
      "SingleBarSmallUpper"
    }

    -- Fix issue with Blizzard trying to call this
    if not AchievementMicroButton_Update then
        AchievementMicroButton_Update = function() end
    end
  end

  ---------------------------------------
  -- FUNCTIONS
  ---------------------------------------

  if IsAddOnLoaded("Masque") and (dominos or bartender4) then
    return
  end

  local function skinButton(bu, icon, isLeaveButton)
    applyRillyCleanButtonSkin(bu, icon, isLeaveButton)
  end

  --style extraactionbutton
  local function styleExtraActionButton(bu)
    if not bu or (bu and bu.rillyClean) then
      return
    end
    local name = bu:GetName() or bu:GetParent():GetName()
    local style = bu.style or bu.Style
    local icon = bu.icon or bu.Icon
    local cooldown = bu.cooldown or bu.Cooldown
    local ho = _G[name .. "HotKey"]

    -- remove the style background theme
    -- style:SetTexture(nil)
    -- hooksecurefunc(
    --   style,
    --   "SetTexture",
    --   function(self, texture)
    --     if texture then
    --       self:SetTexture(nil)
    --     end
    --   end
    -- )

    --icon
    styleIcon(icon, bu)

    --cooldown
    cooldown:SetAllPoints(icon)

    --hotkey
    if RCUIDB.hideHotkeys and ho then
      ho:Hide()
    end

    --apply background
    skinButton(bu, icon)
  end

  --initial style func
  local function styleActionButton(bu)
    if not bu or (bu and bu.rillyClean) then
      return
    end
    local action = bu.action
    local name = bu:GetName()
    local ic = _G[name .. "Icon"]
    local co = _G[name .. "Count"]
    local bo = _G[name .. "Border"]
    local ho = _G[name .. "HotKey"]
    local cd = _G[name .. "Cooldown"]
    local na = _G[name .. "Name"]
    local fl = _G[name .. "Flash"]
    local nt = _G[name .. "NormalTexture"]
    local fbg = _G[name .. "FloatingBG"]
    local fob = _G[name .. "FlyoutBorder"]
    local fobs = _G[name .. "FlyoutBorderShadow"]


    if fbg then
      fbg:Hide()
    end --floating background
    --flyout border stuff
    if fob then
      fob:SetTexture(nil)
    end
    if fobs then
      fobs:SetTexture(nil)
    end

    bo:SetTexture(nil) --hide the border (plain ugly, sry blizz)

    --hotkey
    ho:ClearAllPoints()
    ho:SetPoint("TOP", bu, 0, 0)
    ho:SetPoint("TOP", bu, 0, 0)
    if RCUIDB.hideHotkeys then
      ho:Hide()
    end

    -- Macro name
    if (RCUIDB.hideMacroText) then
      na:Hide()
    end

    if not nt then
      --fix the non existent texture problem (no clue what is causing this)
      nt = bu:GetNormalTexture()
    end

    skinButton(bu, ic)

    if bartender4 then --fix the normaltexture
      nt:SetTexCoord(0, 1, 0, 1)
      nt.SetTexCoord = function()
        return
      end
      bu.SetNormalTexture = function()
        return
      end
    end
  end

  -- style leave button
  local function styleLeaveButton(bu)
    if not bu or (bu and bu.rillyClean) then
      return
    end

    skinButton(bu, nil, true)
  end

  --style pet buttons
  local function stylePetButton(bu)
    if not bu or (bu and bu.rillyClean) then
      return
    end
    local name = bu:GetName()
    local ic = _G[name .. "Icon"]
    local fl = _G[name .. "Flash"]
    local nt = _G[name .. "NormalTexture2"]
    local cd = _G[name .. "Cooldown"]

    --adjust the cooldown frame
    cd:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
    cd:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)

    skinButton(bu, ic)
  end

  -- Style stance buttons
  local function styleStanceButton(bu)
    if not bu or (bu and bu.rillyClean) then
      return
    end
    local name = bu:GetName()
    local ic = _G[name .. "Icon"]
    local fl = _G[name .. "Flash"]
    local nt = _G[name .. "NormalTexture2"]

    skinButton(bu, ic)
  end

  -- for i = 1, NUM_STANCE_SLOTS do
  --   styleStanceButton(_G["StanceButton" .. i])
  -- end

  -- Style possess buttons
  local function stylePossessButton(bu)
    if not bu or (bu and bu.rillyClean) then
      return
    end
    local name = bu:GetName()
    local ic = _G[name .. "Icon"]
    local fl = _G[name .. "Flash"]
    local nt = _G[name .. "NormalTexture"]
    nt:SetAllPoints(bu)

    skinButton(bu, ic)
  end

  --update hotkey func
  local function updateHotkey(self, actionButtonType)
    local ho = _G[self:GetName() .. "HotKey"]
    if ho and ho:IsShown() then
      ho:Hide()
    end
  end

  if not dominos and not bartender and (RCUIDB.hideHotkeys) then
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("UPDATE_BINDINGS")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function()
        for i = 1, 12 do
            updateHotkey(_G["ActionButton"..i])
            updateHotkey(_G["MultiBarBottomLeftButton"..i])
            updateHotkey(_G["MultiBarBottomRightButton"..i])
            updateHotkey(_G["MultiBarLeftButton"..i])
            updateHotkey(_G["MultiBarRightButton"..i])
        end
        for i = 1, 10 do
            updateHotkey(_G["StanceButton"..i])
            updateHotkey(_G["PetActionButton"..i])
        end
        updateHotkey(ExtraActionButton1)
    end)
  end

  --style the actionbar buttons
  for i = 1, NUM_ACTIONBAR_BUTTONS do
    styleActionButton(_G["ActionButton" .. i])
    styleActionButton(_G["MultiBarBottomLeftButton" .. i])
    styleActionButton(_G["MultiBarBottomRightButton" .. i])
    styleActionButton(_G["MultiBarRightButton" .. i])
    for k = 5, 7 do
      styleActionButton(_G["MultiBar" .. k .. "Button" .. i])
    end
    styleActionButton(_G["MultiBarLeftButton" .. i])
  end

  for i = 1, 6 do
    styleActionButton(_G["OverrideActionBarButton" .. i])
  end
  --style leave button
  styleLeaveButton(MainMenuBarVehicleLeaveButton)
  styleLeaveButton(rABS_LeaveVehicleButton)
  --petbar buttons
  for i = 1, NUM_PET_ACTION_SLOTS do
    stylePetButton(_G["PetActionButton" .. i])
  end
  --possess buttons
  for i = 1, NUM_POSSESS_SLOTS do
    stylePossessButton(_G["PossessButton" .. i])
  end

  --extraactionbutton1
  styleExtraActionButton(ExtraActionButton1)

  -- -- Zone Ability buttons
  -- local function styleZoneAbilityButton(self)
  --   local activeSpellButtons = self.SpellButtonContainer
  --   for k,v in pairs(activeSpellButtons) do
  --     -- print(k)
  --   end
  --   local abilities = C_ZoneAbility.GetActiveAbilities()
  --   for i, ability in pairs(abilities) do
  --     -- styleExtraActionButton(button)
  --   end
  -- end
  -- hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", styleZoneAbilityButton)
  -- -- hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, "Refresh", styleZoneAbilityButton)

  --dominos styling
  if dominos then
    print("Dominos found")
    for i = 1, 60 do
      styleActionButton(_G["DominosActionButton" .. i])
    end
  end
  --bartender4 styling
  if bartender4 then
    --print("Bartender4 found")
    for i = 1, 120 do
      styleActionButton(_G["BT4Button" .. i])
      stylePetButton(_G["BT4PetButton" .. i])
    end
  end
end

local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", init)
