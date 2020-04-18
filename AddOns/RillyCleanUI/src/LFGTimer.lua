-----------------------------------
-- Adapted from LFG_ProposalTime --
-----------------------------------
function init()
  local bigWigs = IsAddOnLoaded("BigWigs")
  local lfgProposalTime = IsAddOnLoaded("LFG_ProposalTime")
  if bigWigs or lfgProposalTime then return end -- No need to run when using these addons

  local TIMEOUT = 40

  local BD = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    tile = true,
    tileSize = 32,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
  }

  local timerBar = CreateFrame("StatusBar", nil, LFGDungeonReadyPopup)
  timerBar:SetPoint("TOP", LFGDungeonReadyPopup, "BOTTOM", 0, -5)
  timerBar:SetSize(194, 14)
  timerBar:SetStatusBarTexture(137012, "BORDER") -- "Interface\\TargetingFrame\\UI-StatusBar"
  timerBar:SetStatusBarColor(1, 0.1, 0)
  timerBar:SetBackdrop(BD)
  timerBar:Hide()

  timerBar.Spark = timerBar:CreateTexture(nil, "OVERLAY")
  timerBar.Spark:SetTexture(130877) -- "Interface\\CastingBar\\UI-CastingBar-Spark"
  timerBar.Spark:SetSize(32, 32)
  timerBar.Spark:SetBlendMode("ADD")
  timerBar.Spark:SetPoint("LEFT", timerBar:GetStatusBarTexture(), "RIGHT", -15, 3)

  timerBar.Border = timerBar:CreateTexture(nil, "ARTWORK")
  timerBar.Border:SetTexture(130874) -- "Interface\\CastingBar\\UI-CastingBar-Border"
  timerBar.Border:SetSize(256, 64)
  timerBar.Border:SetPoint("TOP", timerBar, 0, 27)

  timerBar.Text = timerBar:CreateFontString(nil, "OVERLAY")
  timerBar.Text:SetFontObject(GameFontHighlight)
  timerBar.Text:SetPoint("CENTER", timerBar, "CENTER")

  local timeLeft = 0
  local function barUpdate(self, elapsed)
    timeLeft = (timeLeft or 0) - elapsed
    if(timeLeft <= 0) then return self:Hide() end

    self:SetValue(timeLeft)
    self.Text:SetFormattedText("%.1f", timeLeft)
  end
  timerBar:SetScript("OnUpdate", barUpdate)

  local function OnEvent(self, event, ...)
    timerBar:SetMinMaxValues(0, TIMEOUT)
    timeLeft = TIMEOUT
    timerBar:Show()
  end

  local eventFrame = CreateFrame"Frame"
  eventFrame:RegisterEvent"LFG_PROPOSAL_SHOW"
  eventFrame:SetScript("OnEvent", OnEvent)
end

local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", init)
