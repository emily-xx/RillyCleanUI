-- Code via LazyKeystones - https://www.curseforge.com/wow/addons/lazy-keystones by thejustinist

local InsertKeystone = function(self)
	for bag = 0, NUM_BAG_SLOTS do
         for bagSlot = 1, GetContainerNumSlots(bag) do
            local _,_,_,_,_,_,itemName = GetContainerItemInfo(bag, bagSlot);
            if itemName  ~= nil and string.match(itemName, "Keystone") then
               if (ChallengesKeystoneFrame:IsShown()) then
                  PickupContainerItem(bag, bagSlot);
                  if (CursorHasItem()) then
                     C_ChallengeMode.SlotKeystone();
                  end
               end
            end
         end
      end
end

local frame = CreateFrame("Frame", "RillyCleanUI", UIParent);
frame:RegisterEvent("ADDON_LOADED");

frame:SetScript("OnEvent", function(self, event, addonName, ...)
    if event == "ADDON_LOADED" and addonName == "Blizzard_ChallengesUI" then
		ChallengesKeystoneFrame:HookScript("OnShow", InsertKeystone);
        frame:UnregisterEvent("ADDON_LOADED");
        return;
	end
end);
