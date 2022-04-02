local cleanBarBackdrop = {
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

local function skinProgressBar(bar)
  if not bar then return end

  if bar.BorderMid then
    bar.BorderMid:SetAlpha(0)
    bar.BorderLeft:SetAlpha(0)
    bar.BorderRight:SetAlpha(0)
  end

  bar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)

  if bar.BarBG then
    bar.BarBG:Hide()
    bar.BarFrame:Hide()
  end

  -- Rilly Clean Border
  if not bar.back then
    local back = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    back:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
    back:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    back:SetFrameLevel(bar:GetFrameLevel() - 1)
    back.backdropInfo = cleanBarBackdrop
    back:ApplyBackdrop()
    back:SetBackdropBorderColor(0,0,0,1)
    back:SetBackdropColor(0,0,0,1)

    bar.back = back
  end

  local Icon = bar.Icon
  if (Icon and not bar.iconBack) then
    Icon:SetMask(nil)
    styleIcon(Icon)
    Icon:SetHeight(24)
    Icon:SetWidth(24)
    Icon:ClearAllPoints()
    Icon:SetPoint("LEFT", bar, "RIGHT", 0, 0)
    local iconBack = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    iconBack:SetPoint("TOPLEFT", Icon, "TOPLEFT", 0, 0)
    iconBack:SetPoint("BOTTOMRIGHT", Icon, "BOTTOMRIGHT", 0, 0)
    iconBack:SetFrameLevel(bar:GetFrameLevel() - 1)
    iconBack.backdropInfo = cleanBarBackdrop
    iconBack:ApplyBackdrop()
    iconBack:SetBackdropBorderColor(0,0,0,1)
    iconBack:SetBackdropColor(0,0,0,1)
    bar.iconBack = iconBack

    bar.IconBG:Hide()
  end
end

hooksecurefunc("BonusObjectiveTrackerProgressBar_UpdateReward", function(progressBar)
  skinProgressBar(progressBar.Bar)
end)

local function skinBlizzardObjectiveTracker()
  hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "SetStringText", function(_, fontString)
    setDefaultFont(fontString)
  end)

  local function styleBlock(block)
    if ( block.HeaderText ) then
      setDefaultFont(block.HeaderText)
    end
    for objectiveKey, line in pairs(block.lines) do
      setDefaultFont(line.Text)
    end

    if (block.rightButton) then applyRillyCleanButtonSkin(block.rightButton) end
    if (block.currentLine and block.currentLine.Bar) then skinProgressBar(block.currentLine.Bar) end
  end
  hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "OnBlockHeaderEnter", function(_, block) styleBlock(block) end)
  hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "OnBlockHeaderLeave", function(_, block) styleBlock(block) end)

  local function setTrackerHeaderFont()
    setDefaultFont(ObjectiveTrackerFrame.HeaderMenu.Title)
  end
  hooksecurefunc("ObjectiveTracker_Collapse", setTrackerHeaderFont)

  local function rcui_AddObjective(self, block, objectiveKey, _, lineType)
    styleBlock(block)
    local line = self:GetLine(block, objectiveKey, lineType);
    if ( line.Dash ) then
      setDefaultFont(line.Dash)
    end
  end
  hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", rcui_AddObjective)


  local function skinProgressBar(self)
    setDefaultFont(self.Bar.Label)
  end
  hooksecurefunc("ScenarioTrackerProgressBar_SetValue", skinProgressBar)
  hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", skinProgressBar)

  local function rcui_ObjectiveTracker_Update()
      local tracker = ObjectiveTrackerFrame
      if #tracker.MODULES then
        for i = 1, #tracker.MODULES do
          local trackerModule = tracker.MODULES[i]
          local Header = trackerModule.Header
          if ( Header ) then
            setDefaultFont(Header.Text)
            Header.Background:Hide()
          end

          local blocks = trackerModule:GetActiveBlocks()
          for i, v in pairs(blocks) do
            styleBlock(v)
          end
        end
      end
  end
  hooksecurefunc("ObjectiveTracker_Update", rcui_ObjectiveTracker_Update)
end

local catchaddon = CreateFrame("FRAME")
catchaddon:RegisterEvent("ADDON_LOADED")

local function skinnedOnLoad(_, _, addon)
  if addon == "Blizzard_ObjectiveTracker" then
    skinBlizzardObjectiveTracker()
  end
end

local function skinnedOnLogin()
  if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
    skinBlizzardObjectiveTracker()
  else
    catchaddon:SetScript("OnEvent", skinnedOnLoad)
  end
end

local HelloWorld = CreateFrame("FRAME")
HelloWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
HelloWorld:SetScript("OnEvent", skinnedOnLogin)
