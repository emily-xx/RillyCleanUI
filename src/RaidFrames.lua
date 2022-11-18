---------------------
-- COLORING FRAMES --
---------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event) -- Darken Raid Panel
		for _, region in pairs({CompactRaidFrameManager:GetRegions()}) do
			if region:IsObjectType("Texture") then
				region:SetVertexColor(0, 0, 0)
			end
		end

  	self:UnregisterEvent("PLAYER_LOGIN")
  	frame:SetScript("OnEvent", nil)
end)

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
	local roleIcon = _G[prefix .. "RoleIcon"]

	--STATUSBAR
	bar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)
	rbar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)
	rbarBg:SetTexture(TextureDir.."\\raidframe\\Raid-Bar-Resource-Background")
	healthBackground:SetVertexColor(0, 0, 0, 0)
	background:SetTexture(SQUARE_TEXTURE)
	background:SetVertexColor(0.15, 0.15, 0.15, 0.9)
	roleIcon:SetTexture(RILLY_CLEAN_TEXTURES.lfg.portraitRoles)
	roleIcon:SetDrawLayer("OVERLAY")

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

  local isRaidGroup = UnitInRaid("player") and not CompactRaidFrameContainer:UseCombinedGroups()

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

local f = CreateFrame("Frame") -- Skin raid frames
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, ...)
	if CompactRaidFrameContainer.AddUnitFrame then
		self:UnregisterAllEvents()

    local setTexture = CreateFrame("Frame")
		setTexture:RegisterEvent("ADDON_LOADED")
		setTexture:RegisterEvent("PLAYER_LOGIN")
		setTexture:RegisterEvent("VARIABLES_LOADED")
		setTexture:RegisterEvent("PLAYER_ENTERING_WORLD")
		setTexture:RegisterEvent("GROUP_ROSTER_UPDATE")
		setTexture:RegisterEvent("PLAYER_REGEN_ENABLED")
		setTexture:RegisterEvent("COMPACT_UNIT_FRAME_PROFILES_LOADED")
		setTexture:RegisterEvent("UPDATE_EXPANSION_LEVEL")
		setTexture:RegisterEvent("ARTIFACT_XP_UPDATE")
		setTexture:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
		setTexture:RegisterUnitEvent("UNIT_LEVEL", "player")
		setTexture:SetScript("OnEvent", RaidFrameUpdate)

    hooksecurefunc(C_EditMode, "OnEditModeExit", RaidFrameUpdate)
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
