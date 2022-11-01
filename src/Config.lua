-- This table defines the addon's default settings:
local name, RCUI = ...
RCUIDBDefaults = {
  actionBarOffset = 40,
  disableAutoAddSpells = true, -- Whether or not to disable the automatic addition of spells to bars when changing talents and etc
  castbarOffset = 170,
  hideHotkeys = true,
  hideMacroText = true,
  hideMicroButtonsAndBags = true,
  hideStanceBar = false,
  hideTalkingHeads = true,
  arenaNumbers = false,

  hideAltPower = false,
  lootSpecDisplay = true, -- Display loot spec icon in the player frame
  showItemLevels = true,
  afkScreen = true,

  damageFont = true, -- Change damage font to something cooler
  customFonts = true, -- Update all fonts to something cooler
  font = RILLY_CLEAN_FONTS.Andika,

  tooltipAnchor = "ANCHOR_CURSOR_LEFT",

  -- Nameplate Settings
  modNamePlates = true,
  nameplateNameFontSize = 9,
  nameplateHideServerNames = true,
  nameplateNameLength = 20,
  nameplateFriendlyNamesClassColor = true,
  nameplateFriendlySmall = true,
  nameplateHideCastText = false,
  nameplateShowLevel = true,
  nameplateCastFontSize = 6,
  nameplateHealthPercent = true,
  nameplateShowCastTime = true,

  portraitStyle = "3D", -- 3D, 2D, or class (for class icons)
  hideMinimapZoneText = false, -- True = hide zone text, False = show zone text

  -- PvP Settings
  safeQueue = true,
  tabBinder = true,
  dampeningDisplay = true,

  -- Quest Tracker
  objectivesTextOutline = true,
  objectivesHideHeaders = true,
}

local function rcui_defaults()
  -- This function copies values from one table into another:
  local function copyDefaults(src, dst)
    -- If no source (defaults) is specified, return an empty table:
    if type(src) ~= "table" then return {} end
    -- If no target (saved variable) is specified, create a new table:
    if type(dst) ~= "table" then dst = {} end
    -- Loop through the source (defaults):
    for k, v in pairs(src) do
      -- If the value is a sub-table:
      if type(v) == "table" then
        -- Recursively call the function:
        dst[k] = copyDefaults(v, dst[k])
      -- Or if the default value type doesn't match the existing value type:
      elseif type(v) ~= type(dst[k]) then
        -- Overwrite the existing value with the default one:
        dst[k] = v
      end
    end
    -- Return the destination table:
    return dst
  end

  -- Copy the values from the defaults table into the saved variables table
  -- if it exists, and assign the result to the saved variable:

  RCUIDB = copyDefaults(RCUIDBDefaults, RCUIDB)

  rcui ={}
end

local rc_catch = CreateFrame("Frame")
rc_catch:RegisterEvent("PLAYER_LOGIN")
rc_catch:SetScript("OnEvent", rcui_defaults)

-- Fix some bag jank
SetSortBagsRightToLeft(true)
SetInsertItemsLeftToRight(false)

local onShow = function(frame)

end

local makePanel = function(frameName, mainpanel, panelName)
  local panel = CreateFrame("Frame", frameName, mainpanel)
  panel.name, panel.parent = panelName, name
  panel:SetScript("OnShow", onShow)
  InterfaceOptions_AddCategory(panel)
end

local function openRcuiConfig()
  InterfaceOptionsFrame_OpenToCategory(rcuiPanel)
  InterfaceOptionsFrame_OpenToCategory(rcuiPanel)
end

local function rcui_options()
  -- Creation of the options menu
  rcui.panel = CreateFrame( "Frame", "rcuiPanel", UIParent )
  rcui.panel.name = "RillyCleanUI";
  InterfaceOptions_AddCategory(rcui.panel);

  local function newCheckbox(label, description, initialValue, onChange, relativeEl, frame)
    if ( not frame ) then
      frame = rcui.panel
    end

    local check = CreateFrame("CheckButton", "RCUICheck" .. label, frame, "InterfaceOptionsCheckButtonTemplate")
    check:SetScript("OnClick", function(self)
      local tick = self:GetChecked()
      onChange(self, tick and true or false)
      if tick then
        PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
      else
        PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
      end
    end)
    check.label = _G[check:GetName() .. "Text"]
    check.label:SetText(label)
    check.tooltipText = label
    check.tooltipRequirement = description
    check:SetChecked(initialValue)
    if (relativeEl) then
      check:SetPoint("TOPLEFT", relativeEl, "BOTTOMLEFT", 0, -8)
    else
      check:SetPoint("TOPLEFT", 16, -16)
    end
    return check
  end

  local function newDropdown(label, options, initialValue, width, onChange)
    local dropdownText = rcui.panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownText:SetText(label)

    local dropdown = CreateFrame("Frame", "RCUIDropdown" .. label, rcui.panel, "UIDropdownMenuTemplate")
    _G[dropdown:GetName() .. "Middle"]:SetWidth(width)
    dropdown:SetPoint("TOPLEFT", dropdownText, "BOTTOMLEFT", 0, -8)
    local displayText = _G[dropdown:GetName() .. "Text"]
    displayText:SetText(options[initialValue])

    dropdown.initialize = function()
      local selected, info = displayText:GetText(), {}
      info.func = function(v)
        displayText:SetText(v:GetText())
        onChange(v.value)
      end
      for value, label in pairs(options) do
        info.text = label
        info.value = value
        info.checked = info.text == selected
        UIDropDownMenu_AddButton(info)
      end
    end
    return dropdownText, dropdown
  end

  local function newSlider(frameName, label, configVar, min, max, relativeEl, frame, onChanged)
    local slider = CreateFrame("Slider", frameName, frame, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValue(RCUIDB[configVar])
    slider:SetValueStep(1)
    slider:SetWidth(110)
    local textFrame = (frameName .. 'Text')
    slider:SetScript("OnValueChanged", function(_, v)
      v = floor(v)
      _G[textFrame]:SetFormattedText(label, v)
      RCUIDB[configVar] = v
      if onChanged ~= nil and type(onChanged) == "function" then
        onChanged(v)
      end
    end)
    _G[(frameName .. 'Low')]:SetText(min)
    _G[(frameName .. 'High')]:SetText(max)
    _G[textFrame]:SetFormattedText(label, RCUIDB[configVar])
    slider:SetPoint("TOPLEFT", relativeEl, "BOTTOMLEFT", 0, -24)

    return slider
  end

  local version = GetAddOnMetadata("RillyCleanUI", "Version")

  local rcuiTitle = rcui.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  rcuiTitle:SetPoint("TOPLEFT", 16, -16)
  rcuiTitle:SetText("RillyCleanUI ("..version..")")

  local portraitSelect, portraitDropdown = newDropdown(
    "Portrait Style",
    {["3D"] = "3D", ["class"] = "Class", ["default"] = "Default"},
    RCUIDB.portraitStyle,
    50,
    function(value)
      RCUIDB.portraitStyle = value
    end
  )
  portraitSelect:SetPoint("TOPLEFT", rcuiTitle, "BOTTOMLEFT", 0, -16)

  local tooltipAnchor = newDropdown(
    "Tooltip Cursor Anchor",
    {["ANCHOR_CURSOR_LEFT"] = "Bottom Right", ["ANCHOR_CURSOR_RIGHT"] = "Bottom Left", ['DEFAULT'] = 'Disabled'},
    RCUIDB.tooltipAnchor,
    100,
    function(value)
      RCUIDB.tooltipAnchor = value
    end
  )
  tooltipAnchor:SetPoint("LEFT", portraitSelect, "RIGHT", 200, 0)

  local lootSpecDisplay = newCheckbox(
    "Display Loot Spec Indicator",
    "Display loot spec icon in your player portrait.",
    RCUIDB.lootSpecDisplay,
    function(self, value)
      RCUIDB.lootSpecDisplay = value
    end,
    portraitDropdown
  )

  local hideAltPower = newCheckbox(
    "Hide Alt Power (Requires reload)",
    "Hides alt power bars on character frame such as combo points or holy power to clean it up, when preferring WeakAura or etc.",
    RCUIDB.hideAltPower,
    function(self, value)
      RCUIDB.hideAltPower = value
    end,
    lootSpecDisplay
  )

  local customFonts = newCheckbox(
    "Use Custom Fonts (Requires Reload)",
    "Use custom fonts with support for Cyrillic and other character sets",
    RCUIDB.customFonts,
    function(self, value)
      RCUIDB.customFonts = value
    end,
    hideAltPower
  )

  local fontChooser = newDropdown(
    "Font",
    tableToWowDropdown(RILLY_CLEAN_FONTS),
    RCUIDB.font,
    100,
    function(value)
      RCUIDB.font = value
    end
  )
  fontChooser:SetPoint("LEFT", customFonts, "RIGHT", 300, 0)

  local damageFont = newCheckbox(
    "Use Custom Damage Font (Requires Game Restart)",
    "Use custom damage font, ZCOOL KuaiLe. Replace font file in Addons/RillyCleanUI/fonts to customise.",
    RCUIDB.damageFont,
    function(self, value)
      RCUIDB.damageFont = value
    end,
    customFonts
  )

  local objectivesTextOutline = newCheckbox(
    "Outline Quest Tracker Text",
    "Add an outline to Quest Tracker text",
    RCUIDB.objectivesTextOutline,
    function(self, value)
      RCUIDB.objectivesTextOutline = value
    end,
    damageFont
  )

  local objectivesHideHeaders = newCheckbox(
    "Hide Quest Tracker Header Backgrounds",
    "Simplify visual appearance of the Quest Tracker by hiding header art.",
    RCUIDB.objectivesHideHeaders,
    function(self, value)
      RCUIDB.objectivesHideHeaders = value
    end,
    objectivesTextOutline
  )

  -- local hideMinimapZoneText = newCheckbox(
  --   "Hide Minimap Zone Text",
  --   "Hides the Zone text at the top of the Minimap.",
  --   RCUIDB.hideMinimapZoneText,
  --   function(self, value)
  --     RCUIDB.hideMinimapZoneText = value
  --     handleMinimapZoneText()
  --   end,
  --   damageFont
  -- )

  ----------------
  -- Action Bars --
  ----------------
  makePanel("RCUI_ActionBars", rcui.panel, "Action Bars")

  local actionbarText = RCUI_ActionBars:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  actionbarText:SetText("Action Bars")
  actionbarText:SetPoint("TOPLEFT", 16, -16)

  local hideHotkeys = newCheckbox(
    "Hide Hotkeys on Action Bars",
    "Hides keybinding text on your action bar buttons.",
    RCUIDB.hideHotkeys,
    function(self, value)
      RCUIDB.hideHotkeys = value
    end,
    actionbarText,
    RCUI_ActionBars
  )

  local hideMacroText = newCheckbox(
    "Hide Macro Text on Action Bars",
    "Hides macro text on your action bar buttons.",
    RCUIDB.hideMacroText,
    function(self, value)
      RCUIDB.hideMacroText = value
    end,
    hideHotkeys,
    RCUI_ActionBars
  )

  -- local hideMicroButtonsAndBags = newCheckbox(
  --   "Hide Micro Buttons and Bags (Requires reload)",
  --   "Hides micro buttons and bags to increase screen real-estate and cleanliness.",
  --   RCUIDB.hideMicroButtonsAndBags,
  --   function(self, value)
  --     RCUIDB.hideMicroButtonsAndBags = value
  --   end,
  --   hideMacroText,
  --   RCUI_ActionBars
  -- )

  -- local hideStanceBar = newCheckbox(
  --   "Hide Stance Bar (Requires reload)",
  --   "Hides stance bar in favour of binding stances to action bars.",
  --   RCUIDB.hideStanceBar,
  --   function(self, value)
  --     RCUIDB.hideStanceBar = value
  --   end,
  --   hideMicroButtonsAndBags,
  --   RCUI_ActionBars
  -- )

  local disableAutoAddSpells = newCheckbox(
    "Disable Auto Adding of Spells",
    "Disables automatic adding of spells to action bars when learning new spells.",
    RCUIDB.disableAutoAddSpells,
    function(self, value)
      RCUIDB.disableAutoAddSpells = value
    end,
    hideMacroText,
    RCUI_ActionBars
  )

  ----------------
  -- Nameplates --
  ----------------
  makePanel("RCUI_Nameplates", rcui.panel, "Nameplates")

  local nameplateText = RCUI_Nameplates:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  nameplateText:SetText("Nameplates")
  nameplateText:SetPoint("TOPLEFT", 16, -16)

  local nameplateFontSlider = newSlider(
    "RCUI_NameplateFontSlider",
    FONT_SIZE.." "..FONT_SIZE_TEMPLATE,
    "nameplateNameFontSize",
    6,
    20,
    nameplateText,
    RCUI_Nameplates
  )

  local nameplateNameLength = newCheckbox(
    "Abbreviate Unit Names",
    "Abbreviate long NPC names on nameplates.",
    RCUIDB.nameplateNameLength > 0,
    function(self, value)
      if value == true then
        RCUIDB.nameplateNameLength = 20
      else
        RCUIDB.nameplateNameLength = 0
      end
    end,
    nameplateFontSlider,
    RCUI_Nameplates
  )

  local nameplateHideServerNames = newCheckbox(
    "Hide Server Names (Must rezone to see change).",
    "Hide server names for players from different servers to reduce clutter.",
    RCUIDB.nameplateHideServerNames,
    function(self, value)
      RCUIDB.nameplateHideServerNames = value
    end,
    nameplateNameLength,
    RCUI_Nameplates
  )

  local nameplateFriendlyNamesClassColor = newCheckbox(
    "Class Colour Friendly Names",
    "Colours friendly players' names on their nameplates.",
    RCUIDB.nameplateFriendlyNamesClassColor,
    function(self, value)
      RCUIDB.nameplateFriendlyNamesClassColor = value
    end,
    nameplateHideServerNames,
    RCUI_Nameplates
  )

  local nameplateFriendlySmall = newCheckbox(
    "Smaller Friendly Nameplates",
    "Reduce size of friendly nameplates to more easily distinguish friend from foe",
    RCUIDB.nameplateFriendlySmall,
    function(self, value)
      RCUIDB.nameplateFriendlySmall = value
      SetFriendlyNameplateSize(true)
    end,
    nameplateFriendlyNamesClassColor,
    RCUI_Nameplates
  )

  local nameplateShowLevel = newCheckbox(
    "Show Level",
    "Show player/mob level on nameplate",
    RCUIDB.nameplateShowLevel,
    function(self, value)
      RCUIDB.nameplateShowLevel = value
    end,
    nameplateFriendlySmall,
    RCUI_Nameplates
  )

  local nameplateShowHealth = newCheckbox(
    "Show Health Percentage",
    "Show percentages of health on nameplates",
    RCUIDB.nameplateHealthPercent,
    function(self, value)
      RCUIDB.nameplateHealthPercent = value
    end,
    nameplateShowLevel,
    RCUI_Nameplates
  )

  local nameplateHideCastText = newCheckbox(
    "Hide Cast Text",
    "Hide cast text from nameplate castbars.",
    RCUIDB.nameplateHideCastText,
    function(self, value)
      RCUIDB.nameplateHideCastText = value
    end,
    nameplateShowHealth,
    RCUI_Nameplates
  )

  ----------------
  --     PvP    --
  ----------------
  makePanel("RCUI_PvP", rcui.panel, "PvP")

  local pvpText = RCUI_PvP:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  pvpText:SetText("PvP")
  pvpText:SetPoint("TOPLEFT", 16, -16)

  local safeQueue = newCheckbox(
    "Safe Queue",
    "Hide Leave Queue button and show timer for Arena/RBG queues.",
    RCUIDB.safeQueue,
    function(self, value)
      RCUIDB.safeQueue = value
    end,
    pvpText,
    RCUI_PvP
  )

  local dampeningDisplay = newCheckbox(
    "Dampening Display",
    "Display Dampening % under remaining time at the top of the screen in arenas.",
    RCUIDB.dampeningDisplay,
    function(self, value)
      RCUIDB.dampeningDisplay = value
    end,
    safeQueue,
    RCUI_PvP
  )

  local tabBinder = newCheckbox(
    "Tab Binder",
    "Tab-target only between players in Arenas and BGs.",
    RCUIDB.tabBinder,
    function(self, value)
      RCUIDB.tabBinder = value
    end,
    dampeningDisplay,
    RCUI_PvP
  )

  local arenaNumbers = newCheckbox(
    "Show Arena Numbers on nameplates in arenas",
    "Show Arena number (i.e. 1, 2, 3 etc) on top of nameplates in arenas instead of player names to assist with macro use awareness",
    RCUIDB.arenaNumbers,
    function(self, value)
      RCUIDB.arenaNumbers = value
    end,
    tabBinder,
    RCUI_PvP
  )

  ------------------
  --Reload Button --
  ------------------
  local reload = CreateFrame("Button", "reload", rcui.panel, "UIPanelButtonTemplate")
  reload:SetPoint("BOTTOMRIGHT", rcui.panel, "BOTTOMRIGHT", -10, 10)
  reload:SetSize(100,22)
  reload:SetText("Reload")
  reload:SetScript("OnClick", function()
    ReloadUI()
  end)

  SLASH_rcui1 = "/rcui"

  SlashCmdList["rcui"] = function()
    openRcuiConfig()
  end

  -- hooksecurefunc("OptionsFrame_OnHide", function(self) -- Ensure some settings are not randomly reverted when closing/saving Interface Options
  --   local frameName = self:GetName()
  --   if frameName ~= 'InterfaceOptionsFrame' then return end

  --   SetFriendlyNameplateSize()
  -- end)
end

GameMenuFrame.Header:Hide()
local frame = CreateFrame("Button","UIPanelButtonTemplateTest",
  GameMenuFrame, "UIPanelButtonTemplate")
frame:SetHeight(20)
frame:SetWidth(145)
frame:SetText("|cffb07aebRC|r|cff009cffUI|r")
frame:ClearAllPoints()
frame:SetPoint("TOP", 0, -11)
frame:RegisterForClicks("AnyUp")
frame:SetScript("OnClick", function()
	openRcuiConfig()
end)

local rc_catch = CreateFrame("Frame")
rc_catch:RegisterEvent("PLAYER_LOGIN")
rc_catch:SetScript("OnEvent", rcui_options)
