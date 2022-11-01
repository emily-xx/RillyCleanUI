RillyCleanBigDebuffs = CreateFrame("Frame", "RillyCleanBigDebuffs")
RillyCleanBigDebuffs:RegisterEvent("PLAYER_LOGIN")

RillyCleanBigDebuffs:SetScript("OnEvent", function()
  if ( not IsAddOnLoaded('BigDebuffs') ) then return end

  -- Unit portraits
  -- hooksecurefunc(BigDebuffs, 'AttachUnitFrame', function(self, unit)
  --   local frameName = 'BigDebuffs' .. unit .. "UnitFrame"
  --   local bdbFrame = _G[frameName]

  --   local icon = bdbFrame.icon

  --   if (icon) then
  --     local cooldown = bdbFrame.cooldown or bdbFrame.Cooldown
  --     icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  --     cooldown:SetAllPoints(icon)
  --     cooldown:SetSwipeTexture(SQUARE_TEXTURE)
  --   end
  -- end)

  -- Nameplates
  hooksecurefunc(BigDebuffs, 'NAME_PLATE_UNIT_ADDED', function(self, _, unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if (namePlate:IsForbidden()) then return end

    local bdbFrame = namePlate.UnitFrame
    local bdbNameplate = bdbFrame.BigDebuffs

    if (bdbNameplate) then
      applyRillyCleanBackdrop(bdbNameplate)
    end
  end)
end)
