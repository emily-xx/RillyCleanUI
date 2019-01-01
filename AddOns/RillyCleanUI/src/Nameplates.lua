-- Keep nameplates on screen
SetCVar("nameplateOtherBottomInset", 0.1);
SetCVar("nameplateOtherTopInset", 0.08);

-- Increase scale of target nameplate
if RCConfig.targetNameplateScale then
  local NamePlateSetup = CreateFrame("FRAME")
  NamePlateSetup:RegisterEvent("PLAYER_ENTERING_WORLD")
  NamePlateSetup:SetScript("OnEvent", function()
    C_NamePlate.SetNamePlateFriendlySize(100 * RCConfig.targetNameplateScale, 40)
    C_NamePlate.SetNamePlateEnemySize(100 * RCConfig.targetNameplateScale, 40)
  end)

  local f = CreateFrame("Frame")
  f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
  f:SetScript("OnEvent", function(self, event, unit)
    C_NamePlate.GetNamePlateForUnit(unit).UnitFrame:SetScale(RCConfig.targetNameplateScale)
  end)
end

if RCConfig.hideNameplateCastText or RCConfig.nameplateCastFontSize then
  local CF=CreateFrame("Frame")
  CF:RegisterEvent("NAME_PLATE_CREATED")
  CF:SetScript("OnEvent", function(self, event, ...)
    if ( event == "NAME_PLATE_CREATED" ) then
      local nameplate = ...
      nameplate.UnitFrame.isNameplate = true
    end
  end)

  hooksecurefunc("DefaultCompactNamePlateFrameSetup", function(frame, options)
    if ( frame:IsForbidden() ) then return end
    if ( not frame.isNameplate ) then return end

    if RCConfig.hideNameplateCastText then
      frame.castBar.Text:Hide()
    else
      frame.castBar.Text:SetFont("Fonts\\FRIZQT__.TTF", RCConfig.nameplateCastFontSize, "THINOUTLINE")
    end
  end)
end

-------------------------------------------------------
-- Red color when below 30% on Personal Resource Bar --
-------------------------------------------------------
hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
  		if frame.optionTable.colorNameBySelection and not frame:IsForbidden() then
      		local healthPercentage = ceil((UnitHealth(frame.displayedUnit) / UnitHealthMax(frame.displayedUnit) * 100))

      		if C_NamePlate.GetNamePlateForUnit(frame.unit) == C_NamePlate.GetNamePlateForUnit("player") then
          			if healthPercentage == 100 then
              			frame.healthBar:SetStatusBarColor(0, 1, 0)
          			elseif healthPercentage < 100 and healthPercentage >= 30 then
              			frame.healthBar:SetStatusBarColor(0, 1, 0)
          			elseif healthPercentage < 30 then
              			frame.healthBar:SetStatusBarColor(1, 0, 0)
          			end
      		end
  		end
end)
