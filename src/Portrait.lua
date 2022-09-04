-- If the camera isn't reset OnShow, it'll show the entire character instead of just the head. Silly, is it not? :D
local function resetCamera(portraitModel)
  portraitModel:SetPortraitZoom(1)
end

local function resetGUID(portraitModel)
  portraitModel.guid = nil
end

local function makePortraitBG(frame, r, g, b)
  frame.portraitBG = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.portraitBG:SetFrameLevel(frame:GetFrameLevel() - 1)
  frame.portraitBG:SetFrameStrata("background")
  frame.portraitBG:SetAllPoints(frame.portrait)

  frame.portraitBG.backdropInfo = RILLY_CLEAN_BACKDROP
  frame.portraitBG:ApplyBackdrop()
  frame.portraitBG:SetBackdropColor(r,g,b,1)
  frame.portraitBG:SetBackdropBorderColor(r,g,b,1)
  frame.portraitBG:Show()
end

local function makeRillyCleanPortrait(frame)
  if not frame.portrait then return end

  local unit = frame.unit

  if ( RCUIDB.portraitStyle == "class" ) then -- Flat class icons
    if ( UnitIsPlayer(unit) ) then
      local t = CLASS_ICON_TCOORDS[select(2, UnitClass(unit))]
      if t then
        frame.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        frame.portrait:SetTexCoord(unpack(t))
        makePortraitBG(frame,0.05,0.05,0.05)
      end
    else
      frame.portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
    end
  elseif (RCUIDB.portraitStyle == "3D") then
    if ( not frame.portraitModel ) then -- Initialize 3D Model Container
      local portraitModel = CreateFrame("PlayerModel", nil, frame)
      portraitModel:SetScript("OnShow", resetCamera)
      portraitModel:SetScript("OnHide", resetGUID)
      portraitModel.parent = frame
      portraitModel:SetFrameLevel(0)

      makePortraitBG(frame,0.05,0.05,0.05)

      portraitModel:SetAllPoints(frame.portrait)
      portraitModel:Show()
      frame.portrait:Hide()
      frame.portraitModel = portraitModel
    end

    local unitGuid = UnitGUID(unit)

    if not unitGuid or (unit == 'targettarget' and unitGuid == frame.portraitModel.guid) then return end -- Target of Target is spammy and needs this protection

    frame.portraitModel.guid = unitGuid

    -- The players not in range so swap to question mark
    if ( not UnitIsVisible(unit) or not UnitIsConnected(unit) ) then
      frame.portraitModel:ClearModel()
      frame.portraitModel:SetModelScale(5.5)
      resetCamera(frame.portraitModel)
      frame.portraitModel:SetModel("Interface\\Buttons\\talktomequestionmark.m2")
    -- Use animated 3D portrait
    else
      frame.portraitModel:ClearModel()
      frame.portraitModel:SetModelScale(1)
      frame.portraitModel:SetUnit(frame.unit)
      resetCamera(frame.portraitModel)
      frame.portraitModel:SetPosition(0, 0, 0)
      frame.portraitModel:SetAnimation(804)
      frame.portraitModel:Show()
    end
  else -- Standard 2D character image, but made square
    frame.portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
  end
end

local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
  if (RCUIDB.portraitStyle == "default") then return end

  hooksecurefunc("UnitFramePortrait_Update", makeRillyCleanPortrait)
end)
