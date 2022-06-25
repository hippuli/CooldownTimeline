--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}

function CooldownTimeline:CreateBarFrame()
	-- Create the fast lane frame
	CooldownTimeline.fBar = CreateFrame("Frame", "CooldownTimeline_Bar", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	-- Create the other parts
	self.fBar.bg = self.fBar:CreateTexture(nil, "BACKGROUND")
	self.fBar.border = CreateFrame("Frame", "CooldownTimeline_Bar_Border", CooldownTimeline_Bar, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	-- Set things up 
	self.fBar.cdUniqueID = 903
	CooldownTimeline:SetBarFrame()
	
	-- OnUpdate
	self.fBar:HookScript("OnUpdate", function(self, elapsed)
		private.BarUpdate(self, elapsed)
	end)
	
	-- Drag and drop movement
	self.fBar:RegisterForDrag("LeftButton")
	self.fBar:SetScript("OnDragStart", self.fBar.StartMoving)
	self.fBar:SetScript("OnDragStop", self.fBar.StopMovingOrSizing)
	self.fBar.unlockTexture = self.fBar:CreateTexture(nil, "OVERLAY")
	self.fBar.unlockTexture:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", "Flat"))
	self.fBar.unlockTexture:SetAllPoints()
	self.fBar.unlockTexture:SetColorTexture(0.15, 0.15, 0.15, 1)
	self.fBar.unlockText = self.fBar:CreateFontString(nil, "OVERLAY")
	self.fBar.unlockText:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fBar.unlockText:SetPoint("CENTER", 0, 0)
	self.fBar.unlockText:SetText("BARS\nDrag to Move")
	if not CooldownTimeline.db.profile.unlockFrames then
		self.fBar.unlockTexture:Hide()
		self.fBar.unlockText:Hide()
	end
	
	-- Debug text
	self.fBar.text = self.fBar:CreateFontString(nil,"ARTWORK")
	self.fBar.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fBar.text:SetPoint("TOPLEFT",0,15)
	self.fBar.text:SetText("*** Bars ***")
	
	if not self.db.profile.debugFrame then
		self.fBar.text:Hide()
	end
end

function CooldownTimeline:CreateBar2Frame()
	-- Create the fast lane frame
	CooldownTimeline.fBar2 = CreateFrame("Frame", "CooldownTimeline_Bar2", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	-- Create the other parts
	self.fBar2.bg = self.fBar2:CreateTexture(nil, "BACKGROUND")
	self.fBar2.border = CreateFrame("Frame", "CooldownTimeline_Bar2_Border", CooldownTimeline_Bar, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	-- Set things up 
	self.fBar2.cdUniqueID = 904
	CooldownTimeline:SetBar2Frame()
	
	-- OnUpdate
	self.fBar2:HookScript("OnUpdate", function(self, elapsed)
		private.BarUpdate(self, elapsed)
	end)
	
	-- Drag and drop movement
	self.fBar2:RegisterForDrag("LeftButton")
	self.fBar2:SetScript("OnDragStart", self.fBar2.StartMoving)
	self.fBar2:SetScript("OnDragStop", self.fBar2.StopMovingOrSizing)
	self.fBar2.unlockTexture = self.fBar2:CreateTexture(nil, "OVERLAY")
	self.fBar2.unlockTexture:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", "Flat"))
	self.fBar2.unlockTexture:SetAllPoints()
	self.fBar2.unlockTexture:SetColorTexture(0.15, 0.15, 0.15, 1)
	self.fBar2.unlockText = self.fBar2:CreateFontString(nil, "OVERLAY")
	self.fBar2.unlockText:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fBar2.unlockText:SetPoint("CENTER", 0, 0)
	self.fBar2.unlockText:SetText("BARS 2\nDrag to Move")
	if not CooldownTimeline.db.profile.unlockFrames then
		self.fBar2.unlockTexture:Hide()
		self.fBar2.unlockText:Hide()
	end
	
	-- Debug text
	self.fBar2.text = self.fBar2:CreateFontString(nil,"ARTWORK")
	self.fBar2.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fBar2.text:SetPoint("TOPLEFT",0,15)
	self.fBar2.text:SetText("*** Bars 2 ***")
	
	if not self.db.profile.debugFrame then
		self.fBar2.text:Hide()
	end
end

-- Things we need to do to refresh the timeline
function CooldownTimeline:SetBarFrame()
	-- Timeline settings
	local fBarFramePosX = self.db.profile.fBarFramePosX
	local fBarFramePosY = self.db.profile.fBarFramePosY
	local fBarWidth = self.db.profile.fBarWidth
	local fBarHeight = self.db.profile.fBarHeight
	local fBarFramePadding = self.db.profile.fBarFramePadding
	local fBarFrameGrow = self.db.profile.fBarFrameGrow
	local fBarFrameRelativeTo = self.db.profile.fBarFrameRelativeTo
	
	-- Set the timeline
	local anchorPoint = "CENTER"
	if fBarFrameGrow == "UP" then
		anchorPoint = "BOTTOM"
		fBarFramePosY = fBarFramePosY - (fBarHeight / 2)
	elseif fBarFrameGrow == "DOWN" then
		anchorPoint = "TOP"
		fBarFramePosY = fBarFramePosY
		fBarFramePosY = fBarFramePosY + (fBarHeight / 2)
	end
	
	-- Set the timeline
	self.fBar:SetPoint(anchorPoint, UIParent, fBarFrameRelativeTo, fBarFramePosX, fBarFramePosY)
	self.fBar:SetWidth(fBarWidth + (fBarFramePadding * 2))
	self.fBar:SetHeight(fBarHeight + (fBarFramePadding * 2))
	
	-- Set the timeline background
	self.fBar.bg:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", self.db.profile.fBarFrameBackground))
	self.fBar.bg:SetAllPoints(true)
	self.fBar.bg:SetVertexColor(
		CooldownTimeline.db.profile.fBarFrameBackgroundColor["r"],
		CooldownTimeline.db.profile.fBarFrameBackgroundColor["g"],
		CooldownTimeline.db.profile.fBarFrameBackgroundColor["b"],
		CooldownTimeline.db.profile.fBarFrameBackgroundColor["a"]
	)
		
	-- Border settings
	local fBarBorder = CooldownTimeline.db.profile.fBarBorder
	local fBarBorderSize = CooldownTimeline.db.profile.fBarBorderSize
	local fBarBorderInset = CooldownTimeline.db.profile.fBarBorderInset
	local fBarBorderPadding = CooldownTimeline.db.profile.fBarBorderPadding
	local fBarBorderColor = CooldownTimeline.db.profile.fBarBorderColor
	
	-- Set the border
	CooldownTimeline:SetBorder(self.fBar, fBarBorder, fBarBorderSize, fBarBorderInset)
	CooldownTimeline:SetBorderColor(self.fBar, fBarBorderColor)
	CooldownTimeline:SetBorderPoint(self.fBar, fBarBorderPadding)
	self.fBar.border:SetFrameLevel(CooldownTimeline_Bar:GetFrameLevel() + 1)
end

function CooldownTimeline:SetBar2Frame()
	-- Timeline settings
	local fBarFramePosX = self.db.profile.fBar2FramePosX
	local fBarFramePosY = self.db.profile.fBar2FramePosY
	local fBarWidth = self.db.profile.fBar2Width
	local fBarHeight = self.db.profile.fBar2Height
	local fBarFramePadding = self.db.profile.fBar2FramePadding
	local fBarFrameGrow = self.db.profile.fBar2FrameGrow
	local fBarFrameRelativeTo = self.db.profile.fBar2FrameRelativeTo
	
	-- Set the timeline
	local anchorPoint = "CENTER"
	if fBarFrameGrow == "UP" then
		anchorPoint = "BOTTOM"
	elseif fBarFrameGrow == "DOWN" then
		anchorPoint = "TOP"
	end
	
	self.fBar2:SetPoint(anchorPoint, UIParent, fBarFrameRelativeTo, fBarFramePosX, fBarFramePosY)
	self.fBar2:SetWidth(fBarWidth + (fBarFramePadding * 2))
	self.fBar2:SetHeight(fBarHeight + (fBarFramePadding * 2))
	
	-- Set the timeline background
	self.fBar2.bg:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", self.db.profile.fBar2FrameBackground))
	self.fBar2.bg:SetAllPoints(true)
	self.fBar2.bg:SetVertexColor(
		CooldownTimeline.db.profile.fBar2FrameBackgroundColor["r"],
		CooldownTimeline.db.profile.fBar2FrameBackgroundColor["g"],
		CooldownTimeline.db.profile.fBar2FrameBackgroundColor["b"],
		CooldownTimeline.db.profile.fBar2FrameBackgroundColor["a"]
	)
		
	-- Border settings
	local fBarBorder = CooldownTimeline.db.profile.fBar2Border
	local fBarBorderSize = CooldownTimeline.db.profile.fBar2BorderSize
	local fBarBorderInset = CooldownTimeline.db.profile.fBar2BorderInset
	local fBarBorderPadding = CooldownTimeline.db.profile.fBar2BorderPadding
	local fBarBorderColor = CooldownTimeline.db.profile.fBar2BorderColor
	
	-- Set the border
	CooldownTimeline:SetBorder(self.fBar2, fBarBorder, fBarBorderSize, fBarBorderInset)
	CooldownTimeline:SetBorderColor(self.fBar2, fBarBorderColor)
	CooldownTimeline:SetBorderPoint(self.fBar2, fBarBorderPadding)
	self.fBar2.border:SetFrameLevel(CooldownTimeline_Bar2:GetFrameLevel() + 1)
end

function CooldownTimeline:CreateCooldownBar(data)
	local name = "CooldownTimeline_Bar_"..tostring(data["name"])
	local f = CreateFrame("StatusBar", name, CooldownTimeline_Bar, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	f.cdUniqueID = CooldownTimeline:AssignUniqueID()
	f.cdName = data["name"]
	f.cdType = data["type"]
	f.cdID = data["id"]
	f.cdIcon = data["icon"]
	
	-- Create the required parts
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	
	f.ti = CreateFrame("Frame", name.."TI", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.ti:SetParent(name)
	
	f.text = CreateFrame("Frame", name.."Text", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.text:SetParent(name)
	
	f.icon = CreateFrame("Frame", name.."Icon", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.icon:SetParent(name)
	f.icon.tex = f.icon:CreateTexture()
	
	f.ti.bg = f.ti:CreateTexture(nil, "BACKGROUND")
	f.text.text1 = f.text:CreateFontString(nil, "ARTWORK")
	f.text.text2 = f.text:CreateFontString(nil, "ARTWORK")
	f.text.text3 = f.text:CreateFontString(nil, "ARTWORK")
	
	-- Set the bar
	CooldownTimeline:RefreshBar(f)
	
	-- OnUpdate
	f:HookScript("OnUpdate", function(self, elapsed)
		private.CooldownBarUpdate(self, elapsed)
	end)
	
	-- Show the icon unique ID if we are in debug mode
	f.textID = f:CreateFontString(nil,"ARTWORK")
	f.textID:SetFont("Fonts\\ARIALN.ttf", 10, "OUTLINE")
	f.textID:SetPoint("TOPLEFT",2,-2)
	f.textID:SetText(f.cdUniqueID)
	
	f.textName = f:CreateFontString(nil,"ARTWORK")
	f.textName:SetFont("Fonts\\ARIALN.ttf", 10, "OUTLINE")
	f.textName:SetPoint("BOTTOMLEFT",2,-2)
	--f.textName:SetText(f:GetName())
	f.textName:SetText(f:GetName():gsub("CooldownTimeline_", ""))
	
	if not self.db.profile.debugFrame then
		f.textID:Hide()
		f.textName:Hide()
	end
	
	-- Finally, add the icon to the icon table
	table.insert(CooldownTimeline.barTable, f)
end

private.BarUpdate = function(self, elapsed)
	if not CooldownTimeline.db.profile.enableBars then
		self:SetAlpha(0)
	elseif CooldownTimeline.db.profile.hideOutsideCombat or CooldownTimeline.db.profile.onlyShowWhenCoolingDown then
		if CooldownTimeline:ShouldHide(self) then
			-- Straight off
			--self:SetAlpha(0)

			local fBarFrameAnimateOut = CooldownTimeline.db.profile.fBarFrameAnimateOut
			if self:GetName() == "CooldownTimeline_Bar2" then
				fBarFrameAnimateOut = CooldownTimeline.db.profile.fBar2FrameAnimateOut
			end
			
			if fBarFrameAnimateOut["type"] ~= "NONE" then
				if not CooldownTimeline:AnimationIsPlaying(self) then
					if self:GetAlpha() == 1 then
						CooldownTimeline:StartAnimation(
							self,
							fBarFrameAnimateOut["type"],
							GetTime(),
							fBarFrameAnimateOut["duration"],
							fBarFrameAnimateOut["startValue"],
							fBarFrameAnimateOut["endValue"],
							fBarFrameAnimateOut["finishValue"],
							fBarFrameAnimateOut["loop"],
							fBarFrameAnimateOut["bounce"]
						)
					end
				end
			else
				-- Straight off
				self:SetAlpha(0)
			end
		else
			local fBarFrameAnimateIn = CooldownTimeline.db.profile.fBarFrameAnimateIn
			if self:GetName() == "CooldownTimeline_Bar2" then
				fBarFrameAnimateIn = CooldownTimeline.db.profile.fBar2FrameAnimateIn
			end
			
			if fBarFrameAnimateIn["type"] ~= "NONE" then
				-- Via animation
				if not CooldownTimeline:AnimationIsPlaying(self) then
					if self:GetAlpha() == 0 then
						CooldownTimeline:StartAnimation(
							self,
							fBarFrameAnimateIn["type"],
							GetTime(),
							fBarFrameAnimateIn["duration"],
							fBarFrameAnimateIn["startValue"],
							fBarFrameAnimateIn["endValue"],
							fBarFrameAnimateIn["finishValue"],
							fBarFrameAnimateIn["loop"],
							fBarFrameAnimateIn["bounce"]
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
		
		if self:GetName() == "CooldownTimeline_Bar2" then
			CooldownTimeline.db.profile.fBar2FrameRelativeTo = relativeTo
			CooldownTimeline.db.profile.fBar2FramePosX = xOfs
			CooldownTimeline.db.profile.fBar2FramePosY = yOfs
		else
			CooldownTimeline.db.profile.fBarFrameRelativeTo = relativeTo
			CooldownTimeline.db.profile.fBarFramePosX = xOfs
			CooldownTimeline.db.profile.fBarFramePosY = yOfs
		end
	else
		CooldownTimeline:LockFrame(self)
	end
	
	local fBarWidth = CooldownTimeline.db.profile.fBarWidth
	local fBarHeight = CooldownTimeline.db.profile.fBarHeight
	local fBarXPadding = CooldownTimeline.db.profile.fBarXPadding
	local fBarYPadding = CooldownTimeline.db.profile.fBarYPadding
	local fBarFramePadding = CooldownTimeline.db.profile.fBarFramePadding
	local fBarFrameGrow = CooldownTimeline.db.profile.fBarFrameGrow
	local fBarFrameSort = CooldownTimeline.db.profile.fBarFrameSort
	local fBarShowIcon = CooldownTimeline.db.profile.fBarShowIcon
	local fBarIconPosition = CooldownTimeline.db.profile.fBarIconPosition
	
	if self:GetName() == "CooldownTimeline_Bar2" then
		fBarWidth = CooldownTimeline.db.profile.fBar2Width
		fBarHeight = CooldownTimeline.db.profile.fBar2Height
		fBarXPadding = CooldownTimeline.db.profile.fBar2XPadding
		fBarYPadding = CooldownTimeline.db.profile.fBar2YPadding
		fBarFramePadding = CooldownTimeline.db.profile.fBar2FramePadding
		fBarFrameGrow = CooldownTimeline.db.profile.fBar2FrameGrow
		fBarFrameSort = CooldownTimeline.db.profile.fBar2FrameSort
		fBarShowIcon = CooldownTimeline.db.profile.fBar2ShowIcon
		fBarIconPosition = CooldownTimeline.db.profile.fBar2IconPosition
	end
	
	local totalWidth = fBarWidth + (fBarFramePadding * 2)
	local totalHeight = fBarHeight + (fBarFramePadding * 2)
	
	local children = { self:GetChildren() }
	local activeChildren = {}
	local childCount = 0
	for _, child in ipairs(children) do
		-- Only want icons, not other frames attached to the timeline
		if child.cdUniqueID then
			if not child.ignored then
				table.insert(activeChildren, child)
				childCount = childCount + 1
			end
		end
	end
	
	if childCount > 0 then
		totalHeight = fBarHeight * childCount
		totalHeight = totalHeight + (fBarFramePadding * 2)
		
		totalWidth = fBarWidth
		totalWidth = totalWidth + (fBarFramePadding * 2)
			
		totalHeight = totalHeight + (fBarYPadding * (childCount -1))
		totalWidth = totalWidth + (fBarXPadding * (childCount -1))
	else
		totalHeight = fBarHeight + (fBarYPadding * 2)
		totalWidth = fBarWidth + (fBarXPadding * 2)
	end
	
	self:SetSize(totalWidth, totalHeight)
	
	local barIconOffset = 0
	local barPosition = "CENTER"
	if fBarShowIcon then
		barIconOffset = fBarHeight / 2
		if fBarIconPosition == "LEFT" then
			--barPosition = "RIGHT"
			--barIconOffset = barIconOffset
		else
			barIconOffset = -barIconOffset
		end
	end
	
	for key, child in ipairs(activeChildren) do
		local xPosition = 0
		local yPosition = fBarHeight * (key - 1)
		
		xPosition = xPosition - (totalWidth / 2) + (fBarWidth / 2) + fBarFramePadding + barIconOffset
		yPosition = yPosition - (totalHeight / 2) + (fBarHeight / 2) + fBarFramePadding
		
		if key > 1 then
			xPosition = xPosition + (fBarXPadding * (key - 1))
			yPosition = yPosition + (fBarYPadding * (key - 1))			
		end
		
		child:ClearAllPoints()
		if fBarFrameGrow == "UP" then
			child:SetPoint(barPosition, xPosition, yPosition)
		else
			child:SetPoint(barPosition, xPosition, -yPosition)
		end
		
		if child.highlighted then
			child:SetFrameLevel(20)
		else
			child:SetFrameLevel(10)
		end
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
		
		if self:GetName() == "CooldownTimeline_Bar2" then
			self.text:SetText("*** Bars2 ("..childCount..") ***")
		else
			self.text:SetText("*** Bars ("..childCount..") ***")
		end
	else
		self.text:Hide()
	end
end

private.CooldownBarUpdate = function(frame, elapsed)
	if CooldownTimeline.db.profile.debugFrame then
		frame.textID:Show()
		frame.textName:Show()
	else
		frame.textID:Hide()
		frame.textName:Hide()
	end
	
	local fBarOnlyShowOverThreshold = CooldownTimeline.db.profile.fBarOnlyShowOverThreshold
	local fBarTransitionIndicator = CooldownTimeline.db.profile.fBarTransitionIndicator
	
	if frame:GetParent():GetName() == "CooldownTimeline_Bar2" then
		fBarOnlyShowOverThreshold = CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold
		fBarTransitionIndicator = CooldownTimeline.db.profile.fBar2TransitionIndicator
	end
	
	if fBarOnlyShowOverThreshold and fBarTransitionIndicator then
		frame.ti:Show()
	else
		frame.ti:Hide()
	end
end