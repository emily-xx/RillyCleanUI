local function GetDifficultyLevelColor(level)
	level = (level - tt.playerLevel);
	if (level > 4) then
		return "|cffff2020"; -- red
	elseif (level > 2) then
		return "|cffff8040"; -- orange
	elseif (level >= -2) then
		return "|cffffff00"; -- yellow
	elseif (level >= -GetQuestGreenRange()) then
		return "|cff40c040"; -- green
	else
		return "|cff808080"; -- gray
	end
end

local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
	if IsAddOnLoaded('TinyTooltip') or IsAddOnLoaded('TipTac') then
		return
	end

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

	--gametooltip statusbar
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("LEFT", 5, 0)
	GameTooltipStatusBar:SetPoint("RIGHT", -5, 0)
	GameTooltipStatusBar:SetPoint("BOTTOM", 0, 5)
	GameTooltipStatusBar:SetHeight(10)
	--gametooltip statusbar bg
	GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil,"BACKGROUND",nil,-8)
	GameTooltipStatusBar.bg:SetAllPoints()
	GameTooltipStatusBar.bg:SetColorTexture(1,1,1)
	GameTooltipStatusBar.bg:SetVertexColor(0,0,0,0.5)

	-- Class colours
	GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
		local _, unit = tooltip:GetUnit()
		if  not unit then return end
		local level = UnitEffectiveLevel(unit)

		if UnitIsPlayer(unit) then
			local className, class = UnitClass(unit)
			local r, g, b = GetClassColor(class)
			local race = UnitRace(unit)

			if (level < 0) then
				level = "??"
			end

			local text = GameTooltipTextLeft1:GetText()
			GameTooltipTextLeft1:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, text:match("|cff\x\x\x\x\x\x(.+)|r") or text)

			local guild, guildRank = GetGuildInfo(unit)
			local PlayerInfoLine = GameTooltipTextLeft2
			if (guild) then
				PlayerInfoLine = GameTooltipTextLeft3
			end
			PlayerInfoLine:SetText(level .. " " .. race .. " " .. className)
		end

		local family = UnitCreatureFamily(unit)
		if (family) then -- UnitIsBattlePetCompanion(unit);
			GameTooltipTextLeft2:SetText(level .. " " .. family)
		end

		GameTooltip:AddLine(' ')
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
