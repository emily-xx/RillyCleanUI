RillyNiceDamage = CreateFrame("Frame", "RillyNiceDamage")

local damagefont_FONT_NUMBER = "Interface\\AddOns\\RillyCleanUI\\fonts\\ZCOOLKuaiLe-Regular.ttf"

function RillyNiceDamage:ApplySystemFonts()
	DAMAGE_TEXT_FONT = damagefont_FONT_NUMBER
end

RillyNiceDamage:RegisterEvent("PLAYER_LOGIN")

RillyNiceDamage:SetScript("OnEvent", function()
	if (RCUIDB.damageFont) then
		RillyNiceDamage:ApplySystemFonts()
	end
end)
