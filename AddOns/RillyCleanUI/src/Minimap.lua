-------------
-- MINIMAP --
-------------
local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
	for i,v in pairs({
		MinimapBorder,
		MiniMapMailBorder,
		QueueStatusMinimapButtonBorder,
		select(1, TimeManagerClockButton:GetRegions()),
          		}) do
        v:SetVertexColor(0, 0, 0)
		select(2, TimeManagerClockButton:GetRegions()):SetVertexColor(1,1,1)
	end

	--------------------------------------------------------------------
	-- MINIMAP BORDER
	--------------------------------------------------------------------
	local Panel = CreateFrame("Frame", mapborder, Minimap)
	Panel:SetFrameLevel(0)
	Panel:SetFrameStrata("background")
	Panel:SetHeight(142)
	Panel:SetWidth(142)
	Panel:SetPoint("center",0,0)
	Panel:SetScale(1)

	Panel:SetBackdrop( {
		bgFile = SQUARE_TEXTURE,
		edgeFile = SQUARE_TEXTURE,
		tile = false, tileSize = 0, edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	Panel:SetBackdropColor(0,0,0,1)
	Panel:SetBackdropBorderColor(0,0,0,1)
	Panel:Show()

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
	self.SetPoint(TimeManagerClockButton, "TOP", Panel, "BOTTOM", 0, 3)

	-- Hide Border
	MinimapBorder:Hide()
	MinimapBorderTop:Hide()

	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapWorldMapButton:Hide()

	if (RCUIDB.minimapZoneText) then
		MinimapZoneText:SetPoint("CENTER", Minimap, 0, 80)
		setFontOutline(MinimapZoneText)
	else
		MinimapZoneText:Hide()
	end

	MiniMapTracking:Hide()
	MiniMapTracking.Show = kill
	MiniMapTracking:UnregisterAllEvents()
	GameTimeFrame:Hide()
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(self, z)
		local c = Minimap:GetZoom()
		if(z > 0 and c < 5) then
			Minimap:SetZoom(c + 1)
		elseif(z < 0 and c > 0) then
			Minimap:SetZoom(c - 1)
		end
	end)
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			_G.GameTimeFrame:Click()
		elseif btn == "MiddleButton" then
			_G.ToggleDropDownMenu(1, nil, _G.MiniMapTrackingDropDown, self)
		else
			_G.Minimap_OnClick(self)
		end
	end)
end)
