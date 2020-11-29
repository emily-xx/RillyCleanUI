RillyCleanNameplates = CreateFrame("Frame", "RillyCleanNameplates")
RillyCleanNameplates:RegisterEvent("PLAYER_LOGIN")

RillyCleanNameplates:SetScript("OnEvent", function()
  -------------------------------------------------------
  -- Red color when below 30% on Personal Resource Bar --
  -------------------------------------------------------
  hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
    local healthPercentage = ceil((UnitHealth(frame.displayedUnit) / UnitHealthMax(frame.displayedUnit) * 100))
    local isPersonal = C_NamePlate.GetNamePlateForUnit(frame.unit) == C_NamePlate.GetNamePlateForUnit("player")
    if frame.optionTable.colorNameBySelection and not frame:IsForbidden() then
      if isPersonal then
        if healthPercentage <= 100 and healthPercentage >= 30 then
          frame.healthBar:SetStatusBarColor(0, 1, 0)
        elseif healthPercentage < 30 then
          frame.healthBar:SetStatusBarColor(1, 0, 0)
        end
      end
    end

    if frame.isNameplate and not frame:IsForbidden() then
      if not frame.healthPercentage then
        frame.healthPercentage = frame.healthBar:CreateFontString(nil)
        setDefaultFont(frame.healthPercentage, RCUIDB.nameplateNameFontSize - 1)
        frame.healthPercentage:SetTextColor( 1, 1, 1 )
        frame.healthPercentage:SetPoint("CENTER", frame.healthBar, "CENTER", 0, 0)
      end

      if healthPercentage ~= 100 then
        frame.healthPercentage:SetText(healthPercentage .. '%')
      else
        frame.healthPercentage:SetText('')
      end
    end
  end)

  hooksecurefunc("CompactUnitFrame_SetUnit", function(frame, unit)
    local castFrame = frame.castBar
    if ( not frame.isNameplate or not castFrame or frame:IsForbidden() ) then return end

    if ( not castFrame.timer ) then
      addCastbarTimer(castFrame, RCUIDB.nameplateNameFontSize, 2, 0)
    end

    if ( not unit or UnitIsFriend("player", unit) ) then
      castFrame.timer:Hide()
    else
      castFrame.timer:Show()
    end
  end)

  -- Keep nameplates on screen
  SetCVar("nameplateOtherBottomInset", 0.1);
  SetCVar("nameplateOtherTopInset", 0.08);

  if IsAddOnLoaded('TidyPlates_ThreatPlates') then
    return
  end

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

  if RCUIDB.modNamePlates then
    hooksecurefunc(NamePlateDriverFrame, "AcquireUnitFrame", function(_, nameplate)
      if (nameplate.UnitFrame) then
        nameplate.UnitFrame.isNameplate = true
      end
    end);

    local function modifyNamePlates(frame, options)
      if ( frame:IsForbidden() ) then return end
      if ( not frame.isNameplate ) then return end

      if (frame.castBar) then
        if RCUIDB.nameplateHideCastText then
          frame.castBar.Text:Hide()
        end

        setDefaultFont(frame.castBar.Text, RCUIDB.nameplateNameFontSize - 1)
      end
    end

    hooksecurefunc("DefaultCompactNamePlateFrameSetup", modifyNamePlates)
  end

  hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if ( not frame.unit ) or ( not frame.isNameplate ) or ( frame:IsForbidden() ) then
      return
    end

    local isPersonal = UnitIsUnit(frame.displayedUnit, "player")
    if ( isPersonal ) then
      if ( frame.levelText ) then
        frame.levelText:SetText('')
      end
      return
    end

    setDefaultFont(frame.name, RCUIDB.nameplateNameFontSize)

    if RCUIDB.nameplateFriendlyNamesClassColor and UnitIsPlayer(frame.unit) and UnitIsFriend("player", frame.displayedUnit) then
      local _,className = UnitClass(frame.displayedUnit)
      local classR, classG, classB = GetClassColor(className)

      frame.name:SetTextColor(classR, classG, classB, 1)
    end

    if not frame.levelText then
      frame.levelText = frame.healthBar:CreateFontString(nil, "HIGH", "GameFontNormalSmall")
      frame.levelText:SetPoint("RIGHT", frame.healthBar, "RIGHT", -1, 0)
    end
    frame.unitLevel = UnitEffectiveLevel(frame.unit)
    local c = GetCreatureDifficultyColor(frame.unitLevel)
    frame.levelText:SetTextColor( c.r, c.g, c.b )
    frame.levelText:SetText(frame.unitLevel)

    if RCUIDB.nameplateHideServerNames or RCUIDB.nameplateNameLength > 0 then
      local name, realm = UnitName(frame.displayedUnit) or UNKNOWN

      if not RCUIDB.nameplateHideServerNames and realm then
        name = name.." - "..realm 
      end

      if RCUIDB.nameplateNameLength > 0 then
        name = abbrev(name, RCUIDB.nameplateNameLength)
      end

      frame.name:SetText(name)
    end
  end)
end)
