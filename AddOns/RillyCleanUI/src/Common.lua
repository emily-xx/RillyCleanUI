SQUARE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

RILLY_CLEAN_BACKDROP = {
  bgFile = nil,
  edgeFile = "Interface\\BUTTONS\\WHITE8X8",
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

function applyRillyCleanButtonSkin(b)
  if not b or (b and b.styled) then return end

  local name = b:GetName()

  --icon
  local icon = b.icon or b.Icon or _G[name.."Icon"]

  icon:SetTexCoord(0.1,0.9,0.1,0.9)
  icon:ClearAllPoints()
  icon:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)
  icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
  -- icon:SetDrawLayer("BACKGROUND",-8)
  b.icon = icon

  --border
  local border = _G[name.."Border"] or b:CreateTexture(name.."Border", "BACKGROUND", nil, -7)
  border:SetTexture("Interface\\BUTTONS\\WHITE8X8")
  border:SetTexCoord(0,1,0,1)
  border:SetDrawLayer("BACKGROUND",-7)
  border:SetVertexColor(0,0,0)
  border:ClearAllPoints()
  border:SetAllPoints(b)
  b.border = border

  --shadow
  local back = CreateFrame("Frame", nil, b, "BackdropTemplate")
  back:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
  back:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
  back:SetFrameLevel(b:GetFrameLevel() - 1)
  back.backdropInfo = RILLY_CLEAN_BACKDROP
  back:ApplyBackdrop()
  back:SetBackdropBorderColor(0,0,0,1)
  b.bg = back

  --set button styled variable
  b.styled = true
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
