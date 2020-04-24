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
	local RillyCleanMapBorder = CreateFrame("Frame", "RillyCleanMapBorder", Minimap)
	RillyCleanMapBorder:SetFrameLevel(0)
	RillyCleanMapBorder:SetFrameStrata("background")
	RillyCleanMapBorder:SetHeight(142)
	RillyCleanMapBorder:SetWidth(142)
	RillyCleanMapBorder:SetPoint("CENTER",0,0)
	RillyCleanMapBorder:SetScale(1)

	RillyCleanMapBorder:SetBackdrop( {
		bgFile = SQUARE_TEXTURE,
		edgeFile = SQUARE_TEXTURE,
		tile = false, tileSize = 0, edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	RillyCleanMapBorder:SetBackdropColor(0,0,0,1)
	RillyCleanMapBorder:SetBackdropBorderColor(0,0,0,1)
	RillyCleanMapBorder:Show()

	-- Square Minimap
	Minimap:SetMaskTexture(SQUARE_TEXTURE)

	-- Better looking mail icon
	MiniMapMailIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	MiniMapMailIcon:SetScale(0.9)
	local mailBg = CreateFrame("Frame", nil, MiniMapMailFrame)
	mailBg:SetFrameStrata("low")
	mailBg:SetFrameLevel(3)
	mailBg:SetHeight(20)
	mailBg:SetWidth(20)
	mailBg:SetPoint("center",-2,2)

	mailBg:SetBackdrop( {
		bgFile = SQUARE_TEXTURE,
		edgeFile = SQUARE_TEXTURE,
		tile = false, tileSize = 0, edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	mailBg:SetBackdropColor(0,0,0,1)
	mailBg:SetBackdropBorderColor(0,0,0,1)
	mailBg:Show()

	-- Clock Positioning
	self.ClearAllPoints(TimeManagerClockButton)
	self.SetPoint(TimeManagerClockButton, "TOP", RillyCleanMapBorder, "BOTTOM", 0, 3)

	---------------------------
	-- Artifact progress bar --
	---------------------------
	if (UnitLevel("player") >= 110) then
		local artifactBar = CreateFrame("StatusBar", "RillyCleanArtifactBar", RillyCleanMapBorder)
		artifactBar:SetOrientation("Vertical")
		artifactBar:SetPoint("RIGHT", RillyCleanMapBorder, "LEFT", 0, 0)
		local tex = artifactBar:CreateTexture()
		tex:SetTexture(137012) -- "Interface\\TargetingFrame\\UI-StatusBar"
		artifactBar:SetStatusBarTexture(tex)
		artifactBar:SetSize(12, 143)
		artifactBar:SetStatusBarColor((230/255), (204/255), (128/255), 1)

		local bg = artifactBar:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints(artifactBar)
		bg:SetColorTexture(0, 0, 0, 0.7)

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
			local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
			if (not azeriteItemLocation) then
				artifactBar:Hide()
				return false
			end
			local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
			artifactInfo.xpToNextLevel = totalLevelXP - xp

			artifactInfo.xp = xp
			artifactInfo.totalLevelXP = totalLevelXP
			artifactInfo.tPercent = xp / totalLevelXP * 100

			artifactBar:SetMinMaxValues(0, artifactInfo.totalLevelXP)
			artifactBar:SetValue(artifactInfo.xp)
			artifactBar:Show()
		end

		-- Initialise bar
		getBarData()

		local eventFrame = CreateFrame("Frame")
		eventFrame:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
		eventFrame:RegisterEvent("ARTIFACT_XP_UPDATE")
		eventFrame:SetScript("OnEvent", getBarData)
	end

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
end

local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", init)
