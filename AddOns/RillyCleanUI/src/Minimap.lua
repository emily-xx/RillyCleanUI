-------------
-- MINIMAP --
-------------
function handleMinimapZoneText()
	if not RCUIDB.hideMinimapZoneText then
		MinimapZoneText:SetPoint("CENTER", Minimap, 0, 80)
		setFontOutline(MinimapZoneText)
		MinimapZoneText:Show()
	else
		MinimapZoneText:Hide()
	end
end

function init(self, event)
	--------------------------------------------------------------------
	-- MINIMAP BORDER
	--------------------------------------------------------------------
	local RillyCleanMapBorder = CreateFrame("Frame", "RillyCleanMapBorder", Minimap, "BackdropTemplate")
	RillyCleanMapBorder:SetFrameLevel(0)
	RillyCleanMapBorder:SetFrameStrata("background")
	RillyCleanMapBorder:SetHeight(142)
	RillyCleanMapBorder:SetWidth(142)
	RillyCleanMapBorder:SetPoint("CENTER",0,0)
	RillyCleanMapBorder:SetScale(1)

	RillyCleanMapBorder.backdropInfo = {
		bgFile = SQUARE_TEXTURE,
		edgeFile = SQUARE_TEXTURE,
		tile = false, tileSize = 0, edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	}
	RillyCleanMapBorder:ApplyBackdrop()
	RillyCleanMapBorder:SetBackdropColor(0,0,0,1)
	RillyCleanMapBorder:SetBackdropBorderColor(0,0,0,1)
	RillyCleanMapBorder:Show()

	-- Square Minimap
	Minimap:SetMaskTexture(SQUARE_TEXTURE)

	-- Better looking mail icon
	MiniMapMailIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	MiniMapMailIcon:SetScale(0.9)
	local mailBg = CreateFrame("Frame", nil, MiniMapMailFrame, "BackdropTemplate")
	mailBg:SetFrameStrata("low")
	mailBg:SetFrameLevel(3)
	mailBg:SetHeight(20)
	mailBg:SetWidth(20)
	mailBg:SetPoint("center",-2,2)

	mailBg.backdropInfo = {
		bgFile = SQUARE_TEXTURE,
		edgeFile = SQUARE_TEXTURE,
		tile = false, tileSize = 0, edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	}
	mailBg:ApplyBackdrop()
	mailBg:SetBackdropColor(0,0,0,1)
	mailBg:SetBackdropBorderColor(0,0,0,1)
	mailBg:Show()

	-- Clock Positioning
	self.ClearAllPoints(TimeManagerClockButton)
	self.SetPoint(TimeManagerClockButton, "TOP", RillyCleanMapBorder, "BOTTOM", 0, 3)

	-- Hide Border
	MinimapBorder:Hide()
	MinimapBorderTop:Hide()

	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapWorldMapButton:Hide()

	-- Hide/unhide Minimap zone text
	handleMinimapZoneText()

	MiniMapTracking:Hide()
	MiniMapTracking.Show = kill
	MiniMapTracking:UnregisterAllEvents()

	-- Hide Calendar
	GameTimeFrame:Hide()

	-- Mousewheel Zoom
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(self, z)
		local c = Minimap:GetZoom()
		if(z > 0 and c < 5) then
			Minimap:SetZoom(c + 1)
		elseif(z < 0 and c > 0) then
			Minimap:SetZoom(c - 1)
		end
	end)

	-- Mouse shortcuts
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			_G.GameTimeFrame:Click()
		elseif btn == "MiddleButton" then
			_G.ToggleDropDownMenu(1, nil, _G.MiniMapTrackingDropDown, self)
		else
			_G.Minimap_OnClick(self)
		end
	end)

	---------------------------
	-- Artifact progress bar --
	---------------------------
	local artifactBar = createStatusBar(
		"RillyCleanArtifact",
		RillyCleanMapBorder,
		14, 143,
		{ r = (230/255), g = (204/255), b = (128/255) }
	)
	artifactBar:SetPoint("RIGHT", RillyCleanMapBorder, "LEFT", 0, 0)

	local artifactEventFrame = CreateFrame("Frame")

	--------------------
	-- Reputation Bar --
	--------------------
	local repBar = createStatusBar(
		"RillyCleanRep",
		RillyCleanMapBorder,
		14, 143,
		{ r = (230/255), g = (204/255), b = (128/255) }
	)
	local function positionRepBar()
		local repAttachFrame = RillyCleanMapBorder
		if (artifactBar:IsShown()) then
			repAttachFrame = artifactBar
		end
		repBar:SetPoint("RIGHT", repAttachFrame, "LEFT", 0, 0)
	end

	-- artifactBar.Text = artifactBar:CreateFontString(nil, "OVERLAY")
	-- artifactBar.Text:SetFontObject(GameFontHighlight)
	-- artifactBar.Text:SetPoint("CENTER", artifactBar, "CENTER")

	local artifactInfo = {
		level = 0,
		xpToNextLevel = 0,
		xp = 0,
		totalLevelXP = 2000,
		tPercent = 0
	}

	artifactBar:SetScript("OnEnter", function()
		GameTooltip:SetOwner(artifactBar);
		GameTooltip:AddLine("Heart of Azeroth")
		GameTooltip:AddLine("Level " .. artifactInfo.level, 1, 1, 1)
		GameTooltip:AddLine(abbrNumber(artifactInfo.xp) .. "/" .. abbrNumber(artifactInfo.totalLevelXP) .. " (" .. round(artifactInfo.tPercent, 1) .. "%)", 1, 1, 1)
		GameTooltip:Show()
	end)

	artifactBar:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local function getArtifactBarData(self, event, unit)
		if event == "UNIT_INVENTORY_CHANGED" and unit ~= 'player' then
			return
		end

		if UnitLevel("player") < 110 then
			artifactBar:Hide()
			return
		end

		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
		if (not azeriteItemLocation) then
			artifactBar:Hide()
			return false
		end

		artifactEventFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")

		local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
		artifactInfo.xpToNextLevel = totalLevelXP - xp

		local level = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
		artifactInfo.level = level

		artifactInfo.xp = xp
		artifactInfo.totalLevelXP = totalLevelXP
		artifactInfo.tPercent = xp / totalLevelXP * 100

		artifactBar.Status:SetMinMaxValues(0, artifactInfo.totalLevelXP)
		artifactBar.Status:SetValue(artifactInfo.xp)

		if (not artifactBar:IsShown()) then
			artifactBar:Show()
			positionRepBar()
		end
		return true
	end

	-- Initialise artifact bar
	getArtifactBarData()
	positionRepBar()

	artifactEventFrame:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
	artifactEventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	artifactEventFrame:SetScript("OnEvent", getArtifactBarData)

	-- repBar.Text = repBar:CreateFontString(nil, "OVERLAY")
	-- repBar.Text:SetFontObject(GameFontHighlight)
	-- repBar.Text:SetPoint("CENTER", repBar, "CENTER")

	local repInfo = {
		factionName = "",
		factionStanding = "",
		repToNextLevel = 0,
		factionCur = 0,
		factionMax = 2000,
		factionPercent = 0
	}

	repBar:SetScript("OnEnter", function()
		GameTooltip:SetOwner(repBar);
		GameTooltip:AddLine(repInfo.factionName .. ": " .. repInfo.factionStanding)
		GameTooltip:AddLine(repInfo.factionCur .. "/" .. repInfo.factionMax .. " (" .. round(repInfo.factionPercent, 1) .. "%)", 1, 1, 1)
		GameTooltip:Show()
	end)

	repBar:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local function getRepBarData()
		local trackedFactionIndex = nil
    for factionIndex = 1, GetNumFactions() do
			local isTracked = select(12, GetFactionInfo(factionIndex))
			if isTracked then
				trackedFactionIndex = factionIndex
				break
			end
		end

		if trackedFactionIndex == nil then
			repBar:Hide()
			return
		end

		--Check for the faction info
		local name, _, standingID, barMin, barMax, barValue, _, _, _, _, _, isWatched, _, factionID = GetFactionInfo(trackedFactionIndex)
		local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)

		--faction standing information
		local factionStanding = getglobal("FACTION_STANDING_LABEL"..standingID)
		repInfo.factionName = name

		if (friendID ~= nil) then
			--Set faction standing to friend standing
			factionStanding = friendTextLevel
			--Set standingID to 'Friendly'
			standingID = 5
			--if we're not capped on friendship
			if nextFriendThreshold then
				barMin, barMax, barValue = friendThreshold, nextFriendThreshold, friendRep
			else
				barMin, barMax, barValue = 0, 1, 1
			end
		-- Check for Paragon
		elseif (C_Reputation.IsFactionParagon(factionID)) then
			local currentValue,threshold = C_Reputation.GetFactionParagonInfo(factionID)
			factionStanding = "Paragon"
			if (currentValue >= 10000) then
				local equation = currentValue / 10000
				local base = math.floor(equation);
				currentValue = math.floor((equation - base) * 10000)
			end
			barValue, barMax = currentValue, threshold

			repInfo.factionStanding = factionStanding
			repInfo.factionCur, repInfo.factionMax, repInfo.factionPercent = currentValue, threshold, currentValue/threshold*100
		--Check for Exalted(non Paragon)
		elseif standingID == 8 then
			barMin, barMax, barValue = 0, 1, 1
		else
			--Adjust values to account for the true minimum
			barValue = barValue - barMin
			barMax = barMax - barMin
			--aura envs for display text
			repInfo.factionStanding = factionStanding
			repInfo.factionCur, repInfo.factionMax, repInfo.factionPercent = barValue, barMax, barValue/barMax*100
		end

		local barColor = ARA_FACTION_COLORS[standingID]
		repBar.Status:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
		repBar.Status:SetMinMaxValues(0, barMax)
		repBar.Status:SetValue(barValue)
		repBar:Show()
	end

	-- Initialise rep bar
	getRepBarData()

	local repEventFrame = CreateFrame("Frame")
	repEventFrame:RegisterEvent("UPDATE_FACTION")
	repEventFrame:SetScript("OnEvent", getRepBarData)
end

local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", init)
