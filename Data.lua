--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline-2
]]--

-- List of auras to track
CooldownTimeline.aurasToTrack = {
	{	name = "Recently Bandaged",
		type = "DEBUFF",
		id = 11196
	},
	{	name = "Weakened Soul",
		type = "DEBUFF",
		id = 6788
	},
	{	name = "Tinnitus",
		type = "DEBUFF",
		id = 51120
	},
	{	name = "Hypothermia",
		type = "DEBUFF",
		id = 41425
	},
	{	name = "Arcane Blast",
		type = "DEBUFF",
		id = 36032
	},
}

-- This is a list of spells that will never generate an icon
CooldownTimeline.blacklist = {
	"Shadowform",	-- Has a 1.5 second cooldown, the same as the GCD, and does not need to be tracked
}

CooldownTimeline.blacklistPet = {
	
}

-- This is a list of spells that will never generate an icon
CooldownTimeline.blacklistItems = {
	-- MOUNTS - DWARF --
	"Swift Brown Ram",
	"Swift Gray Ram",
	"Swift White Ram",
	
	-- MOUNTS - GNOME --
	"Swift Green Mechanostrider",
	"Swift White Mechanostrider",
	"Swift Yellow Mechanostrider",
	
	-- MOUNTS - HUMAN --
	"Swift Palomino",
	"Swift Brown Steed",
	"Swift White Steed",
	
	-- MOUNTS - NELF --
	"Swift Frostsaber",
	"Swift Stormsaber",
	"Swift Mistsaber",
	
	-- MOUNTS - ORC --
	"Swift Timber Wolf",
	"Swift Brown Wolf",
	"Swift Gray Wolf",
	
	-- MOUNTS - TROLL --
	"Swift Blue Raptor",
	"Swift Olive Raptor",
	"Swift Orange Raptor",
	
	-- MOUNTS - OTHER --
	"Swift Zulian Tiger",
	"Swift Razzashi Raptor",
	
	-- MOUNTS - FLYING --
	
}

-- This is a list of spells that will never generate an icon
CooldownTimeline.blacklistAuras = {

}

-- The String for the custom text tag description
function CooldownTimeline:GetCustomTextTagDescription()
	local text = ""
	
	text = text.."Currently custom tags are in the following format:\n\n"
	text = text.."    [p.hp.max]\n\n"
	text = text.."Currently supports the following categories:\n\n"
	text = text.."    'cdtl' - CDTL specfic\n"
	text = text.."    'p' - Player\n"
	text = text.."    'f' - Focus\n"
	text = text.."    't' - Target\n\n"
	text = text.."Supports the following sub types for CDTL:\n\n"
	text = text.."    '.name.n' - Name of next due CD\n"
	text = text.."    '.name.l' - Name of last due CD\n"
	text = text.."    '.name.nh' - Name of next due highlighted CD\n"
	text = text.."    '.name.lh' - Name of last due highlighted CD\n"
	text = text.."    '.time.n' - Time left of next due CD\n"
	text = text.."    '.time.l' - Time left of last due CD\n"
	text = text.."    '.time.nh' - Time left of next due highlighted CD\n"
	text = text.."    '.time.lh' - Time left of last due highlighted CD\n\n"
	text = text.."Supports the following sub types for non-CDTL:\n\n"
	text = text.."    '.name' - Unit name\n"
	text = text.."    '.class' - Unit class\n"
	text = text.."    '.level' - Unit level\n"
	text = text.."    '.hp.cur' - Current HP\n"
	text = text.."    '.hp.max' - Max HP\n"
	text = text.."    '.pow.cur' - Current power amount\n"
	text = text.."    '.pow.max' - Max power amount\n"
	
	return text
end

-- The String for the icon text tag description
function CooldownTimeline:GetCustomIconTagDescription()
	local text = ""
	
	text = text.."Currently custom tags are in the following format:\n\n"
	text = text.."    [cd.name]\n\n"
	text = text.."Supports the following tags:\n\n"
	text = text.."    'cd.name' - Icon name\n"
	text = text.."    'cd.time' - Time remaining for the icon class\n"
	text = text.."    'cd.type' - Icon type (SPELL, ITEM, etc.)\n"
	
	return text
end


-- Holds all the custom text tags
CooldownTimeline.customTextTags = {
	-- CDTL --
	{	name = "Next CD Name",
		cat = "CDTL",
		desc = "Show the name of the next CD due",
		tag = "%[cdtl.name.n%]",
		func = function()
					local name = ""
					local lowestTime = 10000
					
					for _, icon in ipairs(CooldownTimeline.iconTable) do
						if icon:GetParent():GetName() == "CooldownTimeline_Timeline" then
							if not icon.ignored then
								if icon.cdRemaining < lowestTime then
									name = icon.cdName
									lowestTime = icon.cdRemaining
								end
							end
						end
					end
					
					return name
				end,
	},
	{	name = "Last CD Name",
		cat = "CDTL",
		desc = "Show the name of the last CD due",
		tag = "%[cdtl.name.l%]",
		func = function()
					local name = ""
					local lowestTime = 0
					
					for _, icon in ipairs(CooldownTimeline.iconTable) do
						if icon:GetParent():GetName() == "CooldownTimeline_Timeline" then
							if not icon.ignored then
								if icon.cdRemaining > lowestTime then
									name = icon.cdName
									lowestTime = icon.cdRemaining
								end
							end
						end
					end
					
					return name
				end,
	},
	{	name = "Next CD Time",
		cat = "CDTL",
		desc = "Show the time left of the next CD due",
		tag = "%[cdtl.time.n%]",
		func = function()
					local timeString = ""
					local lowestTime = 10000
					
					for _, icon in ipairs(CooldownTimeline.iconTable) do
						if icon:GetParent():GetName() == "CooldownTimeline_Timeline" then
							if not icon.ignored then
								if icon.cdRemaining < lowestTime then
									timeString = tostring(CooldownTimeline:ConvertToReadableTime(icon.cdRemaining))
									lowestTime = icon.cdRemaining
								end
							end
						end
					end
					
					return timeString
				end,
	},
	{	name = "Last CD Time",
		cat = "CDTL",
		desc = "Show the time left of the last CD due",
		tag = "%[cdtl.time.l%]",
		func = function()
					local timeString = ""
					local lowestTime = 0
					
					for _, icon in ipairs(CooldownTimeline.iconTable) do
						if icon:GetParent():GetName() == "CooldownTimeline_Timeline" then
							if not icon.ignored then
								if icon.cdRemaining > lowestTime then
									timeString = tostring(CooldownTimeline:ConvertToReadableTime(icon.cdRemaining))
									lowestTime = icon.cdRemaining
								end
							end
						end
					end
					
					return timeString
				end,
	},
	{	name = "Next Highlighted CD Name",
		cat = "CDTL",
		desc = "Show the name of the next highlighted CD due",
		tag = "%[cdtl.name.nh%]",
		func = function()
					local name = ""
					local lowestTime = 10000
					
					for _, icon in ipairs(CooldownTimeline.iconTable) do
						if icon:GetParent():GetName() == "CooldownTimeline_Timeline" then
							if not icon.ignored then
								if icon.highlighted then
									if icon.cdRemaining < lowestTime then
										name = icon.cdName
										lowestTime = icon.cdRemaining
									end
								end
							end
						end
					end
					
					return name
				end,
	},
	{	name = "Next Highlighted CD Name",
		cat = "CDTL",
		desc = "Show the name of the last highlighted CD due",
		tag = "%[cdtl.name.lh%]",
		func = function()
					local name = ""
					local lowestTime = 0
					
					for _, icon in ipairs(CooldownTimeline.iconTable) do
						if icon:GetParent():GetName() == "CooldownTimeline_Timeline" then
							if not icon.ignored then
								if icon.highlighted then
									if icon.cdRemaining > lowestTime then
										name = icon.cdName
										lowestTime = icon.cdRemaining
									end
								end
							end
						end
					end
					
					return name
				end,
	},
	{	name = "Next Highlighted CD Time",
		cat = "CDTL",
		desc = "Show the time left of the next highlighted CD due",
		tag = "%[cdtl.time.nh%]",
		func = function()
					local timeString = ""
					local lowestTime = 10000
					
					for _, icon in ipairs(CooldownTimeline.iconTable) do
						if icon:GetParent():GetName() == "CooldownTimeline_Timeline" then
							if not icon.ignored then
								if icon.highlighted then
									if icon.cdRemaining < lowestTime then
										timeString = tostring(CooldownTimeline:ConvertToReadableTime(icon.cdRemaining))
										lowestTime = icon.cdRemaining
									end
								end
							end
						end
					end
					
					return timeString
				end,
	},
	{	name = "Last Highlighted CD Time",
		cat = "CDTL",
		desc = "Show the time left of the last highlighted CD due",
		tag = "%[cdtl.time.lh%]",
		func = function()
					local timeString = ""
					local lowestTime = 0
					
					for _, icon in ipairs(CooldownTimeline.iconTable) do
						if icon:GetParent():GetName() == "CooldownTimeline_Timeline" then
							if not icon.ignored then
								if icon.highlighted then
									if icon.cdRemaining > lowestTime then
										timeString = tostring(CooldownTimeline:ConvertToReadableTime(icon.cdRemaining))
										lowestTime = icon.cdRemaining
									end
								end
							end
						end
					end
					
					return timeString
				end,
	},
	
	-- PLAYER --
	{	name = "Player Name",
		cat = "Player",
		desc = "Show the player name",
		tag = "%[p.name%]",
		func = function()
					return GetUnitName("player")
				end,
	},
	{	name = "Player Class",
		cat = "Player",
		desc = "Show the player class",
		tag = "%[p.class%]",
		func = function()
					local className, _, _ = UnitClass("player")
					return className
				end,
	},
	{	name = "Player Power Current",
		cat = "Player",
		desc = "Show the current amount of power used by the player",
		tag = "%[p.pow.cur%]",
		func = function()
					local className, _, _ = UnitClass("player")
					local powerType = CooldownTimeline:GetPlayerPower(className)
						
					return UnitPower("player", powerType)
				end,
	},
	{	name = "Player Power Max",
		cat = "Player",
		desc = "Show the max amount of power used by player",
		tag = "%[p.pow.max%]",
		func = function()
					local className, _, _ = UnitClass("player")
					local powerType = CooldownTimeline:GetPlayerPower(className)
						
					return UnitPowerMax("player", powerType)
				end,
	},
	{	name = "Player Level",
		cat = "Player",
		desc = "Show the player level",
		tag = "%[p.level%]",
		func = function()
					return UnitLevel("player")
				end,
	},
	{	name = "Player HP Current",
		cat = "Player",
		desc = "Show the current player HP",
		tag = "%[p.hp.cur%]",
		func = function()
					return UnitHealth("player")
				end,
	},
	{	name = "Player HP Max",
		cat = "Player",
		desc = "Show the max player HP",
		tag = "%[p.hp.max%]",
		func = function()
					return UnitHealthMax("player")
				end,
	},
	
	-- PET --
	
	
	-- FOCUS --
	{	name = "Focus Name",
		cat = "Focus",
		desc = "Show the name of your focus",
		tag = "%[f.name%]",
		func = function()
					if UnitExists("focus") then
						return GetUnitName("focus")
					end
					
					return ""
				end,
	},
	{	name = "Focus Class",
		cat = "Focus",
		desc = "Show the class of your focus",
		tag = "%[f.class%]",
		func = function()
					if UnitExists("focus") then
						local className, _, _ = UnitClass("focus")
						return className
					end
					
					return ""
				end,
	},
	{	name = "Focus Power Current",
		cat = "Focus",
		desc = "Show the current amount of power used by the class of your focus",
		tag = "%[f.pow.cur%]",
		func = function()
					if UnitExists("focus") then
						local className, _, _ = UnitClass("focus")
						local powerType = CooldownTimeline:GetPlayerPower(className)
						
						return UnitPower("focus", powerType)
					end
					
					return ""
				end,
	},
	{	name = "Focus Power Max",
		cat = "Focus",
		desc = "Show the max amount of power used by the class of your focus",
		tag = "%[f.pow.max%]",
		func = function()
					if UnitExists("focus") then
						local className, _, _ = UnitClass("focus")
						local powerType = CooldownTimeline:GetPlayerPower(className)
						
						return UnitPowerMax("focus", powerType)
					end
					
					return ""
				end,
	},
	{	name = "Focus Level",
		cat = "Focus",
		desc = "Show the level of your focus",
		tag = "%[f.level%]",
		func = function()
					if UnitExists("focus") then
						return UnitLevel("focus")
					end
					
					return ""
				end,
	},
	{	name = "Focus HP Current",
		cat = "Focus",
		desc = "Show the current HP of your focus",
		tag = "%[f.hp.cur%]",
		func = function()
					if UnitExists("focus") then
						return UnitHealth("focus")
					end
					
					return ""
				end,
	},
	{	name = "Focus HP Max",
		cat = "Focus",
		desc = "Show the max HP of your focus",
		tag = "%[f.hp.max%]",
		func = function()
					if UnitExists("focus") then
						return UnitHealthMax("focus")
					end
					
					return ""
				end,
	},
	
	-- TARGET --
	{	name = "Target Name",
		cat = "Target",
		desc = "Show the name of your target",
		tag = "%[t.name%]",
		func = function()
					if UnitExists("target") then
						return GetUnitName("target")
					end
					
					return ""
				end,
	},
	{	name = "Target Class",
		cat = "Target",
		desc = "Show the class of your target",
		tag = "%[t.class%]",
		func = function()
					if UnitExists("target") then
						local className, _, _ = UnitClass("target")
						return className
					end
					
					return ""
				end,
	},
	{	name = "Target Power Current",
		cat = "Target",
		desc = "Show the current amount of power used by the class of your target",
		tag = "%[t.pow.cur%]",
		func = function()
					if UnitExists("target") then
						local className, _, _ = UnitClass("target")
						local powerType = CooldownTimeline:GetPlayerPower(className)
						
						return UnitPower("target", powerType)
					end
					
					return ""
				end,
	},
	{	name = "Target Power Max",
		cat = "Target",
		desc = "Show the max amount of power used by the class of your target",
		tag = "%[t.pow.max%]",
		func = function()
					if UnitExists("target") then
						local className, _, _ = UnitClass("target")
						local powerType = CooldownTimeline:GetPlayerPower(className)
						
						return UnitPowerMax("target", powerType)
					end
					
					return ""
				end,
	},
	{	name = "Target Level",
		cat = "Target",
		desc = "Show the level of your target",
		tag = "%[t.level%]",
		func = function()
					if UnitExists("target") then
						return UnitLevel("target")
					end
					
					return ""
				end,
	},
	{	name = "Target HP Current",
		cat = "Target",
		desc = "Show the current HP of your target",
		tag = "%[t.hp.cur%]",
		func = function()
					if UnitExists("target") then
						return UnitHealth("target")
					end
					
					return ""
				end,
	},
	{	name = "Target HP Max",
		cat = "Target",
		desc = "Show the max HP of your target",
		tag = "%[t.hp.max%]",
		func = function()
					if UnitExists("target") then
						return UnitHealthMax("target")
					end
					
					return ""
				end,
	},

	-- CURRENT --
	{	name = "Cooldown Name",
		cat = "CD",
		desc = "Show the name of the next CD due",
		tag = "%[cd.name%]",
		func = function(frame)
					--CooldownTimeline:Print(frame.cdName)
		
					if frame then
						return frame.cdName
					end
					
					return "Error"
				end,
	},
	{	name = "Cooldown Time",
		cat = "CD",
		desc = "Show the name of the next CD due",
		tag = "%[cd.time%]",
		func = function(frame)
					if frame then
						return tostring(CooldownTimeline:ConvertToReadableTime(frame.cdRemaining))
					end
					
					return "Error"
				end,
	},
	{	name = "Cooldown Type",
		cat = "CD",
		desc = "Show the name of the next CD due",
		tag = "%[cd.type%]",
		func = function(frame)
					if frame then
						return frame.cdType
					end
					
					return "Error"
				end,
	},
}