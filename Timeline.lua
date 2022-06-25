--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}

function CooldownTimeline:CreateTimelineFrame()
	-- Create the main timeline frame
	CooldownTimeline.fTimeline = CreateFrame("StatusBar", "CooldownTimeline_Timeline", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	-- Create the other parts
	self.fTimeline.bg = self.fTimeline:CreateTexture(nil, "BACKGROUND")
	self.fTimeline.border = CreateFrame("Frame", "CooldownTimeline_Timeline_Border", CooldownTimeline_Timeline, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.fTimeline.secondaryTracker = CreateFrame("Frame", "CooldownTimeline_Timeline_Tracker", CooldownTimeline_Timeline, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.fTimeline.secondaryTracker.bg = self.fTimeline.secondaryTracker:CreateTexture(nil, "BACKGROUND")
	
	-- Set things up
	self.fTimeline.cdUniqueID = 900
	CooldownTimeline:SetTimelineFrame()
	CooldownTimeline:SetTimelineText()
	
	-- Set the various things we need for timeline bar tracking	
	self.fTimeline.onGCD = false
	
	self.fTimeline.fiveSecondRule = false
	self.fTimeline.fiveSecondRuleTime = 0
	self.fTimeline.manaTickTime = 2
	self.fTimeline.manaTickInterval = 2
	self.fTimeline.manaPreviousTickTime = GetTime()
	self.fTimeline.manaPrevious = UnitPower("player", Enum.PowerType.Mana)
	self.fTimeline.manaMax = UnitPowerMax("player", Enum.PowerType.Mana)
	
	self.fTimeline.showEnergyTick = false
	self.fTimeline.energyTickTime = 2	
	self.fTimeline.energyLastTickTime = GetTime()	
	self.fTimeline.energyPrevious = UnitPower("player", Enum.PowerType.Energy)
	self.fTimeline.energyMax = UnitPowerMax("player", Enum.PowerType.Energy)
	
	self.fTimeline.mhSwingTime, self.fTimeline.ohSwingTime = UnitAttackSpeed("player")
	self.fTimeline.mhSwinging = false
	self.fTimeline.ohSwinging = false
	
	self.fTimeline.rSwingTime = -0.1
	self.fTimeline.rSwinging = false
	
	-- OnUpdate
	self.fTimeline:HookScript("OnUpdate", function(self, elapsed)
		private.TimelineUpdate(self, elapsed)
	end)
	
	-- Drag and drop movement
	self.fTimeline:RegisterForDrag("LeftButton")
	self.fTimeline:SetScript("OnDragStart", self.fTimeline.StartMoving)
	self.fTimeline:SetScript("OnDragStop", self.fTimeline.StopMovingOrSizing)
	self.fTimeline.unlockTexture = self.fTimeline:CreateTexture(nil, "OVERLAY")
	self.fTimeline.unlockTexture:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", "Flat"))
	self.fTimeline.unlockTexture:SetAllPoints()
	self.fTimeline.unlockTexture:SetColorTexture(0.15, 0.15, 0.15, 1)
	self.fTimeline.unlockText = self.fTimeline:CreateFontString(nil, "OVERLAY")
	self.fTimeline.unlockText:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fTimeline.unlockText:SetPoint("CENTER", 0, 0)
	self.fTimeline.unlockText:SetText("TIMELINE\nDrag to Move")
	if not CooldownTimeline.db.profile.unlockFrames then
		self.fTimeline.unlockTexture:Hide()
		self.fTimeline.unlockText:Hide()
	end
	
	-- Debug text
	self.fTimeline.text = self.fTimeline:CreateFontString(nil,"ARTWORK")
	self.fTimeline.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fTimeline.text:SetPoint("TOPLEFT",0,15)
	self.fTimeline.text:SetText("*** Timeline ***")
	
	if not self.db.profile.debugFrame then
		self.fTimeline.text:Hide()
	end
end

-- Things we need to do to refresh the timeline
function CooldownTimeline:SetTimelineFrame()
	-- Timeline settings
	local fTimelineRelativeTo = self.db.profile.fTimelineRelativeTo
	local fTimelinePosX = self.db.profile.fTimelinePosX
	local fTimelinePosY = self.db.profile.fTimelinePosY
	
	-- Set the timeline
	self.fTimeline:SetPoint(fTimelineRelativeTo, fTimelinePosX, fTimelinePosY)
	self.fTimeline:SetWidth(self.db.profile.fTimelineWidth)
	self.fTimeline:SetHeight(self.db.profile.fTimelineHeight)
	
	self.fTimeline:SetMinMaxValues(0, 1)
	self.fTimeline:SetReverseFill(CooldownTimeline.db.profile.fTimelineTrackingReverse)
	
	-- Set the timeline texture
	self.fTimeline:SetStatusBarTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", self.db.profile.fTimelineTexture))
	self.fTimeline:GetStatusBarTexture():SetHorizTile(false)
	self.fTimeline:GetStatusBarTexture():SetVertTile(false)
	self.fTimeline:SetStatusBarColor(
		CooldownTimeline.db.profile.fTimelineTextureColor["r"],
		CooldownTimeline.db.profile.fTimelineTextureColor["g"],
		CooldownTimeline.db.profile.fTimelineTextureColor["b"],
		CooldownTimeline.db.profile.fTimelineTextureColor["a"]
	)
	
	-- Set the timeline background
	self.fTimeline.bg:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", self.db.profile.fTimelineBackground))
	self.fTimeline.bg:SetAllPoints(true)
	self.fTimeline.bg:SetVertexColor(
		CooldownTimeline.db.profile.fTimelineBackgroundColor["r"],
		CooldownTimeline.db.profile.fTimelineBackgroundColor["g"],
		CooldownTimeline.db.profile.fTimelineBackgroundColor["b"],
		CooldownTimeline.db.profile.fTimelineBackgroundColor["a"]
	)
	
	-- Set the secondary tracker texture
	self.fTimeline.secondaryTracker:SetWidth(self.db.profile.fTimelineTrackingSecondaryWidth)
	self.fTimeline.secondaryTracker:SetHeight(self.db.profile.fTimelineTrackingSecondaryHeight)
	self.fTimeline.secondaryTracker:SetPoint("CENTER", 0 ,0)
	self.fTimeline.secondaryTracker.bg:SetAllPoints(true)
	self.fTimeline.secondaryTracker.bg:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", self.db.profile.fTimelineTrackingSecondaryTexture))
	self.fTimeline.secondaryTracker.bg:SetVertexColor(
		CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["r"],
		CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["g"],
		CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["b"],
		CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["a"]
	)
	self.fTimeline.secondaryTracker:SetFrameLevel(CooldownTimeline_Timeline:GetFrameLevel() + 1)
	
	-- Border settings
	local fTimelineBorder = CooldownTimeline.db.profile.fTimelineBorder
	local fTimelineBorderSize = CooldownTimeline.db.profile.fTimelineBorderSize
	local fTimelineBorderInset = CooldownTimeline.db.profile.fTimelineBorderInset
	local fTimelineBorderPadding = CooldownTimeline.db.profile.fTimelineBorderPadding
	local fTimelineBorderColor = CooldownTimeline.db.profile.fTimelineBorderColor
	
	-- Set the border
	CooldownTimeline:SetBorder(self.fTimeline, fTimelineBorder, fTimelineBorderSize, fTimelineBorderInset)
	CooldownTimeline:SetBorderColor(self.fTimeline, fTimelineBorderColor)
	CooldownTimeline:SetBorderPoint(self.fTimeline, fTimelineBorderPadding)
	self.fTimeline.border:SetFrameLevel(CooldownTimeline_Timeline:GetFrameLevel() + 1)
end

-- Setup the text on the timeline
-- Creating 10 'slots' to put text into, as you cannot destroy existing text and re-create it
function CooldownTimeline:SetTimelineText()
	-- Create font strings if they dont exist
	if self.fTimeline.t1 == nil then
		-- 1-5 used for 'built-in' text
		self.fTimeline.t1 = self.fTimeline:CreateFontString(nil,"ARTWORK")
		self.fTimeline.t2 = self.fTimeline:CreateFontString(nil,"ARTWORK")
		self.fTimeline.t3 = self.fTimeline:CreateFontString(nil,"ARTWORK")
		self.fTimeline.t4 = self.fTimeline:CreateFontString(nil,"ARTWORK")
		self.fTimeline.t5 = self.fTimeline:CreateFontString(nil,"ARTWORK")
		
		-- 6-10 used for custom text
		self.fTimeline.t6 = self.fTimeline:CreateFontString(nil,"ARTWORK")
		self.fTimeline.t7 = self.fTimeline:CreateFontString(nil,"ARTWORK")
		self.fTimeline.t8 = self.fTimeline:CreateFontString(nil,"ARTWORK")
		self.fTimeline.t9 = self.fTimeline:CreateFontString(nil,"ARTWORK")
		self.fTimeline.t10 = self.fTimeline:CreateFontString(nil,"ARTWORK")
	end
	
	CooldownTimeline:UpdateTimelineText()
	CooldownTimeline:DrawTimelineText()
	CooldownTimeline:DrawTimelineTextCustom()
end

function CooldownTimeline:DrawTimelineText()
	local fTimelineWidth = self.db.profile.fTimelineWidth
	local fTimelineFonts = CooldownTimeline.db.profile.fTimelineFonts
	
	--if CooldownTimeline.db.profile.unlockFrames then
	--	a = 0
	--end

	for key, tObject in pairs(CooldownTimeline.db.profile.fTimelineText) do
		if key == 1 then text = self.fTimeline.t1
		elseif key == 2 then text = self.fTimeline.t2
		elseif key == 3 then text = self.fTimeline.t3
		elseif key == 4 then text = self.fTimeline.t4
		elseif key == 5 then text = self.fTimeline.t5
		end
		
		text:ClearAllPoints()

		local tObject = CooldownTimeline.db.profile.fTimelineText[key]
		
		text:SetFont(CooldownTimeline.SharedMedia:Fetch("font", fTimelineFonts["font"]), fTimelineFonts["size"], fTimelineFonts["outline"])
		text:SetText(tObject["text"])
		
		local adjustedAlign = tObject["align"]
		local adjustedAnchor = tObject["anchor"]
		local adjustedPosition = tObject["position"]
		local adjustedXOffest = tObject["xOffset"]
		
		if CooldownTimeline.db.profile.fTimelineIconReverseDirection then
			if adjustedAlign == "LEFT" then
				adjustedAlign = "RIGHT"
			elseif adjustedAlign == "RIGHT" then
				adjustedAlign = "LEFT"
			end
			
			if adjustedAnchor == "LEFT" then
				adjustedAnchor = "RIGHT"
			elseif adjustedAnchor == "RIGHT" then
				adjustedAnchor = "LEFT"
			end
			
			adjustedPosition = -adjustedPosition
			adjustedXOffest = -adjustedXOffest
		end
		
		text:SetPoint(
			adjustedAlign,
			CooldownTimeline_Timeline,
			adjustedAnchor,
			adjustedXOffest + (fTimelineWidth * adjustedPosition),
			tObject["yOffset"] + fTimelineFonts["yOffset"]
		)
		text:SetTextColor(
			fTimelineFonts["color"]["r"],
			fTimelineFonts["color"]["g"],
			fTimelineFonts["color"]["b"],
			fTimelineFonts["color"]["a"]
		)
		text:SetShadowColor(
			fTimelineFonts["shadowColor"]["r"],
			fTimelineFonts["shadowColor"]["g"],
			fTimelineFonts["shadowColor"]["b"],
			fTimelineFonts["shadowColor"]["a"]
		)
		text:SetShadowOffset(fTimelineFonts["shadowXOffset"], fTimelineFonts["shadowYOffset"])
		text:SetNonSpaceWrap(false)
		
		if not tObject["enabled"] then
			text:SetAlpha(0)
		end
	end
end

function CooldownTimeline:DrawTimelineTextCustom()
	-- Create the custom texts if they dont exist
	if not CooldownTimeline.db.profile.fTimelineTextCustom[1] then
		CooldownTimeline.db.profile.fTimelineTextCustom[1] = {
			text = "Custom Text 1",
			font = "",
			size = 14,
			color = { r = 1, g = 1, b = 1, a = 1 },
			align = "CENTER",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
			enabled = false,
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
		}
	end
	if not CooldownTimeline.db.profile.fTimelineTextCustom[2] then
		CooldownTimeline.db.profile.fTimelineTextCustom[2] = {
			text = "Custom Text 2",
			font = "",
			size = 14,
			color = { r = 1, g = 1, b = 1, a = 1 },
			align = "CENTER",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
			enabled = false,
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
		}
	end
	if not CooldownTimeline.db.profile.fTimelineTextCustom[3] then
		CooldownTimeline.db.profile.fTimelineTextCustom[3] = {
			text = "Custom Text 3",
			font = "",
			size = 14,
			color = { r = 1, g = 1, b = 1, a = 1 },
			align = "CENTER",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
			enabled = false,
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
		}
	end
	if not CooldownTimeline.db.profile.fTimelineTextCustom[4] then
		CooldownTimeline.db.profile.fTimelineTextCustom[4] = {
			text = "Custom Text 4",
			font = "",
			size = 14,
			color = { r = 1, g = 1, b = 1, a = 1 },
			align = "CENTER",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
			enabled = false,
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
		}
	end
	if not CooldownTimeline.db.profile.fTimelineTextCustom[5] then
		CooldownTimeline.db.profile.fTimelineTextCustom[5] = {
			text = "Custom Text 5",
			font = "",
			size = 14,
			color = { r = 1, g = 1, b = 1, a = 1 },
			align = "CENTER",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
			enabled = false,
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
		}
	end
	
	-- Draw the 'custom' text
	for key, tObject in pairs(CooldownTimeline.db.profile.fTimelineTextCustom) do
		if key == 1 then text = self.fTimeline.t6
		elseif key == 2 then text = self.fTimeline.t7
		elseif key == 3 then text = self.fTimeline.t8
		elseif key == 4 then text = self.fTimeline.t9
		elseif key == 5 then text = self.fTimeline.t10
		end
		
		-- Add the new extra settings if needed
		if not tObject["outline"] then
			tObject["outline"] = "NONE"
			tObject["shadowColor"] = { r = 0, g = 0, b = 0, a = 1 }
			tObject["shadowXOffset"] = 0
			tObject["shadowYOffset"] = 0
		end
	
		if CooldownTimeline.db.profile.fTimelineTextCustom[key] then
			local tObject = CooldownTimeline.db.profile.fTimelineTextCustom[key]
			
			text:SetFont(CooldownTimeline.SharedMedia:Fetch("font", tObject["font"]), tObject["size"], tObject["outline"])
			
			local convertedText = CooldownTimeline:ConvertTextTags(tObject["text"])
			text:SetText(convertedText)
			
			local position = tObject["position"]
			text:ClearAllPoints()
			text:SetPoint(
				tObject["align"],
				CooldownTimeline_Timeline,
				tObject["anchor"],
				tObject["xOffset"],
				tObject["yOffset"]
			)
			text:SetTextColor(
				tObject["color"]["r"],
				tObject["color"]["g"],
				tObject["color"]["b"],
				tObject["color"]["a"]
			)
			text:SetShadowColor(
				tObject["shadowColor"]["r"],
				tObject["shadowColor"]["g"],
				tObject["shadowColor"]["b"],
				tObject["shadowColor"]["a"]
			)
			text:SetShadowOffset(tObject["shadowXOffset"], tObject["shadowYOffset"])
			text:SetNonSpaceWrap(false)
			
			if not tObject["enabled"] then
				text:SetAlpha(0)
			end
		end
	end
end

function CooldownTimeline:UpdateTimelineText(refresh)
	local mode = CooldownTimeline.db.profile.fTimelineMode

	if mode == "LINEAR" then		
		if not CooldownTimeline.db.profile.fTimelineText[1] or refresh then
			CooldownTimeline.db.profile.fTimelineText[1] = {
				text = "Ready",
				align = "LEFT",
				anchor = "LEFT",
				position = 0,
				xOffset = 5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[2] or refresh then
			CooldownTimeline.db.profile.fTimelineText[2] = {
				text = "50%",
				align = "CENTER",
				anchor = "LEFT",
				position = 0.5,
				xOffset = 0,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[3] or refresh then
			CooldownTimeline.db.profile.fTimelineText[3] = {
				text = "100%",
				align = "RIGHT",
				anchor = "LEFT",
				position = 1,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[4] or refresh then
			CooldownTimeline.db.profile.fTimelineText[4] = {
				text = "",
				align = "RIGHT",
				anchor = "LEFT",
				position = 1,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = false,
				used = false,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[5] or refresh then
			CooldownTimeline.db.profile.fTimelineText[5] = {
				text = "",
				align = "RIGHT",
				anchor = "LEFT",
				position = 1,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = false,
				used = false,
			}
		end
		
	elseif mode == "LINEAR_ABS" then
		local maxTime = CooldownTimeline.db.profile.fTimelineModeAbsLimit
		
		if not CooldownTimeline.db.profile.fTimelineText[1] or refresh then
			CooldownTimeline.db.profile.fTimelineText[1] = {
				text = "Ready",
				align = "LEFT",
				anchor = "LEFT",
				position = 0,
				xOffset = 5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[2] or refresh then
			CooldownTimeline.db.profile.fTimelineText[2] = {
				text = CooldownTimeline:ConvertToShortTime(maxTime / 2),
				align = "CENTER",
				anchor = "LEFT",
				position = 0.5,
				xOffset = 0,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[3] or refresh then
			CooldownTimeline.db.profile.fTimelineText[3] = {
				text = CooldownTimeline:ConvertToShortTime(maxTime),
				align = "RIGHT",
				anchor = "LEFT",
				position = 1,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[4] or refresh then
			CooldownTimeline.db.profile.fTimelineText[4] = {
				text = "",
				align = "RIGHT",
				anchor = "LEFT",
				position = 1,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = false,
				used = false,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[5] or refresh then
			CooldownTimeline.db.profile.fTimelineText[5] = {
				text = "",
				align = "RIGHT",
				anchor = "LEFT",
				position = 1,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = false,
				used = false,
			}
		end
	
	elseif mode == "SPLIT" then
		local fTimelineModeSplitCount = CooldownTimeline.db.profile.fTimelineModeSplitCount
	
		if not CooldownTimeline.db.profile.fTimelineText[1] or refresh then
			CooldownTimeline.db.profile.fTimelineText[1] = {
				text = "Ready",
				align = "LEFT",
				anchor = "LEFT",
				position = 0,
				xOffset = 5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[2] or refresh then
			CooldownTimeline.db.profile.fTimelineText[2] = {
				text = CooldownTimeline.db.profile.fTimelineModeSplit1.."%",
				align = "CENTER",
				anchor = "LEFT",
				position = 1 / (fTimelineModeSplitCount + 1),
				xOffset = 0,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[3] or refresh then
			local isUsed = false
			local generatedText = ""
			local generatedPosition = 1
			local generatedAlign = "CENTER"
			
			if fTimelineModeSplitCount == 3 then
				isUsed = true
				generatedText = CooldownTimeline.db.profile.fTimelineModeSplit2.."%"
				generatedPosition = 0.5
			elseif fTimelineModeSplitCount == 2 then
				isUsed = true
				generatedText = CooldownTimeline.db.profile.fTimelineModeSplit2.."%"
				generatedPosition = 1 / (fTimelineModeSplitCount + 1) * fTimelineModeSplitCount
			elseif fTimelineModeSplitCount == 1 then
				isUsed = true
				generatedText = CooldownTimeline.db.profile.fTimelineModeSplitLimit.."%"
				generatedAlign = "RIGHT"
			end
			
			CooldownTimeline.db.profile.fTimelineText[3] = {
				text = generatedText,
				align = generatedAlign,
				anchor = "LEFT",
				position = generatedPosition,
				xOffset = -5,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = isUsed,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[4] or refresh then
			local isUsed = false
			local generatedText = ""
			local generatedPosition = 1
			local generatedAlign = "CENTER"
			
			if fTimelineModeSplitCount == 3 then
				isUsed = true
				generatedText = CooldownTimeline.db.profile.fTimelineModeSplit3.."%"
				generatedPosition = 1 / (fTimelineModeSplitCount + 1) * fTimelineModeSplitCount
			elseif fTimelineModeSplitCount == 2 then
				isUsed = true
				generatedText = CooldownTimeline.db.profile.fTimelineModeSplitLimit.."%"
				generatedAlign = "RIGHT"
			end
		
			CooldownTimeline.db.profile.fTimelineText[4] = {
				text = generatedText,
				align = generatedAlign,
				anchor = "LEFT",
				position = generatedPosition,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = isUsed,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[5] or refresh then
			local isUsed = false
			local generatedText = ""
			
			if fTimelineModeSplitCount == 3 then
				isUsed = true
				generatedText = CooldownTimeline.db.profile.fTimelineModeSplitLimit.."%"
			end
		
			CooldownTimeline.db.profile.fTimelineText[5] = {
				text = generatedText,
				align = "RIGHT",
				anchor = "LEFT",
				position = 1,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = isUsed,
			}
		end
	
	elseif mode == "SPLIT_ABS" then
		local fTimelineModeSplitAbsCount = CooldownTimeline.db.profile.fTimelineModeSplitAbsCount
	
		if not CooldownTimeline.db.profile.fTimelineText[1] or refresh then
			CooldownTimeline.db.profile.fTimelineText[1] = {
				text = "Ready",
				align = "LEFT",
				anchor = "LEFT",
				position = 0,
				xOffset = 5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[2] or refresh then
			CooldownTimeline.db.profile.fTimelineText[2] = {
				text = CooldownTimeline:ConvertToShortTime(CooldownTimeline.db.profile.fTimelineModeSplitAbs1),
				align = "CENTER",
				anchor = "LEFT",
				position = 1 / (fTimelineModeSplitAbsCount + 1),
				xOffset = 0,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = true,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[3] or refresh then
			local isUsed = false
			local generatedText = ""
			local generatedPosition = 1
			local generatedAlign = "CENTER"
			
			if fTimelineModeSplitAbsCount == 3 then
				isUsed = true
				generatedText = CooldownTimeline:ConvertToShortTime(CooldownTimeline.db.profile.fTimelineModeSplitAbs2)
				generatedPosition = 0.5
			elseif fTimelineModeSplitAbsCount == 2 then
				isUsed = true
				generatedText = CooldownTimeline:ConvertToShortTime(CooldownTimeline.db.profile.fTimelineModeSplitAbs2)
				generatedPosition = 1 / (fTimelineModeSplitAbsCount + 1) * fTimelineModeSplitAbsCount
			elseif fTimelineModeSplitAbsCount == 1 then
				isUsed = true
				generatedText = CooldownTimeline:ConvertToShortTime(CooldownTimeline.db.profile.fTimelineModeSplitAbsLimit)
				generatedAlign = "RIGHT"
			end
			
			CooldownTimeline.db.profile.fTimelineText[3] = {
				text = generatedText,
				align = generatedAlign,
				anchor = "LEFT",
				position = generatedPosition,
				xOffset = -5,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = isUsed,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[4] or refresh then
			local isUsed = false
			local generatedText = ""
			local generatedPosition = 1
			local generatedAlign = "CENTER"
			
			if fTimelineModeSplitAbsCount == 3 then
				isUsed = true
				generatedText = CooldownTimeline:ConvertToShortTime(CooldownTimeline.db.profile.fTimelineModeSplitAbs3)
				generatedPosition = 1 / (fTimelineModeSplitAbsCount + 1) * fTimelineModeSplitAbsCount
			elseif fTimelineModeSplitAbsCount == 2 then
				isUsed = true
				generatedText = CooldownTimeline:ConvertToShortTime(CooldownTimeline.db.profile.fTimelineModeSplitAbsLimit)
				generatedAlign = "RIGHT"
			end
		
			CooldownTimeline.db.profile.fTimelineText[4] = {
				text = generatedText,
				align = generatedAlign,
				anchor = "LEFT",
				position = generatedPosition,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = isUsed,
			}
		end
		
		if not CooldownTimeline.db.profile.fTimelineText[5] or refresh then
			local isUsed = false
			local generatedText = ""
			
			if fTimelineModeSplitAbsCount == 3 then
				isUsed = true
				generatedText = CooldownTimeline:ConvertToShortTime(CooldownTimeline.db.profile.fTimelineModeSplitAbsLimit)
			end
		
			CooldownTimeline.db.profile.fTimelineText[5] = {
				text = generatedText,
				align = "RIGHT",
				anchor = "LEFT",
				position = 1,
				xOffset = -5,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1, a = 1 },
				enabled = true,
				used = isUsed,
			}
		end
		
	end
end

private.ShowEnergyTick = function()
	-- There are many cases in which we want to show the enery tick
	if CooldownTimeline.db.profile.fTimelineTracking == "ENERGY_TICK" or CooldownTimeline.db.profile.fTimelineTrackingSecondary == "ENERGY_TICK" then
		if	CooldownTimeline:AuraIsActive("player", "Stealth") or
			CooldownTimeline.inCombat or
			UnitPower("player", Enum.PowerType.Energy) < UnitPowerMax("player", Enum.PowerType.Energy) or
			UnitIsEnemy("player", "target")
		then
			return true
		else
			return false
		end
	else
		return false
	end
end

private.ShowManaTick = function()
	-- There are many cases in which we want to show the enery tick
	if CooldownTimeline.db.profile.fTimelineTracking == "MANA_TICK" or CooldownTimeline.db.profile.fTimelineTrackingSecondary == "MANA_TICK" then
		if	--CooldownTimeline.inCombat or
			UnitPower("player", Enum.PowerType.Mana) < UnitPowerMax("player", Enum.PowerType.Mana)
		then
			return true
		else
			return false
		end
	else
		return false
	end
end

private.TimelineUpdate = function(self, elapsed)
	self.showEnergyTick = private.ShowEnergyTick()
	self.showManaTick = private.ShowManaTick()

	-- Check if the frames need to be hidden or not
	if not CooldownTimeline.db.profile.enableTimeline then
		self:SetAlpha(0)
	elseif CooldownTimeline.db.profile.hideOutsideCombat or CooldownTimeline.db.profile.onlyShowWhenCoolingDown then		
		if CooldownTimeline:ShouldHide(self) and not self.showEnergyTick and not self.showManaTick then
			local fTimelineAnimateOutNew = CooldownTimeline.db.profile.fTimelineAnimateOutNew
			if fTimelineAnimateOutNew["type"] ~= "NONE" then
				if not CooldownTimeline:AnimationIsPlaying(self) then
					if self:GetAlpha() == 1 then
						CooldownTimeline:StartAnimation(
							self,
							fTimelineAnimateOutNew["type"],
							GetTime(),
							fTimelineAnimateOutNew["duration"],
							fTimelineAnimateOutNew["startValue"],
							fTimelineAnimateOutNew["endValue"],
							fTimelineAnimateOutNew["finishValue"],
							fTimelineAnimateOutNew["loop"],
							fTimelineAnimateOutNew["bounce"]
						)
					end
				end
			else
				-- Straight off
				self:SetAlpha(0)
			end
			
		else
			local fTimelineAnimateInNew = CooldownTimeline.db.profile.fTimelineAnimateInNew
			if fTimelineAnimateInNew["type"] ~= "NONE" then
				-- Via animation
				if not CooldownTimeline:AnimationIsPlaying(self) then
					if self:GetAlpha() == 0 then
						CooldownTimeline:StartAnimation(
							self,
							fTimelineAnimateInNew["type"],
							GetTime(),
							fTimelineAnimateInNew["duration"],
							fTimelineAnimateInNew["startValue"],
							fTimelineAnimateInNew["endValue"],
							fTimelineAnimateInNew["finishValue"],
							fTimelineAnimateInNew["loop"],
							fTimelineAnimateInNew["bounce"]
						)
					end
				end
			else
				-- Straight on
				self:SetAlpha(1)
			end
			
		end
	end
	
	-- Deal with frame unlocking
	if CooldownTimeline.db.profile.unlockFrames then
		CooldownTimeline:UnlockFrame(self)

		local _, _, relativeTo, xOfs, yOfs = self:GetPoint()
		
		CooldownTimeline.db.profile.fTimelineRelativeTo = relativeTo
		CooldownTimeline.db.profile.fTimelinePosX = xOfs
		CooldownTimeline.db.profile.fTimelinePosY = yOfs
	else
		CooldownTimeline:LockFrame(self)
	end
	
	if CooldownTimeline.db.profile.enableTimeline then
	
		-- Update the custom text
		if 	CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] or
			CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] or
			CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] or
			CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] or
			CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"]
		then
			CooldownTimeline:DrawTimelineTextCustom()
		end
	
		-- Update the timeline to show what its tracking(if it is tracking anything)
		local fTimelineTracking = CooldownTimeline.db.profile.fTimelineTracking
		local fTimelineTrackingInvert = CooldownTimeline.db.profile.fTimelineTrackingInvert
		if fTimelineTracking ~= "NONE" then
			local progress = private.TrackingCalc(self, elapsed, fTimelineTracking, fTimelineTrackingInvert)
			self:SetValue(progress)
		end
		
		-- Update the secondary tracking(if it is tracking anything)
		local fTimelineTrackingSecondary = CooldownTimeline.db.profile.fTimelineTrackingSecondary
		local fTimelineTrackingInvertSecondary = CooldownTimeline.db.profile.fTimelineTrackingInvertSecondary
		local fTimelineTrackingReverseSecondary = CooldownTimeline.db.profile.fTimelineTrackingReverseSecondary
		if fTimelineTrackingSecondary ~= "NONE" then
			local progress = private.TrackingCalc(self, elapsed, fTimelineTrackingSecondary, fTimelineTrackingInvertSecondary)
			
			if progress < 1 and progress > 0 then
				self.secondaryTracker:SetAlpha(1)
			else
				self.secondaryTracker:SetAlpha(0)
			end
			
			local tlWidth = CooldownTimeline.db.profile.fTimelineWidth
			local position = tlWidth * progress
			
			if fTimelineTrackingInvertSecondary then
				--position = position - tlWidth
			end
			
			self.secondaryTracker:ClearAllPoints()
			local relativePoint = "RIGHT"
			if fTimelineTrackingReverseSecondary then
				if fTimelineTrackingInvertSecondary then
					relativePoint = "RIGHT"
					position = position - tlWidth
				else
					relativePoint = "LEFT"
					position = tlWidth - position
				end
			else
				if fTimelineTrackingInvertSecondary then
					relativePoint = "LEFT"
					position = tlWidth - position
				else
					relativePoint = "RIGHT"
					position = position - tlWidth
				end
			end
			
			self.secondaryTracker:SetPoint(relativePoint, position, 0)
		else
			self.secondaryTracker:SetAlpha(0)
		end
		
		-- Sort out icon stacking
		CooldownTimeline:StackCalculator()
	end
	
	if CooldownTimeline.db.profile.debugFrame then
		self.text:Show()
		
		local children = { self:GetChildren() }
		
		local childCount = 0
		for _, child in ipairs(children) do
			if child.cdUniqueID then
				childCount = childCount + 1
			end
		end
		
		self.text:SetText("*** Timeline ("..childCount..") ***")
	else
		self.text:Hide()
	end
end

private.TrackingCalc = function(self, elapsed, toTrack, invert)
	local progress = 0
	
	-- GCD
	if toTrack == "GCD" then
		if self.onGCD then
			local start, duration, _, _ = GetSpellCooldown(8921)	-- Spell ID for Moonfire, but any spell without a cooldown can be used
			local cooldownMS, gcdMS = GetSpellBaseCooldown(8921)	-- Spell ID for Moonfire, but any spell without a cooldown can be used
			
			local timeLeft = (start + duration) - GetTime()
			
			local percent = ( timeLeft / (gcdMS / 1000))

			if timeLeft > 0 then
				progress = percent
			else
				self.onGCD = false
				progress = 1
			end
		else
			progress = 1
		end
		
	-- ENERGY_TICK
	elseif toTrack == "ENERGY_TICK" then
		self.energyTickTime = GetTime() - self.energyLastTickTime
		
		if self.energyTickTime >= 2 then
			self.energyLastTickTime = GetTime()
		end
		
		if self.showEnergyTick then
			local tickDuration = 2
			local percent = self.energyTickTime / tickDuration
			progress = percent
		else
			progress = 1
		end

	-- MANA_TICK
	elseif toTrack == "MANA_TICK" then
		self.manaTickTime = self.manaTickTime - elapsed
		
		if self.manaTickTime < 0 then
			self.manaTickTime = 2
			self.manaPreviousTickTime = GetTime()
		end
		
		if self.showManaTick then
			local percent = self.manaTickTime / self.manaTickInterval
			progress = percent
		else
			progress = 1
		end
		
	-- CLASS_POWER
	elseif toTrack == "CLASS_POWER" then
		local powerType = CooldownTimeline:GetPlayerPower(CooldownTimeline.playerClass)
		local powerMax = UnitPowerMax("player", powerType)
		local powerCurrent = UnitPower("player", powerType)
		
		if powerCurrent ~= 0 then
			local percent = powerCurrent / powerMax
			local reversePercent = math.abs(percent - 1)
			progress = percent
		end

	-- HEALTH
	elseif toTrack == "HEALTH" then
		local healthMax = UnitHealthMax("player")
		local healthCurrent = UnitHealth("player")
		
		if healthCurrent ~= 0 then
			local percent = healthCurrent / healthMax
			local reversePercent = math.abs(percent - 1)
			progress = percent
		end		

	-- COMBO_POINTS
	elseif toTrack == "COMBO_POINTS" then
		local cpMax = UnitPowerMax("player", Enum.PowerType.ComboPoints)
		local cpCurrent = UnitPower("player", Enum.PowerType.ComboPoints)
		
		if cpCurrent ~= 0 then
			local percent = cpCurrent / cpMax
			local reversePercent = math.abs(percent - 1)
			progress = percent
		end
		
	-- MH_SWING
	elseif toTrack == "MH_SWING" then
		local mhSpeed, _ = UnitAttackSpeed("player")
			
		if self.mhSwingTime < 0 then
			self:SetValue(1)
		else
			self.mhSwingTime = self.mhSwingTime - elapsed
			
			local percent = self.mhSwingTime / mhSpeed
			local reversePercent = math.abs(percent - 1)
			
			progress = percent
		end
	
	-- OH_SWING
	elseif toTrack == "OH_SWING" then
		local _, ohSpeed = UnitAttackSpeed("player")
		
		if self.mhSwingTime < 0 then
			self:SetValue(1)
		else
			self.mhSwingTime = self.mhSwingTime - elapsed
			
			local percent = self.mhSwingTime / ohSpeed
			local reversePercent = math.abs(percent - 1)
			
			progress = percent
		end
		
	-- AUTO_SHOT
	elseif toTrack == "AUTO_SHOT" then
		local rSwingTime, _, _, _, _, _ = UnitRangedDamage("player");
			
		if self.rSwingTime < 0 then
			self.rSwinging = false
			progress = 1
		else
			if self.rSwinging then
				self.rSwingTime = self.rSwingTime - elapsed
			
				local percent = self.rSwingTime / rSwingTime
				local reversePercent = math.abs(percent - 1)
				
				progress = percent
			end
		end
		
		--CooldownTimeline:Print(progress)
	end

	-- Now we set the bar progress
	if invert then
		progress = math.abs(progress - 1)
	end
	
	return progress
end