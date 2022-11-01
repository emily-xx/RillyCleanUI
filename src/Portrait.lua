-- If the camera isn't reset OnShow, it'll show the entire character instead of just the head. Silly, is it not? :D
local function resetCamera(portraitModel)
  portraitModel:SetPortraitZoom(1)
end

local function resetGUID(portraitModel)
  portraitModel.guid = nil
end

local function makePortraitBG(frame, r, g, b)
  frame.portraitBG = CreateFrame("Frame", nil, frame)
  frame.portraitBG:SetFrameLevel(frame:GetFrameLevel() - 1)
  frame.portraitBG:SetFrameStrata("background")
  frame.portraitBG:SetAllPoints(frame.portrait)
  local backLayer = frame.portraitBG:CreateTexture("backLayer", "BACKGROUND", nil, -1) --drawLayer=="OVERLAY" and "ARTWORK" or drawLayer)
	backLayer:Hide()
	backLayer:SetTexture("Interface\\AddOns\\RillyCleanUI\\media\\textures\\Portrait-ModelBack")
  backLayer:SetVertexColor(0, 0, 0)
  backLayer:SetAllPoints(frame.portraitBG)
  backLayer:Show()
  frame.portraitBG.backlayer = backlayer
end

local function make3DPortraitFG(frame)
  frame.portraitFG = CreateFrame("Frame", nil, frame)
  frame.portraitFG:SetFrameLevel(frame:GetFrameLevel())
  frame.portraitFG:SetFrameStrata("LOW")
  frame.portraitFG:SetAllPoints(frame.portrait)
  frame.portraitFG:SetPoint("TOPLEFT", frame.portrait, "TOPLEFT", 0, -1)
  frame.portraitFG:SetPoint("BOTTOMRIGHT", frame.portrait, "BOTTOMRIGHT", 0, -1)
  local foreground = frame.portraitFG:CreateTexture("foreLayer", "OVERLAY", nil)
  foreground:Hide()
  foreground:SetTexture("Interface\\AddOns\\RillyCleanUI\\media\\textures\\portrait-modelfront")
  -- foreground:SetVertexColor(0, 0, 0)
  foreground:SetAllPoints(frame.portraitFG)
  foreground:Show()
  frame.portraitFG.forelayer = foreground
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
      local portrait = frame.portrait
      local portraitModel = CreateFrame("PlayerModel", nil, frame)
      portraitModel:SetScript("OnShow", resetCamera)
      portraitModel:SetScript("OnHide", resetGUID)
      portraitModel.parent = frame
      portraitModel:SetFrameLevel(0)

      makePortraitBG(frame,0.05,0.05,0.05)

      -- Round portraits
      local coeff = 0.14
      xoff = coeff*portrait:GetWidth() -- circle portrait has model slightly smaller
      yoff = coeff*portrait:GetHeight()
      portraitModel:SetAllPoints(portrait)
      portraitModel:SetPoint("TOPLEFT", portrait,"TOPLEFT",xoff,-yoff)
      portraitModel:SetPoint("BOTTOMRIGHT",portrait,"BOTTOMRIGHT",-xoff,yoff)
      portraitModel:Show()
      frame.portrait:Hide()
      frame.portraitModel = portraitModel

      -- Add foreground mask
      make3DPortraitFG(frame)
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
  end
end

local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
  if (RCUIDB.portraitStyle == "default") then return end

  hooksecurefunc("UnitFramePortrait_Update", makeRillyCleanPortrait)
end)
