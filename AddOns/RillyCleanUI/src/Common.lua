SQUARE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

function setFontOutline(textObject, outlinestyle)
  local font, size, flags = textObject:GetFont()

  if not outlinestyle then outlinestyle = "OUTLINE" end

  textObject:SetFont(font, size, "OUTLINE")
end
