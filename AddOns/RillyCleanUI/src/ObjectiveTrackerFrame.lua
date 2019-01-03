local function skin_Blizzard_ObjectiveTracker()
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:ClearAllPoints()
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetPoint("TOPRIGHT",ObjectiveTrackerFrame.HeaderMenu,"TOPRIGHT",0.5,-4.5)

  local function m_fontify(arg1,arg2)
		-- arg 1 is the stringname, arg2 is the color
		arg1:SetShadowOffset(1,-1)
		arg1:SetShadowColor(0,0,0,1)

    local _,className = UnitClass("player")
    local classR, classG, classB = GetClassColor(className)

		setFontOutline(arg1)

		if arg2 == "color" and RCConfig.objectivesTitles == "class" then
			arg1:SetTextColor(classR,classG,classB,1)
		elseif arg2 == "highlight" and RCConfig.objectivesTitles == "class" then
			arg1:SetTextColor(classR+0.3,classG+0.3,classB+0.3,1)
		elseif arg2 == "white" then
			arg1:SetTextColor(1,1,1,1)
		elseif arg2 == "green" then
			arg1:SetTextColor(0, 1, 0.5, 1)
		elseif arg2 == "grey" then
			arg1:SetTextColor(0.5, 0.5, 0.5, 1)
		else
			if RCConfig.objectivesTitles == "class" then
				arg1:SetTextColor(classR,classG,classB,1)
			end
		end
	end

	local function miirgui_SetStringText(_,fontString)
		local r, g, b = fontString:GetTextColor()
		local red = floor(r * 255 )
		local green = floor(g * 255 )
		local blue = floor(b * 255 )
		if red == 203 and green == 203 and blue == 203 then
			m_fontify(fontString,"white")
		elseif  red == 190 and green == 155 and blue == 0 then
			m_fontify(fontString,"color")
		elseif red == 152 and green == 152 and blue == 152 then
			m_fontify(fontString,"green")
		else
		end
	end

	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE,"SetStringText", miirgui_SetStringText)

	local function miirgui_OnBlockHeaderEnter(_,block)
		if ( block.HeaderText ) then
			local r, g, b = block.HeaderText:GetTextColor()
			local red = floor(r * 255 )
			local green = floor(g * 255 )
			local blue = floor(b * 255 )
			if red == 254 and green == 208 and blue == 0 then
				m_fontify(block.HeaderText,"highlight")
			end
		end
		for objectiveKey, line in pairs(block.lines) do
			local r, g, b = line.Text:GetTextColor()
			local red = floor(r * 255 )
			local green = floor(g * 255 )
			local blue = floor(b * 255 )
			if red == 254 and green == 254 and blue == 254 then
				m_fontify(line.Text,"white")
			elseif red == 254 and green == 208 and blue == 0 then
				m_fontify(line.Text,"highlight")
			else
			end
		end
	end

	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE,"OnBlockHeaderEnter",miirgui_OnBlockHeaderEnter)

	local function miirgui_OnBlockHeaderLeave(_,block)
		if ( block.HeaderText ) then
			local r, g, b = block.HeaderText:GetTextColor()
			local red = floor(r * 255 )
			local green = floor(g * 255 )
			local blue = floor(b * 255 )
			if red == 190 and green == 155 and blue == 0 then
				m_fontify(block.HeaderText,"color")
			end
		end

		for objectiveKey, line in pairs(block.lines) do
			local r, g, b = line.Text:GetTextColor()
			local red = floor(r * 255 )
			local green = floor(g * 255 )
			local blue = floor(b * 255 )
			if red == 203 and green == 203 and blue == 203 then
				m_fontify(line.Text,"white")
			elseif red == 190 and green == 155 and blue == 0 then
				m_fontify(line.Text,"color")
			else
			end
		end
	end

	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE,"OnBlockHeaderLeave",miirgui_OnBlockHeaderLeave)

	local function miirgui_ObjectiveTracker_Collapse()
		m_fontify(ObjectiveTrackerFrame.HeaderMenu.Title,"white")
	end

	hooksecurefunc("ObjectiveTracker_Collapse",miirgui_ObjectiveTracker_Collapse)

	local function miirgui_AddObjective(self,block,objectiveKey,_,lineType)
		local line = self:GetLine(block, objectiveKey, lineType);
		if ( line.Dash ) then
			m_fontify(line.Dash,"white")
		end
	end

	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE,"AddObjective", miirgui_AddObjective)


	local function miirgui_ProgressBar_SetValue(self)
		self.Bar:ClearAllPoints()
		self.Bar:SetPoint("CENTER",self,22.5,0.5)
		self.Bar.Label:ClearAllPoints()
		self.Bar.Label:SetPoint("CENTER",self.Bar,0,1)
		m_fontify(self.Bar.Label,"white")
	end

	hooksecurefunc("ScenarioTrackerProgressBar_SetValue",miirgui_ProgressBar_SetValue)
	hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue",miirgui_ProgressBar_SetValue)

	local function miirgui_ObjectiveTracker_Update()
			local tracker = ObjectiveTrackerFrame
			if #tracker.MODULES then
				for i = 1, #tracker.MODULES do
					if ( tracker.MODULES[i].Header ) then
						m_fontify(tracker.MODULES[i].Header.Text,"white")
					end
				end
			end
	end

	hooksecurefunc("ObjectiveTracker_Update",miirgui_ObjectiveTracker_Update)

	local function miirgui_Update()
		for i = 1, GetNumAutoQuestPopUps() do
			local questID = GetAutoQuestPopUp(i);
			if AUTO_QUEST_POPUP_TRACKER_MODULE:GetExistingBlock(questID) then
				local block = AUTO_QUEST_POPUP_TRACKER_MODULE:GetExistingBlock(questID);
				local blockContents = block.ScrollChild;
				m_fontify(blockContents.TopText,"green")
				m_fontify(blockContents.QuestName,"color")
				m_fontify(blockContents.BottomText,"grey")
				if string.find (blockContents.Exclamation:GetTexture(),"AutoQuest") then
				else
					blockContents.Exclamation:SetTexCoord(0.15, 0.85, 0.15, 0.85)
				end
			end
		end
	end

	hooksecurefunc(AUTO_QUEST_POPUP_TRACKER_MODULE,"Update",miirgui_Update)
end

local catchaddon = CreateFrame("FRAME")
catchaddon:RegisterEvent("ADDON_LOADED")

--function to catch loading addons
local function skinnedOnLoad(_, _, addon)
	if addon == "Blizzard_ObjectiveTracker" then
		skin_Blizzard_ObjectiveTracker()
	end
end

--this function decides whether the addon is already loaded or if we need to look out for it!

local function skinnedOnLogin()
	if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
		-- Addon is already loaded, procceed to skin!
		skin_Blizzard_ObjectiveTracker()
	else
		-- Addon is not loaded yet, procceed to look out for it!
		catchaddon:SetScript("OnEvent", skinnedOnLoad)
	end
end

local HelloWorld = CreateFrame("FRAME")
HelloWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
HelloWorld:SetScript("OnEvent", skinnedOnLogin)
