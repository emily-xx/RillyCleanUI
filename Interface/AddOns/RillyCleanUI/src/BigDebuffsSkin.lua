RillyCleanBigDebuffs = CreateFrame("Frame", "RillyCleanBigDebuffs")
RillyCleanBigDebuffs:RegisterEvent("PLAYER_LOGIN")

RillyCleanBigDebuffs:SetScript("OnEvent", function()
  if (IsAddOnLoaded('BigDebuffs')) then
    hooksecurefunc(BigDebuffs, 'NAME_PLATE_UNIT_ADDED', function(self, _, unit)
      local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
      if (namePlate:IsForbidden()) then return end

      local bdbFrame = namePlate.UnitFrame
      local bdbNameplate = bdbFrame.BigDebuffs

      if (bdbNameplate) then
        applyRillyCleanButtonSkin(bdbNameplate)
      end
    end)
  end
