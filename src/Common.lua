SQUARE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

AddonDir = "Interface\\AddOns\\RillyCleanUI"
MediaDir = AddonDir.."\\media"
FontsDir = MediaDir.."\\fonts"
TextureDir = MediaDir.."\\textures"

RILLY_CLEAN_TEXTURES = {
  buttons = {
    normal = TextureDir.."\\button-normal",
    pushed = TextureDir.."\\buttons\\button-pressed",
    hover = TextureDir.."\\buttons\\ButtonHilight-Square",
    checked = TextureDir.."\\buttons\\button-checked"
  },

  statusBar = TextureDir.."\\status-bar",
  targetFrame = TextureDir.."\\target-frame",
  targetFrameFlash = TextureDir.."\\UI-TARGETINGFRAME-FLASH",
  targetFrameSmall = TextureDir.."\\target-frame-small",
  targetSmallNoMana = TextureDir.."\\target-small-nomana",
  targetOfTarget = TextureDir.."\\target-of-target",

  circleTexture = TextureDir.."\\Portrait-ModelBack",

  minimap = {
    dungeonDifficulty = TextureDir.."\\minimap\\UI-DungeonDifficulty-Button"
  },

  nameplates = {
    border = TextureDir.."\\nameplates\\border",
    glow = TextureDir.."\\nameplates\\glow",
  },

  characterframe = {
    stateIcon = TextureDir.."\\characterframe\\UI-StateIcon",
    totemBorder = TextureDir.."\\characterframe\\TotemBorder",
  },

  lfg = {
    portraitRoles = TextureDir.."\\lfgframe\\UI-LFG-ICON-PORTRAITROLES",
    roles = TextureDir.."\\lfgframe\\UI-LFG-ICON-ROLES"
  },

  castBorder = TextureDir.."\\UI-CastingBar-Border",
  castFlash = TextureDir.."\\UI-CastingBar-Flash",
  castSpark = TextureDir.."\\UI-CastingBar-Spark",

  clock = TextureDir.."\\clock-bg"
}

RILLY_CLEAN_FONTS = {
  Andika = FontsDir.."\\Andika.ttf",
  Fira = FontsDir.."\\FiraSans.ttf",
  SourceSans = FontsDir.."\\SourceSans3.ttf",
  Marmelad = FontsDir.."\\Marmelad.ttf",
}

function tableToWowDropdown(table)
  local wowTable = {}
  for k, v in pairs(table) do
    wowTable[v] = k
  end

  return wowTable
end

RILLY_CLEAN_DAMAGE_FONT = FontsDir.."\\Bangers-Regular.ttf"

RILLY_CLEAN_BACKDROP = {
  bgFile = SQUARE_TEXTURE,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 0,
  edgeSize = 0,
  insets = {
    left = -1,
    right = -1,
    top = -1,
    bottom = -1
  }
}

RILLY_CLEAN_CIRCLE_BORDER = {
  bgFile = RILLY_CLEAN_TEXTURES.circleTexture,
  -- edgeFile = RILLY_CLEAN_TEXTURES.circleTexture,
  tile = false,
  tileSize = 0,
  edgeSize = 0,
  insets = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
  }
}

RILLY_CLEAN_BORDER = {
  bgFile = nil,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 32,
  edgeSize = 2,
  insets = {
    left = 1,
    right = -1,
    top = 1,
    bottom = -1
  },
}

RILLY_CLEAN_BUFF_BORDER = {
  bgFile = nil,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 32,
  edgeSize = 1,
  insets = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
  },
}

function skinNineSlice(ns)
  local nsPoints = {
    "TopLeftCorner",
    "TopRightCorner",
    "BottomLeftCorner",
    "BottomRightCorner",
    "TopEdge",
    "BottomEdge",
    "LeftEdge",
    "RightEdge",
    "Center"
  }

  for _, nsPoint in pairs(nsPoints) do
    ns[nsPoint]:SetTexture(SQUARE_TEXTURE)
  end
end

function styleIcon(ic, bu)
  ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)
end

function applyRillyCleanButtonSkin(bu, icon, isLeaveButton)
  if not bu then return end
  if (bu and bu.rillyClean) then return bu.border end

  -- Icon
  local name = bu:GetName()
  icon = icon or bu.icon or bu.Icon or _G[name.."Icon"]

  bu:SetHighlightTexture(RILLY_CLEAN_TEXTURES.buttons.hover)

  local nt = bu:GetNormalTexture()
  nt:SetAllPoints(bu)

  if (isLeaveButton) then
    nt:SetTexCoord(0.2, 0.8, 0.2, 0.8)
  else
    -- Simple button border
    nt:SetTexture(RILLY_CLEAN_TEXTURES.buttons.normal)
    nt:SetDrawLayer("ARTWORK")

    local pt = bu:GetPushedTexture()
    pt:SetAllPoints(bu)
    pt:SetTexture(RILLY_CLEAN_TEXTURES.buttons.pushed)
    pt:SetDrawLayer("OVERLAY")

    if bu.SetCheckedTexture ~= nil then
      local ct = bu:GetCheckedTexture()
      ct:SetAllPoints(bu)
      ct:SetTexture(RILLY_CLEAN_TEXTURES.buttons.checked)
      ct:SetDrawLayer("OVERLAY")
    end
  end

  return border, icon
end

function applyRillyCleanBackdrop(b, frame)
  if (b.rillyClean) then return end

  local frame = CreateFrame("Frame", nil, (frame or b))

  -- Icon
  local name = b:GetName()
  local icon = b.icon or b.Icon or (name and _G[name.."Icon"]) or b
  styleIcon(icon, b)

  -- border
  local back = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  back:SetPoint("TOPLEFT", b, "TOPLEFT", -2, 2)
  back:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 2, -2)
  back:SetFrameLevel(frame:GetFrameLevel())
  back.backdropInfo = RILLY_CLEAN_BORDER
  back:ApplyBackdrop()
  back:SetBackdropBorderColor(0,0,0,1)
  b.bg = back

  b.rillyClean = true
  return back, icon
end

ARA_FACTION_COLORS = {
  { r= .54, g= 0,   b= 0   }, -- hated
  { r= 1,   g= .10, b= .1  }, -- hostile
  { r= 1,   g= .55, b= 0   }, -- unfriendly
  { r= .87, g= .87, b= .87 }, -- neutral
  { r= 1,   g= 1,   b= 0   }, -- friendly
  { r= .1,  g= .9,  b= .1  }, -- honored
  { r= .25, g= .41, b= .88 }, -- revered
  { r= .6,  g= .2,  b= .8  }, -- exalted
  { r= .4,  g= 0,   b= .6  }, -- past exalted
}

-- FACTION_BAR_COLORS = ARA_FACTION_COLORS

function setFontOutline(textObject, outlinestyle)
  local font, size, flags = textObject:GetFont()

  if not outlinestyle then outlinestyle = "THINOUTLINE" end

  textObject:SetFont(font, size, outlinestyle)
end

function setFontSize(textObject, size)
  local font, _, flags = textObject:GetFont()

  textObject:SetFont(font, size, flags)
end

function setDefaultFont(textObject, size, outlinestyle)
  if not textObject then return end
  local _, currSize = textObject:GetFont()
  if not size then size = currSize end
  if not outlinestyle then outlinestyle = "THINOUTLINE" end

  textObject:SetFont(RCUIDB.font, size, outlinestyle)
end

xpColors = {
  normal = { r = 0.58, g = 0.0, b = 0.55 },
  rested = { r = 0.0, g = 0.39, b = 0.88 },
}

function addStatusBarToFrame(frame, name, color)
  local statusBar = CreateFrame("StatusBar", (name .. "Bar"), frame)
	statusBar:SetOrientation("Vertical")
	statusBar:SetPoint("CENTER", 0, 0)
	local tex = statusBar:CreateTexture()
	tex:SetTexture(RILLY_CLEAN_TEXTURES.statusBar)
	statusBar:SetStatusBarTexture(tex)
	statusBar:SetSize(frame:GetWidth() - 4, frame:GetHeight() - 2)
	statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)

	local bg = statusBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(statusBar)
  bg:SetColorTexture(0, 0, 0, 0.7)

  return statusBar
end

function createStatusBar(name, parentFrame, width, height, color)
  local barBorder = CreateFrame("Frame", (name .. "Border"), parentFrame, "BackdropTemplate")
	barBorder:SetFrameLevel(0)
	barBorder:SetFrameStrata("low")
	barBorder:SetSize(width, height)
	barBorder:SetScale(1)

	barBorder.backdropInfo = {
		edgeFile = SQUARE_TEXTURE,
		tile = false, tileSize = 0, edgeSize = 2,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
  }
  barBorder:ApplyBackdrop()
	barBorder:SetBackdropBorderColor(0,0,0,1)
	barBorder:Show()

  local statusBar = addStatusBarToFrame(barBorder, name, color)

  barBorder.Status = statusBar
  return barBorder
end

local cleanBarBackdrop = {
  bgFile = SQUARE_TEXTURE,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 0,
  edgeSize = 3,
  insets = {
    left = -2,
    right = -2,
    top = -2,
    bottom = -2
  }
}

function skinProgressBar(bar)
  if not bar then return end

  if bar.BorderMid then
    bar.BorderMid:SetAlpha(0)
    bar.BorderLeft:SetAlpha(0)
    bar.BorderRight:SetAlpha(0)
  end

  bar:SetStatusBarTexture(RILLY_CLEAN_TEXTURES.statusBar)

  if bar.BarBG then
    bar.BarBG:Hide()
    bar.BarFrame:Hide()
  end

  -- Rilly Clean Border
  if not bar.back then
    local back = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    back:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
    back:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    back:SetFrameLevel(bar:GetFrameLevel() - 1)
    back.backdropInfo = cleanBarBackdrop
    back:ApplyBackdrop()
    back:SetBackdropBorderColor(0,0,0,1)
    back:SetBackdropColor(0,0,0,1)

    bar.back = back
  end

  local Icon = bar.Icon
  if Icon then
    Icon:SetMask(nil)
    Icon:SetHeight(24)
    Icon:SetWidth(24)
    Icon:ClearAllPoints()
    Icon:SetPoint("LEFT", bar, "RIGHT", 0, 0)
    styleIcon(Icon)
    if not bar.iconBack then
      local iconBack = CreateFrame("Frame", nil, bar, "BackdropTemplate")
      iconBack:SetPoint("TOPLEFT", Icon, "TOPLEFT", 0, 0)
      iconBack:SetPoint("BOTTOMRIGHT", Icon, "BOTTOMRIGHT", 0, 0)
      iconBack:SetFrameLevel(bar:GetFrameLevel() - 1)
      iconBack.backdropInfo = cleanBarBackdrop
      iconBack:ApplyBackdrop()
      iconBack:SetBackdropBorderColor(0,0,0,1)
      iconBack:SetBackdropColor(0,0,0,1)
      bar.iconBack = iconBack
    end

    bar.IconBG:Hide()
  end

  bar.rillyClean = true
end

function round(what, precision)
  return math.floor(what*math.pow(10,precision)+0.5) / math.pow(10,precision)
end

function abbrNumber(number)
  local punit={"","K","M","B","T","Q"};
  local unitcp = 1;
  while number > 1000 do
      number = number / 1000;
      unitcp = unitcp + 1
  end

  return round(number, 1) .. punit[unitcp]
end

function copyTable(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function addCastbarTimer(castingFrame, fontSize, xOffset, yOffset, point, relativePoint)
  if ( not point ) then point = "LEFT" end
  if ( not relativePoint ) then relativePoint = "RIGHT" end

  castingFrame.timer = castingFrame:CreateFontString(nil)
  setDefaultFont(castingFrame.timer, fontSize)
  castingFrame.timer:SetPoint(point, castingFrame, relativePoint, xOffset, yOffset)
  castingFrame.update = 0.1

  castingFrame:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
end
