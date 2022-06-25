--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}

function CooldownTimeline:CreateReadyFrame()
	-- Create the main ready frame
	self.fReady = CreateFrame("Frame", "CooldownTimeline_Ready", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
		
	-- Create the other parts
	self.fReady.bg = self.fReady:CreateTexture(nil, "BACKGROUND")
	self.fReady.border = CreateFrame("Frame", "CooldownTimeline_Ready_Border", CooldownTimeline_Ready, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	-- Set things up 
	self.fReady.cdUniqueID = 901
	CooldownTimeline:SetReadyFrame()
	self.fReady.outOfCombatTimer = -1

	self.fReady:HookScript("OnUpdate", function(self,elapsed)
		private.ReadyUpdate(self, elapsed)
	end)
	
	-- Setup the ability to drag and drop move the frame
	self.fReady:RegisterForDrag("LeftButton")
	self.fReady:SetScript("OnDragStart", self.fReady.StartMoving)
	self.fReady:SetScript("OnDragStop", self.fReady.StopMovingOrSizing)
	self.fReady.unlockTexture = self.fReady:CreateTexture(nil, "OVERLAY")
	self.fReady.unlockTexture:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", "Flat"))
	self.fReady.unlockTexture:SetAllPoints()
	self.fReady.unlockTexture:SetColorTexture(0.15, 0.15, 0.15, 1)
	self.fReady.unlockText = self.fReady:CreateFontString(nil,"OVERLAY")
	self.fReady.unlockText:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fReady.unlockText:SetPoint("CENTER", 0, 0)
	self.fReady.unlockText:SetText("READY\nDrag to Move")
	if not CooldownTimeline.db.profile.unlockFrames then
		self.fReady.unlockTexture:Hide()
		self.fReady.unlockText:Hide()
	end
	
	-- Debug text
	self.fReady.text = self.fReady:CreateFontString(nil,"ARTWORK")
	self.fReady.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fReady.text:SetPoint("TOPLEFT",0,15)
	self.fReady.text:SetText("*** Ready ***")
	
	if not self.db.profile.debugFrame then
		self.fReady.text:Hide()
	end
end

function CooldownTimeline:SetReadyFrame()
	-- Ready settings
	local fReadyRelativeTo = self.db.profile.fReadyRelativeTo
	local fReadyPosX = self.db.profile.fReadyPosX
	local fReadyPosY = self.db.profile.fReadyPosY
	local fReadyIconSize = self.db.profile.fReadyIconSize
	
	-- Set the ready frame
	self.fReady:SetPoint(fReadyRelativeTo, fReadyPosX, fReadyPosY)
	self.fReady:SetWidth(fReadyIconSize)
	self.fReady:SetHeight(fReadyIconSize)
	
	-- Set the ready background
	self.fReady.bg:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", self.db.profile.fReadyTexture))
	self.fReady.bg:SetAllPoints(true)
	self.fReady.bg:SetVertexColor(
		self.db.profile.fReadyTextureColor["r"],
		self.db.profile.fReadyTextureColor["g"],
		self.db.profile.fReadyTextureColor["b"],
		self.db.profile.fReadyTextureColor["a"]
	)
	
	-- Border settings
	local fReadyBorder = CooldownTimeline.db.profile.fReadyBorder
	local fReadyBorderSize = CooldownTimeline.db.profile.fReadyBorderSize
	local fReadyBorderInset = CooldownTimeline.db.profile.fReadyBorderInset
	local fReadyBorderPadding = CooldownTimeline.db.profile.fReadyBorderPadding
	local fReadyBorderColor = CooldownTimeline.db.profile.fReadyBorderColor
	
	-- Set the border
	CooldownTimeline:SetBorder(self.fReady, fReadyBorder, fReadyBorderSize, fReadyBorderInset)
	CooldownTimeline:SetBorderColor(self.fReady, fReadyBorderColor)
	CooldownTimeline:SetBorderPoint(self.fReady, fReadyBorderPadding)
	self.fReady.border:SetFrameLevel(CooldownTimeline_Ready:GetFrameLevel() + 1)
end

private.ReadyUpdate = function(self, elapsed)
	-- Check if the frames need to be hidden or not
	if CooldownTimeline.db.profile.fIconHighlightPin then
		if self.outOfCombatTimer > 0 then
			self.outOfCombatTimer = self.outOfCombatTimer - elapsed
		end
	end
	
	if not CooldownTimeline.db.profile.enableReady then
		self:SetAlpha(0)
	elseif CooldownTimeline.db.profile.hideOutsideCombat or CooldownTimeline.db.profile.onlyShowWhenCoolingDown then
		if CooldownTimeline:ShouldHide(self) then
			local fReadyAnimateOutNew = CooldownTimeline.db.profile.fReadyAnimateOutNew
			if fReadyAnimateOutNew["type"] ~= "NONE" then
				if not CooldownTimeline:AnimationIsPlaying(self) then
					if self:GetAlpha() == 1 then
						CooldownTimeline:StartAnimation(
							self,
							fReadyAnimateOutNew["type"],
							GetTime(),
							fReadyAnimateOutNew["duration"],
							fReadyAnimateOutNew["startValue"],
							fReadyAnimateOutNew["endValue"],
							fReadyAnimateOutNew["finishValue"],
							fReadyAnimateOutNew["loop"],
							fReadyAnimateOutNew["bounce"]
						)
					end
				end
			else
				-- Straight off
				self:SetAlpha(0)
			end
			
		else
			local fReadyAnimateInNew = CooldownTimeline.db.profile.fReadyAnimateInNew
			if fReadyAnimateInNew["type"] ~= "NONE" then
				-- Via animation
				if not CooldownTimeline:AnimationIsPlaying(self) then
					if self:GetAlpha() == 0 then
						CooldownTimeline:StartAnimation(
							self,
							fReadyAnimateInNew["type"],
							GetTime(),
							fReadyAnimateInNew["duration"],
							fReadyAnimateInNew["startValue"],
							fReadyAnimateInNew["endValue"],
							fReadyAnimateInNew["finishValue"],
							fReadyAnimateInNew["loop"],
							fReadyAnimateInNew["bounce"]
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
		
		CooldownTimeline.db.profile.fReadyRelativeTo = relativeTo
		CooldownTimeline.db.profile.fReadyPosX = xOfs
		CooldownTimeline.db.profile.fReadyPosY = yOfs
	else
		CooldownTimeline:LockFrame(self)
	end
	
	local fReadyIconSize = CooldownTimeline.db.profile.fReadyIconSize
	local fReadyFramePadding = CooldownTimeline.db.profile.fReadyFramePadding
	local fReadyVertical = CooldownTimeline.db.profile.fReadyVertical
	local fReadyIconGrow = CooldownTimeline.db.profile.fReadyIconGrow
	local fReadyIconPadding = CooldownTimeline.db.profile.fReadyIconPadding

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
	
	local totalWidth = fReadyIconSize
	local totalHeight = fReadyIconSize + (fReadyFramePadding * 2)
	
	-- Adjust for padding
	local paddingAdjustment = 0
	if childCount > 0 then
		totalWidth = fReadyIconSize * childCount
		paddingAdjustment = fReadyIconPadding * (childCount -1)
	end
	totalWidth = totalWidth + paddingAdjustment + (fReadyFramePadding * 2)
	
	for key, child in ipairs(activeChildren) do
		local position = fReadyIconSize * (key -1)
		
		position = position - (totalWidth / 2) + (fReadyIconSize / 2) + fReadyFramePadding
		if key > 1 then
			position = position + (fReadyIconPadding * (key - 1))
		end
		
		if fReadyVertical then
			child:SetPoint("CENTER", 0, -position)
		else
			child:SetPoint("CENTER", position, 0)
		end
		
		if child.highlighted then
			child:SetFrameLevel(20)
		else
			child:SetFrameLevel(10)
		end
	end

	local fReadyPosX = CooldownTimeline.db.profile.fReadyPosX
	local fReadyPosY = CooldownTimeline.db.profile.fReadyPosY
	
	if fReadyIconGrow == "CENTER" then
	elseif fReadyIconGrow == "LEFT" or fReadyIconGrow == "UP" then
		if CooldownTimeline.db.profile.fReadyVertical then
			fReadyPosY = fReadyPosY + (totalWidth / 2) - (fReadyIconSize / 2)
		else
			fReadyPosX = fReadyPosX - (totalWidth / 2) + (fReadyIconSize / 2)
		end
	elseif fReadyIconGrow == "RIGHT" or fReadyIconGrow == "DOWN" then
		if CooldownTimeline.db.profile.fReadyVertical then
			fReadyPosY = fReadyPosY - (totalWidth / 2) + (fReadyIconSize / 2)
		else
			fReadyPosX = fReadyPosX + (totalWidth / 2) - (fReadyIconSize / 2)
		end
	end
	
	if fReadyVertical then
		--self:SetSize(fReadyIconSize, totalWidth)
		self:SetSize(totalHeight, totalWidth)
	else
		--self:SetSize(totalWidth, fReadyIconSize)
		self:SetSize(totalWidth, totalHeight)
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
		
		self.text:SetText("*** Ready ("..childCount..") ***")
	else
		self.text:Hide()
	end
end