hooksecurefunc("BonusObjectiveTrackerProgressBar_UpdateReward", function(progressBar)
  skinProgressBar(progressBar.Bar)
end)

local function setQuestTrackerFont(textObject)
  local outline = ""
  if RCUIDB.objectivesTextOutline then
    outline = "THINOUTLINE"
  end

  setDefaultFont(textObject, nil, outline)
end

local function skinBlizzardObjectiveTracker()
  hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "SetStringText", function(_, fontString)
    setQuestTrackerFont(fontString)
  end)

  local function styleBlock(block)
    if block.HeaderText then
      setQuestTrackerFont(block.HeaderText)
    end
    for objectiveKey, line in pairs(block.lines) do
      setQuestTrackerFont(line.Text)
    end

    if (block.rightButton) then applyRillyCleanButtonSkin(block.rightButton) end
    if (block.currentLine and block.currentLine.Bar) then skinProgressBar(block.currentLine.Bar) end
  end
  hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "OnBlockHeaderEnter", function(_, block) styleBlock(block) end)
  hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "OnBlockHeaderLeave", function(_, block) styleBlock(block) end)

  local function setTrackerHeaderFont()
    setQuestTrackerFont(ObjectiveTrackerFrame.HeaderMenu.Title)
  end
  hooksecurefunc("ObjectiveTracker_Collapse", setTrackerHeaderFont)

  local function rcui_AddObjective(self, block, objectiveKey, _, lineType)
    styleBlock(block)
    local line = self:GetLine(block, objectiveKey, lineType);
    if ( line.Dash ) then
      setQuestTrackerFont(line.Dash)
    end
  end
  hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", rcui_AddObjective)


  local function skinProgressBar(self)
    setQuestTrackerFont(self.Bar.Label)
  end
  hooksecurefunc("ScenarioTrackerProgressBar_SetValue", skinProgressBar)
  hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", skinProgressBar)

  local function rcui_ObjectiveTracker_Update(reason, id, moduleWhoseCollapseChanged)
    local tracker = ObjectiveTrackerFrame

    if not #tracker.MODULES then return end

    for i = 1, #tracker.MODULES do
      local trackerModule = tracker.MODULES[i]
      local Header = trackerModule.Header
      if ( Header ) then
        setQuestTrackerFont(Header.Text)
        if RCUIDB.objectivesHideHeaders then
          Header.Background:Hide()
        end

        for _, blocks in pairs(trackerModule.usedBlocks) do
          for _, block in pairs(blocks) do
            styleBlock(block)
          end
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
