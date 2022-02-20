-- If the camera isn't reset OnShow, it'll show the entire character instead of just the head. Silly, is it not? :D
local function resetCamera(portraitModel)
    portraitModel:SetPortraitZoom(1)
end

local function resetGUID(portraitModel)
    portraitModel.guid = nil
end

local function makePortraitBG(frame, r, g, b)
  frame.portraitBG = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.portraitBG:SetFrameLevel(0)
  frame.portraitBG:SetFrameStrata("background")
  frame.portraitBG:SetAllPoints(frame.portrait)

  frame.portraitBG.backdropInfo = RILLY_CLEAN_BACKDROP
  frame.portraitBG:ApplyBackdrop()
  frame.portraitBG:SetBackdropColor(r,g,b,1)
  frame.portraitBG:SetBackdropBorderColor(r,g,b,1)
  frame.portraitBG:Show()
end

local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
hooksecurefunc("UnitFramePortrait_Update",function(frame)
  if frame.portrait then
    if( RCUIDB.portraitStyle == "class" ) then -- Flat class icons
      if( UnitIsPlayer(frame.unit) ) then
        local t = CLASS_ICON_TCOORDS[select(2, UnitClass(frame.unit))]
        if t then
          frame.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
          frame.portrait:SetTexCoord(unpack(t))
          makePortraitBG(frame,0.05,0.05,0.05)
        end
      else
        frame.portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
      end
    elseif( RCUIDB.portraitStyle == "2D" ) then -- Standard 2D character image, but made square
      frame.portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
    elseif (RCUIDB.portraitStyle == "3D") then
      if ( not frame.portraitModel ) then -- Initialize 3D Model Container
        local portraitModel = CreateFrame("PlayerModel", nil, frame)
        portraitModel:SetScript("OnShow", resetCamera)
        portraitModel:SetScript("OnHide", resetGUID)
        portraitModel.parent = frame
        portraitModel:SetFrameLevel(frame:GetFrameLevel())

        makePortraitBG(frame,0.05,0.05,0.05)

        portraitModel:SetAllPoints(frame.portrait)
        portraitModel:Show()
        frame.portrait:Hide()
        frame.portraitModel = portraitModel
      end

      -- Portrait models can't be updated unless the GUID changed or else you have the animation jumping around
      frame.portraitModel.guid = UnitGUID(frame.unit)

      -- The players not in range so swap to question mark
      if ( not UnitIsVisible(frame.unit) or not UnitIsConnected(frame.unit) ) then
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
        frame.portraitModel:SetAnimation(804)
        frame.portraitModel:Show()
      end
    end
    end
  end)
end)
