--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}

function CooldownTimeline:CreateAnimationFrame()
	CooldownTimeline.fAnimation = CreateFrame("Frame", "CooldownTimeline_Animation", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	-- OnUpdate
	self.fTimeline:HookScript("OnUpdate", function(self, elapsed)
		private.AnimationUpdate(self, elapsed)
	end)
end

function CooldownTimeline:AnimationIsPlaying(frame)
	for _, ani in pairs(CooldownTimeline.animationTable) do
		if ani then
			local f = ani["frame"]
			if frame.cdUniqueID == f.cdUniqueID then
				return true
			end
		end
	end

	return false
end

--[[private.GetAnimation = function(uniqueID)
	for _, ani in pairs(CooldownTimeline.animationTable) do
		local frame = ani["frame"]
		if frame.cdUniqueID == uniqueID then
			return ani
		end
	end
	
	return nil
end]]--

function CooldownTimeline:StartAnimation(frame, type, start, duration, startValue, endValue, finishValue, loop, bounce)
	local ani = {}
	ani["frame"] = frame
	ani["type"] = type
	ani["start"] = start
	ani["duration"] = duration
	ani["startValue"] = startValue
	ani["endValue"] = endValue
	ani["finishValue"] = finishValue
	ani["loop"] = loop
	ani["bounce"] = bounce
	
	table.insert(CooldownTimeline.animationTable, ani)
end

function CooldownTimeline:StopAnimation(uniqueID)
	for k, ani in pairs(CooldownTimeline.animationTable) do
		local frame = ani["frame"]
		local type = ani["type"]
		local finishValue = ani["finishValue"]
		
		if frame.cdUniqueID == uniqueID then
			--CooldownTimeline:Print('stopping animation of '..tostring(frame.cdUniqueID))
			
			if type == "FADE" then
				private.StopAnimateFade(frame, finishValue)
			elseif type == "SCALE" then
				private.StopAnimateScale(frame, finishValue)
			end
			
			table.remove(CooldownTimeline.animationTable, k)
			break
		end
	end
end

function CooldownTimeline:StopAllAnimation()
	for k, ani in pairs(CooldownTimeline.animationTable) do
		local frame = ani["frame"]
		local type = ani["type"]
		local finishValue = ani["finishValue"]
		
		if type == "FADE" then
			private.StopAnimateFade(frame, finishValue)
		elseif type == "SCALE" then
			private.StopAnimateScale(frame, finishValue)
		end
		
		table.remove(CooldownTimeline.animationTable, k)
	end
end

private.AnimationUpdate = function(self, elapsed)
	for _, ani in pairs(CooldownTimeline.animationTable) do
		local frame = ani["frame"]
		local type = ani["type"]
		local start = ani["start"]
		local duration = ani["duration"]
		local startValue = ani["startValue"]
		local endValue = ani["endValue"]
		local finishValue = ani["finishValue"]
		local loop = ani["loop"]
		local bounce = ani["bounce"]
		
		local currentTime = GetTime()
		local endtime = ani["start"] + ani["duration"]
		local progress = (endtime - currentTime) - ani["duration"]
		local percent = progress / duration
		
		if currentTime > endtime then
			if ani["loop"] == -1 then
				ani["start"] = currentTime
			else
				ani["loop"] = ani["loop"] - 1
				ani["start"] = currentTime
			end
			
			if bounce then
				ani["startValue"] = endValue
				ani["endValue"] = startValue
			end
		end
		
		if ani["loop"] == 0 then
			CooldownTimeline:StopAnimation(frame.cdUniqueID)
		else
			--frame:SetAlpha(percent)
			
			if type == "FADE" then
				private.AnimateFade(frame, percent, startValue, endValue)
			elseif type == "SCALE" then
				private.AnimateScale(frame, percent, startValue, endValue)
			end
		end
	end
end

private.AnimateFade = function(frame, percent, startValue, endValue)
	local variation = startValue - endValue
	local value = (variation * percent) + startValue
	
	frame:SetAlpha(value)
	--CooldownTimeline:Print("animating "..frame.cdUniqueID.." - "..tostring(value))	
end

private.AnimateScale = function(frame, percent, startValue, endValue)
	local scale = frame:GetScale()
	local effectiveScale = frame:GetEffectiveScale()
	
	local variation = (startValue * effectiveScale) - (endValue * effectiveScale)
	local value = (variation * percent) + startValue
	
	local width, height = frame:GetSize();
	frame:SetSize(width * value, height * value);
	
end

private.StopAnimateFade = function(frame, finishValue)
	frame:SetAlpha(finishValue)
end

private.StopAnimateScale = function(frame, finishValue)
	frame:SetScale(finishValue)
end