local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)

hooksecurefunc(
    StaticPopupDialogs["DELETE_GOOD_ITEM"],
    "OnShow",
    function(s)
        s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
    end
)

end)
