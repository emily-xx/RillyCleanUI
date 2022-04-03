---------------------
-- COLORING FRAMES --
---------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, addon) -- Darken Raid Panel
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

local f = CreateFrame("Frame") -- Skin raid frames
f:SetScript("OnEvent", function(self, event, ...)
	-- Clean Skins
	local function SkinRaidFrame(prefix)
		local bar = _G[prefix .. "HealthBar"]

		if not bar then return end

		local rbar = _G[prefix .. "PowerBar"]
		local rbarBg = _G[prefix .. "PowerBarBackground"]
		local Divider = _G[prefix .. "HorizDivider"]
		local vleftseparator = _G[prefix .. "VertLeftBorder"]
		local vrightseparator = _G[prefix .. "VertRightBorder"]
		local htopseparator = _G[prefix .. "HorizTopBorder"]
		local hbotseparator = _G[prefix .. "HorizBottomBorder"]
		local healthBackground = _G[prefix .. "HealthBarBackground"]
		local background = _G[prefix .. "Background"]

		--STATUSBAR
		bar:SetStatusBarTexture(TextureDir.."\\raidframe\\Raid-Bar-Hp-Fill")
		rbar:SetStatusBarTexture(TextureDir.."\\raidframe\\Raid-Bar-Resource-Fill")
		rbarBg:SetTexture(TextureDir.."\\raidframe\\Raid-Bar-Resource-Background")
		Divider:SetTexture(TextureDir.."\\raidframe\\Raid-HSeparator")
		vleftseparator:SetTexture(TextureDir.."\\raidframe\\Raid-VSeparator")
		vrightseparator:SetTexture(TextureDir.."\\raidframe\\Raid-VSeparator")
		htopseparator:SetTexture(TextureDir.."\\raidframe\\Raid-HSeparator")
		hbotseparator:SetTexture(TextureDir.."\\raidframe\\Raid-HSeparator")
		healthBackground:SetTexture(nil)
		background:SetTexture(SQUARE_TEXTURE)
		background:SetVertexColor(0.15, 0.15, 0.15, 0.9)

		return bar
	end

	local function SkinBorders(prefix)
		_G[prefix.."BorderFrameBorderTopLeft"]:SetTexture(TextureDir.."\\raidframe\\RaidBorder-UpperLeft")
		_G[prefix.."BorderFrameBorderTop"]:SetTexture(TextureDir.."\\raidframe\\RaidBorder-UpperMiddle")
		_G[prefix.."BorderFrameBorderTopRight"]:SetTexture(TextureDir.."\\raidframe\\RaidBorder-UpperRight")
		_G[prefix.."BorderFrameBorderLeft"]:SetTexture(TextureDir.."\\raidframe\\RaidBorder-Left")
		_G[prefix.."BorderFrameBorderRight"]:SetTexture(TextureDir.."\\raidframe\\RaidBorder-Right")
		_G[prefix.."BorderFrameBorderBottomLeft"]:SetTexture(TextureDir.."\\raidframe\\RaidBorder-BottomLeft")
		_G[prefix.."BorderFrameBorderBottom"]:SetTexture(TextureDir.."\\raidframe\\RaidBorder-BottomMiddle")
		_G[prefix.."BorderFrameBorderBottomRight"]:SetTexture(TextureDir.."\\raidframe\\RaidBorder-BottomRight")
	end

	local function RaidFrameUpdate()
		local g = 1
		local isRaidGroup = _G["CompactRaidGroup1"] ~= nil
		local isParty = _G["CompactPartyFrameMember1"] ~= nil

		if isRaidGroup then
			repeat
				local i, bar = 1
				local group = _G["CompactRaidGroup" .. g]
				repeat
					local prefix = ("CompactRaidGroup" .. g .. "Member" .. i)
					bar = SkinRaidFrame(prefix)
					i = i + 1
				until not bar
				g = g + 1
			until not group
		elseif isParty then
			local i, bar = 1
			repeat
				local prefix = ("CompactPartyFrameMember" .. i)
				bar = SkinRaidFrame(prefix)
				i = i + 1
			until not bar
		end

		-- Always check this because regardless of group settings, main tanks come up as CompactRaidFrameX
		local i, bar = 1
		repeat
			local prefix = ("CompactRaidFrame" .. i)
			bar = SkinRaidFrame(prefix)
			i = i + 1
		until not bar
	end

	if CompactRaidFrameContainer_AddUnitFrame then
		self:UnregisterAllEvents()
		hooksecurefunc("CompactRaidFrameContainer_AddUnitFrame", RaidFrameUpdate)
		hooksecurefunc("CompactUnitFrame_UpdateAll", RaidFrameUpdate)
		SkinBorders("CompactRaidFrameContainer")

		hooksecurefunc("CompactRaidGroup_UpdateUnits", function()
			local g = 1
			repeat
				local group = _G["CompactRaidGroup" .. g]
				if (group) then
					SkinBorders("CompactRaidGroup" .. g)
				end
				g = g + 1
			until not group
		end)

		hooksecurefunc("CompactPartyFrame_Generate", function() SkinBorders("CompactPartyFrame") end)
	end

	--RAID BUFFS
	-- for i = 1, 4 do
	-- 	local f = _G["PartyMemberFrame" .. i]
	-- 	f:UnregisterEvent("UNIT_AURA")
	-- 	local g = CreateFrame("Frame")
	-- 	g:RegisterEvent("UNIT_AURA")
	-- 	g:SetScript(
	-- 		"OnEvent",
	-- 		function(self, event, a1)
	-- 			if a1 == f.unit then
	-- 				RefreshDebuffs(f, a1, 20, nil, 1)
	-- 			else
	-- 				if a1 == f.unit .. "pet" then
	-- 					PartyMemberFrame_RefreshPetDebuffs(f)
	-- 				end
	-- 			end
	-- 		end
	-- 	)
	-- 	local b = _G[f:GetName() .. "Debuff1"]
	-- 	b:ClearAllPoints()
	-- 	b:SetPoint("LEFT", f, "RIGHT", -7, 5)
	-- 	for j = 5, 20 do
	-- 		local l = f:GetName() .. "Debuff"
	-- 		local n = l .. j
	-- 		local c = CreateFrame("Frame", n, f, "PartyDebuffFrameTemplate")
	-- 		c:SetPoint("LEFT", _G[l .. (j - 1)], "RIGHT")
	-- 	end
	-- end

	-- for i = 1, 4 do
	-- 	local f = _G["PartyMemberFrame" .. i]
	-- 	f:UnregisterEvent("UNIT_AURA")
	-- 	local g = CreateFrame("Frame")
	-- 	g:RegisterEvent("UNIT_AURA")
	-- 	g:SetScript(
	-- 		"OnEvent",
	-- 		function(self, event, a1)
	-- 			if a1 == f.unit then
	-- 				RefreshBuffs(f, a1, 20, nil, 1)
	-- 			end
	-- 		end
	-- 	)
	-- 	for j = 1, 20 do
	-- 		local l = f:GetName() .. "Buff"
	-- 		local n = l .. j
	-- 		local c = CreateFrame("Frame", n, f, "TargetBuffFrameTemplate")
	-- 		c:EnableMouse(false)
	-- 		if j == 1 then
	-- 			c:SetPoint("TOPLEFT", 48, -32)
	-- 		else
	-- 			c:SetPoint("LEFT", _G[l .. (j - 1)], "RIGHT", 1, 0)
	-- 		end
	-- 	end
	-- end
end)

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
