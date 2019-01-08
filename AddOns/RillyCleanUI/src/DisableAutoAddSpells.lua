if not RCConfig.disableAutoAddSpells then return end

-- This prevents icons from being animated onto the main action bar
IconIntroTracker.RegisterEvent = function() end
IconIntroTracker:UnregisterEvent('SPELL_PUSHED_TO_ACTIONBAR')

-- In the unlikely event that you're looking at a different action page while switching talents
-- the spell is automatically added to your main bar. This takes it back off.
local f = CreateFrame('frame')
f:SetScript('OnEvent', function(self, event, spellID, slotIndex, slotPos)
	-- This event should never fire in combat, but check anyway
	if not InCombatLockdown() then
		ClearCursor()
		PickupAction(slotIndex)
		ClearCursor()
	end
end)
f:RegisterEvent('SPELL_PUSHED_TO_ACTIONBAR')
