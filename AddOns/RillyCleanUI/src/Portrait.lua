-- If the camera isn't reset OnShow, it'll show the entire character instead of just the head. Silly, is it not? :D
local function resetCamera(portraitModel)
	portraitModel:SetPortraitZoom(1)
end

local function resetGUID(portraitModel)
	portraitModel.guid = nil
end

local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
  hooksecurefunc("UnitFramePortrait_Update",function(frame)
    if frame.portrait then
    	if( RCConfig.portraitStyle == "class" ) then -- Flat class icons
    		if( UnitIsPlayer(frame.unit) ) then
          local t = CLASS_ICON_TCOORDS[select(2, UnitClass(frame.unit))]
          if t then
            frame.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
            frame.portrait:SetTexCoord(unpack(t))
          end
    		else
    			frame.portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
    		end
    	elseif( RCConfig.portraitStyle == "2D" ) then -- Standard 2D character image, but made square
    		frame.portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
      elseif (RCConfig.portraitStyle == "3D") then
        if( not frame.portraitModel ) then -- Initialize 3D Model Container
    			frame.portraitModel = CreateFrame("PlayerModel", nil, frame)
    			frame.portraitModel:SetScript("OnShow", resetCamera)
    			frame.portraitModel:SetScript("OnHide", resetGUID)
    			frame.portraitModel.parent = frame
          frame.portraitModel:SetFrameLevel(0)

          frame.portraitBG = CreateFrame("Frame", nil, frame)
          frame.portraitBG:SetFrameLevel(0)
      		frame.portraitBG:SetFrameStrata("background")
      		frame.portraitBG:SetAllPoints(frame.portraitModel)

      		frame.portraitBG:SetBackdrop({
      		  bgFile = SQUARE_TEXTURE,
      		  edgeFile = SQUARE_TEXTURE,
      		  tile = false, tileSize = 0, edgeSize = 1,
      		  insets = { left = -1, right = -1, top = -1, bottom = -1 }
      		})
      		frame.portraitBG:SetBackdropColor(0.05,0.05,0.05,1)
      		frame.portraitBG:SetBackdropBorderColor(0.05,0.05,0.05,1)
      		frame.portraitBG:Show()

          frame.portraitModel:SetAllPoints(frame.portrait)
          frame.portraitModel:Show()
          frame.portrait:Hide()
    		end

        -- Portrait models can't be updated unless the GUID changed or else you have the animation jumping around
        local guid = UnitGUID(frame.unit)
      	frame.portraitModel.guid = guid

        -- The players not in range so swap to question mark
      	if( not UnitIsVisible(frame.unit) or not UnitIsConnected(frame.unit) ) then
      		frame.portraitModel:ClearModel()
      		frame.portraitModel:SetModelScale(5.5)
      		resetCamera(frame.portraitModel)
      		frame.portraitModel:SetModel("Interface\\Buttons\\talktomequestionmark.m2")
      	-- Use animated 3D portrait
      	else
      		frame.portraitModel:ClearModel()
      		frame.portraitModel:SetUnit(frame.unit)
      		resetCamera(frame.portraitModel)
      		frame.portraitModel:SetPosition(0, 0, 0)
      		frame.portraitModel:Show()
      	end
      end
  	end
  end)
end)
