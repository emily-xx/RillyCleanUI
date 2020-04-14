RillyCleanNameplates = CreateFrame("Frame", "RillyCleanNameplates")
RillyCleanNameplates:RegisterEvent("PLAYER_LOGIN")

RillyCleanNameplates:SetScript("OnEvent", function()
  -- Keep nameplates on screen
  SetCVar("nameplateOtherBottomInset", 0.1);
  SetCVar("nameplateOtherTopInset", 0.08);

  local len = string.len
  local gsub = string.gsub

  function abbrev(str, length)
      if ( not str ) then
          return UNKNOWN
      end

      length = length or 20

      str = (len(str) > length) and gsub(str, "%s?(.[\128-\191]*)%S+%s", "%1. ") or str
      return str
  end

  local NamePlateSetup = CreateFrame("FRAME")
  NamePlateSetup:RegisterEvent("PLAYER_ENTERING_WORLD")
  NamePlateSetup:SetScript("OnEvent", function()
    local targetNameplateHeight = 45

    C_NamePlate.SetNamePlateFriendlySize(RCUIDB.namePlateWidth, targetNameplateHeight)
    C_NamePlate.SetNamePlateEnemySize(RCUIDB.namePlateWidth, targetNameplateHeight)
  end)

  local f = CreateFrame("Frame")
  f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
  f:SetScript("OnEvent", function(self, event, unit)
    C_NamePlate.GetNamePlateForUnit(unit).UnitFrame:SetScale(RCUIDB.namePlateScale)
  end)

  if RCUIDB.modNamePlates then
    local CF=CreateFrame("Frame")
    CF:RegisterEvent("NAME_PLATE_CREATED")
    CF:SetScript("OnEvent", function(self, event, ...)
        local nameplate = ...
        nameplate.UnitFrame.isNameplate = true
    end)

    local function modifyNamePlates(frame, options)
      if ( frame:IsForbidden() ) then return end
      if ( not frame.isNameplate ) then return end

      if RCUIDB.hideNameplateCastText then
        frame.castBar.Text:Hide()
      elseif RCUIDB.nameplateCastFontSize then
        setFontSize(frame.castBar.Text, RCUIDB.nameplateCastFontSize)
      end
    end

    hooksecurefunc("DefaultCompactNamePlateFrameSetup", modifyNamePlates)
  end

  hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not frame.isNameplate ) then return end

    setDefaultFont(frame.name, RCUIDB.nameplateNameFontSize)

    if RCUIDB.nameplateFriendlyNamesClassColor and UnitIsPlayer(frame.unit) and UnitIsFriend("player", frame.displayedUnit) then
      local _,className = UnitClass(frame.displayedUnit)
      local classR, classG, classB = GetClassColor(className)

      frame.name:SetTextColor(classR, classG, classB, 1)
    end

    if RCUIDB.nameplateHideServerNames or RCUIDB.nameplateNameLength > 0 then
      local name, realm = UnitName(frame.displayedUnit) or UNKNOWN

      if not RCUIDB.nameplateHideServerNames and realm then
        name = name.." - "..realm
      elseif RCUIDB.nameplateNameLength > 0 then
        name = abbrev(name, RCUIDB.nameplateNameLength)
      end

      frame.name:SetText(name)
    end
  end)

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
end)
