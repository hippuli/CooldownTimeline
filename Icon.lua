--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}

-- Create, or find and show an existing spell icon
function CooldownTimeline:CreateCooldownIcon(data)
	-- Create the icon frame
	local name = "CooldownTimeline_"..tostring(data["name"])
	local f = CreateFrame("Button", name, CooldownTimeline_Active, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	-- Create the other parts
	f.text = f:CreateFontString(nil, "ARTWORK")
	f.tex = f:CreateTexture()
	f.border = CreateFrame("Frame", name.."_Border", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.border:SetParent(name)
	f.highlightBorder = CreateFrame("Frame", name.."_HL_Border", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.highlightBorder:SetParent(name)
	--f.highlightBorder:SetAlpha(0)
	
	-- Setup the icon variables
	f.cdUniqueID = CooldownTimeline:AssignUniqueID()
	f.cdName = data["name"]
	f.cdType = data["type"]
	f.cdID = data["id"]
	f.target = ""
	f.cdIcon = 134400	-- Question mark icon
	f.cdStart = 0
	f.cdEnabled = 1
	f.cdBaseDuration = 1
	f.cdRemaining = 1
	f.stackOffset = 0
	f.hasCooldown = true
	f.ignored = false
	f.highlighted = false
	f.equippable = false
	f.fastlane = CooldownTimeline:SpellIsInFastLane(f.cdName, f.cdType)
	f.bar = CooldownTimeline:SpellShowBar(f.cdName, f.cdType)
	f.updateCount = 0
	f.readyStart = 0
	--f.stacks = 0
	f.mouseover = false
	f.createdBar = false
	
	--f.animationStart
	
	-- Get the icon texture
	if f.cdType == "SPELL" or f.cdType == "PETSPELL" then
		local _,_,spellIcon,_,_,_,_ = GetSpellInfo(f.cdID)
		f.cdIcon = spellIcon
	elseif f.cdType == "ITEM" then
		f.cdIcon = GetItemIcon(f.cdID)
		--f.cdSID = data["sid"]
	elseif f.cdType == "BUFF" or f.cdType == "DEBUFF" or f.cdType == "OAURA" then
		local _,_,spellIcon,_,_,_,_ = GetSpellInfo(f.cdID)
		f.cdIcon = spellIcon
	end
	
	if f.cdType == "OAURA" then
		f.target = data["target"]
	end
	
	-- Finally, add the icon to the icon table
	table.insert(CooldownTimeline.iconTable, f)
	
	-- Set things up
	CooldownTimeline:SendToTimeline(f)
	CooldownTimeline:RefreshIcon(f)
	f.agIN, f.agOUT, f.agHL = CooldownTimeline:SetIconAnimations(f)
	if f.cdType == "ITEM" then
		f.equippable = IsEquippableItem(f.cdID)
	end
	
	-- On update
	f:HookScript("OnUpdate", function(self, elapsed)
		private.IconUpdate(self, elapsed)
	end)
	
	f:SetScript("OnEnter", function(self)		
		if CooldownTimeline.db.profile.enableTooltips then
			self.mouseover = true
			
			local scale, cursorX, cursorY = f:GetEffectiveScale(), GetCursorPosition()
			CooldownTimeline.fTooltip:SetPoint("CENTER", nil, "BOTTOMLEFT", (cursorX / scale) + 80, cursorY / scale);
			CooldownTimeline.fTooltip.text:SetText(f.cdName)
			
			local width, height = CooldownTimeline.fTooltip.text:GetWidth(), CooldownTimeline.fTooltip.text:GetHeight()
			local fTooltipPadding = CooldownTimeline.db.profile.fTooltipPadding
			CooldownTimeline.fTooltip:SetSize(width + fTooltipPadding, height + fTooltipPadding)
			
			CooldownTimeline.fTooltip:Show()
			
			self:SetFrameStrata("HIGH")
		end
	end)
	
	f:SetScript("OnLeave", function(self)
		self:SetFrameStrata("MEDIUM")
		
		if CooldownTimeline.db.profile.enableTooltips then
			self.mouseover = false
			CooldownTimeline.fTooltip:Hide()
		end
	end)
	
	-- Show the icon unique ID if we are in debug mode
	f.textID = f:CreateFontString(nil,"ARTWORK")
	f.textID:SetFont("Fonts\\ARIALN.ttf", 10, "OUTLINE")
	f.textID:SetPoint("TOPLEFT",2,-2)
	f.textID:SetText(f.cdUniqueID)
	
	f.textName = f:CreateFontString(nil,"ARTWORK")
	f.textName:SetFont("Fonts\\ARIALN.ttf", 10, "OUTLINE")
	f.textName:SetPoint("BOTTOMLEFT",2,-2)
	f.textName:SetText(f:GetName():gsub("CooldownTimeline_", ""))
	
	if not self.db.profile.debugFrame then
		f.textID:Hide()
		f.textName:Hide()
	end
end

-- Send an icon to the holding frame for later use
function CooldownTimeline:SendToHolding(frame)
	if frame:GetParent():GetName() ~= "CooldownTimeline_Holding" then
		frame:SetParent("CooldownTimeline_Holding")
		CooldownTimeline:RefreshIcon(frame)
		frame.text:SetText("Hold");
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", 0, 0)
		frame:EnableMouse(false)
	end
end

-- Send an icon to the ignored frame, which will keep counting down the icons, until it is no longer ignored
function CooldownTimeline:SendToInactive(frame)
	if frame:GetParent():GetName() ~= "CooldownTimeline_Inactive" then
		frame:SetParent("CooldownTimeline_Inactive")
		frame:EnableMouse(false)
	end
end

-- Send an icon to the ready frame
function CooldownTimeline:SendToReady(frame)
	if frame:GetParent():GetName() ~= "CooldownTimeline_Ready" then
		if CooldownTimeline.db.profile.enableReady then
			-- Finally send it where it needs to go
			if frame.fastlane and CooldownTimeline.db.profile.fFastlaneSkipReady then
				CooldownTimeline:SendToHolding(frame)
			else
				frame.readyStart = GetTime()
				frame.updateCount = 0
				
				-- Reset the higlighted show time if we are pinning it to ready
				if self.db.profile.fIconHighlightPin and frame.highlighted then
					self.fReady.outOfCombatTimer = self.db.profile.fReadyIconHighlightDuration
				end
				
				-- Do this to reset the size of the glow to the new icon size
				if frame.highlighted then
					ActionButton_HideOverlayGlow(frame)
				end
				
				-- Play a sound if needed
				if frame.highlighted then
					PlaySoundFile(CooldownTimeline.SharedMedia:Fetch("sound", CooldownTimeline.db.profile.fIconReadyHighlightSound), "SFX")
				else
					PlaySoundFile(CooldownTimeline.SharedMedia:Fetch("sound", CooldownTimeline.db.profile.fIconReadySound), "SFX")
				end
				
				frame:SetParent("CooldownTimeline_Ready")
				CooldownTimeline:RefreshIcon(frame)
			end
		else
			CooldownTimeline:SendToHolding(frame)
		end
	end
end

-- Send an icon to the timeline
function CooldownTimeline:SendToTimeline(frame)
	if frame.hasCooldown then
		-- Reset some parameters
		frame.cdRemaining = 1000
		frame.updateCount = 0
		
		-- Send it to the correct frame
		if self.db.profile.enableTimeline or self.db.profile.enableFastlane then
			local parent = frame:GetParent():GetName()
			
			if self.db.profile.attemptSharedCooldownDetection then
				CooldownTimeline:DetectSharedCooldown(frame)
			end
			
			-- Send it to the Fast Lane if needed
			if self.db.profile.enableFastlane and frame.fastlane then
				if parent == "CooldownTimeline_Fastlane" then
				else
					frame:SetParent("CooldownTimeline_Fastlane")
					CooldownTimeline:RefreshIcon(frame)
				end
			
			-- Send it to the Timeline if needed
			elseif self.db.profile.enableTimeline then
				if parent == "CooldownTimeline_Timeline" then
				else
					frame:SetParent("CooldownTimeline_Timeline")
					CooldownTimeline:RefreshIcon(frame)
				end
			
			else				
				--CooldownTimeline:Print(frame.cdName..' is not sure where to go')
			end
			
		-- Otherwise we are sending it to an active holding frame
		else
			frame:SetParent("CooldownTimeline_Active")
			frame:EnableMouse(false)
		end
	end
end

function CooldownTimeline:SetIconAnimations(icon)
	icon.animationXAdjustment = 0
	icon.animationYAdjustment = 0
	icon.animationXScale = 0
	icon.animationYScale = 0

	-- FADE IN
	icon.agIN = icon:CreateAnimationGroup()
		icon.agIN:SetLooping("NONE")
		icon.agIN:SetToFinalAlpha(true)
		local fadeIn = icon.agIN:CreateAnimation("Alpha")
		fadeIn:SetFromAlpha(0)
		fadeIn:SetToAlpha(1)
		fadeIn:SetDuration(0.3)
		fadeIn:SetSmoothing("OUT")
		fadeIn:SetOrder(1)
	
	-- FADE OUT
	icon.agOUT = icon:CreateAnimationGroup()
		icon.agOUT:SetLooping("NONE")
		icon.agOUT:SetToFinalAlpha(true)
		local fadeOut = icon.agOUT:CreateAnimation("Alpha")
		fadeOut:SetFromAlpha(1)
		fadeOut:SetToAlpha(0)
		fadeOut:SetDuration(0.3)
		fadeOut:SetSmoothing("OUT")
		fadeOut:SetOrder(1)
		
	-- MOVE
	icon.agMOVE = icon:CreateAnimationGroup()
		icon.aniMove = icon.agMOVE:CreateAnimation("Translation")
		
	-- PULSE
	icon.agPulse = icon:CreateAnimationGroup()
		icon.agPulse:SetLooping("BOUNCE")
		local pulse = icon.agPulse:CreateAnimation("Alpha")
		pulse:SetFromAlpha(0.2)
		pulse:SetToAlpha(1)
		pulse:SetDuration(0.5)
		pulse:SetOrder(1)
		
	-- BORDER PULSE
	icon.agBorderPulse = icon.highlightBorder:CreateAnimationGroup()
		icon.agBorderPulse:SetLooping("BOUNCE")
		local borderPulse = icon.agBorderPulse:CreateAnimation("Alpha")
		borderPulse:SetFromAlpha(0.2)
		borderPulse:SetToAlpha(1)
		borderPulse:SetDuration(0.5)
		borderPulse:SetOrder(1)
		
	-- SHAKE
	icon.agShake = icon:CreateAnimationGroup()
		icon.agShake:SetLooping("BOUNCE")
		local shake = icon.agShake:CreateAnimation("Rotation")
		shake:SetDuration(0.5)
		shake:SetDegrees(10)
		shake:SetOrder(1)
		
	-- BOUNCE
	icon.agBounce = icon:CreateAnimationGroup()
		icon.agBounce:SetLooping("REPEAT")
		
		local bounceUP = icon.agBounce:CreateAnimation("Translation")
		bounceUP:SetDuration(0.25)
		bounceUP:SetOffset(0, 10)
		bounceUP:SetOrder(1)
		local bounceDOWN = icon.agBounce:CreateAnimation("Translation")
		bounceDOWN:SetDuration(0.25)
		bounceDOWN:SetOffset(0, -10)
		bounceDOWN:SetEndDelay(0.25)
		bounceDOWN:SetOrder(2)
	
	-- SCALE
	icon.agScale = icon:CreateAnimationGroup()
		icon.agScale:SetLooping("REPEAT")
		local scaleUP = icon.agScale:CreateAnimation("Scale")
		scaleUP:SetDuration(0.25)
		scaleUP:SetScale(1.2, 1.2)
		scaleUP:SetOrder(1)
		local scaleDOWN = icon.agScale:CreateAnimation("Scale")
		scaleDOWN:SetDuration(0.25)
		scaleDOWN:SetScale(0.8, 0.8)
		scaleDOWN:SetOrder(2)
end

function CooldownTimeline:StopAllHighlights(icon)
	-- Non-animations
	ActionButton_HideOverlayGlow(icon)
	icon.highlightBorder:SetAlpha(0)
	
	-- The animations
	if icon.agPulse then icon.agPulse:Stop() end
	if icon.agBorderPulse then icon.agBorderPulse:Stop() end
	if icon.agShake then icon.agShake:Stop() end
	if icon.agBounce then icon.agBounce:Stop() end
	if icon.agScale then icon.agScale:Stop() end
end

private.AnimationUpdate = function(self, elapsed, icon)
	local fIconHighlightEffect = CooldownTimeline.db.profile.fIconHighlightEffect
	
	if fIconHighlightEffect == "BOUNCE" then
		local aOne, aTwo = self:GetAnimations()
		
		if aOne:IsPlaying() then
			local progress = aOne:GetSmoothProgress()
			local xOfs, yOfs = aOne:GetOffset()
			
			icon.animationXAdjustment = xOfs * progress
			icon.animationYAdjustment = yOfs * progress
		elseif aTwo:IsPlaying() then
			local progress = math.abs(1 - aTwo:GetSmoothProgress())
			local xOfs, yOfs = aTwo:GetOffset()
			
			icon.animationXAdjustment = math.abs(xOfs) * progress
			icon.animationYAdjustment = math.abs(yOfs) * progress
		end
	elseif fIconHighlightEffect == "SCALE" then
		local aOne, aTwo = self:GetAnimations()

		if aOne:IsPlaying() then
			local progress = aOne:GetProgress()
			local xScale, yScale = aTwo:GetOffset()
			
		elseif aTwo:IsPlaying() then
			local progress = aTwo:GetProgress()
			local xScale, yScale = aTwo:GetOffset()
			
		end
	end
end

private.AnimationAdjustment = function(icon)
	local fIconHighlightEffect = CooldownTimeline.db.profile.fIconHighlightEffect
	local xAdjustment = 0
	local yAdjustment = 0
	
	if fIconHighlightEffect == "BOUNCE" then
		local aOne, aTwo = icon.agBounce:GetAnimations()
		
		if aOne:IsPlaying() then
			local progress = aOne:GetProgress()
			local xOfs, yOfs = aOne:GetOffset()
			
			xAdjustment = xOfs * progress
			yAdjustment = yOfs * progress
		elseif aTwo:IsPlaying() then
			local progress = math.abs(1 - aTwo:GetProgress())
			local xOfs, yOfs = aTwo:GetOffset()
			
			xAdjustment = math.abs(xOfs) * progress
			yAdjustment = math.abs(yOfs) * progress
		end
	elseif fIconHighlightEffect == "SCALE" then
		local aOne, aTwo = icon.agScale:GetAnimations()

		if aOne:IsPlaying() then
			local progress = aOne:GetProgress()
			local xScale, yScale = aTwo:GetOffset()
			
		elseif aTwo:IsPlaying() then
			local progress = aTwo:GetProgress()
			local xScale, yScale = aTwo:GetOffset()
			
		end
	end
	
	return xAdjustment, yAdjustment
end

-- This will run every update for each icon
private.IconUpdate = function(frame, elapsed)
	local currentParent = frame:GetParent():GetName()
	
	if frame.updateCount == 0 then
		frame:EnableMouse(CooldownTimeline.db.profile.enableTooltips)
	end
	
	-- What to do if we are holding
	if currentParent == "CooldownTimeline_Holding" then
		-- Doing nothing, as we are holding
	-- What to do if we are ignored	
	elseif currentParent == "CooldownTimeline_Inactive" then
		-- Doing nothing
		-- Icons here will never see the light of day
		
	-- What to do if we are ready
	elseif currentParent == "CooldownTimeline_Ready" then
		local fReadyIconDuration = CooldownTimeline.db.profile.fReadyIconDuration
		local fReadyIconHighlightDuration = CooldownTimeline.db.profile.fReadyIconHighlightDuration
		local currentTime = GetTime()
		
		frame.text:SetText(CooldownTimeline:ConvertTextTags(CooldownTimeline.db.profile.fIconReadyText["text"], frame))

		if frame.highlighted then
			if not CooldownTimeline.db.profile.fIconHighlightPin then 
				if currentTime - frame.readyStart > fReadyIconHighlightDuration then
					CooldownTimeline:SendToHolding(frame)
				end
			end
		else
			if currentTime - frame.readyStart > fReadyIconDuration then
				CooldownTimeline:SendToHolding(frame)
			end
		end
		
		-- Remove any icons from the ready area if they are actually on cooldown
		if frame.updateCount % 50 == 0 then
			local start, duration, enabled, _ = GetSpellCooldown(frame.cdID)
			if duration > 1.5 then
				CooldownTimeline:SendToHolding(frame)
			end
		end
		
		-- Remove any unequipped item icons from ready if required
		if frame.equippable then
			if CooldownTimeline.db.profile.fReadyIgnoreUnequipped then
				local itemEquipped = false
				
				for i = 0, 23, 1 do
					local itemId = GetInventoryItemID("player", i)
					if itemId == frame.ID then
						itemEquipped = true
						break
					end
				end
				
				if not itemEquipped then
					CooldownTimeline:SendToHolding(frame)
				end
			end
		end
		
	-- What to do if we are cooling down
	elseif 
		currentParent == "CooldownTimeline_Timeline" or
		currentParent == "CooldownTimeline_Fastlane" or
		currentParent == "CooldownTimeline_Active"
	then
		-- We source information differently
		--
		--	SPELLS
		--
		if frame.cdType == "SPELL" or frame.cdType == "PETSPELL" then
			-- Which unit is casting the spell
			local unit = "player"
			if frame.cdType == "PETSPELL" then
				unit = "pet"
			end
		
			-- On the first update frame we want to get the data we need, as it doesnt load correctly if first run on the event
			if frame.updateCount == 0 then
				local start, duration, enabled, _ = GetSpellCooldown(frame.cdID)
				local baseDuration, _ = GetSpellBaseCooldown(frame.cdID)
				
				frame.cdStart = start
				frame.cdEnabled = enabled
				frame.cdRemaining = start + duration - GetTime()
				
				if duration < baseDuration then
					frame.cdBaseDuration = duration
				else
					--frame.cdRemaining = baseDuration / 1000
					frame.cdBaseDuration = baseDuration / 1000
				end
				
				if duration <= 1.50 then
					-- Some spells show a duration of 0, and rely on an aura to trigger the cooldown
					local activeAura, auraDuration = CooldownTimeline:AuraIsActive(unit, frame.cdName)
					if activeAura and auraDuration ~= 0 then
						if frame.cdName ~= "Feign Death" and
							frame.cdName ~= "Amplify Curse" then
							frame.hasCooldown = false
							currentParent = "CooldownTimeline_Inactive"
							CooldownTimeline:SendToInactive(frame)
						end
					end
				end
			else
				if frame.cdEnabled == 0 then
					local start, duration, enabled, _ = GetSpellCooldown(frame.cdID)
					local baseDuration, _ = GetSpellBaseCooldown(frame.cdID)
					
					if enabled == 1 then
						frame.cdEnabled = enabled						
						frame.cdRemaining = frame.cdRemaining - elapsed
					else
						if duration < baseDuration then
							frame.cdRemaining = duration
							
							if math.floor(duration + 0.5) == 0 then
								frame.cdRemaining = baseDuration / 1000
							end
						else
							frame.cdRemaining = baseDuration / 1000
						end
					end
				else
					-- Some spells dont use the enabled flag, but track an aura
					local activeAura, auraDuration = CooldownTimeline:AuraIsActive(unit, frame.cdName)					
					if activeAura and auraDuration == 0 then
						local baseDuration, _ = GetSpellBaseCooldown(frame.cdID)
						frame.cdRemaining = baseDuration / 1000
					else
						frame.cdRemaining = frame.cdRemaining - elapsed
					end
				end
				
				-- Periodically check that the cooldown is still active
				local start, duration, enabled, _ = GetSpellCooldown(frame.cdID)
				if frame.updateCount % 50 == 0 then
					
					local baseDuration, _ = GetSpellBaseCooldown(frame.cdID)
					frame.cdBaseDuration = baseDuration / 1000
				
					if duration == 0 then
						frame.cdRemaining = 0
					end
				end
			end
		
		--
		--	ITEMS
		--
		elseif frame.cdType == "ITEM" then
			-- On the first update frame we want to get the data we need, as it doesnt load correctly if first run on the event
			if frame.updateCount == 0 then
				local start, duration, enabled = GetItemCooldown(frame.cdID)
				
				frame.cdStart = start
				frame.cdEnabled = enabled
				frame.cdRemaining = duration
				frame.cdBaseDuration = duration
				
				-- Ignore items that dont have a cooldown
				if duration <= 3 then
					frame.hasCooldown = false
					currentParent = "CooldownTimeline_Inactive"
					CooldownTimeline:SendToInactive(frame)
				end
			else
				-- Do a periodic check on the items cooldown in case it has changed
				if frame.updateCount % 10 == 0 then
					local start, duration, enabled = GetItemCooldown(frame.cdID)
					frame.cdRemaining = start + duration - GetTime()
				else
					frame.cdRemaining = frame.cdRemaining - elapsed
				end
			end
			
		--
		--	AURAS
		--
		elseif frame.cdType == "BUFF" or frame.cdType == "DEBUFF" or frame.cdType == "OAURA" then		
			if frame.updateCount == 0 then
				if frame.cdType == "BUFF" then
					for i = 1, 40, 1 do
						local name, _, _, _, duration, expirationTime, _, _,  _, _, _, _, _, _, _ = UnitBuff("player", i)
						
						if name then
							if name == frame.cdName or name == frame.cdName:gsub("BUFF_", "") then
								frame.cdStart = expirationTime - duration
								frame.cdRemaining = expirationTime - GetTime()
								frame.cdBaseDuration = duration
							end
						end
					end
				elseif frame.cdType == "DEBUFF" then
					for i = 1, 40, 1 do
						local name, _, _, _, duration, expirationTime, _, _,  _, _, _, _, _, _, _ = UnitDebuff("player", i)
						
						if name then
							if name == frame.cdName then
								frame.cdStart = expirationTime - duration
								frame.cdRemaining = expirationTime - GetTime()
								frame.cdBaseDuration = duration
							end
						end
					end
				elseif frame.cdType == "OAURA" then
					for i = 1, 40, 1 do
						local name, _, _, _, duration, expirationTime, _, _,  _, _, _, _, _, _, _ = UnitDebuff("target", i)
						
						if name then
							if name == frame.cdName or name == frame.cdName:gsub("OAURA_", "") then
								frame.cdStart = expirationTime - duration
								frame.cdRemaining = expirationTime - GetTime()
								frame.cdBaseDuration = duration
							end
						end
					end
				end
			else
				-- Auras can be refreshed, or apply stacks, and so we need to keep track of this and update\
				if frame.updateCount % 30 == 0 then
					for i = 1, 40, 1 do
						
						if frame.cdType == "BUFF" or frame.cdType == "DEBUFF" then
							local name, _, count, _, duration, expirationTime, _, _,  _, _, _, _, _, _, _ = UnitBuff("player", i)
							
							if name then
								if "BUFF_"..name == frame.cdName then
									frame.cdStart = expirationTime - duration
									frame.cdRemaining = expirationTime - GetTime()
									frame.cdBaseDuration = duration
								end
							end
							
							local name, _, count, _, duration, expirationTime, _, _,  _, _, _, _, _, _, _ = UnitDebuff("player", i)
							
							if name then
								if name == frame.cdName then
									frame.cdStart = expirationTime - duration
									frame.cdRemaining = expirationTime - GetTime()
									frame.cdBaseDuration = duration
								end
							end
						elseif frame.cdType == "OAURA" then
							
							local name, _, count, _, duration, expirationTime, _, _,  _, _, _, _, _, _, _ = UnitDebuff("target", i)
							
							if name then
								if "OAURA_"..name == frame.cdName then
									frame.cdStart = expirationTime - duration
									frame.cdRemaining = expirationTime - GetTime()
									frame.cdBaseDuration = duration
								end
							end
						end
					end
				end
					
				local stillActive = false
				local currentAuras = CooldownTimeline:ScanAuras()
				
				for _, aura in pairs(currentAuras) do
					if aura == frame.cdName or "BUFF_"..aura == frame.cdName or "DEBUFF_"..aura == frame.cdName then
						stillActive = true
					end
				end
				
				if stillActive or frame.cdType == "OAURA" then
					frame.cdRemaining = frame.cdRemaining - elapsed
				else
					frame.cdRemaining = 0
				end
			end
		end

		if frame.updateCount % 30 == 0 then
			frame.fastlane = CooldownTimeline:SpellIsInFastLane(frame.cdName, frame.cdType)
			frame.bar = CooldownTimeline:SpellShowBar(frame.cdName, frame.cdType)
			frame.highlighted = CooldownTimeline:SpellIsHighlighted(frame.cdName, frame.cdType)
		end

		-- Now we work out the icons position on the timeline
		if currentParent ~= "CooldownTimeline_Inactive" then
			if frame.cdRemaining > 0 then
				local longIgnoreThreshold = CooldownTimeline.db.profile.longIgnoreThreshold
				if CooldownTimeline.db.profile.enableTimeline then
					-- Calculate its position			
					local tlWidth = CooldownTimeline.db.profile.fTimelineWidth
					local mode = CooldownTimeline.db.profile.fTimelineMode
					local generalIconOffset = CooldownTimeline.db.profile.fTimelineIconOffset
					
					local fIconSize = CooldownTimeline.db.profile.fIconSize
					local fFastlaneIconSize = CooldownTimeline.db.profile.fFastlaneIconSize
					local xAdjustment = 0
					local yAdjustment = 0
					
					
					local position = tlWidth
					local durationToPass = frame.cdBaseDuration
					if durationToPass > longIgnoreThreshold then
						durationToPass = longIgnoreThreshold
					end
					
					--frame.fastlane = CooldownTimeline:SpellIsInFastLane(frame.cdName, frame.cdType)
					if frame.fastlane then
						position = CooldownTimeline:CalcLinearPercentPosition(frame.cdRemaining, durationToPass, fFastlaneIconSize)
						generalIconOffset = CooldownTimeline.db.profile.fFastlaneIconOffset
					else
						if mode == "LINEAR" then
							position = CooldownTimeline:CalcLinearPercentPosition(frame.cdRemaining, durationToPass, fIconSize)
						elseif mode == "SPLIT" then
							position = CooldownTimeline:CalcSplitPercentPosition(frame.cdRemaining, durationToPass)
						elseif mode == "LINEAR_ABS" then
							position = CooldownTimeline:CalcLinearAbsolutePosition(frame.cdRemaining, nil)
						elseif mode == "SPLIT_ABS" then
							position = CooldownTimeline:CalcSplitAbsolutePosition(frame.cdRemaining, nil)
						end
					end
					-- Get any adjustments due to animations
					local xAdjustmentAnimation, yAdjustmentAnimation = private.AnimationAdjustment(frame)
					
					local iconRelativeTo = "RIGHT"
					local adjustedPosition = position - tlWidth
					
					if CooldownTimeline.db.profile.fTimelineIconReverseDirection then
						iconRelativeTo = "LEFT" 
						adjustedPosition = tlWidth - position
					end
					
					frame:ClearAllPoints()
					frame:SetPoint(iconRelativeTo, adjustedPosition + xAdjustment, frame.stackOffset + generalIconOffset + yAdjustment)
					
					if frame.textID then
						frame.textID:SetPoint("TOPLEFT", 2 + xAdjustmentAnimation, -2 + yAdjustmentAnimation)
					end
				end
				
				-- Send the linked bar to bar area if required
				if CooldownTimeline.db.profile.enableBars and frame.createdBar then
					if frame.cooldownBar:GetParent():GetName() ~= "CooldownTimeline_Bar"  then
						local enableBar2 = CooldownTimeline.db.profile.enableBar2
						
						if enableBar2 then
							if frame.cdType == "OAURA" then
								frame.cooldownBar:SetParent("CooldownTimeline_Bar2")
							else
								frame.cooldownBar:SetParent("CooldownTimeline_Bar")
							end
						else
							frame.cooldownBar:SetParent("CooldownTimeline_Bar")
						end
						
						--CooldownTimeline:RefreshBar(frame.cooldownBar)
					end
				end
				
				-- Create a linked cooldown bar if required
				if CooldownTimeline.db.profile.enableBars then
					frame.bar = CooldownTimeline:SpellShowBar(frame.cdName, frame.cdType)
					
					local fBarText1 = CooldownTimeline.db.profile.fBarText1["text"]
					local fBarText2 = CooldownTimeline.db.profile.fBarText2["text"]
					local fBarText3 = CooldownTimeline.db.profile.fBarText3["text"]
					
					local fBarOnlyShowOverThreshold = CooldownTimeline.db.profile.fBarOnlyShowOverThreshold
					local fBarShowTimeToTransition = CooldownTimeline.db.profile.fBarShowTimeToTransition
					local fBarAlwaysShowOffensiveAuras = CooldownTimeline.db.profile.fBarAlwaysShowOffensiveAuras
					
					local fBarWidth = CooldownTimeline.db.profile.fBarWidth
					local fBarHeight = CooldownTimeline.db.profile.fBarHeight
					local fBarShowIcon = CooldownTimeline.db.profile.fBarShowIcon
					
					local fBarTransitionTextureWidth = CooldownTimeline.db.profile.fBarTransitionTextureWidth
					
					local fBarDirectionReverse = CooldownTimeline.db.profile.fBarDirectionReverse
					
					if frame.bar and not frame.createdBar then
						local data = {}
						data["name"] = frame.cdName
						data["type"] = frame.cdType
						data["id"] = frame.cdID
						data["icon"] = frame.cdIcon
						
						CooldownTimeline:CreateCooldownBar(data)
						
						for _, bar in pairs(CooldownTimeline.barTable) do
							if bar.cdName == frame.cdName then
								frame.cooldownBar = bar
							end
						end
						
						frame.createdBar = true
					end
					
					if frame.createdBar then
						if frame.bar then
							if frame.cooldownBar:GetParent():GetName() == "CooldownTimeline_Bar2" then
								fBarText1 = CooldownTimeline.db.profile.fBar2Text1["text"]
								fBarText2 = CooldownTimeline.db.profile.fBar2Text2["text"]
								fBarText3 = CooldownTimeline.db.profile.fBar2Text3["text"]
								
								fBarOnlyShowOverThreshold = CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold
								fBarShowTimeToTransition = CooldownTimeline.db.profile.fBar2ShowTimeToTransition
								fBarAlwaysShowOffensiveAuras = CooldownTimeline.db.profile.fBar2AlwaysShowOffensiveAuras
							
								fBarWidth = CooldownTimeline.db.profile.fBar2Width
								fBarHeight = CooldownTimeline.db.profile.fBar2Height
								fBarShowIcon = CooldownTimeline.db.profile.fBar2ShowIcon
								
								fBarTransitionTextureWidth = CooldownTimeline.db.profile.fBar2TransitionTextureWidth
								fBarDirectionReverse = CooldownTimeline.db.profile.fBar2DirectionReverse
							end
						
							-- Set the bar progress
							local progress = frame.cdRemaining / frame.cdBaseDuration
							--local longIgnoreThreshold = CooldownTimeline.db.profile.longIgnoreThreshold
							frame.cooldownBar:SetValue(progress)
							
							frame.cooldownBar.text.text1:SetText(CooldownTimeline:ConvertTextTags(fBarText1, frame))
							frame.cooldownBar.text.text2:SetText(CooldownTimeline:ConvertTextTags(fBarText2, frame))
							frame.cooldownBar.text.text3:SetText(CooldownTimeline:ConvertTextTags(fBarText3, frame))
							
							local alwaysShowOffensiveAuras = false
							if frame.cdType == "OAURA" then
								if fBarAlwaysShowOffensiveAuras then
									alwaysShowOffensiveAuras = true
								end
							end
							
							if fBarOnlyShowOverThreshold or alwaysShowOffensiveAuras then
								-- Position/hide/show transition indicators
								if frame.cdBaseDuration > longIgnoreThreshold then
									
									
									if fBarShowIcon then
										
										fBarWidth = fBarWidth - fBarHeight
									end
									
									local percent = ( longIgnoreThreshold / frame.cdBaseDuration ) * 100						
									local position = ( fBarWidth / 100 ) * percent
								
								
									local align = "LEFT"
									if fBarDirectionReverse then
										align = "RIGHT"
									end
								
									if fBarShowTimeToTransition == "REGION" then
										frame.cooldownBar.ti:SetWidth(position)
										frame.cooldownBar.ti:ClearAllPoints()
										frame.cooldownBar.ti:SetPoint(align, 0, 0)
										
										frame.cooldownBar.ti:Show()
									elseif fBarShowTimeToTransition == "LINE" then
										frame.cooldownBar.ti:SetWidth(fBarTransitionTextureWidth)
										frame.cooldownBar.ti:ClearAllPoints()
										frame.cooldownBar.ti:SetPoint(align, position - (fBarTransitionTextureWidth / 2), 0)
										
										frame.cooldownBar.ti:Show()
									else
										frame.cooldownBar.ti:Hide()
									end
								else
									frame.cooldownBar.ti:Hide()
								end
							
								if frame.cdRemaining < longIgnoreThreshold and not alwaysShowOffensiveAuras then
									frame.cooldownBar:SetParent("CooldownTimeline_BarHolding")
								else
									--frame.cooldownBar:SetParent("CooldownTimeline_Bar")
									local enableBar2 = CooldownTimeline.db.profile.enableBar2
									
									if enableBar2 then
										if frame.cdType == "OAURA" then
											frame.cooldownBar:SetParent("CooldownTimeline_Bar2")
										else
											frame.cooldownBar:SetParent("CooldownTimeline_Bar")
										end
									else
										frame.cooldownBar:SetParent("CooldownTimeline_Bar")
									end
									
									--CooldownTimeline:RefreshBar(frame.cooldownBar)
									
									-- Change the progress to show only the time until it passes to the timeline
									if fBarShowTimeToTransition == "SHORTEN" then
										local progress = (frame.cdRemaining - longIgnoreThreshold) / (frame.cdBaseDuration - longIgnoreThreshold)
										frame.cooldownBar:SetValue(progress)
									end
								end
							else
								--frame.cooldownBar:SetParent("CooldownTimeline_BarHolding")
							end
						else
							frame.cooldownBar:SetParent("CooldownTimeline_BarHolding")
						end
					end
				else
					if frame.createdBar then
						frame.cooldownBar:SetParent("CooldownTimeline_BarHolding")
					end
				end
				
				local iconText = CooldownTimeline:ConvertTextTags(CooldownTimeline.db.profile.fIconText["text"], frame)
				--frame.text:SetText(CooldownTimeline:ConvertTextTags(CooldownTimeline.db.profile.fIconText["text"], frame))
				
				if frame.fastlane then
					iconText = CooldownTimeline:ConvertTextTags(CooldownTimeline.db.profile.fIconFastlaneText["text"], frame)
				end
				
				frame.text:SetText(iconText)
			else
				--CooldownTimeline:Print("aura icon - "..tostring(frame.cdName))
			
				-- Send to ready
				CooldownTimeline:SendToReady(frame)
				
				-- Send the linked bar to bar holding
				if frame.createdBar then
					frame.cooldownBar:SetParent("CooldownTimeline_BarHolding")
				end
			end

			-- Do we need to ignore the icon or not?
			if frame.cdRemaining > CooldownTimeline.db.profile.longIgnoreThreshold then
				frame.ignored = true
			else
				frame.ignored = false
				if frame.cdType == "ITEM" then
					if not CooldownTimeline.db.profile.trackItemCooldowns then
						frame.ignored = true
					else
						frame.ignored = false
					end
				elseif frame.cdType == "PETSPELL" then
					if not CooldownTimeline.db.profile.trackPetSpells then
						frame.ignored = true
					else
						frame.ignored = false
					end
				end
			end
			
			if not CooldownTimeline:SpellIsWhitelisted(frame.cdName, frame.cdType) then
				frame.ignored = true
			end
		end
	end
	
	if CooldownTimeline.db.profile.enableTimeline or CooldownTimeline.db.profile.enableFastlane then
		-- Apply highlighting effect if required
		--frame.highlighted = CooldownTimeline:SpellIsHighlighted(frame.cdName, frame.cdType)
		if frame.highlighted then
			local fIconHighlightEffect = CooldownTimeline.db.profile.fIconHighlightEffect
			
			if fIconHighlightEffect == "GLOW" then
				ActionButton_ShowOverlayGlow(frame)
			elseif fIconHighlightEffect == "BORDER" then
				frame.highlightBorder:SetAlpha(1)
			elseif fIconHighlightEffect == "PULSE" then
				if not frame.agPulse:IsPlaying() then
					frame.agPulse:Play()
				end
			elseif fIconHighlightEffect == "BORDER_PULSE" then
				if not frame.agBorderPulse:IsPlaying() then
					frame.agBorderPulse:Play()
				end
			elseif fIconHighlightEffect == "SHAKE" then
				if not frame.agShake:IsPlaying() then
					frame.agShake:Play()
				end
			elseif fIconHighlightEffect == "BOUNCE" then
				if not frame.agBounce:IsPlaying() then
					frame.agBounce:Play()
				end
			elseif fIconHighlightEffect == "SCALE" then
				if not frame.agScale:IsPlaying() then
					frame.agScale:Play()
				end
			end
		else
			ActionButton_HideOverlayGlow(frame)
			CooldownTimeline:StopAllHighlights(frame)
			frame.highlightBorder:SetAlpha(0)
			frame.border:SetAlpha(1)
		end
	
		-- Set the icon color appropriately
		local fIconNotUsableOverride = CooldownTimeline.db.profile.fIconNotUsableOverride
		local fIconNotUsableDesaturate = CooldownTimeline.db.profile.fIconNotUsableDesaturate
		local fIconNotUsableColor = CooldownTimeline.db.profile.fIconNotUsableColor
	
		if fIconNotUsableOverride then
			if frame.cdType == "SPELL" or frame.cdType == "PETSPELL" then
				if not IsUsableSpell(frame.cdID) then
					if fIconNotUsableDesaturate then
						frame.tex:SetDesaturated(1)
					else
						frame.tex:SetDesaturated(nil)
						local r = fIconNotUsableColor["r"]
						local g = fIconNotUsableColor["g"]
						local b = fIconNotUsableColor["b"]
						local a = fIconNotUsableColor["a"]
					
						frame.tex:SetVertexColor(r, g, b, a)
					end
				else
					frame.tex:SetDesaturated(nil)
					frame.tex:SetVertexColor(1, 1, 1, 1)
				end
			end
		end
	end
	
	if frame.mouseover then
		local width, height = CooldownTimeline.fTooltip.text:GetWidth(), CooldownTimeline.fTooltip.text:GetHeight()
		local scale, cursorX, cursorY = frame:GetEffectiveScale(), GetCursorPosition()
		
		CooldownTimeline.fTooltip:SetPoint("CENTER", nil, "BOTTOMLEFT", (cursorX / scale) + (width / 2) + 30, (cursorY / scale) + 15);
	end
	
	-- Finally ignore the frame.  Or not.
	if frame.ignored then
		if CooldownTimeline.db.profile.debugFrame then
			frame:SetAlpha(0.2)
		else
			frame:SetAlpha(0)
		end
		
		frame:EnableMouse(false)
	else
		frame:SetAlpha(1)
				
		if CooldownTimeline.db.profile.enableTooltips then
			if currentParent == "CooldownTimeline_Timeline" or currentParent == "CooldownTimeline_Fastlane" or currentParent == "CooldownTimeline_Ready" then
				frame:EnableMouse(true)
			else
				frame:EnableMouse(false)
			end
		end
	end
	
	if CooldownTimeline.db.profile.debugFrame then
		frame.textID:Show()
		frame.textName:Show()
	else
		frame.textID:Hide()
		frame.textName:Hide()
	end
	
	frame.updateCount = frame.updateCount + 1
end