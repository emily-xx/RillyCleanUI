local format = string.format
local max = math.max
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local CastBars = CreateFrame("Frame", nil, UIParent)

-- CastBar timer function
local function CastingBarFrame_OnUpdate_Hook(self, elapsed)
	if not self.timer then
		return
	end
	if self.update and self.update < elapsed then
		if self.casting then
			self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
		elseif self.channeling then
			self.timer:SetText(format("%.1f", max(self.value, 0)))
		else
			self.timer:SetText("")
		end
		self.update = .1
	else
		self.update = self.update - elapsed
	end
end

function addCastbarTimer(castingFrame, fontSize, xOffset, yOffset, point, relativePoint)
  if ( not point ) then point = "LEFT" end
  if ( not relativePoint ) then relativePoint = "RIGHT" end

  castingFrame.timer = castingFrame:CreateFontString(nil)
  setDefaultFont(castingFrame.timer, fontSize)
  castingFrame.timer:SetPoint(point, castingFrame, relativePoint, xOffset, yOffset)
  castingFrame.update = 0.1

  castingFrame:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
end

CastBars:RegisterEvent("ADDON_LOADED")
CastBars:SetScript(
	"OnEvent",
	function(self, event, addon)
		if addon == "RillyCleanUI" then
      -- Player Castbar
      local castbarOffset = 0
      local actionBarOffset = 0
      if not RCUIDB or not RCUIDB.castbarOffset then
        castbarOffset = RCUIDBDefaults.castbarOffset
        actionBarOffset = RCUIDBDefaults.actionBarOffset
      elseif RCUIDB then
        castbarOffset = RCUIDB.castbarOffset
        actionBarOffset = RCUIDB.actionBarOffset
      end
      CastingBarFrame:SetMovable(true)
      CastingBarFrame:ClearAllPoints()
      CastingBarFrame:SetScale(1)
      CastingBarFrame:SetPoint("CENTER", MainMenuBar, "CENTER", 0, (actionBarOffset + castbarOffset))
      CastingBarFrame:SetUserPlaced(true)
      CastingBarFrame:SetMovable(false)

      CastingBarFrame.Icon:Show()
      CastingBarFrame.Icon:ClearAllPoints()
      CastingBarFrame.Icon:SetSize(20, 20)
      CastingBarFrame.Icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -8, -1)
      CastingBarFrame.Text:ClearAllPoints()
      CastingBarFrame.Text:SetPoint("CENTER", 0, 0)
      -- CastingBarFrame.Border:SetWidth(CastingBarFrame.Border:GetWidth() + 4)
      -- CastingBarFrame.Flash:SetWidth(CastingBarFrame.Flash:GetWidth() + 4)
      -- CastingBarFrame.BorderShield:SetWidth(CastingBarFrame.BorderShield:GetWidth() + 4)
      CastingBarFrame.Border:SetPoint("TOP", 0, 26)
      CastingBarFrame.Flash:SetPoint("TOP", 0, 26)
      CastingBarFrame.BorderShield:SetPoint("TOP", 0, 26)
      CastingBarFrame.Spark:SetPoint("LEFT", CastingBarFrame:GetStatusBarTexture(), "RIGHT", -15, 1)

      -- Player Timer
      addCastbarTimer(CastingBarFrame, 14, 5, -1)

      -- Target Castbar
      TargetFrameSpellBar.Icon:SetPoint("RIGHT", TargetFrameSpellBar, "LEFT", -5, 0)

      -- Target
      addCastbarTimer(TargetFrameSpellBar, 11, 4, 0)

      self:UnregisterEvent("ADDON_LOADED")
		end

    -----------------------------
    -- Castbar spell icon styling
    -----------------------------
    local function applycastSkin(b)
      if not b or (b and b.rillyClean) then return end
      -- parent
      if b == CastingBarFrame.Icon then
        b.parent = CastingBarFrame
      elseif b == FocusFrameSpellBar.Icon then
        b.parent = FocusFrameSpellBar
      else
        b.parent = TargetFrameSpellBar
      end

      -- frame
      frame = CreateFrame("Frame", nil, b.parent)

      applyRillyCleanBackdrop(b)

      b.rillyClean = true
    end

    -- setting timer for castbar icons
    function UpdateTimer(self, elapsed)
      total = total + elapsed
      if CastingBarFrame.Icon then
        applycastSkin(CastingBarFrame.Icon)
      end
      if TargetFrameSpellBar.Icon then
        applycastSkin(TargetFrameSpellBar.Icon)
      end
      if FocusFrameSpellBar.Icon then
        applycastSkin(FocusFrameSpellBar.Icon)
      end
      if CastingBarFrame.Icon.styled and TargetFrameSpellBar.Icon.styled then
        castSkinTimer:SetScript("OnUpdate", nil)
      end
    end

    total = 0
    castSkinTimer = CreateFrame("Frame")
    castSkinTimer:SetScript("OnUpdate", UpdateTimer)
	end
)
