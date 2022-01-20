---------------------
-- COLORING FRAMES --
---------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, addon)
		for _, region in pairs({CompactRaidFrameManager:GetRegions()}) do
			if region:IsObjectType("Texture") then
				region:SetVertexColor(0, 0, 0)
			end
		end

		for _, region in pairs({CompactRaidFrameManagerContainerResizeFrame:GetRegions()}) do
			if region:GetName():find("Border") then
				region:SetVertexColor(0, 0, 0)
			end
		end

  	self:UnregisterEvent("ADDON_LOADED")
  	frame:SetScript("OnEvent", nil)
end)
