--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}

function CooldownTimeline:CreateFastlaneFrame()
	-- Create the fast lane frame
	CooldownTimeline.fFastlane = CreateFrame("Frame", "CooldownTimeline_Fastlane", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	-- Create the other parts
	self.fFastlane.bg = self.fFastlane:CreateTexture(nil, "BACKGROUND")
	self.fFastlane.border = CreateFrame("Frame", "CooldownTimeline_Fastlane_Border", CooldownTimeline_Fastlane, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.fFastlane.text = self.fFastlane:CreateFontString(nil, "ARTWORK")
	
	-- Set things up 
	self.fFastlane.cdUniqueID = 902
	CooldownTimeline:SetFastlaneFrame()
	
	-- OnUpdate
	self.fFastlane:HookScript("OnUpdate", function(self, elapsed)
		private.FastlaneUpdate(self, elapsed)
	end)
	
	-- Drag and drop movement
	self.fFastlane:RegisterForDrag("LeftButton")
	self.fFastlane:SetScript("OnDragStart", self.fFastlane.StartMoving)
	self.fFastlane:SetScript("OnDragStop", self.fFastlane.StopMovingOrSizing)
	self.fFastlane.unlockTexture = self.fFastlane:CreateTexture(nil, "OVERLAY")
	self.fFastlane.unlockTexture:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", "Flat"))
	self.fFastlane.unlockTexture:SetAllPoints()
	self.fFastlane.unlockTexture:SetColorTexture(0.15, 0.15, 0.15, 1)
	self.fFastlane.unlockText = self.fFastlane:CreateFontString(nil, "OVERLAY")
	self.fFastlane.unlockText:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fFastlane.unlockText:SetPoint("CENTER", 0, 0)
	self.fFastlane.unlockText:SetText("FASTLANE\nDrag to Move")
	if not CooldownTimeline.db.profile.unlockFrames then
		self.fFastlane.unlockTexture:Hide()
		self.fFastlane.unlockText:Hide()
	end
	
	-- Debug text
	self.fFastlane.text = self.fFastlane:CreateFontString(nil,"ARTWORK")
	self.fFastlane.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fFastlane.text:SetPoint("TOPLEFT",0,15)
	self.fFastlane.text:SetText("*** Fastlane ***")
	
	if not self.db.profile.debugFrame then
		self.fFastlane.text:Hide()
	end
end

-- Things we need to do to refresh the timeline
function CooldownTimeline:SetFastlaneFrame()
	-- Timeline settings
	local fFastlaneRelativeTo = self.db.profile.fFastlaneRelativeTo
	local fFastlanePosX = self.db.profile.fFastlanePosX
	local fFastlanePosY = self.db.profile.fFastlanePosY
	local fFastlaneWidth = self.db.profile.fFastlaneWidth
	local fFastlaneHeight = self.db.profile.fFastlaneHeight
	
	local fFastlaneBackground = self.db.profile.fFastlaneBackground
	local fFastlaneBackgroundColor = self.db.profile.fFastlaneBackgroundColor
	
	-- Set the timeline
	self.fFastlane:SetPoint(fFastlaneRelativeTo, fFastlanePosX, fFastlanePosY)
	self.fFastlane:SetWidth(fFastlaneWidth)
	self.fFastlane:SetHeight(fFastlaneHeight)
	
	-- Set the timeline background
	self.fFastlane.bg:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", fFastlaneBackground))
	self.fFastlane.bg:SetAllPoints(true)
	self.fFastlane.bg:SetVertexColor(
		fFastlaneBackgroundColor["r"],
		fFastlaneBackgroundColor["g"],
		fFastlaneBackgroundColor["b"],
		fFastlaneBackgroundColor["a"]
	)
	
	-- Border settings
	local fFastlaneBorder = CooldownTimeline.db.profile.fFastlaneBorder
	local fFastlaneBorderSize = CooldownTimeline.db.profile.fFastlaneBorderSize
	local fFastlaneBorderInset = CooldownTimeline.db.profile.fFastlaneBorderInset
	local fFastlaneBorderPadding = CooldownTimeline.db.profile.fFastlaneBorderPadding
	local fFastlaneBorderColor = CooldownTimeline.db.profile.fFastlaneBorderColor
	
	-- Set the border
	CooldownTimeline:SetBorder(self.fFastlane, fFastlaneBorder, fFastlaneBorderSize, fFastlaneBorderInset)
	CooldownTimeline:SetBorderColor(self.fFastlane, fFastlaneBorderColor)
	CooldownTimeline:SetBorderPoint(self.fFastlane, fFastlaneBorderPadding)
	self.fFastlane.border:SetFrameLevel(CooldownTimeline_Fastlane:GetFrameLevel() + 1)
end

private.FastlaneUpdate = function(self, elapsed)
	if not CooldownTimeline.db.profile.enableFastlane then
		self:SetAlpha(0)
	elseif CooldownTimeline.db.profile.hideOutsideCombat or CooldownTimeline.db.profile.onlyShowWhenCoolingDown then
		if CooldownTimeline:ShouldHide(self) then
			-- Straight off
			--self:SetAlpha(0)
			
			local fFastlaneAnimateOut = CooldownTimeline.db.profile.fFastlaneAnimateOut
			if fFastlaneAnimateOut["type"] ~= "NONE" then
				if not CooldownTimeline:AnimationIsPlaying(self) then
					if self:GetAlpha() == 1 then
						CooldownTimeline:StartAnimation(
							self,
							fFastlaneAnimateOut["type"],
							GetTime(),
							fFastlaneAnimateOut["duration"],
							fFastlaneAnimateOut["startValue"],
							fFastlaneAnimateOut["endValue"],
							fFastlaneAnimateOut["finishValue"],
							fFastlaneAnimateOut["loop"],
							fFastlaneAnimateOut["bounce"]
						)
					end
				end
			else
				-- Straight off
				self:SetAlpha(0)
			end
		else
			-- Straight on
			--self:SetAlpha(1)
			
			local fFastlaneAnimateIn = CooldownTimeline.db.profile.fFastlaneAnimateIn
			if fFastlaneAnimateIn["type"] ~= "NONE" then
				-- Via animation
				if not CooldownTimeline:AnimationIsPlaying(self) then
					if self:GetAlpha() == 0 then
						CooldownTimeline:StartAnimation(
							self,
							fFastlaneAnimateIn["type"],
							GetTime(),
							fFastlaneAnimateIn["duration"],
							fFastlaneAnimateIn["startValue"],
							fFastlaneAnimateIn["endValue"],
							fFastlaneAnimateIn["finishValue"],
							fFastlaneAnimateIn["loop"],
							fFastlaneAnimateIn["bounce"]
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
		
		CooldownTimeline.db.profile.fFastlaneRelativeTo = relativeTo
		CooldownTimeline.db.profile.fFastlanePosX = xOfs
		CooldownTimeline.db.profile.fFastlanePosY = yOfs
	else
		CooldownTimeline:LockFrame(self)
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
		
		self.text:SetText("*** Fastlane ("..childCount..") ***")
	else
		self.text:Hide()
	end
end