-- This table defines the addon's default settings:
RCUIDBDefaults = {
  actionBarOffset = 20,
  disableAutoAddSpells = true, -- Whether or not to disable the automatic addition of spells to bars when changing talents and etc
  castbarOffset = 170,
  hideHotkeys = true,

  lootSpecDisplay = true, -- Display loot spec under the player frame

  damageFont = true, -- Change damage font to something cooler

  tooltipAnchor = "ANCHOR_CURSOR_LEFT",

  -- Nameplate Settings
  modNamePlates = true, -- Set to false to ignore all nameplate customization
  nameplateNameFontSize = 7,
  nameplateHideServerNames = true,
  nameplateNameLength = 20, -- Set to nil for no abbreviation
  nameplateFriendlyNamesClassColor = true,
  nameplateHideCastText = false,
  nameplateCastFontSize = 6,

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

local function rcui_options()
  -- Creation of the options menu
  rcui.panel = CreateFrame( "Frame", "rcuiPanel", UIParent)
  rcui.panel.name = "RillyCleanUI";
  InterfaceOptions_AddCategory(rcui.panel);
  rcui.childpanel = CreateFrame( "Frame", "rcuiChild", rcui.panel)
  rcui.childpanel:SetPoint("TOPLEFT",rcuiPanel,0,0)
  rcui.childpanel:SetPoint("BOTTOMRIGHT",rcuiPanel,0,0)
  InterfaceOptions_AddCategory(rcui.childpanel)

  local function newCheckbox(label, description, initialValue, onChange, relativeEl)
    local check = CreateFrame("CheckButton", "RCUICheck" .. label, rcui.childpanel, "InterfaceOptionsCheckButtonTemplate")
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
    check:SetPoint("TOPLEFT", relativeEl, "BOTTOMLEFT", 0, -8)
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

  local damageFont = newCheckbox(
    "Use Custom Damage Font (Requires Game Restart)",
    "Use custom damage font, ZCOOL KuaiLe. Replace font file in Addons/RillyCleanUI/fonts to customise.",
    RCUIDB.damageFont,
    function(self, value)
      RCUIDB.damageFont = value
    end,
    lootSpecDisplay
  )

  local hideHotkeys = newCheckbox(
    "Hide Hotkeys on Action Bars",
    "Hides keybinding text on your action bar buttons.",
    RCUIDB.hideHotkeys,
    function(self, value)
      RCUIDB.hideHotkeys = value
    end,
    damageFont
  )

  local hideMinimapZoneText = newCheckbox(
    "Hide Minimap Zone Text",
    "Hides the Zone text at the top of the Minimap.",
    RCUIDB.hideMinimapZoneText,
    function(self, value)
      RCUIDB.hideMinimapZoneText = value
      handleMinimapZoneText()
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
    hideMinimapZoneText
  )

  local nameplateText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  nameplateText:SetText("Nameplates")
  nameplateText:SetPoint("TOPLEFT", disableAutoAddSpells, "BOTTOMLEFT", 0, -16)

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
    nameplateText
  )

  local nameplateHideServerNames = newCheckbox(
    "Hide Server Names (Must rezone to see change).",
    "Hide server names for players from different servers to reduce clutter.",
    RCUIDB.nameplateHideServerNames,
    function(self, value)
      RCUIDB.nameplateHideServerNames = value
    end,
    nameplateNameLength
  )

  local nameplateFriendlyNamesClassColor = newCheckbox(
    "Class Colour Friendly Names",
    "Colours friendly players' names on their nameplates.",
    RCUIDB.nameplateFriendlyNamesClassColor,
    function(self, value)
      RCUIDB.nameplateFriendlyNamesClassColor = value
    end,
    nameplateHideServerNames
  )

  local nameplateHideCastText = newCheckbox(
    "Hide Cast Text",
    "Hide cast text from nameplate castbars.",
    RCUIDB.nameplateHideCastText,
    function(self, value)
      RCUIDB.nameplateHideCastText = value
    end,
    nameplateFriendlyNamesClassColor
  )

  ------------
  -- Layout --
  ------------
  local nameplateText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  nameplateText:SetText("Layout Options")
  nameplateText:SetPoint("TOPLEFT", nameplateHideCastText, "BOTTOMLEFT", 0, -16)

  -- Action Bar Offset
  local actionBarOffset = CreateFrame("EditBox", "actionBarOffset", nameplateHideCastText, "InputBoxTemplate")
  actionBarOffset:SetAutoFocus(false)
  actionBarOffset:SetPoint("TOPLEFT", nameplateText, "BOTTOMLEFT", 12, -8)
  actionBarOffset:SetSize(40, 20)
  actionBarOffset:SetNumber(RCUIDB.actionBarOffset)
  actionBarOffset:SetCursorPosition(0)
  function setActionBarOffset()
    actionBarOffset:ClearFocus()
    RCUIDB.actionBarOffset = actionBarOffset:GetNumber()
  end
  actionBarOffset:SetScript("OnEditFocusLost", setActionBarOffset)
  actionBarOffset:SetScript("OnEnterPressed", setActionBarOffset)

  local actionBarOffsetText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  actionBarOffsetText:SetText("Action Bar Offset (Vertical)")
  actionBarOffsetText:SetTextColor( 1, 1, 1 )
  actionBarOffsetText:SetPoint("LEFT", actionBarOffset, "RIGHT", 6, 0)

  -- Castbar Offset
  local castBarOffset = CreateFrame("EditBox", "castBarOffset", actionBarOffset, "InputBoxTemplate")
  castBarOffset:SetAutoFocus(false)
  castBarOffset:SetPoint("TOPLEFT", actionBarOffset, "BOTTOMLEFT", 0, -8)
  castBarOffset:SetSize(40, 20)
  castBarOffset:SetNumber(RCUIDB.castbarOffset)
  castBarOffset:SetCursorPosition(0)
  function setcastBarOffset()
    castBarOffset:ClearFocus()
    RCUIDB.castbarOffset = castBarOffset:GetNumber()
  end
  castBarOffset:SetScript("OnEditFocusLost", setcastBarOffset)
  castBarOffset:SetScript("OnEnterPressed", setcastBarOffset)

  local castBarOffsetText = rcui.childpanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  castBarOffsetText:SetText("CastBar Offset (Vertical)")
  castBarOffsetText:SetTextColor( 1, 1, 1 )
  castBarOffsetText:SetPoint("LEFT", castBarOffset, "RIGHT", 6, 0)

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
