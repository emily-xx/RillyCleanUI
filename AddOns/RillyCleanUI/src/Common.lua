SQUARE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

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
