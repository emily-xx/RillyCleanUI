-- This table defines the addon's default settings:
local name, RCUI = ...
RCUIDBDefaults = {
  actionBarOffset = 20,
  disableAutoAddSpells = true, -- Whether or not to disable the automatic addition of spells to bars when changing talents and etc
  castbarOffset = 170,
  hideHotkeys = true,

  hideAltPower = true,
  hideStanceBar = true,
  lootSpecDisplay = true, -- Display loot spec under the player frame

  damageFont = true, -- Change damage font to something cooler

  tooltipAnchor = "ANCHOR_CURSOR_LEFT",

  -- Nameplate Settings
  modNamePlates = true, -- Set to false to ignore all nameplate customization
  nameplateNameFontSize = 9,
  nameplateHideServerNames = true,
  nameplateNameLength = 20, -- Set to nil for no abbreviation
  nameplateFriendlyNamesClassColor = true,
  nameplateHideCastText = false,
  nameplateShowLevel = true,
  nameplateCastFontSize = 6,
  nameplateHealthPercent = true,
  nameplateShowCastTime = true,

  portraitStyle = "3D", -- 3D, 2D, or class (for class icons)
  hideMinimapZoneText = false, -- True = hide zone text, False = show zone text
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

local function rcui_options()
  -- Creation of the options menu
  rcui.panel = CreateFrame( "Frame", "rcuiPanel", UIParent )
  rcui.panel.name = "RillyCleanUI";
  InterfaceOptions_AddCategory(rcui.panel);
  rcui.childpanel = CreateFrame( "Frame", "rcuiChild", rcui.panel)
  rcui.childpanel:SetPoint("TOPLEFT",rcuiPanel,0,0)
  rcui.childpanel:SetPoint("BOTTOMRIGHT",rcuiPanel,0,0)
  InterfaceOptions_AddCategory(rcui.childpanel)

  local function newCheckbox(label, description, initialValue, onChange, relativeEl, frame)
    if ( not frame ) then
      frame = rcui.childpanel
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
    local dropdownText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownText:SetText(label)

    local dropdown = CreateFrame("Frame", "RCUIDropdown" .. label, rcui.childpanel, "UIDropdownMenuTemplate")
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

  local function newSlider(frameName, label, configVar, min, max, relativeEl, frame)
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
    end)
    _G[(frameName .. 'Low')]:SetText(min)
    _G[(frameName .. 'High')]:SetText(max)
    _G[textFrame]:SetFormattedText(label, RCUIDB[configVar])
    slider:SetPoint("TOPLEFT", relativeEl, "BOTTOMLEFT", 0, -24)

    return slider
  end

  local version = GetAddOnMetadata("RillyCleanUI", "Version")

  local rcuiTitle = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  rcuiTitle:SetPoint("TOPLEFT", 16, -16)
  rcuiTitle:SetText("RillyCleanUI ("..version..")")

  local portraitSelect, portraitDropdown = newDropdown(
    "Portrait Style",
    {["3D"] = "3D", ["2D"] = "2D", ["class"] = "Class"},
    RCUIDB.portraitStyle,
    50,
    function(value)
      RCUIDB.portraitStyle = value
    end
  )
  portraitSelect:SetPoint("TOPLEFT", rcuiTitle, "BOTTOMLEFT", 0, -16)

  local tooltipAnchor = newDropdown(
    "Tooltip Cursor Anchor",
    {["ANCHOR_CURSOR_LEFT"] = "Bottom Right", ["ANCHOR_CURSOR_RIGHT"] = "Bottom Left"},
    RCUIDB.tooltipAnchor,
    100,
    function(value)
      RCUIDB.tooltipAnchor = value
    end
  )
  tooltipAnchor:SetPoint("LEFT", portraitSelect, "RIGHT", 200, 0)

  local lootSpecDisplay = newCheckbox(
    "Display Loot Spec",
    "Display loot spec and icon under your player frame.",
    RCUIDB.lootSpecDisplay,
    function(self, value)
      RCUIDB.lootSpecDisplay = value
    end,
    portraitDropdown
  )

  local hideAltPower = newCheckbox(
    "Hide Alt Power (Requires reload)",
    "Hides alt power bars on character frame such as combo points or holy power to clean it up, preferring their view on personal resource display.",
    RCUIDB.hideAltPower,
    function(self, value)
      RCUIDB.hideAltPower = value
    end,
    lootSpecDisplay
  )

  local actionbarText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  actionbarText:SetText("Action Bar Options")
  actionbarText:SetPoint("TOPLEFT", hideAltPower, "BOTTOMLEFT", 0, -12)

  local hideHotkeys = newCheckbox(
    "Hide Hotkeys on Action Bars",
    "Hides keybinding text on your action bar buttons.",
    RCUIDB.hideHotkeys,
    function(self, value)
      RCUIDB.hideHotkeys = value
    end,
    actionbarText
  )

  local hideStanceBar = newCheckbox(
    "Hide Stance Bar (Requires reload)",
    "Hides stance bar in favour of binding stances to action bars.",
    RCUIDB.hideStanceBar,
    function(self, value)
      RCUIDB.hideStanceBar = value
    end,
    hideHotkeys
  )

  local disableAutoAddSpells = newCheckbox(
    "Disable Auto Adding of Spells",
    "Disables automatic adding of spells to action bars when learning new spells.",
    RCUIDB.disableAutoAddSpells,
    function(self, value)
      RCUIDB.disableAutoAddSpells = value
    end,
    hideStanceBar
  )

  local miscText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  miscText:SetText("Misc. Options")
  miscText:SetPoint("TOPLEFT", disableAutoAddSpells, "BOTTOMLEFT", 0, -12)

  local damageFont = newCheckbox(
    "Use Custom Damage Font (Requires Game Restart)",
    "Use custom damage font, ZCOOL KuaiLe. Replace font file in Addons/RillyCleanUI/fonts to customise.",
    RCUIDB.damageFont,
    function(self, value)
      RCUIDB.damageFont = value
    end,
    miscText
  )

  local hideMinimapZoneText = newCheckbox(
    "Hide Minimap Zone Text",
    "Hides the Zone text at the top of the Minimap.",
    RCUIDB.hideMinimapZoneText,
    function(self, value)
      RCUIDB.hideMinimapZoneText = value
      handleMinimapZoneText()
    end,
    damageFont
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

  local nameplateShowLevel = newCheckbox(
    "Show Level",
    "Show player/mob level on nameplate",
    RCUIDB.nameplateShowLevel,
    function(self, value)
      RCUIDB.nameplateShowLevel = value
    end,
    nameplateFriendlyNamesClassColor,
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

  ------------
  -- Layout --
  ------------
  local layoutText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  layoutText:SetText("Layout Options")
  layoutText:SetPoint("TOPLEFT", hideMinimapZoneText, "BOTTOMLEFT", 0, -12)

  -- Action Bar Offset
  local actionBarOffsetText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  actionBarOffsetText:SetText("Action Bar Offset (Vertical)")
  actionBarOffsetText:SetTextColor( 1, 1, 1 )
  actionBarOffsetText:SetPoint("TOPLEFT", layoutText, "BOTTOMLEFT", 6, -12)

  local actionBarOffset = newSlider(
    "RCUI_ActionbaroffsetSlider",
    "Offset: %d px",
    'actionBarOffset',
    0,
    600,
    actionBarOffsetText,
    rcui.childpanel
  )

  -- Castbar Offset
  local castBarOffsetText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  castBarOffsetText:SetText("CastBar Offset (Vertical, relative to action bars)")
  castBarOffsetText:SetTextColor( 1, 1, 1 )
  castBarOffsetText:SetPoint("TOPLEFT", actionBarOffset, "BOTTOMLEFT", 0, -16)

  local castBarOffset = newSlider(
    "RCUI_CastbaroffsetSlider",
    "Offset: %d px",
    'castbarOffset',
    0,
    600,
    castBarOffsetText,
    rcui.childpanel
  )

  ------------------
  --Reload Button --
  ------------------
  local reload = CreateFrame("Button", "reload", rcui.childpanel, "UIPanelButtonTemplate")
  reload:SetPoint("BOTTOMRIGHT", rcui.childpanel, "BOTTOMRIGHT", -10, 10)
  reload:SetSize(100,22)
  reload:SetText("Reload")
  reload:SetScript("OnClick", function()
    ReloadUI()
  end)

  SLASH_rcui1 = "/rcui"

  SlashCmdList["rcui"] = function()
    InterfaceOptionsFrame_OpenToCategory(rcuiPanel)
    InterfaceOptionsFrame_OpenToCategory(rcuiPanel)
  end

end

local rc_catch = CreateFrame("Frame")
rc_catch:RegisterEvent("PLAYER_LOGIN")
rc_catch:SetScript("OnEvent", rcui_options)
