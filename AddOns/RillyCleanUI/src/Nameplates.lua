-- Keep nameplates on screen
SetCVar("nameplateOtherBottomInset", 0.1);
SetCVar("nameplateOtherTopInset", 0.08);

local NamePlateSetup = CreateFrame("FRAME")
NamePlateSetup:RegisterEvent("PLAYER_ENTERING_WORLD")
NamePlateSetup:SetScript("OnEvent", function()
  local targetNameplateHeight = 45

  C_NamePlate.SetNamePlateFriendlySize(RCConfig.namePlateWidth, targetNameplateHeight)
  C_NamePlate.SetNamePlateEnemySize(RCConfig.namePlateWidth, targetNameplateHeight)
end)

local f = CreateFrame("Frame")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:SetScript("OnEvent", function(self, event, unit)
  C_NamePlate.GetNamePlateForUnit(unit).UnitFrame:SetScale(RCConfig.namePlateScale)
end)

if RCConfig.hideNameplateCastText then
  local CF=CreateFrame("Frame")
  CF:RegisterEvent("NAME_PLATE_CREATED")
  CF:SetScript("OnEvent", function(self, event, ...)
      local nameplate = ...
      nameplate.UnitFrame.isNameplate = true
  end)

  local function modifyNamePlates(frame, options)
    if ( frame:IsForbidden() ) then return end
    if ( not frame.isNameplate ) then return end

    frame.healthBar:SetHeight(RCConfig.namePlateHeight)
  end

  hooksecurefunc("DefaultCompactNamePlateFrameSetup", modifyNamePlates)
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
