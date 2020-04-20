local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
	-- Tooltips anchored on mouse
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
		if (InCombatLockdown()) then
	    self:SetOwner(parent, "ANCHOR_NONE")
	    self:ClearAllPoints()
	    self:SetPoint(unpack({"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -200, 220}))
		else
			self:SetOwner(parent, RCUIDB.tooltipAnchor)
		end
	end)

	local bar = GameTooltipStatusBar
	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints()
	bar.bg:SetColorTexture(1, 1, 1)
	bar.bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
	bar.TextString = bar:CreateFontString(nil, "OVERLAY")
	bar.TextString:SetPoint("CENTER")
	setDefaultFont(bar.TextString, 11)
	bar.capNumericDisplay = true
	bar.lockShow = 1

	-- Class colours
	GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
		local _, unit = tooltip:GetUnit()

		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			local r, g, b = GetClassColor(class)

			local text = GameTooltipTextLeft1:GetText()
			GameTooltipTextLeft1:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, text:match("|cff\x\x\x\x\x\x(.+)|r") or text)
		end
	end)

	GameTooltip:HookScript("OnUpdate", function(tooltip)
		GameTooltip:SetBackdropColor(0.13,0.13,0.13) -- Simpler and themed BG color
	end)

	GameTooltipStatusBar:HookScript("OnValueChanged", function(self, hp)
		TextStatusBar_UpdateTextString(self)
	  local unit = "mouseover"
	  local focus = GetMouseFocus()
	  if (focus and focus.unit) then
	      unit = focus.unit
	  end
	  local r, g, b

	  if (UnitIsPlayer(unit)) then
	    r, g, b = GetClassColor(select(2,UnitClass(unit)))
	  else
	    r, g, b = GameTooltip_UnitColor(unit)
	    if (g == 0.6) then g = 0.9 end
	    if (r==1 and g==1 and b==1) then r, g, b = 0, 0.9, 0.1 end
	  end
	  self:SetStatusBarColor(r, g, b)
	end)
end)
