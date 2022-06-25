--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local SharedMedia = LibStub( "LibSharedMedia-3.0" )

-- Check for a specific active auras
function CooldownTimeline:AuraIsActive(unit, nameToFind)
	-- Buffs
	for i = 1, 40, 1 do
		local name, _, _, _, duration, _, _, _,  _, spellId, _, _, _, _, _ = UnitBuff(unit, i)
		if name then
			if name == nameToFind then
				--CooldownTimeline:Print("MATCH - "..name)
				return true, duration
			end
		end
	end
	
	-- Debufs
	for i = 1, 40, 1 do
		local name, _, _, _, duration, _, _, _,  _, spellId, _, _, _, _, _ = UnitDebuff(unit, i)
		if name then
			if name == nameToFind then
				--CooldownTimeline:Print("MATCH - "..name)
				return true, duration
			end
		end
	end
	
	return false
end

function CooldownTimeline:AssignUniqueID()
	local id = CooldownTimeline.uniqueID
	CooldownTimeline.uniqueID = CooldownTimeline.uniqueID + 1
	return id
end

-- Check for edgecases and create/move icons as needed
function CooldownTimeline:CheckEdgeCases(spellName)
	if spellName == "Vanish" then
		--CooldownTimeline:Print("Detected Vanish Cast")
	
		local matchFound, matchFrame = self:CheckExistingIcons("Stealth")
		
		if matchFound then
			CooldownTimeline:SendToTimeline(matchFrame)
		else
			local data = {}
			
			data["name"] = "Stealth"
			data["type"] = "SPELL"
			data["id"] = "1787"
			
			-- Stop searching as we have a match
			self:CreateCooldownIcon(data)
		end
	end
end

-- Check if the icon already exists, and return it if it does
function CooldownTimeline:CheckExistingIcons(spellName, spellID)
	--CooldownTimeline:Print("Searching for "..tostring(spellName)..":")
	for k, v in pairs(CooldownTimeline.iconTable) do
		if v ~= nil then
			--CooldownTimeline:Print("   - "..v:GetName():gsub("CooldownTimeline_", ""))
			if v:GetName() == "CooldownTimeline_"..tostring(spellName) then
				
				return true, v
			end
		end
	end

	return false, nil
end

-- Does the spell already exist in the whitelist
function CooldownTimeline:CheckWhitelistForDoubles(spellName, type)
	local searchList = CooldownTimeline.db.profile.whitelist
	
	if type == "ITEM" then
		searchList = CooldownTimeline.db.profile.whitelistItems
	elseif type == "PETSPELL" then
		searchList = CooldownTimeline.db.profile.whitelistPet
	elseif type == "AURA" or type == "OAURA" then
		searchList = CooldownTimeline.db.profile.whitelistAuras
	end
	
	for _, spell in pairs(searchList) do
		if spell["name"] == spellName then
			--CooldownTimeline:Print(spell["spellName"])
			return true
		end
	end
	--CooldownTimeline:Print("No match, adding "..spellName)
	return false
end

-- Check if there is already in the Spell Table
function CooldownTimeline:CheckSpellTableForDoubles(id)
	for k, v in pairs(CooldownTimeline.spellTable) do
		if v["id"] == id then
			return true
		end
	end
	return false
end

function CooldownTimeline:CleanDuplicates()
	local spellDupeCount = 0
	if CooldownTimeline.db.profile.cleanSpells then
		local lastSpell = ""
		local tempWhitelist = {}
		table.sort(CooldownTimeline.db.profile.whitelist, function(a, b)
				local aN = a["name"]
				local bN = b["name"]
				
				return aN < bN
			end)
		
		for key, spell in pairs(CooldownTimeline.db.profile.whitelist) do
			--CooldownTimeline:Print("checking: "..spell["name"]..' --- '..key)
			
			if lastSpell ~= spell["name"] then
				table.insert(tempWhitelist, spell)
				lastSpell = spell["name"]
				--CooldownTimeline:Print("    keep: "..spell["name"])
			else
				--CooldownTimeline:Print("    dupe: "..spell["name"])
				spellDupeCount = spellDupeCount + 1
			end
		end

		CooldownTimeline.db.profile.whitelist = tempWhitelist
	end
	
	local petSpellDupeCount = 0
	if CooldownTimeline.db.profile.cleanPetSpells then
		local lastSpell = ""
		local tempWhitelistPet = {}
		table.sort(CooldownTimeline.db.profile.whitelistPet, function(a, b)
				local aN = a["name"]
				local bN = b["name"]
				
				return aN < bN
			end)
		
		for key, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
			--CooldownTimeline:Print("checking: "..spell["name"]..' --- '..key)
			
			if lastSpell ~= spell["name"] then
				table.insert(tempWhitelistPet, spell)
				lastSpell = spell["name"]
				--CooldownTimeline:Print("    keep: "..spell["name"])
			else
				--CooldownTimeline:Print("    dupe: "..spell["name"])
				petSpellDupeCount = petSpellDupeCount + 1
			end
		end

		CooldownTimeline.db.profile.whitelistPet = tempWhitelistPet
	end
	
	local itemDupeCount = 0
	if CooldownTimeline.db.profile.cleanItems then
		local lastSpell = ""
		local tempWhitelistItems = {}
		table.sort(CooldownTimeline.db.profile.whitelistItems, function(a, b)
				local aN = a["name"]
				local bN = b["name"]
				
				return aN < bN
			end)
		
		for key, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
			--CooldownTimeline:Print("checking: "..spell["name"]..' --- '..key)
			
			if lastSpell ~= spell["name"] then
				table.insert(tempWhitelistItems, spell)
				lastSpell = spell["name"]
				--CooldownTimeline:Print("    keep: "..spell["name"])
			else
				--CooldownTimeline:Print("    dupe: "..spell["name"])
				itemDupeCount = itemDupeCount + 1
			end
		end

		CooldownTimeline.db.profile.whitelistItems = tempWhitelistItems
	end
	
	local auraDupeCount = 0
	if CooldownTimeline.db.profile.cleanAuras then
		local lastSpell = ""
		local tempWhitelistAuras = {}
		table.sort(CooldownTimeline.db.profile.whitelistAuras, function(a, b)
				local aN = a["name"]
				local bN = b["name"]
				
				return aN < bN
			end)
		
		for key, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
			--CooldownTimeline:Print("checking: "..spell["name"]..' --- '..key)
			
			if lastSpell ~= spell["name"] then
				table.insert(tempWhitelistAuras, spell)
				lastSpell = spell["name"]
				--CooldownTimeline:Print("    keep: "..spell["name"])
			else
				--CooldownTimeline:Print("    dupe: "..spell["name"])
				auraDupeCount = auraDupeCount + 1
			end
		end
		
		CooldownTimeline.db.profile.whitelistAuras = tempWhitelistAuras
	end

	local dupeCount = spellDupeCount + petSpellDupeCount + itemDupeCount + auraDupeCount
	--ReloadUI()
end

function CooldownTimeline:ConvertTextTags(inputString, frame)
	local exportString = inputString
			
	for _, tag in ipairs(CooldownTimeline.customTextTags) do
		if inputString:find(tag["tag"]) then
			--local replacement = tag["func"]
			local replacement = tag["func"](frame)
		
			exportString = string.gsub(exportString, tag["tag"], replacement)
			--exportString = string.gsub(exportString, tag["tag"], tag.func(frame))
		end
	end
	
	return exportString
end

-- Create some nice readable text for times
function CooldownTimeline:ConvertToReadableTime(rawTime)
	local readableTimeLeft = rawTime

	if rawTime > 60 then
		readableTimeLeft = math.floor(rawTime*math.pow(10,0)+0.5) / math.pow(10,0)
		
		local minutes = tostring(math.floor(readableTimeLeft / 60))
		
		local seconds = readableTimeLeft % 60
		if seconds >= 10 then
			seconds = tostring(seconds)
		elseif seconds > 0 then
			seconds = tostring("0"..seconds)
		else
			seconds = "00"
		end
		
		readableTimeLeft = minutes..":"..seconds
		
	elseif rawTime > 10 then
		readableTimeLeft = tonumber(string.format("%.0f", readableTimeLeft))
	else
		readableTimeLeft = tonumber(string.format("%.1f", readableTimeLeft))
		if readableTimeLeft == math.floor(readableTimeLeft) then
			readableTimeLeft = readableTimeLeft..".0"
		end
	end
	
	return readableTimeLeft
end

-- Create some nice readable short text for times
function CooldownTimeline:ConvertToShortTime(rawTime)
	local readableTimeLeft = rawTime
	
	if rawTime >= 60 then
		local minutes = tostring(math.floor(readableTimeLeft / 60))
		local seconds = readableTimeLeft % 60
		
		readableTimeLeft = minutes.."m"
		
		if seconds ~= 0 then
			readableTimeLeft = readableTimeLeft..seconds.."s"
		end
	else
		readableTimeLeft = tonumber(string.format("%.0f", readableTimeLeft)).."s"
	end
	
	return readableTimeLeft
end

-- Detect whether there are any icons in the ready area that share a cooldown with the spell just cast and move it out
function CooldownTimeline:DetectSharedCooldown(icon)
	
end

function CooldownTimeline:GetPlayerPower(class)
	if class == "Rogue" then
		return Enum.PowerType.Energy
	elseif class == "Warrior" then
		return Enum.PowerType.Rage
	elseif class == "Druid" then
		local form = GetShapeshiftForm()
		if form == 1 then
			return Enum.PowerType.Rage
		elseif form == 3 then
			return Enum.PowerType.Energy
		else
			return Enum.PowerType.Mana
		end
	else
		return Enum.PowerType.Mana
	end
end

-- Should we generate an item for the spell (distinct from if we generate an item to then ignore it or not)
function CooldownTimeline:IsBlacklisted(type, spellName)
	local tableToSearch = {}
	
	if type == "SPELL" then
		tableToSearch = CooldownTimeline.blacklist
	elseif type == "PETSPELL" then
		tableToSearch = CooldownTimeline.blacklistPet
	elseif type == "ITEM" then
		tableToSearch = CooldownTimeline.blacklistItems
	end
	
	for _, spell in pairs(tableToSearch) do
		if spellName == spell then
			--CooldownTimeline:Print(spellName.." is blacklisted")
			return true
		end
	end
	
	return false
end

-- We dont want to track all item types that have spells attached (eg. recipies)
function CooldownTimeline:IsValidItemType(type)
	if type == "Key" then
		return false
	elseif type == "Recipe" then
		return false
	elseif type == "Trade Goods" then
		return false
	end
	
	-- This will clean out old quest items, but only if a call to clean the table has been made
	if CooldownTimeline.db.profile.needToCleanTable then
		if type == "Quest" then
			return false
		end
	end
	
	return true
end

-- Refresh everything we need to when changing profiles
function CooldownTimeline:RefreshConfig()
	self:SetReadyFrame()
	self:SetTimelineFrame()
	self:SetTimelineText()
	self:RefreshIcons()
end

function CooldownTimeline:RefreshBars()
	for _, child in ipairs(CooldownTimeline.barTable) do
		CooldownTimeline:RefreshBar(child)
	end
end

function CooldownTimeline:RefreshBar(bar)
	local fBarWidth = self.db.profile.fBarWidth
	local fBarHeight = self.db.profile.fBarHeight
	local fBarTexture = self.db.profile.fBarTexture
	local fBarTextureColor = self.db.profile.fBarTextureColor
	local fBarBackground = self.db.profile.fBarBackground
	local fBarBackgroundColor = self.db.profile.fBarBackgroundColor
	local fBarShowIcon = self.db.profile.fBarShowIcon
	local fBarIconPosition = self.db.profile.fBarIconPosition
	local fBarUseIconAsTexture = self.db.profile.fBarUseIconAsTexture
	local fBarFont = self.db.profile.fBarFont
	local fBarFontSize = self.db.profile.fBarFontSize
	local fBarFontColor = self.db.profile.fBarFontColor
	local fBarDirectionReverse = self.db.profile.fBarDirectionReverse
	
	local fBarTransitionTextureWidth = self.db.profile.fBarTransitionTextureWidth
	local fBarTransitionTextureHeight = self.db.profile.fBarTransitionTextureHeight
	local fBarTransitionTexture = self.db.profile.fBarTransitionTexture
	local fBarTransitionTextureColor = self.db.profile.fBarTransitionTextureColor
	
	local t1 =  self.db.profile.fBarText1
	local t2 =  self.db.profile.fBarText2
	local t3 =  self.db.profile.fBarText3
	
	if bar:GetParent():GetName() == "CooldownTimeline_Bar2" then
		fBarWidth = self.db.profile.fBar2Width
		fBarHeight = self.db.profile.fBar2Height
		fBarTexture = self.db.profile.fBar2Texture
		fBarTextureColor = self.db.profile.fBar2TextureColor
		fBarBackground = self.db.profile.fBar2Background
		fBarBackgroundColor = self.db.profile.fBar2BackgroundColor
		fBarShowIcon = self.db.profile.fBar2ShowIcon
		fBarIconPosition = self.db.profile.fBar2IconPosition
		fBarUseIconAsTexture = self.db.profile.fBar2UseIconAsTexture
		fBarFont = self.db.profile.fBar2Font
		fBarFontSize = self.db.profile.fBar2FontSize
		fBarFontColor = self.db.profile.fBar2FontColor
		
		fBarTransitionTextureWidth = self.db.profile.fBar2TransitionTextureWidth
		fBarTransitionTextureHeight = self.db.profile.fBar2TransitionTextureHeight
		fBarTransitionTexture = self.db.profile.fBar2TransitionTexture
		fBarTransitionTextureColor = self.db.profile.fBar2TransitionTextureColor
		
		t1 =  self.db.profile.fBar2Text1
		t2 =  self.db.profile.fBar2Text2
		t3 =  self.db.profile.fBar2Text3
	end
	
	if fBarShowIcon then
		bar.icon:Show()
		fBarWidth = fBarWidth - fBarHeight
	else
		bar.icon:Hide()
	end
	
	local iconOffset = fBarHeight
	if fBarIconPosition == "LEFT" then
		iconOffset = -fBarHeight
	end
	
	bar.icon:ClearAllPoints()
	bar.icon:SetPoint(fBarIconPosition, iconOffset, 0)
	bar.icon:SetWidth(fBarHeight)
	bar.icon:SetHeight(fBarHeight)
	
	bar.icon.tex:SetAllPoints(bar.icon)
	bar.icon.tex:SetTexture(bar.cdIcon)
	
	if CooldownTimeline.Masque then
		-- Kill masque for this icon(button)
		CooldownTimeline.masqueGroup = CooldownTimeline.Masque:Group("CooldownTimeline")
		CooldownTimeline.masqueGroup:RemoveButton(bar.icon)
		
		-- Reapply masque
		CooldownTimeline.masqueGroup:AddButton(bar.icon, { Icon = bar.icon.tex })	
	end
	
	bar:ClearAllPoints()
	bar:SetPoint(fBarIconPosition, 0, 0)
	bar:SetWidth(fBarWidth)
	bar:SetHeight(fBarHeight)

	bar:SetMinMaxValues(0, 1)
	bar:SetReverseFill(fBarDirectionReverse)

	-- Set the bar texture
	bar:SetStatusBarTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", fBarTexture))
	bar:SetStatusBarColor(
		fBarTextureColor["r"],
		fBarTextureColor["g"],
		fBarTextureColor["b"],
		fBarTextureColor["a"]
	)
	
	bar.bg:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", fBarBackground))
	bar.bg:SetAllPoints(true)
	bar.bg:SetVertexColor(
		fBarBackgroundColor["r"],
		fBarBackgroundColor["g"],
		fBarBackgroundColor["b"],
		fBarBackgroundColor["a"]
	)
	
	bar:GetStatusBarTexture():SetHorizTile(false)
	bar:GetStatusBarTexture():SetVertTile(false)
	
	-- Set the indicator
	local align = "LEFT"
	if fBarDirectionReverse then
		align = "RIGHT"
	end
	
	--bar.ti:Show()
	bar.ti:ClearAllPoints()
	bar.ti:SetPoint(align, 0, 0)
	bar.ti:SetWidth(fBarTransitionTextureWidth)
	bar.ti:SetHeight(fBarHeight)
	
	bar.ti.bg:SetTexture(CooldownTimeline.SharedMedia:Fetch("statusbar", fBarTransitionTexture))
	bar.ti.bg:SetAllPoints(true)
	bar.ti.bg:SetVertexColor(
		fBarTransitionTextureColor["r"],
		fBarTransitionTextureColor["g"],
		fBarTransitionTextureColor["b"],
		fBarTransitionTextureColor["a"]
	)
	
	-- Set the text
	bar.text:SetPoint("CENTER", 0, 0)
	bar.text:SetWidth(fBarWidth)
	bar.text:SetHeight(fBarHeight)
	
	
	bar.text.text1:SetFont(CooldownTimeline.SharedMedia:Fetch("font", t1["font"]), t1["size"], t1["outline"])
	bar.text.text1:ClearAllPoints()
	bar.text.text1:SetPoint(t1["align"], bar.text, t1["anchor"], t1["xOffset"], t1["yOffset"])
	--bar.text.text1:SetText(CooldownTimeline:ConvertTextTags(t1["text"]))
	bar.text.text1:SetTextColor(
		t1["color"]["r"],
		t1["color"]["g"],
		t1["color"]["b"],
		t1["color"]["a"]
	)
	bar.text.text1:SetShadowColor(
		t1["shadowColor"]["r"],
		t1["shadowColor"]["g"],
		t1["shadowColor"]["b"],
		t1["shadowColor"]["a"]
	)
	bar.text.text1:SetShadowOffset(t1["shadowXOffset"], t1["shadowYOffset"])
	bar.text.text1:SetNonSpaceWrap(false)
	if t1["enabled"] then
		bar.text.text1:Show()
	else
		bar.text.text1:Hide()
	end
	
	bar.text.text2:SetFont(CooldownTimeline.SharedMedia:Fetch("font", t2["font"]), t2["size"], t2["outline"])
	bar.text.text2:ClearAllPoints()
	bar.text.text2:SetPoint(t2["align"], bar.text, t2["anchor"], t2["xOffset"], t2["yOffset"])
	--bar.text.text2:SetText(CooldownTimeline:ConvertTextTags(t2["text"]))
	bar.text.text2:SetTextColor(
		t2["color"]["r"],
		t2["color"]["g"],
		t2["color"]["b"],
		t2["color"]["a"]
	)
	bar.text.text2:SetShadowColor(
		t2["shadowColor"]["r"],
		t2["shadowColor"]["g"],
		t2["shadowColor"]["b"],
		t2["shadowColor"]["a"]
	)
	bar.text.text2:SetShadowOffset(t2["shadowXOffset"], t2["shadowYOffset"])
	bar.text.text2:SetNonSpaceWrap(false)
	if t2["enabled"] then
		bar.text.text2:Show()
	else
		bar.text.text2:Hide()
	end
	
	bar.text.text3:SetFont(CooldownTimeline.SharedMedia:Fetch("font", t3["font"]), t3["size"], t3["outline"])
	bar.text.text3:ClearAllPoints()
	bar.text.text3:SetPoint(t3["align"], bar.text, t3["anchor"], t3["xOffset"], t3["yOffset"])
	--bar.text.text3:SetText(CooldownTimeline:ConvertTextTags(t3["text"]))
	bar.text.text3:SetTextColor(
		t3["color"]["r"],
		t3["color"]["g"],
		t3["color"]["b"],
		t3["color"]["a"]
	)
	bar.text.text3:SetShadowColor(
		t3["shadowColor"]["r"],
		t3["shadowColor"]["g"],
		t3["shadowColor"]["b"],
		t3["shadowColor"]["a"]
	)
	bar.text.text3:SetShadowOffset(t3["shadowXOffset"], t3["shadowYOffset"])
	bar.text.text3:SetNonSpaceWrap(false)
	if t3["enabled"] then
		bar.text.text3:Show()
	else
		bar.text.text3:Hide()
	end
	
	bar.ti:Hide()
end

-- Things we need to do to refresh all icons
function CooldownTimeline:RefreshIcons()
	for _, child in ipairs(CooldownTimeline.iconTable) do
		CooldownTimeline:RefreshIcon(child)
	end
end

function CooldownTimeline:RefreshIcon(icon)
	local SharedMedia = CooldownTimeline.SharedMedia
	
	local iconSize = self.db.profile.fIconSize
	local fIconText = self.db.profile.fIconText
	local offset = self.db.profile.fTimelineIconOffset
	--local text = fIconText["text"]
	
	local parent = icon:GetParent():GetName()
	if parent == "CooldownTimeline_Ready" then
		fIconText = self.db.profile.fIconReadyText
		--text = "Ready"
		iconSize = 	self.db.profile.fReadyIconSize
		offset = 0
	elseif parent == "CooldownTimeline_Fastlane" then
		fIconText = self.db.profile.fIconFastlaneText
		iconSize = self.db.profile.fFastlaneIconSize
		offset = self.db.profile.fFastlaneIconOffset
	end
	
	-- Border
	local border = self.db.profile.fIconBorder
	local borderColor = self.db.profile.fIconBorderColor
	local borderSize = self.db.profile.fIconBorderSize
	local borderInset = self.db.profile.fIconBorderInset
	local borderPadding = self.db.profile.fIconBorderPadding
	
	-- Highlight Border
	local highlightBorder = self.db.profile.fIconHighlightBorder
	local highlightBorderColor = self.db.profile.fIconHighlightBorderColor
	local highlightBorderSize = self.db.profile.fIconHighlightBorderSize
	local highlightBorderInset = self.db.profile.fIconHighlightBorderInset
	local highlightBorderPadding = self.db.profile.fIconHighlightBorderPadding
	
	icon:ClearAllPoints()
	icon:SetSize(iconSize, iconSize)
	icon:SetPoint("CENTER", 0, offset)
	
	-- Set the icon texture
	icon.tex:SetAllPoints(icon)
	icon.tex:SetTexture(icon.cdIcon)
	
	if CooldownTimeline.Masque then
		-- Kill masque for this icon(button)
		CooldownTimeline.masqueGroup = CooldownTimeline.Masque:Group("CooldownTimeline")
		CooldownTimeline.masqueGroup:RemoveButton(icon)
		
		-- Reapply masque
		CooldownTimeline.masqueGroup:AddButton(icon, { Icon = icon.tex })	
	end
	
	-- Set the icon fonts/text
	icon.text:SetFont(CooldownTimeline.SharedMedia:Fetch("font", fIconText["font"]), fIconText["size"], fIconText["outline"])
	icon.text:ClearAllPoints()
	icon.text:SetPoint(fIconText["align"], icon, fIconText["anchor"], fIconText["xOffset"], fIconText["yOffset"])
	icon.text:SetText(CooldownTimeline:ConvertTextTags(fIconText["text"], icon))
	icon.text:SetTextColor(
		fIconText["color"]["r"],
		fIconText["color"]["g"],
		fIconText["color"]["b"],
		fIconText["color"]["a"]
	)
	icon.text:SetShadowColor(
		fIconText["shadowColor"]["r"],
		fIconText["shadowColor"]["g"],
		fIconText["shadowColor"]["b"],
		fIconText["shadowColor"]["a"]
	)
	icon.text:SetShadowOffset(fIconText["shadowXOffset"], fIconText["shadowYOffset"])
	icon.text:SetNonSpaceWrap(false)
	
	-- Reset the icon coloring back to normal
	icon.tex:SetDesaturated(nil)
	icon.tex:SetVertexColor(1,1,1,1)
	
	-- Set the duration of the stay in 'Ready'
	icon.readyTimerDuration = self.db.profile.fReadyIconDuration
	
	-- Setup the icon border
	icon.border:SetSize(iconSize + borderPadding, iconSize + borderPadding)
	icon.border:SetPoint("CENTER", 0, 0)
	--icon.border:SetPoint("TOPLEFT", icon.frameName, "TOPLEFT", -borderPadding, borderPadding)
	--icon.border:SetPoint("BOTTOMRIGHT", icon.frameName, "BOTTOMRIGHT", borderPadding, -borderPadding)
	icon.border:SetBackdrop({
		bgFile = SharedMedia:Fetch("background", "None"),
		edgeFile = SharedMedia:Fetch("border", border),
		tile = false,
		tileSize = 0,
		edgeSize = borderSize,
		insets = { left = borderInset, right = borderInset, top = borderInset, bottom = borderInset }
	})
	local r = borderColor["r"]
	local g = borderColor["g"]
	local b = borderColor["b"]
	local a = borderColor["a"]
	icon.border:SetBackdropBorderColor(r, g, b, a)
	icon.border:SetFrameLevel(icon:GetFrameLevel() + 1)
	
	-- Setup the icon border highlight
	icon.highlightBorder:SetSize(iconSize + highlightBorderPadding, iconSize + highlightBorderPadding)
	icon.highlightBorder:SetPoint("CENTER", 0, 0)
	icon.highlightBorder:SetBackdrop({
		bgFile = SharedMedia:Fetch("background", "None"),
		edgeFile = SharedMedia:Fetch("border", highlightBorder),
		tile = false,
		tileSize = 0,
		edgeSize = highlightBorderSize,
		insets = { left = highlightBorderInset, right = highlightBorderInset, top = highlightBorderInset, bottom = highlightBorderInset }
	})
	local r = highlightBorderColor["r"]
	local g = highlightBorderColor["g"]
	local b = highlightBorderColor["b"]
	local a = highlightBorderColor["a"]
	icon.highlightBorder:SetBackdropBorderColor(r, g, b, a)
	icon.highlightBorder:SetFrameLevel(icon:GetFrameLevel() + 2)
	
	icon:EnableMouse(self.db.profile.enableTooltips)
end

-- Scan all auras and return them in a table
function CooldownTimeline:ScanAuras()
	local auras = {}
	
	-- Buffs
	for i = 1, 40, 1 do
		local name, _, _, _, duration, _, _, _,  _, spellId, _, _, _, _, _ = UnitBuff("player", i)
		if name then
			--CooldownTimeline:Print(name.." - "..duration.." - "..spellId)
			table.insert(auras, name)
		end
	end
	
	-- Debufs
	for i = 1, 40, 1 do
		local name, _, _, _, duration, _, _, _,  _, spellId, _, _, _, _, _ = UnitDebuff("player", i)
		if name then
			--CooldownTimeline:Print(name.." - "..duration.." - "..spellId)
			table.insert(auras, name)
		end
	end
	
	return auras
end

-- Go through the list of manually added 
function CooldownTimeline:ScanAuraTable()
	for _, aura in pairs(CooldownTimeline.aurasToTrack) do
		if not CooldownTimeline:CheckWhitelistForDoubles(aura["name"], "AURA") then
			table.insert(CooldownTimeline.db.profile.whitelistAuras, { type = aura["type"], id = aura["id"], tracked = true, highlight = false, name = aura["name"] })
		end
	end
end

-- Check if any spells are currently on cooldown
-- Used when zoning/reloading
function CooldownTimeline:ScanCurrentCooldowns()
	for _, spell in ipairs(CooldownTimeline.spellTable) do
		local matchFound, matchFrame = self:CheckExistingIcons(spell["name"])
		
		if not matchFound then
			local start, duration
			
			if spell["type"] == "SPELL" or spell["type"] == "PETSPELL" then
				start, duration, _, _ = GetSpellCooldown(spell["id"])
			elseif spell["type"] == "ITEM" then
				start, duration, _, _ = GetItemCooldown(spell["id"])
				--CooldownTimeline:Print(spell["name"].." - "..spell["sid"].." - "..start.." - "..duration)
			end
			
			local remaining = (start + duration) - GetTime()
		
			if remaining > 0 then
				local data = {}
				
				data["name"] = spell["name"]
				data["type"] = spell["type"]
				data["id"] = spell["id"]
				
				self:CreateCooldownIcon(data)
			end
		end
	end
end

-- Scan your inventory for items that can be 'used'
function CooldownTimeline:ScanInventory()
	--CooldownTimeline:Print("scanning inventory")
	-- Scan the items equipped
	for i = 0, 23, 1 do
		local itemId = GetInventoryItemID("player", i)
		local spellName, spellID = GetItemSpell(itemId)
		
		if not CooldownTimeline:IsBlacklisted("ITEM", spellName) then
			if spellName ~= nil then
				local _, itemType, itemSubType, _, _, itemClassID, itemSubClassID = GetItemInfoInstant(itemId)
				--CooldownTimeline:Print(i.." - "..tostring(itemId).." - "..tostring(itemType).." - "..tostring(itemSubType))
				
				local data = {
					type = "ITEM",
					--name = itemName,
					name = spellName,
					id = itemId,
					sid = spellID,
				}
				if not CooldownTimeline:CheckSpellTableForDoubles(itemId) then
					--CooldownTimeline:Print(itemId.." - "..spellName.." - "..spellID)
					table.insert(CooldownTimeline.spellTable, data)
					
					if not CooldownTimeline:CheckWhitelistForDoubles(spellName, "ITEM") then
						table.insert(CooldownTimeline.db.profile.whitelistItems, { type = "ITEM", id = itemId, tracked = true, highlight = false, name = spellName })
					end
				end
			end
		end
	end
	
	-- Scan items in bags
	for i = 0, 4, 1 do
		local numberOfSlots = GetContainerNumSlots(0)
		for x = 0, numberOfSlots, 1 do
			local itemId = GetContainerItemID(i, x)
			local spellName, spellID = GetItemSpell(itemId)
			
			if spellName ~= nil then
				local _, itemType, itemSubType, _, _, itemClassID, itemSubClassID = GetItemInfoInstant(itemId)
				
				if	itemSubType ~= "Mount" and
					itemSubType ~= "Recipe"
				then
					if CooldownTimeline:IsValidItemType(itemType) then
						if not CooldownTimeline:IsBlacklisted("ITEM", spellName) then
							--CooldownTimeline:Print(i.."/"..x.." - "..tostring(itemId).." - "..tostring(itemType).." - "..tostring(itemSubType))
							
							local data = {
								type = "ITEM",
								--name = itemName,
								name = spellName,
								id = itemId,
								sid = spellID,
							}
							if not CooldownTimeline:CheckSpellTableForDoubles(itemId) then
								--CooldownTimeline:Print(spellName.." - "..itemId)
								table.insert(CooldownTimeline.spellTable, data)
								
								if not CooldownTimeline:CheckWhitelistForDoubles(spellName, "ITEM") then
									table.insert(CooldownTimeline.db.profile.whitelistItems, { type = "ITEM", id = itemId, tracked = true, highlight = false, name = spellName })
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- Sort the whitelist
	table.sort(CooldownTimeline.db.profile.whitelistItems, function(a, b)
			local aN = a["name"]
			local bN = b["name"]
			
			return aN < bN
		end)
end

-- Scan spellbook spells, and save the ones that have cooldowns
function CooldownTimeline:ScanSpellbook()
	--CooldownTimeline:Print("scanning spellbook")
	local numTabs = GetNumSpellTabs()
	
	-- Count the number of spells
	local numSpells = 0
	for i = 1, numTabs, 1 do
		local _, _, _, numEntries, _, _ = GetSpellTabInfo(i)
		numSpells = numSpells + numEntries
	end
	
	-- Now we collect them
	for i = 1, numSpells, 1 do
		local spellName, spellSubName, spellID = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		local cooldownMS, _ = GetSpellBaseCooldown(spellID)
		
		if not CooldownTimeline:IsBlacklisted("SPELL", spellName) then
			if cooldownMS > 0 then
				local data = {
					type = "SPELL",
					name =  spellName,
					subname = spellSubName,
					id = spellID,
				}
				if not CooldownTimeline:CheckSpellTableForDoubles(spellID) then
					--CooldownTimeline:Print(spellName.." - "..spellID)
					table.insert(CooldownTimeline.spellTable, data)
					
					if not CooldownTimeline:CheckWhitelistForDoubles(spellName, "SPELL") then
						table.insert(CooldownTimeline.db.profile.whitelist, { type = "SPELL", tracked = true, highlight = false, name = spellName })
					end
				end
			end
		end
	end
	
	-- Sort the whitelist
	table.sort(CooldownTimeline.db.profile.whitelist, function(a, b)
			local aN = a["name"]
			local bN = b["name"]
			
			return aN < bN
		end)
end

-- Scan pet spellbook spells, and save the ones that have cooldowns
function CooldownTimeline:ScanPetSpellbook()
	-- Collect pet spells if available
	local petExists = UnitExists("pet")
	
	if petExists then
		local hasPetSpells, _ = HasPetSpells()
		
		if hasPetSpells then
			if hasPetSpells > 0 then
				for i = 1, hasPetSpells, 1 do
					local pSpellName, pSpellSubName, pSpellID = GetSpellBookItemName(i, BOOKTYPE_PET)
					
					if pSpellName then
						if not CooldownTimeline:IsBlacklisted("PETSPELL", pSpellName) then
							--CooldownTimeline:Print(pSpellName.." - "..pSpellID)
							local pCooldownMS, _ = GetSpellBaseCooldown(pSpellID)
							
							if pCooldownMS > 0 then
								local data = {
									type = "PETSPELL",
									name =  pSpellName,
									subname = pSpellSubName,
									id = pSpellID,
									--cd = pCooldownMS
								}
								if not CooldownTimeline:CheckSpellTableForDoubles(pSpellID) then
									--CooldownTimeline:Print(tostring(pSpellName).." - "..tostring(pSpellID))
									table.insert(CooldownTimeline.spellTable, data)
									
									if not CooldownTimeline:CheckWhitelistForDoubles(pSpellName, "PETSPELL") then
										table.insert(CooldownTimeline.db.profile.whitelistPet, { type = "PETSPELL", tracked = true, highlight = false, name = pSpellName })
									end
								end
							end
						end
					end
				end
				
				-- Sort the whitelist
				table.sort(CooldownTimeline.db.profile.whitelistPet, function(a, b)
						local aN = a["name"]
						local bN = b["name"]
						
						return aN < bN
					end)
			end
		end
	end
end

function CooldownTimeline:SetBorder(frame, border, size, inset)
	frame.border:SetBackdrop({
		bgFile = SharedMedia:Fetch("background", "None"),
		edgeFile = SharedMedia:Fetch("border", border),
		tile = false,
		tileSize = 0,
		edgeSize = size,
		insets = { left = inset, right = inset, top = inset, bottom = inset }
	})
end
	
function CooldownTimeline:SetBorderColor(frame, color)	
	frame.border:SetBackdropBorderColor(color["r"], color["g"], color["b"], color["a"])
end

function CooldownTimeline:SetBorderPoint(frame, padding)
	frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -padding, padding)
	frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", padding, -padding)
end

function CooldownTimeline:SetHighlightBorder(frame, border, size, inset)
	frame.highlightBorder:SetBackdrop({
		bgFile = SharedMedia:Fetch("background", "None"),
		edgeFile = SharedMedia:Fetch("border", border),
		tile = false,
		tileSize = 0,
		edgeSize = size,
		insets = { left = inset, right = inset, top = inset, bottom = inset }
	})
end
	
function CooldownTimeline:SetHighlightBorderColor(frame, color)	
	frame.highlightBorder:SetBackdropBorderColor(color["r"], color["g"], color["b"], color["a"])
end

function CooldownTimeline:SetHighlightBorderPoint(frame, padding)
	frame.highlightBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -padding, padding)
	frame.highlightBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", padding, -padding)
end

-- Should we 'hide' the timeline/ready frame
function CooldownTimeline:ShouldHide(frame)
	-- Dont hide if the frames are unlocked
	if CooldownTimeline.db.profile.unlockFrames then
		return false
	end
	
	-- Dont hide in combat
	if not CooldownTimeline.db.profile.onlyShowWhenCoolingDown then
		if CooldownTimeline.inCombat then
			return false
		end
	end
	
	-- And dont hide if there is a non-ignored cooldown currently active
	local children = { frame:GetChildren() }
	local validCount = 0
	for k, child in pairs(children) do
		-- Only want icons, not other frames attached to the timeline
		if child.cdUniqueID then
			if not child.ignored then
				if frame:GetName() == "CooldownTimeline_Ready" then
					if child.highlighted then
						if CooldownTimeline.db.profile.fIconHighlightPin then
							if CooldownTimeline.fReady.outOfCombatTimer > 0 or CooldownTimeline.inCombat then
								validCount = validCount + 1
							end
						else
							validCount = validCount + 1
						end
					else
						validCount = validCount + 1
					end
				else
					validCount = validCount + 1
				end
				
			end
		end
	end
	
	if validCount > 0 then
		return false
	end
	
	return true
end

-- Work out if the spell should show a bar
function CooldownTimeline:SpellShowBar(spellName, type)
	local searchList = CooldownTimeline.db.profile.whitelist
	
	if type == "ITEM" then
		searchList = CooldownTimeline.db.profile.whitelistItems
	elseif type == "PETSPELL" then
		searchList = CooldownTimeline.db.profile.whitelistPet
	elseif type == "BUFF" or type == "DEBUFF" then
		searchList = CooldownTimeline.db.profile.whitelistAuras
		spellName = spellName:gsub("BUFF_", "")
	elseif type == "OAURA" then
		searchList = CooldownTimeline.db.profile.whitelistAuras
		spellName = spellName:gsub("OAURA_", "")
	end
	
	for _, spell in pairs(searchList) do
		if spell["name"] == spellName then
				return spell["bar"]
		end
	end
	
	return false
end

-- Work out if the spell is highlighted
function CooldownTimeline:SpellIsHighlighted(spellName, type)
	local searchList = CooldownTimeline.db.profile.whitelist
	
	if type == "ITEM" then
		searchList = CooldownTimeline.db.profile.whitelistItems
	elseif type == "PETSPELL" then
		searchList = CooldownTimeline.db.profile.whitelistPet
	elseif type == "BUFF" or type == "DEBUFF" then
		searchList = CooldownTimeline.db.profile.whitelistAuras
		spellName = spellName:gsub("BUFF_", "")
	elseif type == "OAURA" then
		searchList = CooldownTimeline.db.profile.whitelistAuras
		spellName = spellName:gsub("OAURA_", "")
	end
	
	for _, spell in pairs(searchList) do
		if spell["name"] == spellName then
				return spell["highlight"]
		end
	end
	
	return false
end

-- Work out if the spell is in the fastlane
function CooldownTimeline:SpellIsInFastLane(spellName, type)
	local searchList = CooldownTimeline.db.profile.whitelist
	
	if type == "ITEM" then
		searchList = CooldownTimeline.db.profile.whitelistItems
	elseif type == "PETSPELL" then
		searchList = CooldownTimeline.db.profile.whitelistPet
	elseif type == "BUFF" or type == "DEBUFF" then
		searchList = CooldownTimeline.db.profile.whitelistAuras
		spellName = spellName:gsub("BUFF_", "")
	elseif type == "OAURA" then
		searchList = CooldownTimeline.db.profile.whitelistAuras
		spellName = spellName:gsub("OAURA_", "")
	end
	
	for _, spell in pairs(searchList) do
		if spell["name"] == spellName then
				return spell["fastlane"]
		end
	end
	
	return false
end

-- Work out if the spell is whitelisted
function CooldownTimeline:SpellIsWhitelisted(spellName, type)
	local searchList = CooldownTimeline.db.profile.whitelist
	
	if type == "ITEM" then
		searchList = CooldownTimeline.db.profile.whitelistItems
	elseif type == "PETSPELL" then
		searchList = CooldownTimeline.db.profile.whitelistPet
	elseif type == "BUFF" or type == "DEBUFF" or type == "OAURA" then
		searchList = CooldownTimeline.db.profile.whitelistAuras
		spellName = spellName:gsub("BUFF_", "")
		spellName = spellName:gsub("DEBUFF_", "")
		spellName = spellName:gsub("OAURA_", "")
	end
	
	for _, spell in pairs(searchList) do
		if spell["name"] == spellName then
			return spell["tracked"]
		end
	end
	
	return true
end

-- Organise and stack all the icons
function CooldownTimeline:StackCalculator()
	-- Get the icons
	local iconCount = 0
	local iconsToStack = {}
	for k, icon in pairs(CooldownTimeline.iconTable) do
		if icon:GetParent():GetName() == "CooldownTimeline_Timeline" then
			-- Dont get ignored icons
			if not icon.ignored and not icon.fastlane then
				table.insert(iconsToStack, icon)
				iconCount = iconCount + 1
			-- Just set the icon to the bottom
			else
				local levelMultiplier = 5
				local baseLevel = k * levelMultiplier
				
				icon:SetFrameLevel(baseLevel)
				icon.border:SetFrameLevel(baseLevel + 1)
				icon.highlightBorder:SetFrameLevel(baseLevel + 2)
			end
		end
	end
	
	if CooldownTimeline.db.profile.fTimelineStack then
		if iconCount > 0 then			
			local stackHeight = CooldownTimeline.db.profile.fTimelineStackMaxSize
			local verticalOffset = stackHeight / iconCount
			local fIconSize = CooldownTimeline.db.profile.fIconSize
			
			if CooldownTimeline.db.profile.fTimelineStackOverlap then
				-- Sort the icons
				table.sort(iconsToStack, function(a, b)
						local aX, _ = a:GetCenter()
						local bX, _ = b:GetCenter()
						
						return aX < bX
					end)
				
				-- We dont need to do anything for only 1 icon
				if iconCount > 1 then
					local stackIndexes = {}
					local currentStackNumber = 1
					
					for k, iconA in pairs(iconsToStack) do
						if k == 1 then
							table.insert(stackIndexes, currentStackNumber)
						end
						
						if k + 1 <= iconCount then
							local iconB = iconsToStack[k + 1]
							local aX, _ = iconA:GetCenter()
							local bX, _ = iconB:GetCenter()
							local distance = math.abs(aX - bX)
							
							if distance <= fIconSize then
								table.insert(stackIndexes, currentStackNumber)
							else
								currentStackNumber = currentStackNumber + 1
								table.insert(stackIndexes, currentStackNumber)
							end
						end
						
						for i = 1, currentStackNumber, 1 do
							local currentStack = {}
							local iconsInCurrentStack = 0
							-- Count how many we have in the i'nth stack
							for k, v in pairs(stackIndexes) do
								if v == i then
									iconsInCurrentStack = iconsInCurrentStack + 1
									table.insert(currentStack, iconsToStack[k])
								end
							end
							
							table.sort(currentStack, function(a, b)
									return a.cdRemaining > b.cdRemaining
								end)
							
							-- Then set the correct data for the i'nth stack
							for k, icon in pairs(currentStack) do
								verticalOffset = stackHeight / iconsInCurrentStack
								local iconOffset = verticalOffset * (k - 1)
								local stackOffset = (stackHeight / 2)
								--icon:SetPoint("CENTER", 0, iconOffset - stackOffset  + (verticalOffset / 2) + generalIconOffset)						
								icon.stackOffset = iconOffset - stackOffset  + (verticalOffset / 2)
								
								local levelMultiplier = 5
								local baseLevel = k * levelMultiplier
								
								icon:SetFrameLevel(baseLevel)
								icon.border:SetFrameLevel(baseLevel + 1)
								icon.highlightBorder:SetFrameLevel(baseLevel + 2)
							end
						end
					end
				else
					iconsToStack[1].stackOffset = 0
				end
				
				table.sort(iconsToStack, function(a, b)
					return a.cdRemaining > b.cdRemaining
				end)
				
				for k, icon in pairs(iconsToStack) do
					local levelMultiplier = 5
					local baseLevel = k * levelMultiplier
					
					icon:SetFrameLevel(baseLevel)
					icon.border:SetFrameLevel(baseLevel + 1)
					icon.highlightBorder:SetFrameLevel(baseLevel + 2)
				end
			else
				table.sort(iconsToStack, function(a, b)
					return a.cdRemaining > b.cdRemaining
				end)
				
				for k, icon in pairs(iconsToStack) do
					if iconCount == 1 then
						icon.stackOffset = 0
					else
						local iconOffset = verticalOffset * (k - 1)
						local stackOffset = (stackHeight / 2)
						icon.stackOffset = iconOffset - stackOffset  + (verticalOffset / 2)
					end
					
					local levelMultiplier = 5
					local baseLevel = k * levelMultiplier
					
					icon:SetFrameLevel(baseLevel)
					icon.border:SetFrameLevel(baseLevel + 1)
					icon.highlightBorder:SetFrameLevel(baseLevel + 2)
				end
			end
		end
	-- Simple layering based on time left on the cooldown
	else
		table.sort(iconsToStack, function(a, b)
				return a.cdRemaining > b.cdRemaining
			end)
	
		for k, icon in pairs(iconsToStack) do
			local levelMultiplier = 5
			local baseLevel = k * levelMultiplier
			
			icon.stackOffset = 0
			
			icon:SetFrameLevel(baseLevel)
			icon.border:SetFrameLevel(baseLevel + 1)
			icon.highlightBorder:SetFrameLevel(baseLevel + 2)
		end
	end
end

function CooldownTimeline:UnlockFrame(frame)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	
	if frame:GetName() == "CooldownTimeline_Timeline" then
		CooldownTimeline:SetTimelineText()
	end
	
	frame.unlockTexture:Show()
	frame.unlockText:Show()
end

function CooldownTimeline:LockFrame(frame)
	frame:SetMovable(false)
	frame:EnableMouse(false)
	
	if frame:GetName() == "CooldownTimeline_Timeline" then
		CooldownTimeline:SetTimelineText()
	end
	
	frame.unlockTexture:Hide()
	frame.unlockText:Hide()
end

function CooldownTimeline:TestCode1()
	--CooldownTimeline:Print("")
	self:CleanDuplicates()
end

function CooldownTimeline:TestCode2()
	--CooldownTimeline:Print("")
	CooldownTimeline:StopAnimation(901)
end