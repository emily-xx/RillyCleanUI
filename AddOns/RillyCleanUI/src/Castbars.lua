local format = string.format
local max = math.max
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local CastBars = CreateFrame("Frame", nil, UIParent)

local backdrop = {
  bgFile = nil,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 32,
  edgeSize = 2,
  insets = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
  },
}

CastBars:RegisterEvent("ADDON_LOADED")
CastBars:SetScript(
	"OnEvent",
	function(self, event, addon)
		if addon == "RillyCleanUI" then
      -- Player Castbar
      if not RCUIDB or RCUIDB.castbarOffset then
        CastingBarFrame:SetMovable(true)
        CastingBarFrame:ClearAllPoints()
        CastingBarFrame:SetScale(1)
        CastingBarFrame:SetPoint("CENTER", MainMenuBar, "CENTER", 0, RCUIDB.castbarOffset)
        CastingBarFrame:SetUserPlaced(true)
        CastingBarFrame:SetMovable(false)
      end

      CastingBarFrame.Icon:Show()
      CastingBarFrame.Icon:ClearAllPoints()
      CastingBarFrame.Icon:SetSize(20, 20)
      CastingBarFrame.Icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -8, 0)
      CastingBarFrame.Text:ClearAllPoints()
      CastingBarFrame.Text:SetPoint("CENTER", 0, 0)
      CastingBarFrame.Border:SetWidth(CastingBarFrame.Border:GetWidth() + 4)
      CastingBarFrame.Flash:SetWidth(CastingBarFrame.Flash:GetWidth() + 4)
      CastingBarFrame.BorderShield:SetWidth(CastingBarFrame.BorderShield:GetWidth() + 4)
      CastingBarFrame.Border:SetPoint("TOP", 0, 26)
      CastingBarFrame.Flash:SetPoint("TOP", 0, 26)
      CastingBarFrame.BorderShield:SetPoint("TOP", 0, 26)

      -- Player Timer
      CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
      setDefaultFont(CastingBarFrame.timer, 14)
      CastingBarFrame.timer:SetPoint("LEFT", CastingBarFrame, "RIGHT", 5, 0)
      CastingBarFrame.update = 0.1
      -- end

      -- Target Castbar
      TargetFrameSpellBar.Icon:SetPoint("RIGHT", TargetFrameSpellBar, "LEFT", -5, 0)

      -- Target Timer
      TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
      setDefaultFont(TargetFrameSpellBar.timer, 11)
      TargetFrameSpellBar.timer:SetPoint("LEFT", TargetFrameSpellBar, "RIGHT", 4, 0)
      TargetFrameSpellBar.update = 0.1

      self:UnregisterEvent("ADDON_LOADED")
		end

    -----------------------------
    -- Castbar spell icon styling
    -----------------------------
    local function applycastSkin(b)
      if not b or (b and b.styled) then return end
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
      --icon
      b:SetTexCoord(0.1, 0.9, 0.1, 0.9)

      -- border
      local back = CreateFrame("Frame", nil, b.parent)
      back:SetPoint("TOPLEFT", b, "TOPLEFT", -2, 2)
      back:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 2, -2)
      back:SetFrameLevel(frame:GetFrameLevel() - 1)
      back:SetBackdrop(backdrop)
      back:SetBackdropBorderColor(0,0,0,1)
      b.bg = back
      --set button styled variable
      b.styled = true
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

CastingBarFrame:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
TargetFrameSpellBar:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
