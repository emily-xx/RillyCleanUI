-- Tooltips anchored on mouse
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
	if (InCombatLockdown()) then
    self:SetOwner(parent, "ANCHOR_NONE")
    self:ClearAllPoints()
    self:SetPoint(unpack({"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -200, 220}))
	else
		self:SetOwner(parent, "ANCHOR_CURSOR")
	end
end)

-- local tt = GameTooltip
local ttSBar = GameTooltipStatusBar
local SetSBarColor = ttSBar.SetStatusBarColor

-- Class colours
GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
	local _, unit = tooltip:GetUnit()

	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		local r, g, b = GetClassColor(class)

		local text = GameTooltipTextLeft1:GetText()
		GameTooltipTextLeft1:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, text:match("|cff\x\x\x\x\x\x(.+)|r") or text)
		-- GameTooltipStatusBar:SetStatusBarColor(tooltip, r, g, b)
		-- tt.SetBackdropBorderColor(GameTooltip, color.r, color.g, color.b, 255)
	end
end)

-- ttSBar:HookScript("OnValueChanged", function(self, hp)
-- 		local _, unit = self:GetUnit()
--
-- 		if UnitIsPlayer(unit) then
-- 			local _, class = UnitClass(unit)
-- 			local r, g, b = GetClassColor(class)
--
-- 			self:SetStatusBarColor(r, g, b)
-- 		end
-- end)
