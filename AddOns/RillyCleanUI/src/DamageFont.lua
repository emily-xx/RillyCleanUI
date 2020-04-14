RillyNiceDamage = CreateFrame("Frame", "RillyNiceDamage")

function RillyNiceDamage:ApplySystemFonts()
  DAMAGE_TEXT_FONT = "Interface\\AddOns\\RillyCleanUI\\fonts\\ZCOOLKuaiLe-Regular.ttf"
end

RillyNiceDamage:RegisterEvent("ADDON_LOADED")

RillyNiceDamage:SetScript("OnEvent", function()
  if (not RCUIDB or RCUIDB.damageFont) then
    RillyNiceDamage:ApplySystemFonts()
  end
end)
