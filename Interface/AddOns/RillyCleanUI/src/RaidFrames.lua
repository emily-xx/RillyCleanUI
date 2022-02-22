local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
	-- HIDE RAIDFRAMERESIZE
	local n, w, h = "CompactUnitFrameProfilesGeneralOptionsFrame"
	h, w = _G[n .. "HeightSlider"], _G[n .. "WidthSlider"]
	h:SetMinMaxValues(1, 200)
	w:SetMinMaxValues(1, 200)

	--BLACK SKIN
	local function RaidFrameUpdate()
		local i, bar = 1
		repeat
			bar = _G["CompactRaidFrame" .. i .. "HealthBar"]
			rbar = _G["CompactRaidFrame" .. i .. "PowerBar"]
			Divider = _G["CompactRaidFrame" .. i .. "HorizDivider"]
			vleftseparator = _G["CompactRaidFrame" .. i .. "VertLeftBorder"]
			vrightseparator = _G["CompactRaidFrame" .. i .. "VertRightBorder"]
			htopseparator = _G["CompactRaidFrame" .. i .. "HorizTopBorder"]
			hbotseparator = _G["CompactRaidFrame" .. i .. "HorizBottomBorder"]
			if bar then
				--STATUSBAR
				bar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)
				rbar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)
				--DARK
				vleftseparator:SetTexture(TextureDir.."\\raidframe\\Raid-VSeparator")
				vrightseparator:SetTexture(TextureDir.."\\raidframe\\Raid-VSeparator")
				htopseparator:SetTexture(TextureDir.."\\raidframe\\Raid-HSeparator")
				hbotseparator:SetTexture(TextureDir.."\\raidframe\\Raid-HSeparator")
			end
			i = i + 1
		until not bar
	end

	if CompactRaidFrameContainer_AddUnitFrame then
		self:UnregisterAllEvents()
		hooksecurefunc("CompactRaidFrameContainer_AddUnitFrame", RaidFrameUpdate)
		--hooksecurefunc("CompactUnitFrame_UpdateAll", RaidFrameUpdate)
		CompactRaidFrameContainerBorderFrameBorderTopLeft:SetTexture(TextureDir.."\\raidframe\\RaidBorder-UpperLeft")
		CompactRaidFrameContainerBorderFrameBorderTop:SetTexture(TextureDir.."\\raidframe\\RaidBorder-UpperMiddle")
		CompactRaidFrameContainerBorderFrameBorderTopRight:SetTexture(TextureDir.."\\raidframe\\RaidBorder-UpperRight")
		CompactRaidFrameContainerBorderFrameBorderLeft:SetTexture(TextureDir.."\\raidframe\\RaidBorder-Left")
		CompactRaidFrameContainerBorderFrameBorderRight:SetTexture(TextureDir.."\\raidframe\\RaidBorder-Right")
		CompactRaidFrameContainerBorderFrameBorderBottomLeft:SetTexture(TextureDir.."\\raidframe\\RaidBorder-BottomLeft")
		CompactRaidFrameContainerBorderFrameBorderBottom:SetTexture(TextureDir.."\\raidframe\\RaidBorder-BottomMiddle")
		CompactRaidFrameContainerBorderFrameBorderBottomRight:SetTexture(TextureDir.."\\raidframe\\RaidBorder-BottomRight")
	end

	--RAID BUFFS
	for i = 1, 4 do
		local f = _G["PartyMemberFrame" .. i]
		f:UnregisterEvent("UNIT_AURA")
		local g = CreateFrame("Frame")
		g:RegisterEvent("UNIT_AURA")
		g:SetScript(
			"OnEvent",
			function(self, event, a1)
				if a1 == f.unit then
					RefreshDebuffs(f, a1, 20, nil, 1)
				else
					if a1 == f.unit .. "pet" then
						PartyMemberFrame_RefreshPetDebuffs(f)
					end
				end
			end
		)
		local b = _G[f:GetName() .. "Debuff1"]
		b:ClearAllPoints()
		b:SetPoint("LEFT", f, "RIGHT", -7, 5)
		for j = 5, 20 do
			local l = f:GetName() .. "Debuff"
			local n = l .. j
			local c = CreateFrame("Frame", n, f, "PartyDebuffFrameTemplate")
			c:SetPoint("LEFT", _G[l .. (j - 1)], "RIGHT")
		end
	end

	for i = 1, 4 do
		local f = _G["PartyMemberFrame" .. i]
		f:UnregisterEvent("UNIT_AURA")
		local g = CreateFrame("Frame")
		g:RegisterEvent("UNIT_AURA")
		g:SetScript(
			"OnEvent",
			function(self, event, a1)
				if a1 == f.unit then
					RefreshBuffs(f, a1, 20, nil, 1)
				end
			end
		)
		for j = 1, 20 do
			local l = f:GetName() .. "Buff"
			local n = l .. j
			local c = CreateFrame("Frame", n, f, "TargetBuffFrameTemplate")
			c:EnableMouse(false)
			if j == 1 then
				c:SetPoint("TOPLEFT", 48, -32)
			else
				c:SetPoint("LEFT", _G[l .. (j - 1)], "RIGHT", 1, 0)
			end
		end
	end
end)

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
