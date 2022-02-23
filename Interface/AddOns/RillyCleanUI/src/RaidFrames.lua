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
-- TODO - Work out bugs here
-- local f = CreateFrame("Frame")
-- f:SetScript("OnEvent", function(self, event, ...)
-- 	-- HIDE RAIDFRAMERESIZE
-- 	local n, w, h = "CompactUnitFrameProfilesGeneralOptionsFrame"
-- 	h, w = _G[n .. "HeightSlider"], _G[n .. "WidthSlider"]
-- 	h:SetMinMaxValues(1, 200)
-- 	w:SetMinMaxValues(1, 200)

-- 	-- Clean Skins
-- 	local function SkinRaidFrame(prefix)
-- 		bar = _G[prefix .. "HealthBar"]
-- 		rbar = _G[prefix .. "PowerBar"]
-- 		Divider = _G[prefix .. "HorizDivider"]
-- 		vleftseparator = _G[prefix .. "VertLeftBorder"]
-- 		vrightseparator = _G[prefix .. "VertRightBorder"]
-- 		htopseparator = _G[prefix .. "HorizTopBorder"]
-- 		hbotseparator = _G[prefix .. "HorizBottomBorder"]
-- 		local roleIcon = _G[prefix .. "RoleIcon"]
-- 		if bar then
-- 			--STATUSBAR
-- 			bar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)
-- 			rbar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)

-- 			vleftseparator:SetTexture(TextureDir.."\\raidframe\\Raid-VSeparator")
-- 			vrightseparator:SetTexture(TextureDir.."\\raidframe\\Raid-VSeparator")
-- 			htopseparator:SetTexture(TextureDir.."\\raidframe\\Raid-HSeparator")
-- 			hbotseparator:SetTexture(TextureDir.."\\raidframe\\Raid-HSeparator")
-- 			roleIcon:SetTexture(RILLY_CLEAN_TEXTURES.lfg.portraitRoles)
-- 		end

-- 		return bar
-- 	end

-- 	local function RaidGroupsUpdate()
-- 		local g = 1
-- 		local party = _G["CompactPartyFrameMember1"]
-- 		if party ~= nil then
-- 			local i, bar = 1
-- 			repeat
-- 				local prefix = ("CompactPartyFrameMember" .. i)
-- 				bar = SkinRaidFrame(prefix)
-- 				i = i + 1
-- 			until not bar
-- 		else
-- 			repeat
-- 				local i, bar = 1
-- 				local group = _G["CompactRaidGroup" .. g]
-- 				repeat
-- 					local prefix = ("CompactRaidGroup" .. g .. "Member" .. i)
-- 					bar = SkinRaidFrame(prefix)
-- 					i = i + 1
-- 				until not bar
-- 				g = g + 1
-- 			until not group
-- 		end
-- 	end

-- 	local function RaidFrameUpdate()
-- 		local i, bar = 1
-- 		repeat
-- 			local prefix = ("CompactRaidFrame" .. i)
-- 			bar = SkinRaidFrame(prefix)
-- 			i = i + 1
-- 		until not bar
-- 	end

-- 	if CompactRaidFrameContainer_AddUnitFrame then
-- 		self:UnregisterAllEvents()
-- 		hooksecurefunc("CompactRaidFrameContainer_AddUnitFrame", RaidFrameUpdate)
-- 		hooksecurefunc("CompactUnitFrame_UpdateAll", RaidGroupsUpdate)
-- 		CompactRaidFrameContainerBorderFrameBorderTopLeft:SetTexture(TextureDir.."\\raidframe\\RaidBorder-UpperLeft")
-- 		CompactRaidFrameContainerBorderFrameBorderTop:SetTexture(TextureDir.."\\raidframe\\RaidBorder-UpperMiddle")
-- 		CompactRaidFrameContainerBorderFrameBorderTopRight:SetTexture(TextureDir.."\\raidframe\\RaidBorder-UpperRight")
-- 		CompactRaidFrameContainerBorderFrameBorderLeft:SetTexture(TextureDir.."\\raidframe\\RaidBorder-Left")
-- 		CompactRaidFrameContainerBorderFrameBorderRight:SetTexture(TextureDir.."\\raidframe\\RaidBorder-Right")
-- 		CompactRaidFrameContainerBorderFrameBorderBottomLeft:SetTexture(TextureDir.."\\raidframe\\RaidBorder-BottomLeft")
-- 		CompactRaidFrameContainerBorderFrameBorderBottom:SetTexture(TextureDir.."\\raidframe\\RaidBorder-BottomMiddle")
-- 		CompactRaidFrameContainerBorderFrameBorderBottomRight:SetTexture(TextureDir.."\\raidframe\\RaidBorder-BottomRight")
-- 	end

-- 	--RAID BUFFS
-- 	for i = 1, 4 do
-- 		local f = _G["PartyMemberFrame" .. i]
-- 		f:UnregisterEvent("UNIT_AURA")
-- 		local g = CreateFrame("Frame")
-- 		g:RegisterEvent("UNIT_AURA")
-- 		g:SetScript(
-- 			"OnEvent",
-- 			function(self, event, a1)
-- 				if a1 == f.unit then
-- 					RefreshDebuffs(f, a1, 20, nil, 1)
-- 				else
-- 					if a1 == f.unit .. "pet" then
-- 						PartyMemberFrame_RefreshPetDebuffs(f)
-- 					end
-- 				end
-- 			end
-- 		)
-- 		local b = _G[f:GetName() .. "Debuff1"]
-- 		b:ClearAllPoints()
-- 		b:SetPoint("LEFT", f, "RIGHT", -7, 5)
-- 		for j = 5, 20 do
-- 			local l = f:GetName() .. "Debuff"
-- 			local n = l .. j
-- 			local c = CreateFrame("Frame", n, f, "PartyDebuffFrameTemplate")
-- 			c:SetPoint("LEFT", _G[l .. (j - 1)], "RIGHT")
-- 		end
-- 	end

-- 	for i = 1, 4 do
-- 		local f = _G["PartyMemberFrame" .. i]
-- 		f:UnregisterEvent("UNIT_AURA")
-- 		local g = CreateFrame("Frame")
-- 		g:RegisterEvent("UNIT_AURA")
-- 		g:SetScript(
-- 			"OnEvent",
-- 			function(self, event, a1)
-- 				if a1 == f.unit then
-- 					RefreshBuffs(f, a1, 20, nil, 1)
-- 				end
-- 			end
-- 		)
-- 		for j = 1, 20 do
-- 			local l = f:GetName() .. "Buff"
-- 			local n = l .. j
-- 			local c = CreateFrame("Frame", n, f, "TargetBuffFrameTemplate")
-- 			c:EnableMouse(false)
-- 			if j == 1 then
-- 				c:SetPoint("TOPLEFT", 48, -32)
-- 			else
-- 				c:SetPoint("LEFT", _G[l .. (j - 1)], "RIGHT", 1, 0)
-- 			end
-- 		end
-- 	end
-- end)

-- f:RegisterEvent("PLAYER_LOGIN")
-- f:RegisterEvent("ADDON_LOADED")
