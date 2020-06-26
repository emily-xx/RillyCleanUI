-- This table defines the addon's default settings:
RCUIDBDefaults = {
  actionBarOffset = 20,
  disableAutoAddSpells = true, -- DONE Whether or not to disable the automatic addition of spells to bars when changing talents and etc
  castbarOffset = 210,
  hideHotkeys = true, -- DONE

  lootSpecDisplay = true, -- DONE Display loot spec under the player frame

  damageFont = true, -- DONE Change damage font to something cooler

  tooltipAnchor = "ANCHOR_CURSOR_LEFT",

  -- Nameplate Settings
  modNamePlates = true, -- Set to false to ignore all nameplate customization
  nameplateNameFontSize = 7,
  nameplateHideServerNames = true,
  nameplateNameLength = 20, -- DONE Set to nil for no abbreviation
  nameplateFriendlyNamesClassColor = true, -- DONE
  namePlateWidth = 120,
  namePlateScale = 1.3,
  nameplateHideCastText = false, -- DONE
  nameplateCastFontSize = 6,

  portraitStyle = "3D", -- DONE 3D, 2D, or class (for class icons)
  objectivesTitles = "class", -- DONE Class for class coloured quest titles, or default for default
  objectivesTextOutline = false, -- DONE
  hideMinimapZoneText = false, -- DONE True = hide zone text, False = show zone text
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

  local objectivesTitles = newCheckbox(
    "Class Coloured Quest Tracker",
    "Colours quest titles with the colour of your character's class in the tracker under the minimap.",
    RCUIDB.objectivesTitles == "class",
    function(self, value)
      if (value == true) then
        RCUIDB.objectivesTitles = "class"
      else
        RCUIDB.objectivesTitles = "default"
      end
    end,
    hideMinimapZoneText
  )

  local objectivesTextOutline = newCheckbox(
    "Outline Quest Track Text",
    "Puts an outline around the text in the Objectives Tracker.",
    RCUIDB.objectivesTextOutline,
    function(self, value)
      RCUIDB.objectivesTextOutline = value
    end,
    objectivesTitles
  )

  local disableAutoAddSpells = newCheckbox(
    "Disable Auto Adding of Spells",
    "Disables automatic adding of spells to action bars when learning new spells.",
    RCUIDB.disableAutoAddSpells,
    function(self, value)
      RCUIDB.disableAutoAddSpells = value
    end,
    objectivesTextOutline
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

  local actionBarOffset = CreateFrame("EditBox", "actionBarOffset", nameplateHideCastText, "InputBoxTemplate");
  actionBarOffset:SetAutoFocus(false)
  actionBarOffset:SetPoint("TOPLEFT", nameplateHideCastText, "BOTTOMLEFT", 26, -8);
  actionBarOffset:SetSize(40,20)
  actionBarOffset:SetNumber(RCUIDB.actionBarOffset)
  actionBarOffset:SetCursorPosition(0)
  function setActionBarOffset()
    actionBarOffset:ClearFocus()
    RCUIDB.actionBarOffset = actionBarOffset:GetNumber()
  end
  actionBarOffset:SetScript("OnEditFocusLost", setActionBarOffset)
  actionBarOffset:SetScript("OnEnterPressed", setActionBarOffset)

  --reload button

  local reload = CreateFrame("Button","reload",rcui.childpanel,"UIPanelButtonTemplate")
  reload:SetPoint("BOTTOMRIGHT", rcui.childpanel, "BOTTOMRIGHT", -10, 10)
  reload:SetSize(100,22)
  reload:SetText("Reload")
  reload:SetScript("OnClick", function()
    ReloadUI()
  end)

  -- Blue & Grey Buttons

  -- ButtonFactory("blue","TOPLEFT",rcuiChild,6,-42,100,22,"Blue")
  -- ButtonFactory("grey","CENTER",blue,0,-20,100,22,"Grey")

  -- blue:SetScript("OnEnter", function()
  -- 	GameTooltip:SetOwner(blue,"ANCHOR_TOP");
  -- 	GameTooltip:AddLine("Activate blue color scheme.")
  -- 	GameTooltip:Show()
  -- end)

  -- blue:SetScript("OnLeave", function()
  -- 	GameTooltip:Hide()
  -- end)

  -- grey:SetScript("OnEnter", function()
  -- 	GameTooltip:SetOwner(grey,"ANCHOR_TOP");
  -- 	GameTooltip:AddLine("Activate grey colors scheme.")
  -- 	GameTooltip:Show()
  -- end)

  -- grey:SetScript("OnLeave", function()
  -- 	GameTooltip:Hide()
  -- end)

  -- local misc=CreateFrame("CheckButton", "misc", grey, "UICheckButtonTemplate")
  -- misc:SetPoint("LEFT", -3, -22)
  -- misc.text:SetText("Misc Color")
  -- m_fontify(misc.text,"white")

  -- -- Misc Main Color Inputs

  -- InputFactory("miscR",grey,"LEFT",8,-60,50,20)
  -- miscR:SetAutoFocus(false)
  -- miscR:SetNumber(RCUIDB.color.r)
  -- miscR:SetCursorPosition(0)

  -- InputFactory("miscG",miscR,"BOTTOM",0,-20,50,20)
  -- miscG:SetAutoFocus(false)
  -- miscG:SetNumber(RCUIDB.color.g)
  -- miscG:SetCursorPosition(0)

  -- InputFactory("miscB",miscG,"BOTTOM",0,-20,50,20)
  -- miscB:SetAutoFocus(false)
  -- miscB:SetNumber(RCUIDB.color.b)
  -- miscB:SetCursorPosition(0)

  -- miscR:SetScript("OnEditFocusLost",function()
  -- 	miscR:ClearFocus()
  -- 	RCUIDB.color.r = miscR:GetNumber()
  -- end)
  -- miscR:SetScript("OnEnterPressed",function()
  -- 	miscR:ClearFocus()
  -- 	RCUIDB.color.r = miscR:GetNumber()
  -- end)

  -- miscG:SetScript("OnEditFocusLost",function()
  -- 	miscG:ClearFocus()
  -- 	RCUIDB.color.g = miscG:GetNumber()
  -- end)
  -- miscG:SetScript("OnEnterPressed",function()
  -- 	miscG:ClearFocus()
  -- 	RCUIDB.color.g = miscG:GetNumber()
  -- end)

  -- miscB:SetScript("OnEditFocusLost",function()
  -- 	miscB:ClearFocus()
  -- 	RCUIDB.color.b = miscB:GetNumber()
  -- end)
  -- miscB:SetScript("OnEnterPressed",function()
  -- 	miscB:ClearFocus()
  -- 	RCUIDB.color.b = miscB:GetNumber()
  -- end)

  -- --Misc Highlight Inputs

  -- InputFactory("highR",grey,"LEFT",120,-60,50,20)
  -- highR:SetAutoFocus(false)
  -- highR:SetNumber(RCUIDB.color.hr)
  -- highR:SetCursorPosition(0)

  -- InputFactory("highG",highR,"BOTTOM",0,-20,50,20)
  -- highG:SetAutoFocus(false)
  -- highG:SetNumber(RCUIDB.color.hg)
  -- highG:SetCursorPosition(0)

  -- InputFactory("highB",highG,"BOTTOM",0,-20,50,20)
  -- highB:SetAutoFocus(false)
  -- highB:SetNumber(RCUIDB.color.hb)
  -- highB:SetCursorPosition(0)

  -- highR:SetScript("OnEditFocusLost",function()
  -- 	highR:ClearFocus()
  -- 	RCUIDB.color.hr = highR:GetNumber()
  -- end)
  -- highR:SetScript("OnEnterPressed",function()
  -- 	miscR:ClearFocus()
  -- 	RCUIDB.color.hr = highR:GetNumber()
  -- end)

  -- highG:SetScript("OnEditFocusLost",function()
  -- 	highG:ClearFocus()
  -- 	RCUIDB.color.hg = highG:GetNumber()
  -- end)
  -- highG:SetScript("OnEnterPressed",function()
  -- 	highG:ClearFocus()
  -- 	RCUIDB.color.hg = highG:GetNumber()
  -- end)

  -- highB:SetScript("OnEditFocusLost",function()
  -- 	highB:ClearFocus()
  -- 	RCUIDB.color.hb = highB:GetNumber()
  -- end)
  -- highB:SetScript("OnEnterPressed",function()
  -- 	highB:ClearFocus()
  -- 	RCUIDB.color.hb = highB:GetNumber()
  -- end)

  -- local maincolorstring = rcui.childpanel:CreateFontString()
  -- TextFactory(maincolorstring,12,"Main Color","TOPLEFT",miscR,-5,14,"color")

  -- local highcolorstring = rcui.childpanel:CreateFontString()
  -- TextFactory(highcolorstring,12,"Highlight Color","TOPLEFT",highR,-5,14,"highlight")

  -- local redr = rcui.childpanel:CreateFontString()
  -- TextFactory(redr,12,"R","CENTER",miscR,55,0,"white")
  -- redr:SetTextColor(1,0,0,1)

  -- local greeng = rcui.childpanel:CreateFontString()
  -- TextFactory(greeng,12,"G","CENTER",miscG,55,0,"white")
  -- greeng:SetTextColor(0,1,0,1)

  -- local blueb = rcui.childpanel:CreateFontString()
  -- TextFactory(blueb,12,"B","CENTER",miscB,55,0,"white")
  -- blueb:SetTextColor(0,0,1,1)

  -- if RCUIDB.color.enable == true then
  -- 	misc:SetChecked(true)
  -- 	miscR:SetAlpha(1)
  -- 	highR:SetAlpha(1)
  -- 	redr:SetAlpha(1)
  -- 	blueb:SetAlpha(1)
  -- 	greeng:SetAlpha(1)
  -- 	maincolorstring:SetAlpha(1)
  -- 	highcolorstring:SetAlpha(1)
  -- else
  -- 	misc:SetChecked(false)
  -- 	miscR:Disable()
  -- 	miscG:Disable()
  -- 	miscB:Disable()
  -- 	highR:Disable()
  -- 	highG:Disable()
  -- 	highB:Disable()
  -- 	miscR:SetAlpha(0.2)
  -- 	highR:SetAlpha(0.2)
  -- 	redr:SetAlpha(0.2)
  -- 	blueb:SetAlpha(0.2)
  -- 	greeng:SetAlpha(0.2)
  -- 	maincolorstring:SetAlpha(0.2)
  -- 	highcolorstring:SetAlpha(0.2)
  -- end

  -- if misc:GetChecked() then
  -- 	blue:Disable()
  -- 	grey:Disable()
  -- end

  -- misc:SetScript("OnClick", function()
  -- 	if misc:GetChecked() then
  -- 		RCUIDB.color.enable = true
  -- 		RCUIDB.grey = false
  -- 		RCUIDB.blue = false
  -- 		blue:Disable()
  -- 		grey:Disable()
  -- 		miscR:Enable()
  -- 		miscG:Enable()
  -- 		miscB:Enable()
  -- 		highR:Enable()
  -- 		highG:Enable()
  -- 		highB:Enable()
  -- 		miscR:SetAlpha(1)
  -- 		highR:SetAlpha(1)
  -- 		redr:SetAlpha(1)
  -- 		blueb:SetAlpha(1)
  -- 		greeng:SetAlpha(1)
  -- 		maincolorstring:SetAlpha(1)
  -- 		highcolorstring:SetAlpha(1)
  -- 	else
  -- 		RCUIDB.color.enable = false
  -- 		RCUIDB.grey = false
  -- 		RCUIDB.blue = true
  -- 		blue:Disable()
  -- 		grey:Enable()
  -- 		miscR:Disable()
  -- 		miscG:Disable()
  -- 		miscB:Disable()
  -- 		highR:Disable()
  -- 		highG:Disable()
  -- 		highB:Disable()
  -- 		miscR:SetAlpha(0.2)
  -- 		highR:SetAlpha(0.2)
  -- 		redr:SetAlpha(0.2)
  -- 		blueb:SetAlpha(0.2)
  -- 		greeng:SetAlpha(0.2)
  -- 		maincolorstring:SetAlpha(0.2)
  -- 		highcolorstring:SetAlpha(0.2)
  -- 	end
  -- end)

  -- -- Misc Settings

  -- local miscsettings = rcui.childpanel:CreateFontString()
  -- TextFactory(miscsettings,12,"+ Misc Settings + (reload required)","LEFT",misc,4,-100,"white")

  -- --cpu saver

  -- local outline = CreateFrame("CheckButton", "outline", misc, "UICheckButtonTemplate")
  -- outline:SetPoint("LEFT",0, -120)
  -- outline.text:SetText("Outline fonts")
  -- m_fontify(outline.text,"white")
  -- if RCUIDB.outline== true then
  -- 	outline:SetChecked(true)
  -- end
  -- outline:SetScript("OnClick", function()
  -- 	if outline:GetChecked() then
  -- 		RCUIDB.outline = true
  -- 	else
  -- 		RCUIDB.outline = false
  -- 	end
  -- end)

  -- --loot roll skinning

  -- local bonus = CreateFrame("CheckButton", "bonus", outline, "UICheckButtonTemplate")
  -- bonus:SetPoint("CENTER",0, -20)
  -- bonus.text:SetText("Skin lootroll frames (pass by right-clicking the rollbar)")
  -- m_fontify(bonus.text,"white")
  -- if RCUIDB.rolls == true then
  -- 	bonus:SetChecked(true)
  -- end
  -- bonus:SetScript("OnClick", function()
  -- 	if bonus:GetChecked() then
  -- 		RCUIDB.rolls = true
  -- 	else
  -- 		RCUIDB.rolls = false
  -- 	end
  -- end)

  -- --alertframe dummy & position

  -- if RCUIDB.alerpos.enable == true then
  -- 	AlertFrame:ClearAllPoints()
  -- 	AlertFrame:SetPoint("CENTER","UIParent",RCUIDB.alerpos.x,RCUIDB.alerpos.y)
  -- end


  -- local dummyalert = CreateFrame("FRAME","dummyalert",UIParent)
  -- dummyalert:SetSize(512,64)
  -- dummyalert:SetFrameStrata("DIALOG")
  -- dummyalert:SetPoint("CENTER","UIParent",RCUIDB.alerpos.x,RCUIDB.alerpos.y+51)
  -- dummyalert:SetBackdrop({
  -- bgFile = "Interface\\Achievementframe\\rcui_ach.tga",
  -- })
  -- dummyalert:Hide()

  -- local alertpos = CreateFrame("CheckButton", "alertpos",bonus,"UICheckButtonTemplate")
  -- alertpos:SetPoint("CENTER",0,-20)
  -- alertpos.text:SetText("Move alertframes")
  -- m_fontify(alertpos.text,"white")
  -- if RCUIDB.alerpos.enable == true then
  -- 	alertpos:SetChecked(true)
  -- end
  -- alertpos:SetScript("OnClick", function()
  -- 	if alertpos:GetChecked() then
  -- 		RCUIDB.alerpos.enable = true
  -- 		alert_x:Show()
  -- 	else
  -- 		alert_x:Hide()
  -- 		RCUIDB.alerpos.enable =false
  -- 	end
  -- end)

  -- local alert_x = CreateFrame("EditBox", "alert_x", alertpos, "InputBoxTemplate");
  -- alert_x:SetAutoFocus(false)
  -- alert_x:SetPoint("LEFT", 144,0);
  -- alert_x:SetSize(40,20)
  -- alert_x:SetNumber(RCUIDB.alerpos.x)
  -- alert_x:SetCursorPosition(0)
  -- alert_x:SetScript("OnEditFocusLost",function()
  -- 	alert_x:ClearFocus()
  -- 	RCUIDB.alerpos.x = alert_x:GetNumber()
  -- 	dummyalert:ClearAllPoints()
  -- 	dummyalert:SetPoint("CENTER","UIParent",RCUIDB.alerpos.x,RCUIDB.alerpos.y+51)

  -- end)
  -- alert_x:SetScript("OnEnterPressed",function()
  -- 	alert_x:ClearFocus()
  -- 	RCUIDB.alerpos.x = alert_x:GetNumber()
  -- 	dummyalert:ClearAllPoints()
  -- 	dummyalert:SetPoint("CENTER","UIParent",RCUIDB.alerpos.x,RCUIDB["alerpos"].y+51)
  -- end)
  -- if RCUIDB.alerpos.enable == true then
  -- 	alert_x:Show()
  -- else
  -- 	alert_x:Hide()
  -- end

  -- local alert_y = CreateFrame("EditBox", "alert_y", alert_x, "InputBoxTemplate");
  -- alert_y:SetAutoFocus(false)
  -- alert_y:SetPoint("LEFT", 46,0);
  -- alert_y:SetSize(40,20)
  -- alert_y:SetNumber(RCUIDB.alerpos.y)
  -- alert_y:SetCursorPosition(0)
  -- alert_y:SetScript("OnEditFocusLost",function()
  -- 	alert_y:ClearFocus()
  -- 	RCUIDB.alerpos.y = alert_y:GetNumber()
  -- 	dummyalert:ClearAllPoints()
  -- 	dummyalert:SetPoint("CENTER","UIParent",RCUIDB.alerpos.x,RCUIDB.alerpos.y+51)

  -- end)
  -- alert_y:SetScript("OnEnterPressed",function()
  -- 	alert_y:ClearFocus()
  -- 	RCUIDB.alerpos.y = alert_y:GetNumber()
  -- 	dummyalert:ClearAllPoints()
  -- 	dummyalert:SetPoint("CENTER","UIParent",RCUIDB.alerpos.x,RCUIDB.alerpos.y+51)

  -- end)

  -- local dummyalerpos = CreateFrame("Button","dummyalerpos",alert_y,"UIPanelButtonTemplate")
  -- dummyalerpos:SetPoint("LEFT",46,0)
  -- dummyalerpos:SetSize(100,22)
  -- dummyalerpos:SetText("Show Dummy")
  -- dummyalerpos:SetScript("OnClick", function()
  -- 	if dummyalert:IsShown() then
  -- 		dummyalert:Hide()
  -- 	else
  -- 		dummyalert:Show()
  -- 	end
  -- end)

  -- -- command bar

  -- local cbar = CreateFrame("CheckButton", "cbar", skinminimap, "UICheckButtonTemplate")
  -- cbar:SetPoint("CENTER",0, -20)
  -- cbar.text:SetText("Hide orderhall command bar")
  -- m_fontify(cbar.text,"white")
  -- if RCUIDB.cbar == true then
  -- 	cbar:SetChecked(true)
  -- end
  -- cbar:SetScript("OnClick", function()
  -- 	if cbar:GetChecked() then
  -- 		RCUIDB.cbar = true
  -- 		if OrderHallCommandBar then
  -- 			OrderHallCommandBar:SetAlpha(0)
  -- 		end
  -- 	else
  -- 		if OrderHallCommandBar then
  -- 			OrderHallCommandBar:SetAlpha(1)
  -- 		end
  -- 		RCUIDB.cbar = false
  -- 	end
  -- end)
  -- SLASH  Command

  SLASH_rcui1 = "/rcui"

  SlashCmdList["rcui"] = function()
    InterfaceOptionsFrame_OpenToCategory(rcuiPanel)
    InterfaceOptionsFrame_OpenToCategory(rcuiPanel)
  end

end

local rc_catch = CreateFrame("Frame")
rc_catch:RegisterEvent("PLAYER_LOGIN")
rc_catch:SetScript("OnEvent", rcui_options)
