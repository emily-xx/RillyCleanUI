-----------------------------------
-- Adapted from LFG_ProposalTime --
-----------------------------------
function init()
  local bigWigs = IsAddOnLoaded("BigWigs")
  local lfgProposalTime = IsAddOnLoaded("LFG_ProposalTime")

  local TIMEOUT = 40

  local timerBar = CreateFrame("StatusBar", nil, LFGDungeonReadyPopup)
  timerBar:SetPoint("TOP", LFGDungeonReadyPopup, "BOTTOM", 0, -5)
  local tex = timerBar:CreateTexture()
  tex:SetTexture(RILLY_CLEAN_TEXTURES.statusBar)
  timerBar:SetStatusBarTexture(tex, "BORDER")
  timerBar:SetStatusBarColor(1, 0.1, 0)
  timerBar:SetSize(194, 14)

  skinProgressBar(timerBar)

  timerBar.Spark = timerBar:CreateTexture(nil, "OVERLAY")
  timerBar.Spark:SetTexture(RILLY_CLEAN_TEXTURES.castSpark)
  timerBar.Spark:SetSize(32, 32)
  timerBar.Spark:SetBlendMode("ADD")
  timerBar.Spark:SetPoint("LEFT", timerBar:GetStatusBarTexture(), "RIGHT", -15, 3)

  if not bigWigs and not lfgProposalTime then
    timerBar.Text = timerBar:CreateFontString(nil, "OVERLAY")
    timerBar.Text:SetFontObject(GameFontHighlight)
    timerBar.Text:SetPoint("CENTER", timerBar, "CENTER")
  end

  local timeLeft = 0
  local function barUpdate(self, elapsed)
    timeLeft = (timeLeft or 0) - elapsed
    if(timeLeft <= 0) then return self:Hide() end

    self:SetValue(timeLeft)
    if not bigWigs and not lfgProposalTime then
      self.Text:SetFormattedText("%.1f", timeLeft)
    end
  end
  timerBar:SetScript("OnUpdate", barUpdate)

  local function OnEvent(self, event, ...)
    timerBar:SetMinMaxValues(0, TIMEOUT)
    timeLeft = TIMEOUT
    timerBar:Show()
  end

  local eventFrame = CreateFrame("Frame")
  eventFrame:RegisterEvent("LFG_PROPOSAL_SHOW")
  eventFrame:SetScript("OnEvent", OnEvent)
end

local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", init)
