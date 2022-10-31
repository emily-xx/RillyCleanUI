function init()
  TimerTracker:HookScript("OnEvent", function(self, event, timerType, timeSeconds, totalTime)
    if event ~= "START_TIMER" then return; end

    for i = 1, #self.timerList do
      local prefix = 'TimerTrackerTimer'..i
      local timer = _G[prefix]
      local statusBar = _G['TimerTrackerTimer'..i..'StatusBar']
      if statusBar and not timer.isFree and not timer.rillyClean then
        _G[prefix..'StatusBarBorder']:Hide()
        skinProgressBar(statusBar)
      end
    end
  end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", init)
