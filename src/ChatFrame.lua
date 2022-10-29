function init()
  QuickJoinToastButton:Hide()
  ChatFrame1ButtonFrame:Hide()
end

local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", init)
