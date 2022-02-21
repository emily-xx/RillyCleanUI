SQUARE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

RILLY_CLEAN_TEXTURES = {
  button = "Interface\\AddOns\\RillyCleanUI\\media\\textures\\button-normal",
  statusBar = "Interface\\AddOns\\RillyCleanUI\\media\\textures\\status-bar",
  targetFrame = "Interface\\AddOns\\RillyCleanUI\\media\\textures\\target-frame",
  targetFrameSmall = "Interface\\AddOns\\RillyCleanUI\\media\\textures\\target-frame-small",
  targetSmallNoMana = "Interface\\AddOns\\RillyCleanUI\\media\\textures\\target-small-nomana",
  targetOfTarget = "Interface\\AddOns\\RillyCleanUI\\media\\textures\\target-of-target",
}

RILLY_CLEAN_BACKDROP = {
  bgFile = SQUARE_TEXTURE,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 0,
  edgeSize = 1,
  insets = {
    left = -1,
    right = -1,
    top = -1,
    bottom = -1
  }
}

RILLY_CLEAN_BORDER = {
  bgFile = nil,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 32,
  edgeSize = 2,
  insets = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
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

function applyRillyCleanButtonSkin(b, icon)
  if not b then return end
  if (b and b.rillyClean) then return b.border end

  local name = b:GetName()

  -- Icon
  icon = icon or b.icon or b.Icon or _G[name.."Icon"]

  if (icon) then
    styleIcon(icon, b)
    b.icon = icon
  end

  -- Border
  local border = CreateFrame("Frame", "BACKGROUND", b, "BackdropTemplate")
  border:SetPoint("TOPLEFT", b, "TOPLEFT", -2, 2)
  border:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 2, -2)
  border:SetFrameLevel(math.max(0, (b:GetFrameLevel() - 7)))
  border.backdropInfo = RILLY_CLEAN_BORDER
  border:ApplyBackdrop()
  border:SetBackdropBorderColor(0,0,0,1)

  -- Set button styled variable
  b.rillyClean = true
  return border, icon
end

function applyRillyCleanBackdrop(b, frame)
  if (b.rillyClean) then return end

  local frame = CreateFrame("Frame", nil, (frame or b))

  -- Icon
  local name = b:GetName()
  local icon = b.icon or b.Icon or (name and _G[name.."Icon"]) or b
  icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

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
  if not size then size = 12 end
  if not outlinestyle then outlinestyle = "THINOUTLINE" end

  textObject:SetFont("Fonts\\FRIZQT__.TTF", size, outlinestyle)
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

	local statusBar = CreateFrame("StatusBar", (name .. "Bar"), barBorder)
	statusBar:SetOrientation("Vertical")
	statusBar:SetPoint("CENTER", 0, 0)
	local tex = statusBar:CreateTexture()
	tex:SetTexture(137012) -- "Interface\\TargetingFrame\\UI-StatusBar"
	statusBar:SetStatusBarTexture(tex)
	statusBar:SetSize(barBorder:GetWidth() - 4, barBorder:GetHeight() - 2)
	statusBar:SetStatusBarColor(color.r, color.g, color.b, 1)

	local bg = statusBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(statusBar)
  bg:SetColorTexture(0, 0, 0, 0.7)

  barBorder.Status = statusBar
  return barBorder
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
