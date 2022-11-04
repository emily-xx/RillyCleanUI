RillyCleanUnitFrames = CreateFrame("Frame", "RillyCleanUnitFrames")
RillyCleanUnitFrames:RegisterEvent("PLAYER_LOGIN")

RillyCleanUnitFrames:SetScript("OnEvent", function()
	-------------------------
	-- Hide Alt Power bars --
	-------------------------
	if (RCUIDB.hideAltPower) then
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
	end

	-- --------------------------------------
	-- ---      Class colored frames      ---
	-- --------------------------------------
	local function ClassColor(statusbar, unit)
		local _, class, c, color
    local TargetFrameHealthBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar
		if not statusbar then statusbar = TargetFrameHealthBar end
		statusbar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)

		if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
			_, class = UnitClass(unit)
			c = RAID_CLASS_COLORS[class]
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
			local bar = TargetFrameToT.HealthBar
			-- bar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)
			if (not UnitPlayerControlled("targettarget") and UnitIsTapDenied("targettarget")) then
				bar:SetStatusBarColor(0.5, 0.5, 0.5)
			else
				if color then
					bar:SetStatusBarColor(color.r, color.g, color.b)
					bar.lockColor = true
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

		color = FACTION_BAR_COLORS[UnitReaction("pet", "player")]
		PetFrameHealthBar:SetStatusBarColor(color.r, color.g, color.b)
		PetFrameHealthBar.lockColor = true
	end

	hooksecurefunc(
		"UnitFrameHealthBar_Update",
		function(self)
			ClassColor(self, self.unit)
		end
	)

	hooksecurefunc(
		TargetFrame,
		"HealthUpdate",
		function(elapsed, unit)
			ClassColor(nil, unit)
		end
	)

	hooksecurefunc(
		"HealthBar_OnValueChanged",
		function(self)
			ClassColor(self, self.unit)
		end
	)
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

		PlayerLootSpecFrame:SetPoint("BOTTOMRIGHT", PlayerFrame.portrait, "BOTTOMRIGHT", 0, yVal)
		PlayerLootSpecFrame:SetHeight(20)
		PlayerLootSpecFrame:SetWidth(46)
		PlayerLootSpecFrame.specname = PlayerLootSpecFrame:CreateFontString(nil)
		setDefaultFont(PlayerLootSpecFrame.specname, 11)
		PlayerLootSpecFrame.specname:SetPoint("LEFT", PlayerLootSpecFrame, "LEFT", 0, 0)

		local LootDisplaySetupFrame = CreateFrame("FRAME")
		LootDisplaySetupFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		LootDisplaySetupFrame:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
		LootDisplaySetupFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
		LootDisplaySetupFrame:SetScript("OnEvent", function(self, event)
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
				PlayerLootSpecFrame.specname:SetFormattedText("%s", lootIconText)
			end
		end)
	end
end)
