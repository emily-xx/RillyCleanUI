local hiddenElements = {
	-- Micro buttons
	MicroButtonAndBagsBar,
	MicroButton,
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	GuildMicroButton,
	LFDMicroButton,
	CollectionsMicroButton,
	EJMicroButton,
	MainMenuMicroButton,
	-- Action Bars
	MainMenuBarArtFrameBackground,
	ActionBarUpButton,
	ActionBarDownButton,
	MainMenuBarArtFrame.PageNumber,
	MainMenuBarArtFrame.LeftEndCap,
	MainMenuBarArtFrame.RightEndCap
}

for _, hiddenElement in pairs(hiddenElements) do
	elementToHide = _G[hiddenElement]
	hiddenElement:Hide()
end

-- Function to hide the talking frame
local function NoTalkingHeads()
	hooksecurefunc(TalkingHeadFrame, "Show", function(self)
		self:Hide()
	end)
end

-- Run function when Blizzard addon is loaded
if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
	NoTalkingHeads()
else
	local waitFrame = CreateFrame("FRAME")
	waitFrame:RegisterEvent("ADDON_LOADED")
	waitFrame:SetScript("OnEvent", function(self, event, arg1)
		if arg1 == "Blizzard_TalkingHeadUI" then
			NoTalkingHeads()
			waitFrame:UnregisterAllEvents()
		end
	end)
end

-- Clean up XP Bar/Azerite Bar appearance
local statusBars = {
	"SingleBarLargeUpper",
	"SingleBarLarge",
	"SingleBarSmall",
	"SingleBarSmallUpper"
}

for _, statusBar in pairs(statusBars) do
	_G["StatusTrackingBarManager"][statusBar]:SetAlpha(0)
end

-- Remove obtrusive artwork from Stance bar when only bottom bar enabled
SlidingActionBarTexture0:SetAlpha(0)
SlidingActionBarTexture1:SetAlpha(0)

-- Fix issue with Blizzard trying to call this
if not AchievementMicroButton_Update then
    AchievementMicroButton_Update = function() end
end

-- Store button needs moved off screen as it does not have Hide() for some reason.
StoreMicroButton:SetPoint("TOPLEFT",-250,-50000)

-------------------
-- Skinning Code --
-------------------

-- Color out of range red
local CF=CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")
CF:SetScript("OnEvent", function(self, event)
	hooksecurefunc(
	    "ActionButton_OnEvent",
	    function(self, event, ...)
	        if (event == "PLAYER_TARGET_CHANGED") then
	            self.newTimer = self.rangeTimer
	        end
	    end
	)
	hooksecurefunc(
	    "ActionButton_UpdateUsable",
	    function(self)
	        local icon = _G[self:GetName() .. "Icon"]
	        local valid = IsActionInRange(self.action)
	        if (valid == false) then
	            icon:SetVertexColor(1, 0.2, 0.1)
	        end
	    end
	)
	hooksecurefunc(
	    "ActionButton_OnUpdate",
	    function(self, elapsed)
	        local rangeTimer = self.newTimer
	        if (rangeTimer) then
	            rangeTimer = rangeTimer - elapsed
	            if (rangeTimer <= 0) then
	                ActionButton_UpdateUsable(self)
	                rangeTimer = TOOLTIP_UPDATE_TIME
	            end
	            self.newTimer = rangeTimer
	        end
	    end
	)
end)

local addon, ns = ...
local dominos = IsAddOnLoaded("Dominos")
local bartender4 = IsAddOnLoaded("Bartender4")

--backdrop settings
local bgfile, edgefile = "", ""

--backdrop
local backdropcolor = {0,0,0,1}

local backdrop = {
  bgFile = "Interface\\BUTTONS\\WHITE8X8",
  edgeFile = "Interface\\BUTTONS\\WHITE8X8",
  tile = false,
  tileSize = 32,
  edgeSize = 1,
  insets = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
  }
}

---------------------------------------
-- FUNCTIONS
---------------------------------------

if IsAddOnLoaded("Masque") and (dominos or bartender4) then
  return
end

local function applyBackground(bu, isLeaveButton)
  if not bu or (bu and bu.bg) then
    return
  end

  --shadows+background
  if bu:GetFrameLevel() < 1 then
    bu:SetFrameLevel(1)
  end

  bu.bg = CreateFrame("Frame", nil, bu)
  -- bu.bg:SetAllPoints(bu)
  bu.bg:SetPoint("TOPLEFT", bu, "TOPLEFT", 0, 0)
  bu.bg:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 0, 0)
  bu.bg:SetFrameLevel(bu:GetFrameLevel() - 1)

  bu.bg:SetBackdrop(backdrop)
  bu.bg:SetBackdropColor(backdropcolor)

  bu.bg:SetBackdropBorderColor(0, 0, 0, 1)

	-- Remove the normaltexture
	local nt = bu:GetNormalTexture()
	if not isLeaveButton then
		nt:SetAlpha(0)

		hooksecurefunc(
	    bu,
	    "SetNormalTexture",
	    function(self, texture)
	      --make sure the normaltexture stays the way we want it
				nt:SetAlpha(0)
	    end
	  )
	else
    nt:SetTexCoord(0.2, 0.8, 0.2, 0.8)
    nt:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
    nt:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	end
end

--style extraactionbutton
local function styleExtraActionButton(bu)
  if not bu or (bu and bu.rabs_styled) then
    return
  end
  local name = bu:GetName() or bu:GetParent():GetName()
  local style = bu.style or bu.Style
  local icon = bu.icon or bu.Icon
  local cooldown = bu.cooldown or bu.Cooldown
  local ho = _G[name .. "HotKey"]

  -- remove the style background theme
  style:SetTexture(nil)
  hooksecurefunc(
    style,
    "SetTexture",
    function(self, texture)
      if texture then
        self:SetTexture(nil)
      end
    end
  )

  --icon
  icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  icon:SetAllPoints(bu)
  icon:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
  icon:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)

  --cooldown
  cooldown:SetAllPoints(icon)

  --hotkey
  if ho then
    ho:Hide()
  end

  --apply background
  if not bu.bg then applyBackground(bu) end
end

--initial style func
local function styleActionButton(bu)
  if not bu or (bu and bu.rabs_styled) then
    return
  end
  local action = bu.action
  local name = bu:GetName()
  local ic = _G[name .. "Icon"]
  local co = _G[name .. "Count"]
  local bo = _G[name .. "Border"]
  local ho = _G[name .. "HotKey"]
  local cd = _G[name .. "Cooldown"]
  local na = _G[name .. "Name"]
  local fl = _G[name .. "Flash"]
  local nt = _G[name .. "NormalTexture"]
  local fbg = _G[name .. "FloatingBG"]
  local fob = _G[name .. "FlyoutBorder"]
  local fobs = _G[name .. "FlyoutBorderShadow"]


  if fbg then
    fbg:Hide()
  end --floating background
  --flyout border stuff
  if fob then
    fob:SetTexture(nil)
  end
  if fobs then
    fobs:SetTexture(nil)
  end

  bo:SetTexture(nil) --hide the border (plain ugly, sry blizz)

  --hotkey
  ho:ClearAllPoints()
  ho:SetPoint("TOP", bu, 0, 0)
  ho:SetPoint("TOP", bu, 0, 0)
  ho:Hide()

  --macro name
  na:Hide()

  if not nt then
    --fix the non existent texture problem (no clue what is causing this)
    nt = bu:GetNormalTexture()
  end
  --cut the default border of the icons
  ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
  ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
  --adjust the cooldown frame
  cd:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
  cd:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)

  --make the normaltexture match the buttonsize
  nt:SetAllPoints(bu)
	nt:SetAlpha(0)

  --hook to prevent Blizzard from reseting our colors
	hooksecurefunc(
      nt,
      "SetVertexColor",
      function(nt, r, g, b, a)
        if nt then nt:SetAlpha(0) end
      end
    )

  --shadows+background
  if not bu.bg then
    applyBackground(bu)
  end
  bu.rabs_styled = true

  if bartender4 then --fix the normaltexture
    nt:SetTexCoord(0, 1, 0, 1)
    nt.SetTexCoord = function()
      return
    end
    bu.SetNormalTexture = function()
      return
    end
  end
end

-- style leave button
local function styleLeaveButton(bu)
  if not bu or (bu and bu.rabs_styled) then
    return
  end
  --local region = select(1, bu:GetRegions())
  local name = bu:GetName()
  -- local bo = bu:CreateTexture(name .. "Border", "BACKGROUND", nil, -7)
	--
  -- bo:SetTexCoord(0, 1, 0, 1)
  -- bo:SetDrawLayer("BACKGROUND", -7)
  -- bo:SetVertexColor(0.4, 0.35, 0.35)
  -- bo:ClearAllPoints()
  -- bo:SetAllPoints(bu)

  --shadows+background
  if not bu.bg then
    applyBackground(bu, true)
  end

  bu.rabs_styled = true
end

--style pet buttons
local function stylePetButton(bu)
  if not bu or (bu and bu.rabs_styled) then
    return
  end
  local name = bu:GetName()
  local ic = _G[name .. "Icon"]
  local fl = _G[name .. "Flash"]
  local nt = _G[name .. "NormalTexture2"]
	local cd = _G[name .. "Cooldown"]
  nt:SetAllPoints(bu)

  --cut the default border of the icons and make them shiny
	--cut the default border of the icons and make them shiny
	ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
	ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	--adjust the cooldown frame
	cd:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
	cd:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)

  --shadows+background
  if not bu.bg then
    applyBackground(bu)
  end
  bu.rabs_styled = true
end

--style stance buttons
local function styleStanceButton(bu)
  if not bu or (bu and bu.rabs_styled) then
    return
  end
  local name = bu:GetName()
  local ic = _G[name .. "Icon"]
  local fl = _G[name .. "Flash"]
  local nt = _G[name .. "NormalTexture2"]
  nt:SetAllPoints(bu)

  --shadows+background
  if not bu.bg then
    applyBackground(bu)
  end
  bu.rabs_styled = true
end

--style possess buttons
local function stylePossessButton(bu)
  if not bu or (bu and bu.rabs_styled) then
    return
  end
  local name = bu:GetName()
  local ic = _G[name .. "Icon"]
  local fl = _G[name .. "Flash"]
  local nt = _G[name .. "NormalTexture"]
  nt:SetAllPoints(bu)
  --cut the default border of the icons and make them shiny
  ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
  ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
  --shadows+background
  if not bu.bg then
    applyBackground(bu)
  end
  bu.rabs_styled = true
end

--update hotkey func
local function updateHotkey(self, actionButtonType)
  local ho = _G[self:GetName() .. "HotKey"]
  if ho and ho:IsShown() then
    ho:Hide()
  end
end

local function init()
  --style the actionbar buttons
  for i = 1, NUM_ACTIONBAR_BUTTONS do
    styleActionButton(_G["ActionButton" .. i])
    styleActionButton(_G["MultiBarBottomLeftButton" .. i])
    styleActionButton(_G["MultiBarBottomRightButton" .. i])
    styleActionButton(_G["MultiBarRightButton" .. i])
    styleActionButton(_G["MultiBarLeftButton" .. i])
  end

  for i = 1, 6 do
    styleActionButton(_G["OverrideActionBarButton" .. i])
  end
  --style leave button
  styleLeaveButton(MainMenuBarVehicleLeaveButton)
  styleLeaveButton(rABS_LeaveVehicleButton)
  --petbar buttons
  for i = 1, NUM_PET_ACTION_SLOTS do
    stylePetButton(_G["PetActionButton" .. i])
  end
  --stancebar buttons
  for i = 1, NUM_STANCE_SLOTS do
    styleStanceButton(_G["StanceButton" .. i])
  end
  --possess buttons
  for i = 1, NUM_POSSESS_SLOTS do
    stylePossessButton(_G["PossessButton" .. i])
  end

  --hide stancebarbackground
  StanceBarLeft:SetPoint("BOTTOMLEFT", "StanceBarFrame", "BOTTOMLEFT", 0,-2)
  StanceButton1:SetPoint("BOTTOMLEFT", "StanceBarFrame", "BOTTOMLEFT", 11,2)

  --extraactionbutton1
  styleExtraActionButton(ExtraActionButton1)
  styleExtraActionButton(ZoneAbilityFrame.SpellButton)
  --spell flyout
  SpellFlyoutBackgroundEnd:SetTexture(nil)
  SpellFlyoutHorizontalBackground:SetTexture(nil)
  SpellFlyoutVerticalBackground:SetTexture(nil)
  local function checkForFlyoutButtons(self)
    local NUM_FLYOUT_BUTTONS = 10
    for i = 1, NUM_FLYOUT_BUTTONS do
      styleActionButton(_G["SpellFlyoutButton" .. i])
    end
  end
  SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)

  --dominos styling
  if dominos then
    --print("Dominos found")
    for i = 1, 60 do
      styleActionButton(_G["DominosActionButton" .. i])
    end
  end
  --bartender4 styling
  if bartender4 then
    --print("Bartender4 found")
    for i = 1, 120 do
      styleActionButton(_G["BT4Button" .. i])
      stylePetButton(_G["BT4PetButton" .. i])
    end
  end

  --hide the hotkeys if needed
  if not dominos and not bartender4 then
    hooksecurefunc("ActionButton_UpdateHotkeys", updateHotkey)
  end
end

local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", init)
