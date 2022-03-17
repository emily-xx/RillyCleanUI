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

      if RCUIDB.nameplateHealthPercent and healthPercentage ~= 100 then
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

  hooksecurefunc("CompactUnitFrame_UpdatePower", function(frame)
    if ( not frame.isNameplate or frame:IsForbidden() ) then return end
    local unit = frame.displayedUnit
    local isPersonal = C_NamePlate.GetNamePlateForUnit(frame.unit) == C_NamePlate.GetNamePlateForUnit("player")

    if ( not isPersonal or not frame.powerBar) then
      if ( frame.powerPercentage ) then
        frame.powerPercentage:SetText('')
      end
      return
    end

    local powerPercentage = ceil((UnitPower(unit) / UnitPowerMax(unit) * 100))
    if ( not frame.powerPercentage ) then
      frame.powerPercentage = frame.powerBar:CreateFontString(nil, "HIGH", "GameFontNormal")
      frame.powerPercentage:SetTextColor( 1, 1, 1 )
      frame.powerPercentage:SetPoint("CENTER", frame.powerBar, "CENTER", 0, 0)
    end

    if (powerPercentage ~= 100) then
      frame.powerPercentage:SetText(powerPercentage .. '%')
    else
      frame.powerPercentage:SetText('')
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

      local healthBar = frame.healthBar
      healthBar.barTexture:SetTexture(RILLY_CLEAN_TEXTURES.statusBar)

      local castBar = frame.castBar
      if (castBar) then
        if RCUIDB.nameplateHideCastText then
          castBar.Text:Hide()
        end

        castBar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)
        castBar.Flash:SetTexture(RILLY_CLEAN_TEXTURES.statusBar)

        if (castBar.rillyClean) then return end

        setDefaultFont(castBar.Text, RCUIDB.nameplateNameFontSize - 1)

        applyRillyCleanBackdrop(castBar.Icon, castBar)

        castBar.rillyClean = true
      end

      if (frame.ClassificationFrame) then
        frame.ClassificationFrame:SetPoint('CENTER', frame.healthBar, 'LEFT', 0, 0)
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

    local hasArenaNumber = false

    if RCUIDB.arenaNumbers and IsActiveBattlefieldArena() and UnitIsPlayer(frame.unit) and UnitIsEnemy(frame.unit) then -- Check to see if unit is a player to avoid needless checks on pets
      for i = 1, 5 do
        if UnitIsUnit(frame.unit, "arena" .. i) then
          frame.name:SetText(i)
          frame.name:SetTextColor(1, 1, 0)
          hasArenaNumber = true
          break
        end
      end
    end

    if RCUIDB.nameplateFriendlyNamesClassColor and UnitIsPlayer(frame.unit) and UnitIsFriend("player", frame.displayedUnit) then
      local _,className = UnitClass(frame.displayedUnit)
      local classR, classG, classB = GetClassColor(className)

      frame.name:SetTextColor(classR, classG, classB, 1)
    end

    if not frame.levelText then
      frame.levelText = frame.healthBar:CreateFontString(nil, "HIGH", "GameFontNormalSmall")
      local isLargeNameplates = tonumber(GetCVar("nameplateVerticalScale")) >= 2.7
      frame.levelText:SetPoint("RIGHT", frame.healthBar, "RIGHT", -1, 0)
    end
    if (RCUIDB.nameplateShowLevel) then
      frame.unitLevel = UnitEffectiveLevel(frame.unit)
      local c = GetCreatureDifficultyColor(frame.unitLevel)
      local unitClassification = UnitClassification(frame.unit)
      if (unitClassification == 'rare' or unitClassification == 'rareelite') then
        c = {
          r = 0.8,
          g = 0.8,
          b = 0.8
        }
      end
      local levelText = frame.unitLevel
      local levelSuffix = ''
      if (levelText < 0) then
        levelText = '??'
      else
        if (unitClassification == 'elite') then
          levelSuffix = '+'
        elseif (unitClassification == 'rareelite') then
          levelSuffix = '*+'
        elseif (unitClassification == 'worldboss') then
          levelSuffix = '++'
        elseif (unitClassification == 'rare') then
          levelSuffix = '*'
        elseif (unitClassification == 'minus') then
          levelSuffix = '-'
        end
      end
      frame.levelText:SetTextColor( c.r, c.g, c.b )
      frame.levelText:SetText(levelText .. levelSuffix)
      frame.levelText:Show()
    elseif (not RCUIDB.nameplateShowLevel) then
      frame.levelText:SetText('')
      frame.levelText:Hide()
    end

    if not hasArenaNumber and (RCUIDB.nameplateHideServerNames or RCUIDB.nameplateNameLength > 0) then
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
