-- Customised version of Friend List Colors - https://www.curseforge.com/wow/addons/flc

local addonName, ns = ...

local addon = CreateFrame("Frame")
addon:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)

local STRUCT = {
	[FRIENDS_BUTTON_TYPE_BNET] = {
		["bnetIDAccount"] = 1,
		["accountName"] = 2,
		["battleTag"] = 3,
		["isBattleTag"] = 4,
		["characterName"] = 5,
		["bnetIDGameAccount"] = 6,
		["client"] = 7,
		["isOnline"] = 8,
		["lastOnline"] = 9,
		["isAFK"] = 10, 
		["isDND"] = 11,
		["messageText"] = 12,
		["noteText"] = 13,
		["isRIDFriend"] = 14,
		["messageTime"] = 15,
		["canSoR"] = 16,
		["isReferAFriend"] = 17,
		["canSummonFriend"] = 18,
		-- character fields extension
		["hasFocus"] = 19,
		-- ["characterName"] = 20,
		-- ["client"] = 21,
		["realmName"] = 22,
		["realmID"] = 23,
		["faction"] = 24,
		["race"] = 25,
		["class"] = 26,
		["guild"] = 27,
		["zoneName"] = 28,
		["level"] = 29,
		["gameText"] = 30,
		["broadcastText"] = 31,
		["broadcastTime"] = 32,
		-- ["canSoR"] = 33,
		-- ["bnetIDGameAccount"] = 34,
	},
	[FRIENDS_BUTTON_TYPE_WOW] = {
		["name"] = 1,
		["level"] = 2,
		["class"] = 3,
		["area"] = 4,
		["connected"] = 5,
		["status"] = 6,
		["notes"] = 7,
		["isReferAFriend"] = 8
	}
}

local STRUCT_LENGTH = {}

do
	local function CountItems(data)
		local i = 0

		for _, _ in pairs(data) do
			i = i + 1
		end

		return i
	end

	STRUCT_LENGTH.BNET_CHARACTER = 12 -- 16 -- manually updated to reflect the amount of character fields specified above
	STRUCT_LENGTH[FRIENDS_BUTTON_TYPE_BNET] = CountItems(STRUCT[FRIENDS_BUTTON_TYPE_BNET]) - STRUCT_LENGTH.BNET_CHARACTER
	STRUCT_LENGTH[FRIENDS_BUTTON_TYPE_WOW] = CountItems(STRUCT[FRIENDS_BUTTON_TYPE_WOW])
end

do
	local mapMetaTable = {
		__index = function(self, key)
			for k, v in pairs(self) do
				if k == key then
					return v
				elseif v == key then
					return k
				end
			end
		end
	}

	setmetatable(STRUCT[FRIENDS_BUTTON_TYPE_BNET], mapMetaTable)
	setmetatable(STRUCT[FRIENDS_BUTTON_TYPE_WOW], mapMetaTable)
end

local function ColorRgbToHex(r, g, b)
	if type(r) == "table" then
		if r.r then
			g = r.g
			b = r.b
			r = r.r
		else
			r, g, b = unpack(r)
		end
	end

	return format("%02X%02X%02X", floor(r * 255), floor(g * 255), floor(b * 255))
end

local CLASS_COLORS = {}

do
	local colors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)

	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		CLASS_COLORS[v] = ColorRgbToHex(colors[k])
	end

	for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		CLASS_COLORS[v] = ColorRgbToHex(colors[k])
	end

	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		CLASS_COLORS.Monk = "00FF96"
		CLASS_COLORS.Paladin = "F58CBA"
		CLASS_COLORS.Shaman = "0070DE"
	end
end

local COLORS = {
	GRAY = ColorRgbToHex(FRIENDS_GRAY_COLOR),
	BNET = ColorRgbToHex(FRIENDS_BNET_NAME_COLOR),
	WOW = ColorRgbToHex(FRIENDS_WOW_NAME_COLOR)
}

local config = {
	format = "[if=level][color=level]([=level])[/color][/if] [=accountName|name] [if=characterName][color=class]([=characterName])[/color][/if]",
	-- format = "[if=level][color=level]L[=level][/color] [/if][color=class][=accountName|characterName|name][/color]",
}

local function GetFriendInfo(friend)
	local info
	if type(friend) == "number" then
		info = C_FriendList.GetFriendInfoByIndex(friend)
	elseif type(friend) == "string" then
		info = C_FriendList.GetFriendInfo(friend)
	end
	if not info then
		return
	end
	local chatFlag = ""
	if info.dnd then
		chatFlag = CHAT_FLAG_DND
	elseif info.afk then
		chatFlag = CHAT_FLAG_AFK
	end
	return info.name,
		info.level,
		info.className,
		info.area,
		info.connected,
		chatFlag,
		info.notes,
		info.referAFriend,
		info.guid
end

local function EscapePattern(text)
	if type(text) == "string" then
		text = text:gsub("%%", "%%%%")
		text = text:gsub("%|", "%%|")
		text = text:gsub("%?", "%%?")
		text = text:gsub("%.", "%%.")
		text = text:gsub("%-", "%%-")
		text = text:gsub("%_", "%%_")
		text = text:gsub("%[", "%%[")
		text = text:gsub("%]", "%%]")
		text = text:gsub("%(", "%%(")
		text = text:gsub("%)", "%%)")
		text = text:gsub("%*", "%%*")
	end
	return text
end

local function PackageFriendBNetCharacter(data, id)
	local offset = STRUCT_LENGTH[FRIENDS_BUTTON_TYPE_BNET]

	for i = 1, BNGetNumFriendGameAccounts(id) do
		local temp = {BNGetFriendGameAccountInfo(id, i)}

		if temp[3] == BNET_CLIENT_WOW then
			for j = 1, STRUCT_LENGTH.BNET_CHARACTER do
				data[j + offset] = temp[j]
			end

			break
		end
	end

	return data
end

local function PackageFriend(buttonType, id)
	local temp = {}

	if buttonType == FRIENDS_BUTTON_TYPE_BNET then
		temp.type = buttonType
		temp.data = PackageFriendBNetCharacter({BNGetFriendInfo(id)}, id)

	elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
		temp.type = buttonType
		temp.data = {GetFriendInfo(id)}
	end

	return temp.type and temp or nil
end

local function ColorFromLevel(level)
	level = tonumber(level, 10)

	if level then
		local color = GetQuestDifficultyColor(level)

		return ColorRgbToHex(color.r, color.g, color.b)
	end
end

local function ColorFromClass(class)
	return CLASS_COLORS[class]
end

local function ParseNote(note)
	if type(note) == "string" then
		local alias = note:match("%^(.-)%$")

		if not alias or alias == "" then
			alias = nil
		end

		return alias
	end
end

local function ParseColor(temp, field)
	field = field:lower()

	local index = STRUCT[temp.type][field]
	local out

	if index then
		local value = temp.data[index]

		if field == "level" then
			out = ColorFromLevel(value)

		elseif field == "class" then
			out = ColorFromClass(value)
		end
	end

	-- fallback class color logic
	if not out then
		out = ColorFromClass(field:upper())
	end

	-- fallback rgb/hex color logic
	if not out then
		local r, g, b = field:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")

		if r then
			out = ColorRgbToHex({r = r/255, g = g/255, b = b/255})

		else
			local hex = field:match("^%s*([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])%s*$")

			if hex then
				out = hex
			end
		end
	end

	-- fallback color logic
	if not out then
		local offline = not temp.data[STRUCT[temp.type][temp.type == FRIENDS_BUTTON_TYPE_BNET and "isOnline" or "connected"]]

		if offline then
			out = COLORS.GRAY
		elseif temp.type == FRIENDS_BUTTON_TYPE_BNET then
			out = COLORS.BNET
		else
			out = COLORS.WOW
		end
	end

	return out or "FFFFFF"
end

local ParseFormat -- used in ParseLogic

local function ParseLogic(temp, raw, content)
	local out

	local fields = {("|"):split(raw)}
	fields = #fields > 0 and fields or {raw}

	for i = 1, #fields do
		local field = fields[i]
		local index = STRUCT[temp.type][field]

		if index then
			local value = temp.data[index]

			if value then
				-- is this the account/character name? output alias if found in the note
				if field == "accountName" or field == "name" then
					local aliasIndex = STRUCT[temp.type][temp.type == FRIENDS_BUTTON_TYPE_BNET and "noteText" or "notes"]

					if aliasIndex then
						local aliasValue = ParseNote(temp.data[aliasIndex])

						if aliasValue then
							out = aliasValue
						end
					end
				end

				-- assign our value to the output
				if not out then
					out = value
				end

				-- nil invalid results
				if not out or out == "" or out == 0 or out == "0" then
					out = nil
				end

				-- break if we got valid data
				if out then
					-- stringify for less headaches in later parses
					out = tostring(out)

					-- we got what we need, abort the loop
					break
				end
			end
		end
	end

	-- got content? use the output to determine if we show the content or not
	if content and content ~= "" then
		if out then
			return ParseFormat(temp, content)
		end

		return ""
	end

	-- fallback to showing the output or empty string
	return out or ""
end

local function SafeReplace(a, b, c)
	if type(a) == "string" and type(b) == "string" and type(c) == "string" then
		return a:gsub(b, c)
	end

	return a
end

function ParseFormat(temp, raw)

	-- [=X|Y|Z|...]
	for matched, logic in raw:gmatch("(%[=(.-)%])") do
		raw = SafeReplace(raw, EscapePattern(matched), ParseLogic(temp, logic))
	end

	-- [color=X]Y[/color]
	for matched, text, content in raw:gmatch("(%[[cC][oO][lL][oO][rR]=(.-)%](.-)%[%/[cC][oO][lL][oO][rR]%])") do
		raw = SafeReplace(raw, EscapePattern(matched), "|cff" .. ParseColor(temp, text) .. ParseFormat(temp, content) .. "|r")
	end

	-- [if=X]Y[/if]
	for matched, logic, content in raw:gmatch("(%[[iI][fF]=(.-)%](.-)%[%/[iI][fF]%])") do
		raw = SafeReplace(raw, EscapePattern(matched), ParseLogic(temp, logic, content))
	end

	return raw
end

function addon:InitAPI()
	local SetText

	local function UpdateButtonName(self, ...)
		local button = self:GetParent()
		local buttonType, id = button.buttonType, button.id

		if buttonType == FRIENDS_BUTTON_TYPE_BNET or buttonType == FRIENDS_BUTTON_TYPE_WOW then
			if true then
				--button.gameIcon:SetTexture("Interface\\Buttons\\ui-paidcharactercustomization-button")
				--button.gameIcon:SetTexCoord(8/128, 55/128, 72/128, 119/128)
			end

			return SetText(self, ParseFormat(PackageFriend(buttonType, id), config.format))
		end

		return SetText(self, ...)
	end

	local scrollFrame = FriendsListFrameScrollFrame or FriendsFrameFriendsScrollFrame -- retail and classic support
	local friendButtons = scrollFrame.buttons

	for i = 1, #friendButtons do
		local button = friendButtons[i]

		if not SetText then
			SetText = button.name.SetText
		end

		button.name.SetText = UpdateButtonName
	end

	local function GetAliasFromNote(type, name)
		if type == "WHISPER" then
			local temp = {GetFriendInfo(name)}

			if temp[1] then
				local struct = STRUCT[FRIENDS_BUTTON_TYPE_WOW]

				name = ParseNote(temp[struct["notes"]]) or temp[struct["name"]] or name -- use alias name, fallback to default name
			end

		elseif type == "BN_WHISPER" then
			local presenceID = GetAutoCompletePresenceID(name)

			if presenceID then
				local temp = {BNGetFriendInfoByID(presenceID)}

				if temp[1] then
					local struct = STRUCT[FRIENDS_BUTTON_TYPE_BNET]

					name = ParseNote(temp[struct["noteText"]]) or temp[struct["accountName"]] or name -- use alias name, fallback to default name
				end
			end
		end

		return name
	end

	-- [=[
	local function ChatEdit_UpdateHeader(editBox)
		local type = editBox:GetAttribute("chatType")

		-- sanity check
		if type == "WHISPER" or type == "BN_WHISPER" then
			local header = _G[editBox:GetName().."Header"]

			if header then
				-- the whisper target
				local name = editBox:GetAttribute("tellTarget")

				-- extract the alias or regular name based on tellTarget attribute
				name = GetAliasFromNote(type, name) or name

				-- update the name
				header:SetFormattedText(_G["CHAT_" .. type .. "_SEND"], name)

				-- adjust the width
				local headerSuffix = _G[editBox:GetName().."HeaderSuffix"]
				local headerWidth = (header:GetRight() or 0) - (header:GetLeft() or 0)
				local editBoxWidth = editBox:GetRight() - editBox:GetLeft()

				if headerWidth > editBoxWidth / 2 then
					header:SetWidth(editBoxWidth / 2)
					headerSuffix:Show()
				end

				editBox:SetTextInsets(15 + header:GetWidth() + (headerSuffix:IsShown() and headerSuffix:GetWidth() or 0), 13, 0, 0)
			end
		end
	end

	hooksecurefunc("ChatEdit_UpdateHeader", ChatEdit_UpdateHeader)
end

function addon:ADDON_LOADED(event, name)
	if name == addonName then
		addon:UnregisterEvent(event)
		addon:InitAPI()
	end
end

addon:RegisterEvent("ADDON_LOADED")
