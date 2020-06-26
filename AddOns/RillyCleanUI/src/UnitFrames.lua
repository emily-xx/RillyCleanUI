RillyCleanUnitFrames = CreateFrame("Frame", "RillyCleanUnitFrames")
RillyCleanUnitFrames:RegisterEvent("PLAYER_LOGIN")

RillyCleanUnitFrames:SetScript("OnEvent", function()
	-------------------------
	-- Hide Alt Power bars --
	-------------------------
	local altPowerBars = {
		PaladinPowerBarFrame,
		PlayerFrameAlternateManaBar,
		MageArcaneChargesFrame,
		MonkHarmonyBarFrame,
		MonkStaggerBar,
		RuneFrame,
		ComboPointPlayerFrame,
		WarlockPowerFrame,
		TotemFrame
	}

	for _, altPowerBar in pairs(altPowerBars) do
		altPowerBar:SetAlpha(0)
		RegisterStateDriver(altPowerBar, "visibility", "hide")
	end

	function cleanPlayerFrame()
		PlayerStatusTexture:Hide()
		PlayerRestGlow:Hide()
		PlayerStatusGlow:Hide()
		PlayerPrestigeBadge:SetAlpha(0)
		PlayerPrestigePortrait:SetAlpha(0)

		TargetFrameTextureFramePrestigeBadge:SetAlpha(0)
		TargetFrameTextureFramePrestigePortrait:SetAlpha(0)
		FocusFrameTextureFramePrestigeBadge:SetAlpha(0)
		FocusFrameTextureFramePrestigePortrait:SetAlpha(0)
	end

	hooksecurefunc("PlayerFrame_UpdateStatus", cleanPlayerFrame)

	--------------------------------------
	---      Class colored frames      ---
	--------------------------------------
	local function ClassColor(statusbar, unit)
		local _, class, c
		if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
			_, class = UnitClass(unit)
			c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
			statusbar:SetStatusBarColor(c.r, c.g, c.b)
		end
		if not UnitIsPlayer("target") then
			color = FACTION_BAR_COLORS[UnitReaction("target", "player")]
			if (not UnitPlayerControlled("target") and UnitIsTapDenied("target")) then
				TargetFrameHealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
			else
				if color then
					TargetFrameHealthBar:SetStatusBarColor(color.r, color.g, color.b)
					TargetFrameHealthBar.lockColor = true
				end
			end
		end
		if not UnitIsPlayer("focus") then
			color = FACTION_BAR_COLORS[UnitReaction("focus", "player")]
			if (not UnitPlayerControlled("focus") and UnitIsTapDenied("focus")) then
				FocusFrameHealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
			else
				if color then
					FocusFrameHealthBar:SetStatusBarColor(color.r, color.g, color.b)
					FocusFrameHealthBar.lockColor = true
				end
			end
		end
		if not UnitIsPlayer("targettarget") then
			color = FACTION_BAR_COLORS[UnitReaction("targettarget", "player")]
			if (not UnitPlayerControlled("targettarget") and UnitIsTapDenied("targettarget")) then
				TargetFrameToTHealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
			else
				if color then
					TargetFrameToTHealthBar:SetStatusBarColor(color.r, color.g, color.b)
					TargetFrameToTHealthBar.lockColor = true
				end
			end
		end
		if not UnitIsPlayer("focustarget") then
			color = FACTION_BAR_COLORS[UnitReaction("focustarget", "player")]
			if (not UnitPlayerControlled("focustarget") and UnitIsTapDenied("focustarget")) then
				FocusFrameToTHealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
			else
				if color then
					FocusFrameToTHealthBar:SetStatusBarColor(color.r, color.g, color.b)
					FocusFrameToTHealthBar.lockColor = true
				end
			end
		end
	end

	hooksecurefunc(
		"UnitFrameHealthBar_Update",
		function(self)
			ClassColor(self, self.unit)
		end
	)

	hooksecurefunc(
		"HealthBar_OnValueChanged",
		function(self)
			ClassColor(self, self.unit)
		end
	)

	--PLAYER
	function StylePlayerFrame(isVehicle)
		PlayerName:SetPoint("BOTTOM", PlayerFrameHealthBar, "TOP", 0, 3)
		setFontOutline(PlayerName)

		PlayerFrameGroupIndicatorText:ClearAllPoints()
		PlayerFrameGroupIndicatorText:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 42, -10)
		PlayerFrameGroupIndicatorLeft:Hide()
		PlayerFrameGroupIndicatorMiddle:Hide()
		PlayerFrameGroupIndicatorRight:Hide()

		PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -24)
		PlayerFrameHealthBar:SetHeight(26)
		PlayerFrameHealthBar.LeftText:ClearAllPoints()
		PlayerFrameHealthBar.LeftText:SetPoint("LEFT", PlayerFrameHealthBar, "LEFT", 10, 0)
		PlayerFrameHealthBar.RightText:ClearAllPoints()
		PlayerFrameHealthBar.RightText:SetPoint("RIGHT", PlayerFrameHealthBar, "RIGHT", -5, 0)
		PlayerFrameHealthBarText:SetPoint("CENTER", PlayerFrameHealthBar, "CENTER", 0, 0)

		PlayerFrameManaBar:SetPoint("TOPLEFT", 106, -52)
		PlayerFrameManaBar:SetHeight(13)
		PlayerFrameManaBar.LeftText:ClearAllPoints()
		PlayerFrameManaBar.LeftText:SetPoint("LEFT", PlayerFrameManaBar, "LEFT", 10, 0)
		PlayerFrameManaBar.RightText:ClearAllPoints()
		PlayerFrameManaBar.RightText:SetPoint("RIGHT", PlayerFrameManaBar, "RIGHT", -5, 1)
		PlayerFrameManaBarText:SetPoint("CENTER", PlayerFrameManaBar, "CENTER", 0, 0)
		PlayerFrameManaBar.FeedbackFrame:ClearAllPoints()
		PlayerFrameManaBar.FeedbackFrame:SetPoint("CENTER", PlayerFrameManaBar, "CENTER", 0, 0)
		PlayerFrameManaBar.FeedbackFrame:SetHeight(13)
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:ClearAllPoints()
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:SetPoint(
			"CENTER",
			PlayerFrameManaBar.FullPowerFrame,
			"RIGHT",
			-6,
			-3
		)
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:SetSize(30, 29)
		PlayerFrameManaBar.FullPowerFrame.PulseFrame:ClearAllPoints()
		PlayerFrameManaBar.FullPowerFrame.PulseFrame:SetPoint("CENTER", PlayerFrameManaBar.FullPowerFrame, "CENTER", -6, -2)
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.BigSpikeGlow:ClearAllPoints()
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.BigSpikeGlow:SetPoint(
			"CENTER",
			PlayerFrameManaBar.FullPowerFrame,
			"RIGHT",
			5,
			-4
		)
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.BigSpikeGlow:SetSize(30, 50)

		if isVehicle then
			PlayerFrameHealthBar:SetWidth(112);
			PlayerFrameManaBar:SetWidth(112);
		end
	end
	hooksecurefunc("PlayerFrame_ToPlayerArt", function()
		StylePlayerFrame(false)
		cleanPlayerFrame()
	end)
	hooksecurefunc("PlayerFrame_ToVehicleArt", function()
		StylePlayerFrame(true)
	end)

	--TARGET
	function StyleTargetFrame(self, forceNormalTexture)
		local classification = UnitClassification(self.unit)
		self.deadText:ClearAllPoints()
		self.deadText:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
		self.levelText:SetPoint("RIGHT", self.healthbar, "BOTTOMRIGHT", 63, 10)
		self.nameBackground:Hide()
		self.Background:SetSize(119, 42)
		self.manabar.pauseUpdates = false
		self.manabar:Show()
		TextStatusBar_UpdateTextString(self.manabar)
		self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")

		self.name:SetPoint("LEFT", self, 15, 36)
		setFontOutline(self.name)

		self.healthbar:SetSize(120, 26)
		self.healthbar:ClearAllPoints()
		self.healthbar:SetPoint("TOPLEFT", 5, -24)
		self.healthbar.LeftText:ClearAllPoints()
		self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 8, 0)
		self.healthbar.RightText:ClearAllPoints()
		self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -5, 0)
		self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
		self.manabar:ClearAllPoints()
		self.manabar:SetPoint("TOPLEFT", 5, -52)
		self.manabar:SetSize(120, 13)
		self.manabar.LeftText:ClearAllPoints()
		self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 8, 0)
		self.manabar.RightText:ClearAllPoints()
		self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -5, 1)
		self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0)

		--TargetOfTarget
		TargetFrameToTHealthBar:ClearAllPoints()
		TargetFrameToTHealthBar:SetPoint("TOPLEFT", 44, -15)
		TargetFrameToTHealthBar:SetHeight(8)
		TargetFrameToTManaBar:ClearAllPoints()
		TargetFrameToTManaBar:SetPoint("TOPLEFT", 44, -24)
		TargetFrameToTManaBar:SetHeight(5)
		FocusFrameToTHealthBar:ClearAllPoints()
		FocusFrameToTHealthBar:SetPoint("TOPLEFT", 45, -15)
		FocusFrameToTHealthBar:SetHeight(8)
		FocusFrameToTManaBar:ClearAllPoints()
		FocusFrameToTManaBar:SetPoint("TOPLEFT", 45, -25)
		FocusFrameToTManaBar:SetHeight(3)
		FocusFrameToT.deadText:SetWidth(0.01)

		if (forceNormalTexture) then
			self.haveElite = nil
			if (classification == "minus") then
				self.Background:SetSize(119, 42)
				self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35)
				--
				self.nameBackground:Hide()
				self.name:SetPoint("LEFT", self, 15, 36)
				self.healthbar:ClearAllPoints()
				self.healthbar:SetPoint("LEFT", 5, 13)
			else
				self.Background:SetSize(119, 42)
				self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35)
			end
			if (self.threatIndicator) then
				if (classification == "minus") then
					self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash")
					self.threatIndicator:SetTexCoord(0, 1, 0, 1)
					self.threatIndicator:SetWidth(256)
					self.threatIndicator:SetHeight(128)
					self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0)
				else
					self.threatIndicator:SetTexCoord(0, 0.9453125, 0, 0.181640625)
					self.threatIndicator:SetWidth(242)
					self.threatIndicator:SetHeight(93)
					self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0)
					self.threatNumericIndicator:SetPoint("BOTTOM", PlayerFrame, "TOP", 75, -22)
				end
			end
		else
			self.haveElite = true
			TargetFrameBackground:SetSize(119, 42)
			self.Background:SetSize(119, 42)
			self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35)
			if (self.threatIndicator) then
				self.threatIndicator:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625)
				self.threatIndicator:SetWidth(242)
				self.threatIndicator:SetHeight(112)
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -22, 9)
			end
		end

		if (self.questIcon) then
			if (UnitIsQuestBoss(self.unit)) then
				self.questIcon:Show()
			else
				self.questIcon:Hide()
			end
		end
	end
	hooksecurefunc("TargetFrame_CheckClassification", StyleTargetFrame)

	------------------------
	-- PetFrame placement --
	------------------------
	PetFrame:ClearAllPoints()
	PetFrame:SetPoint("BOTTOMLEFT", PetActionButton1, "TOPLEFT", -20, 20)

	PetFrameManaBar:ClearAllPoints()
	PetFrameManaBar:SetPoint("TOPLEFT", PetPortrait, "TOPRIGHT", 2, -24)

	PetFrameHealthBar:ClearAllPoints()
	PetFrameHealthBar:SetPoint("BOTTOM", PetFrameManaBar, "TOP", 0, 0)
	PetFrameHealthBar:SetHeight(18)

	PetName:SetTextColor(1,1,1)
	setFontOutline(PetName)
	PetName:ClearAllPoints()
	PetName:SetPoint("BOTTOM", PetFrameHealthBar, "TOP", 0, 5)

	PetFrameHealthBar:SetWidth(80)
	PetFrameHealthBar.LeftText:SetPoint("LEFT", PetFrameHealthBar, "LEFT", 0, 0)
	PetFrameManaBar:SetWidth(80)
	PetFrameHealthBar.RightText:SetPoint("RIGHT", PetFrameHealthBar, "RIGHT", 0, 0)
	PetFrameHealthBarText:SetPoint("CENTER", PetFrameHealthBar, "CENTER", 0, 0)

	-----------------------------------------------------------------
	-- Changes default nametext color from yellow to white (r,g,b) --
	-----------------------------------------------------------------
	PlayerName:SetTextColor(1,1,1)
	TargetFrameTextureFrameName:SetTextColor(1,1,1)
	TargetFrameToTTextureFrameName:SetTextColor(1,1,1)
	FocusFrameTextureFrameName:SetTextColor(1,1,1)
	FocusFrameToTTextureFrameName:SetTextColor(1,1,1)

	------------
	-- XP Bar --
	------------
	local maxPlayerLevel = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]
	if (UnitLevel("player") < maxPlayerLevel) then
		local xpInfo = {
			xp = 0,
			totalLevelXP = 0,
			xpToNextLevel = 0,
			tPercent = 0
		}

		local xpBar = createStatusBar(
			"RillyCleanXp",
			PlayerFrame,
			14, 67,
			{ r = 0.6, g = 0, b = 0.6 }
		)
		xpBar:SetPoint("RIGHT", PlayerFrame, "LEFT", 41, 6)

		xpBar:SetScript("OnEnter", function()
			GameTooltip:SetOwner(xpBar);
			GameTooltip:AddLine("Experience")
			GameTooltip:AddLine(abbrNumber(xpInfo.xp) .. "/" .. abbrNumber(xpInfo.totalLevelXP) .. " (" .. round(xpInfo.tPercent, 1) .. "%)", 1, 1, 1)
			GameTooltip:Show()
		end)

		xpBar:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		-- artifactBar.Text = artifactBar:CreateFontString(nil, "OVERLAY")
		-- artifactBar.Text:SetFontObject(GameFontHighlight)
		-- artifactBar.Text:SetPoint("CENTER", artifactBar, "CENTER")

		local artifactInfo = {
			xpToNextLevel = 0,
			xp = 0,
			totalLevelXP = 2000,
			tPercent = 0
		}
		local function getBarData()
			if (UnitLevel("player") == maxPlayerLevel) then
				xpBar:Hide()
				return
			end
			local xp = UnitXP("player")
			local totalLevelXP = UnitXPMax("player")
			xpInfo.xpToNextLevel = totalLevelXP - xp

			xpInfo.xp = xp
			xpInfo.totalLevelXP = totalLevelXP
			xpInfo.tPercent = xp / totalLevelXP * 100

			xpBar.Status:SetMinMaxValues(0, xpInfo.totalLevelXP)
			xpBar.Status:SetValue(xpInfo.xp)
			xpBar:Show()
		end

		-- Initialise bar
		getBarData()

		local eventFrame = CreateFrame("Frame")
		eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
		eventFrame:SetScript("OnEvent", getBarData)
	end

	-----------------------
	-- Loot Spec Display --
	-----------------------
	if RCUIDB.lootSpecDisplay then
		local lootSpecId = nil
		local lootSpecName = ""
		local lootIcon = nil
		local defaultSpecName
		local defaultIcon

		local PlayerLootSpecFrame = CreateFrame("Frame", nil, PlayerFrame)
		PlayerLootSpecFrame:SetPoint("TOPLEFT", PlayerFrame, "BOTTOMRIGHT", -120, 32)
		PlayerLootSpecFrame:SetHeight(16)
		PlayerLootSpecFrame:SetWidth(16)
		PlayerLootSpecFrame.specname = PlayerLootSpecFrame:CreateFontString(nil)
		setDefaultFont(PlayerLootSpecFrame.specname, 11)
		PlayerLootSpecFrame.specname:SetPoint("LEFT", PlayerLootSpecFrame, "LEFT", 0, 0)

		local LootDisplaySetupFrame = CreateFrame("FRAME")
		LootDisplaySetupFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		LootDisplaySetupFrame:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
		LootDisplaySetupFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
		LootDisplaySetupFrame:SetScript("OnEvent", function(self, event)
			cleanPlayerFrame() -- Ensure that things stay hidden on spec change
			-- Loot Spec
			newLootSpecId = GetLootSpecialization()

			if (lootSpecId ~= newLootSpecId or (not LootSpecId and event == "PLAYER_TALENT_UPDATE")) then
				lootSpecId = newLootSpecId

				if lootSpecId ~= 0 then
					_,lootSpecName,_,lootIcon = GetSpecializationInfoByID(lootSpecId)
				else
					_,lootSpecName,_,lootIcon = GetSpecializationInfo(GetSpecialization())
				end

				if not lootIcon then return end

				local lootIconText = format('|T%s:16:16:0:0:64:64:4:60:4:60|t', lootIcon)
				PlayerLootSpecFrame.specname:SetFormattedText("%s %s: %s", lootIconText, "Loot", lootSpecName)
			end
		end)
	end
end)
