SQUARE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

AddonDir = "Interface\\AddOns\\RillyCleanUI"
MediaDir = AddonDir.."\\media"
FontsDir = MediaDir.."\\fonts"
TextureDir = MediaDir.."\\textures"

RILLY_CLEAN_TEXTURES = {
  buttons = {
    normal = TextureDir.."\\button-normal",
    pushed = TextureDir.."\\buttons\\UI-Quickslot-Depress",
    hover = TextureDir.."\\buttons\\ButtonHilight-Square",
    checked = TextureDir.."\\buttons\\button-checked"
  },

  statusBar = TextureDir.."\\status-bar",
  targetFrame = TextureDir.."\\target-frame",
  targetFrameFlash = TextureDir.."\\UI-TARGETINGFRAME-FLASH",
  targetFrameSmall = TextureDir.."\\target-frame-small",
  targetSmallNoMana = TextureDir.."\\target-small-nomana",
  targetOfTarget = TextureDir.."\\target-of-target",

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
  number = FontsDir.."\\Marmelad.ttf",
  standard = FontsDir.."\\Andika.ttf",
  damage = FontsDir.."\\Bangers-Regular.ttf",
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

  if (icon) then
    styleIcon(icon, bu)
  end

  -- Border
  local border = CreateFrame("Frame", nil, bu, "BackdropTemplate")
  border:SetPoint("TOPLEFT", bu, "TOPLEFT", -2, 2)
  border:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 2, -2)
  -- border:SetFrameLevel()
  border.backdropInfo = RILLY_CLEAN_BORDER
  border:ApplyBackdrop()
  border:SetBackdropBorderColor(0,0,0,1)
  bu.border = border

  -- Background
  local background = CreateFrame("Frame", nil, bu, "BackdropTemplate")
  background:SetPoint("TOPLEFT", bu, "TOPLEFT", 0, 0)
  background:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 0, 0)
  background:SetFrameLevel(bu:GetFrameLevel() - 1)
  background.backdropInfo = RILLY_CLEAN_BACKDROP
  background:ApplyBackdrop()
  background:SetBackdropBorderColor(0,0,0,1)
  background:SetBackdropColor(0,0,0,0.6)

  bu:SetHighlightTexture(RILLY_CLEAN_TEXTURES.buttons.hover)

  local nt = bu:GetNormalTexture()

  if (isLeaveButton) then
    nt:SetTexCoord(0.2, 0.8, 0.2, 0.8)
    nt:SetAllPoints(bu)
  else
    -- Hide the normal texture
    nt:SetAlpha(0)

    bu:SetPushedTexture(RILLY_CLEAN_TEXTURES.buttons.pushed)
    if bu.SetCheckedTexture ~= nil then
      bu:SetCheckedTexture(RILLY_CLEAN_TEXTURES.buttons.checked)
    end

    hooksecurefunc(
      bu,
      "SetNormalTexture",
      function(self, texture)
        -- Make sure the normaltexture stays the way we want it
        local nt = self:GetNormalTexture()
        nt:SetAlpha(0)
      end
    )

    hooksecurefunc(
      nt,
      "SetVertexColor",
      function(nt)
        nt:SetAlpha(0)
      end
    )
  end

  bu.rillyClean = true
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

  textObject:SetFont(RILLY_CLEAN_FONTS.standard, size, outlinestyle)
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
