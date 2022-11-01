-- Enhanced version of SafeQueue by Jordon

local SafeQueue = CreateFrame("Frame")
local queueTime
local queue = 0
local remaining = 0
SafeQueueDB = SafeQueueDB or { announce = "self" }

PVPReadyDialog.leaveButton:Hide()
PVPReadyDialog.leaveButton.Show = function() end -- Prevent other mods from showing the button
PVPReadyDialog.enterButton:ClearAllPoints()
PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99SafeQueue|r: " .. msg)
end

local function PrintTime()
	local announce = SafeQueueDB.announce
	if announce == "off" then return end
	local secs, str, mins = floor(GetTime() - queueTime), "Queue popped "
	if secs < 1 then
		str = str .. "instantly!"
	else
		str = str .. "after "
		if secs >= 60 then
			mins = floor(secs/60)
			str = str .. mins .. "m "
			secs = secs%60
		end
		if secs%60 ~= 0 then
			str = str .. secs .. "s"
		end
	end
	if announce == "self" or not IsInGroup() then
		Print(str)
	else
		local group = IsInRaid() and "RAID" or "PARTY"
		SendChatMessage(str, group)
	end
end

SafeQueue:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
SafeQueue:SetScript("OnEvent", function()
	if not RCUIDB.safeQueue then return end

	local queued
	for i=1, GetMaxBattlefieldID() do
		local status = GetBattlefieldStatus(i)
		if status == "queued" then
			queued = true
			if not queueTime then queueTime = GetTime() end
		elseif status == "confirm" then
			if queueTime then
				PrintTime()
				queueTime = nil
				remaining = 0
				queue = i
			end
		end
		break
	end
	if not queued and queueTime then queueTime = nil end
end)

SafeQueue:SetScript("OnUpdate", function(self)
	if not RCUIDB.safeQueue then return end

	local timerBar = PVPReadyDialog.timerBar

	if not PVPReadyDialog_Showing(queue) then return end

	if not timerBar then
		timerBar = CreateFrame("StatusBar", nil, PVPReadyDialog)
		timerBar:SetPoint("TOP", PVPReadyDialog, "BOTTOM", 0, -5)
		local tex = timerBar:CreateTexture()
		tex:SetTexture(RILLY_CLEAN_TEXTURES.statusBar)
		timerBar:SetStatusBarTexture(tex, "BORDER")
		timerBar:SetStatusBarColor(1, 0.1, 0)
		timerBar:SetSize(194, 14)

		skinProgressBar(timerBar)

		timerBar.Spark = timerBar:CreateTexture(nil, "OVERLAY")
		timerBar.Spark:SetTexture(RILLY_CLEAN_TEXTURES.castSpark)
		timerBar.Spark:SetSize(32, 32)
		timerBar.Spark:SetBlendMode("ADD")
		timerBar.Spark:SetPoint("LEFT", timerBar:GetStatusBarTexture(), "RIGHT", -15, 3)

		timerBar.Text = timerBar:CreateFontString(nil, "OVERLAY")
		timerBar.Text:SetFontObject(GameFontHighlight)
		timerBar.Text:SetPoint("CENTER", timerBar, "CENTER")

		local timeout = GetBattlefieldPortExpiration(queue)
		timerBar:SetMinMaxValues(0, timeout)
	end

	local function barUpdate(self, elapsed)
		local timeLeft = GetBattlefieldPortExpiration(queue)
		if (timeLeft <= 0) then return self:Hide() end

		self:SetValue(timeLeft)
		self.Text:SetFormattedText("%.1f", timeLeft)
	end
	timerBar:SetScript("OnUpdate", barUpdate)

	local function OnEvent(self, event, ...)
		timerBar:Show()
	end

	PVPReadyDialog.timerBar = timerBar
end)

SlashCmdList.SafeQueue = function(msg)
	msg = msg or ""
	local cmd, arg = string.split(" ", msg, 2)
	cmd = string.lower(cmd or "")
	arg = string.lower(arg or "")
	if cmd == "announce" then
		if arg == "off" or arg == "self" or arg == "group" then
			SafeQueueDB.announce = arg
			Print("Announce set to " .. arg)
		else
			Print("Announce set to " .. SafeQueueDB.announce)
			Print("Announce types are \"off\", \"self\", and \"group\"")
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99SafeQueue v2.7|r")
		Print("/sq announce : " .. SafeQueueDB.announce)
	end
end
SLASH_SafeQueue1 = "/safequeue"
SLASH_SafeQueue2 = "/sq"
