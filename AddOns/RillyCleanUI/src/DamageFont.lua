if RCConfig.damageFont then
	RillyNiceDamage = CreateFrame("Frame", "RillyNiceDamage")

	local damagefont_FONT_NUMBER = "Interface\\AddOns\\RillyCleanUI\\fonts\\ZCOOLKuaiLe-Regular.ttf"

	function RillyNiceDamage:ApplySystemFonts()
		DAMAGE_TEXT_FONT = damagefont_FONT_NUMBER
	end

	RillyNiceDamage:SetScript("OnEvent", function()
		if (event == "ADDON_LOADED") then
			RillyNiceDamage:ApplySystemFonts()
		end
	end);

	RillyNiceDamage:RegisterEvent("ADDON_LOADED")
	RillyNiceDamage:ApplySystemFonts()
end
