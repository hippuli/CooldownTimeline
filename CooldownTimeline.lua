--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
	
	Update notes:
		- Bis thanks to MrFIXlT for these updates
		- Multiple fixes and cleanups
]]--

CooldownTimeline = LibStub("AceAddon-3.0"):NewAddon("CooldownTimeline", "AceConsole-3.0", "AceEvent-3.0")
CooldownTimeline.Masque = LibStub("Masque", true)
CooldownTimeline.SharedMedia = LibStub( "LibSharedMedia-3.0" )
CooldownTimeline.inCombat = false
CooldownTimeline.ignoreNextManaTick = true
CooldownTimeline.uniqueID = 1000
CooldownTimeline.spellTable = {}
CooldownTimeline.iconTable = {}
CooldownTimeline.barTable = {}
CooldownTimeline.animationTable = {}
CooldownTimeline.characterFilterList = {}
CooldownTimeline.characterFilterListItems = {}
CooldownTimeline.characterFilterListPet = {}
CooldownTimeline.characterFilterListAuras = {}
CooldownTimeline.characterFilterListOAuras = {}
CooldownTimeline.characterHighlightList = {}
CooldownTimeline.characterHighlightItems = {}
CooldownTimeline.characterHighlightPet = {}
CooldownTimeline.characterHighlightAuras = {}
CooldownTimeline.characterHighlightOAuras = {}
CooldownTimeline.characterFastLaneList = {}
CooldownTimeline.characterFastLaneItems = {}
CooldownTimeline.characterFastLanePet = {}
CooldownTimeline.characterFastLaneAuras = {}
CooldownTimeline.characterFastLaneOAuras = {}
CooldownTimeline.stringImportExport = ""

local version = "2.5.4-23r2"
local changeLog = ""
	changeLog = changeLog.."\n"
	changeLog = changeLog.."Changelog r2:\n\n"
	changeLog = changeLog.."  - Big thanks to MrFIXlT for these updates\n"
	changeLog = changeLog.."  - Multiple fixes and cleanups\n"
	changeLog = changeLog.."\n"
	changeLog = changeLog.."Changelog r1:\n\n"
	changeLog = changeLog.."  - Addon is now up-to-date for 2.5.4\n"
	changeLog = changeLog.."\n"
	changeLog = changeLog.."Changelog:\n\n"
	changeLog = changeLog.."  - Added icons to cooldown bars\n"
	changeLog = changeLog.."  - Added a second set of bars that will just display OAURAs to make them easier to separate to standard cooldowns\n"
	changeLog = changeLog.."  - Fixed an issue in which OAURAs would create duplicate settings instead of using existing ones\n"
	changeLog = changeLog.."  - Added the ability to cleanup the spell tables and remove duplicates (via the Cleanup tab on the main settings page)\n"
	changeLog = changeLog.."  - If you are getting an error when looking at filters, please perform a cleanup first, then try again\n"
	changeLog = changeLog.."  - Fixed an issue that prevented transition indicators on bars\n"
	changeLog = changeLog.."  - Addon is now up-to-date for 2.5.3\n"
	changeLog = changeLog.."\n"
	
local Masque = CooldownTimeline.Masque
local SharedMedia = CooldownTimeline.SharedMedia

local options = {
	name = "Cooldown Timeline",
	handler = CooldownTimeline,
	type = "group",
	childGroups  = "tab",
	args = {
		optionsGeneral = {
			name = "General",
			order = 1.1,
			type = "group",
			args = {
				--generalOptionsHeader = {
				--	name = "General Options",
				--	type = "header",
				--	order = 1,
				--},
				spacer1 = {
					name = "\n",
					type = "description",
					order = 1.1,
				},				
				unlockFrames = {
					name = "Unlock Frames (allow drag and drop movement)",
					desc = "Allows drag and drop movement of the frames",
					order = 1.2,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.unlockFrames end,
					set = function(info, val) CooldownTimeline.db.profile.unlockFrames = val end,
					width = "full",
				},
				spacer2 = {
					name = "\n\nEnable/Disable",
					type = "description",
					order = 2.1,
				},
				enableTimeline = {
					name = "Timeline",
					desc = "Enable/disable the timeline frame",
					order = 2.2,
					type = "toggle",
					hidden = false,
					get = function(info) return CooldownTimeline.db.profile.enableTimeline end,
					set = function(info, val)
							CooldownTimeline.db.profile.enableTimeline = val
							
							if val then
								if CooldownTimeline.fTimeline then
									--CooldownTimeline:Print("fTimeline already exists")
									CooldownTimeline.fTimeline:SetAlpha(1)
								else
									--CooldownTimeline:Print("fTimeline doesnt exist, creating")
									CooldownTimeline:CreateTimelineFrame()
								end
							end
						end,
					--width = "half",
				},
				enableReady = {
					name = "Ready",
					desc = "Enable/disable the ready frame",
					order = 2.3,
					type = "toggle",
					hidden = false,
					get = function(info) return CooldownTimeline.db.profile.enableReady	end,
					set = function(info, val)
							CooldownTimeline.db.profile.enableReady = val
							
							if val then
								if CooldownTimeline.fReady then
									CooldownTimeline.fReady:SetAlpha(1)
								else
									CooldownTimeline:CreateReadyFrame()
								end
							end
						end,
					width = "double",
				},
				enableFastlane = {
					name = "Fastlane",
					desc = "Enable/disable the fastlane frame",
					order = 3.2,
					type = "toggle",
					hidden = false,
					get = function(info) return CooldownTimeline.db.profile.enableFastlane end,
					set = function(info, val)
							CooldownTimeline.db.profile.enableFastlane = val
								
							if val then
								if CooldownTimeline.fFastlane then
									CooldownTimeline.fFastlane:SetAlpha(1)
								else
									CooldownTimeline:CreateFastlaneFrame()
								end
							end
						end,
					--width = "half",
				},
				enableBars = {
					name = "Bars",
					desc = "Enable/disable cooldown bars",
					order = 3.3,
					type = "toggle",
					hidden = false,
					get = function(info) return CooldownTimeline.db.profile.enableBars end,
					set = function(info, val)
							CooldownTimeline.db.profile.enableBars = val
							
							if val then
								if CooldownTimeline.fBar then
									CooldownTimeline.fBar:SetAlpha(1)
									CooldownTimeline.fBarHolding:SetAlpha(1)
								else
									CooldownTimeline:CreateBarFrame()
									CooldownTimeline:CreateBarHoldingFrame()
								end
							end
						end,
					width = "double",
				},
				spacer4 = {
					name = "\n\nAutohide",
					type = "description",
					order = 4.1,
				},
				hideOutsideCombat = {
					name = "Hide out of combat - they will still show if there is something cooling down",
					type = "toggle",
					order = 4.2,
					get = function(info) return CooldownTimeline.db.profile.hideOutsideCombat end,
					set = function(info,val)
							CooldownTimeline.db.profile.hideOutsideCombat = val

							if val then
								CooldownTimeline.fReady:SetAlpha(0)
								CooldownTimeline.fTimeline:SetAlpha(0)
							else
								CooldownTimeline.fReady:SetAlpha(1)
								CooldownTimeline.fTimeline:SetAlpha(1)
							end
							
						end,
					width = "full",
				},
				onlyShowWhenCoolingDown = {
					name = "Only show when cooling down, even in combat",
					type = "toggle",
					order = 4.3,
					get = function(info) return CooldownTimeline.db.profile.onlyShowWhenCoolingDown end,
					set = function(info,val)
							CooldownTimeline.db.profile.onlyShowWhenCoolingDown = val

							if val then
								CooldownTimeline.fReady:SetAlpha(0)
								CooldownTimeline.fTimeline:SetAlpha(0)
							else
								CooldownTimeline.fReady:SetAlpha(1)
								CooldownTimeline.fTimeline:SetAlpha(1)
							end
							
						end,
					width = "full",
				},
				spacer5 = {
					name = "\n\nTracking",
					type = "description",
					order = 5.1,
				},
				trackSpellCooldowns = {
					name = "Spells",
					desc = "Enables tracking cooldowns of spells cast by you",
					type = "toggle",
					hidden = false,
					order = 5.1,
					get = function(info) return CooldownTimeline.db.profile.trackSpellCooldowns end,
					set = function(info,val)
							CooldownTimeline.db.profile.trackSpellCooldowns = val
						end,
					--width = "full",
				},
				trackItemCooldowns = {
					name = "Items",
					desc = "Enables tracking cooldowns of items both equipped and in your bags (can show a LOT of things)",
					type = "toggle",
					hidden = false,
					order = 5.2,
					get = function(info) return CooldownTimeline.db.profile.trackItemCooldowns end,
					set = function(info,val)
							CooldownTimeline.db.profile.trackItemCooldowns = val
						end,
					width = "double",
				},
				trackPetSpells = {
					name = "Pet Spells",
					desc = "Enables tracking cooldowns of spells cast by your pet",
					type = "toggle",
					hidden = false,
					order = 5.3,
					get = function(info) return CooldownTimeline.db.profile.trackPetSpells end,
					set = function(info,val)
							CooldownTimeline.db.profile.trackPetSpells = val
						end,
					--width = "full",
				},
				trackDebuffs = {
					name = "Debuffs",
					desc = "Enables tracking of specific debuffs that are preset (recently bandaged, weakened soul, etc.)",
					type = "toggle",
					hidden = false,
					order = 5.4,
					get = function(info) return CooldownTimeline.db.profile.trackDebuffs end,
					set = function(info,val)
							CooldownTimeline.db.profile.trackDebuffs = val
						end,
					width = "double",
				},
				trackShortBuffs = {
					name = "Short Buffs",
					desc = "Enables tracking of buffs that have a duration below a defined threshold",
					type = "toggle",
					hidden = false,
					order = 5.5,
					get = function(info) return CooldownTimeline.db.profile.trackShortBuffs end,
					set = function(info,val)
							CooldownTimeline.db.profile.trackShortBuffs = val
						end,
					--width = "full",
				},
				trackOffensiveAuras = {
					name = "Offensive Auras",
					desc = "Enables tracking of offensive auras on targets (DoTs, etc.)",
					type = "toggle",
					hidden = false,
					order = 5.6,
					get = function(info) return CooldownTimeline.db.profile.trackOffensiveAuras end,
					set = function(info,val)
							CooldownTimeline.db.profile.trackOffensiveAuras = val
						end,
					width = "double",
				},
				spacer6 = {
					name = "\n\nThresholds",
					type = "description",
					order = 6.1,
				},
				longIgnoreThreshold = {
					name = "Ignore Threshold (long)",
					desc = "Any cooldowns longer than this value will be hidden",
					order = 6.2,
					type = "range",
					softMin = 0,
					softMax = 3600,
					get = function(info) return CooldownTimeline.db.profile.longIgnoreThreshold end,
					set = function(info, val) CooldownTimeline.db.profile.longIgnoreThreshold = val end,
				},
				spacer7 = {
					name = "",
					type = "description",
					order = 7.1,
				},
				buffCaptureThreshold = {
					name = "Buff capture threshold",
					desc = "Any buffs with a duration shorter than this will be shown as an icon",
					order = 7.2,
					type = "range",
					hidden = false,
					softMin = 0,
					softMax = 300,
					get = function(info) return CooldownTimeline.db.profile.buffCaptureThreshold end,
					set = function(info, val) CooldownTimeline.db.profile.buffCaptureThreshold = val end,
				},
				
				--[[spacer1 = {
					name = "",
					type = "description",
					order = 7,
				},
				optionsExport = {
					name = "Export",
					desc = "",
					order = 7.1,
					type = "execute",
					func = function(info)
							--CooldownTimeline.stringImportExport = "ksdjflkasdj flksadjglksdjf lksadjf lksajglksjadg l"
							local tempString = ""
							
							for key, value in ipairs(CooldownTimeline.db.profile) do
								
								tempString = tempString..key..":"..value..","
							end
							
							CooldownTimeline.stringImportExport = tempString
						end
				},
				optionsImport = {
					name = "Import",
					desc = "",
					order = 7.2,
					type = "execute",
					confirm = true,
					func = function(info)
							
						end
				},
				spacer2 = {
					name = "",
					type = "description",
					order = 8,
				},
				optionsImportExportString = {
					name = "Import",
					desc = "",
					order = 8.1,
					type = "input",
					multiline = 10,
					get = function(info) return CooldownTimeline.stringImportExport end,
					set = function(info,val)
							CooldownTimeline.stringImportExport = val
						end,
					width = "full",
				},]]--
				
				spacer3 = {
					name = "\n\n",
					type = "description",
					order = -1,
				},
				debugFrame = {
					name = "Enable Debug",
					desc = "You do not need this as it adds no functionality, its purely for author tinkering/debugging",
					type = "toggle",
					hidden = false,
					order = -1,
					--confirm = true,
					get = function(info) return CooldownTimeline.db.profile.debugFrame end,
					set = function(info,val)
							CooldownTimeline.db.profile.debugFrame = val
							
							if not CooldownTimeline.fDebug then
								CooldownTimeline:CreateDebugFrame()
							end
						end,
					width = "full",
				},
			}
		},
		optionsCleanup = {
			name = "Cleanup",
			order = 1.2,
			type = "group",
			args = {
				spacer1 = {
					name = "This will cleanup the spell table settings and remove duplicate entries\n\n",
					fontSize = "large",
					type = "description",
					order = 1.1,
				},
				spacer2 = {
					name = "Performing a cleanup will require a UI reload\n\n",
					fontSize = "large",
					type = "description",
					order = 2.1,
				},
				spacer3 = {
					name = "Select which tables to clean:\n\n",
					type = "description",
					order = 3.1,
				},
				cleanSpells = {
					name = "Spells",
					desc = "",
					order = 3.2,
					type = "toggle",
					hidden = false,
					get = function(info) return CooldownTimeline.db.profile.cleanSpells end,
					set = function(info, val)
							CooldownTimeline.db.profile.cleanSpells = val
						end,
					width = "double",
				},
				cleanPetSpells = {
					name = "Pet Spells",
					desc = "",
					order = 3.3,
					type = "toggle",
					hidden = false,
					get = function(info) return CooldownTimeline.db.profile.cleanPetSpells end,
					set = function(info, val)
							CooldownTimeline.db.profile.cleanPetSpells = val
						end,
					width = "double",
				},
				cleanItems = {
					name = "Items",
					desc = "",
					order = 3.4,
					type = "toggle",
					hidden = false,
					get = function(info) return CooldownTimeline.db.profile.cleanItems end,
					set = function(info, val)
							CooldownTimeline.db.profile.cleanItems = val
						end,
					width = "double",
				},
				cleanAuras = {
					name = "Auras",
					desc = "",
					order = 3.5,
					type = "toggle",
					hidden = false,
					get = function(info) return CooldownTimeline.db.profile.cleanAuras end,
					set = function(info, val)
							CooldownTimeline.db.profile.cleanAuras = val
						end,
					width = "double",
				},
				spacer4 = {
					name = "\n\n",
					type = "description",
					order = 4.1,
				},
				cleanupButton = {
					name = "Clean Spell Table",
					desc = "This will remove duplicates in the spell table\n\nRequires UI Reload",
					order = 4.2,
					type = "execute",
					confirm = true,
					func = function(info)
							CooldownTimeline:CleanDuplicates()
							ReloadUI()
						end
				},
			}
		},
		optionsChangelog = {
			name = "Changelog",
			order = 1.3,
			type = "group",
			args = {
				spacer1 = {
					name = function() return "Cooldown Timeline v."..version.."\n\n" end,
					fontSize = "large",
					type = "description",
					order = 1.1,
				},
				spacer2 = {
					name = function() return changeLog end,
					fontSize = "small",
					type = "description",
					order = 2.1,
				},
			}
		},
	}
}

local optionsIcons = {
	name = "Icons",
	handler = CooldownTimeline,
	type = "group",
	childGroups  = "tab",
	args = {
		optionsGeneral = {
			name = "General",
			type = "group",
			args = {
				fIconSize = {
					name = "Icon Size",
					desc = "Sets the size of the icon on the timeline",
					order = 1,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fIconSize end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconSize = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer2 = {
					name = "\n\n\n",
					type = "description",
					order = 2.1,
				},
				fIconText = {
					name = "Text 1",
					desc = function(info) return CooldownTimeline:GetCustomIconTagDescription() end,
					type = "input",
					order = 2.2,
					width = "double",
					get = function(info) return CooldownTimeline.db.profile.fIconText["text"] end,
					set = function(info, val) CooldownTimeline.db.profile.fIconText["text"] = val end,
				},
				spacer3 = {
					name = "",
					type = "description",
					order = 3.1,
				},
				fIconTextFont = {
					name = "Font",
					desc = "Selects the font for text on the icons",
					order = 3.2,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fIconText["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconText["font"] = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconTextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 3.3,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fIconText["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconText["outline"] = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer4 = {
					name = "",
					type = "description",
					order = 4.1,
				},
				fIconTextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 4.2,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fIconText["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconText["size"] = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconTextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 4.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fIconText
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fIconText["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconTextShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 4.4,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fIconText
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fIconText["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer5 = {
					name = "",
					type = "description",
					order = 5.1,
				},
				fIconTextShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the shadow x offset",
					order = 5.2,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fIconText["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconText["shadowXOffset"] = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconTextShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the shadow y offset",
					order = 5.3,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fIconText["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconText["shadowYOffset"] = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer6 = {
					name = "",
					type = "description",
					order = 6.1,
				},
				fIconTextAnchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 6.2,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fIconText["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconText["anchor"] = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconTextAlign = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 6.3,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fIconText["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconText["align"] = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer7 = {
					name = "",
					type = "description",
					order = 7.1,
				},
				fIconTextXOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 7.2,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fIconText["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconText["xOffset"] = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconTextYOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 7.3,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fIconText["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconText["yOffset"] = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer8 = {
					name = "\n\n\n",
					type = "description",
					order = 8.1,
				},
				fIconBorder = {
					name = "                    Border Texture",
					desc = "Selects the texture",
					order = 8.2,
					type = "select",
					dialogControl = 'LSM30_Border',
					values = AceGUIWidgetLSMlists.border,
					get = function(info) return CooldownTimeline.db.profile.fIconBorder end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconBorder = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconBorderColor = {
					name = "Border Color",
					desc = "Selects the border color",
					order = 8.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fIconBorderColor["r"]
							local g = CooldownTimeline.db.profile.fIconBorderColor["g"]
							local b = CooldownTimeline.db.profile.fIconBorderColor["b"]
							local a = CooldownTimeline.db.profile.fIconBorderColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fIconBorderColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer9 = {
					name = "",
					type = "description",
					order = 9.1,
				},
				fIconBorderSize = {
					name = "Border Size",
					desc = "Sets the size of the border",
					order = 9.2,
					type = "range",
					softMin = 1,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fIconBorderSize end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconBorderSize = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconBorderPadding = {
					name = "Border Padding",
					desc = "Sets the size of the border",
					order = 9.3,
					type = "range",
					softMin = 0,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fIconBorderPadding end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconBorderPadding = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer10 = {
					name = "\n\n\n",
					type = "description",
					order = 10.1,
				},
				fTimelineIconOffset = {
					name = "Icon Offset",
					desc = "Sets the vertical offset of the icons on the timeline",
					order = 10.2,
					type = "range",
					softMin = -50,
					softMax = 50,
					get = function(info) return CooldownTimeline.db.profile.fTimelineIconOffset end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineIconOffset = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer11 = {
					name = "\n\n\n",
					type = "description",
					order = 11.1,
				},
				fIconReadySound = {
					name = "Ready Sound",
					desc = "Selects a sound to play when an icon is 'ready'",
					order = 11.2,
					type = "select",
					dialogControl = 'LSM30_Sound',
					values = AceGUIWidgetLSMlists.sound,
					get = function(info) return CooldownTimeline.db.profile.fIconReadySound end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconReadySound = val
						end,
				},
				spacer12 = {
					name = "\n\n\n",
					type = "description",
					order = 12.1,
				},
				fTimelineStack = {
					name = "Icon Stacking",
					desc = "When enabled icons will offset up/down to avoid overlapping",
					type = "toggle",
					order = 12.2,
					get = function(info) return CooldownTimeline.db.profile.fTimelineStack end,
					set = function(info,val) CooldownTimeline.db.profile.fTimelineStack = val end,
					width = 'full',
				},
				fTimelineStackOverlap = {
					name = "Overlap only Stacking",
					desc = "If enabled, stacking will only occur on overlapped icons",
					type = "toggle",
					order = 12.3,
					get = function(info) return CooldownTimeline.db.profile.fTimelineStackOverlap end,
					set = function(info,val) CooldownTimeline.db.profile.fTimelineStackOverlap = val end,
					width = 'full',
				},
				fTimelineStackMaxSize = {
					name = "Max stack height",
					desc = "Sets how tall the stack will be total (the stack will center vertically on the timeline)",
					order = 12.4,
					type = "range",
					softMin = 0,
					softMax = 100,
					get = function(info) return CooldownTimeline.db.profile.fTimelineStackMaxSize end,
					set = function(info, val) CooldownTimeline.db.profile.fTimelineStackMaxSize = val end,
				},
				spacer13 = {
					name = "\n\n\n",
					type = "description",
					order = 13.1,
				},
				fIconNotUsableOverride = {
					name = "Set Unusable Color",
					desc = "If the spell/item is unusable (for any reason) then tint the icon a custom color",
					type = "toggle",
					order = 13.2,
					get = function(info) return CooldownTimeline.db.profile.fIconNotUsableOverride end,
					set = function(info,val)
							CooldownTimeline.db.profile.fIconNotUsableOverride = val
							CooldownTimeline:RefreshIcons()
						end,
					width = 'full',
				},
				fIconNotUsableDesaturate = {
					name = "Desaturate",
					desc = "Desaturate the icon instead of color tinting it",
					type = "toggle",
					order = 13.3,
					get = function(info) return CooldownTimeline.db.profile.fIconNotUsableDesaturate end,
					set = function(info,val)
							CooldownTimeline.db.profile.fIconNotUsableDesaturate = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconNotUsableColor = {
					name = "Color",
					desc = "Selects the icon tint color",
					order = 13.4,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fIconNotUsableColor["r"]
							local g = CooldownTimeline.db.profile.fIconNotUsableColor["g"]
							local b = CooldownTimeline.db.profile.fIconNotUsableColor["b"]
							local a = CooldownTimeline.db.profile.fIconNotUsableColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fIconNotUsableColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshIcons()
						end,
				},
			}
		},
		optionsHighlight = {
			name = "Highlight",
			type = "group",
			args = {
				fIconHighlightEffect = {
					name = "Highlight Effect",
					desc = "This will change what effect is used to highlight icons on the timeline/ready frames",
					order = 1.1,
					type = "select",
					values = {
							["NONE"] = "None",
							["GLOW"] = "Glow",
							["PULSE"] = "Pulse",
							["BORDER"] = "Border",
							["BORDER_PULSE"] = "Border Pulse",
							--["SHAKE"] = "Shake",
							["BOUNCE"] = "Bounce",
							--["SCALE"] = "Scale",
						},
					get = function(info) return CooldownTimeline.db.profile.fIconHighlightEffect end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconHighlightEffect = val
							
							for _, icon in ipairs(CooldownTimeline.iconTable) do
								CooldownTimeline:StopAllHighlights(icon)
							end
						end,
				},
				spacer2 = {
					name = "",
					type = "description",
					order = 2.1,
				},
				fReadyIconHighlightDuration = {
					name = "Icon Duration",
					desc = "Sets the duration a highlighted icon will display as ready",
					order = 2.2,
					type = "range",
					softMin = 0,
					softMax = 20,
					get = function(info) return CooldownTimeline.db.profile.fReadyIconHighlightDuration end,
					set = function(info, val)
							CooldownTimeline.db.profile.fReadyIconHighlightDuration = val
						end,
				},
				fIconHighlightPin = {
					name = "Pin to Ready",
					desc = "This will pin highlighted icons to the ready area until the spell/item is used again",
					type = "toggle",
					order = 2.3,
					get = function(info) return CooldownTimeline.db.profile.fIconHighlightPin end,
					set = function(info,val) CooldownTimeline.db.profile.fIconHighlightPin = val end,
				},
				spacer3 = {
					name = "",
					type = "description",
					order = 3.1,
				},
				fIconHighlightBorder = {
					name = "                    Border Texture",
					desc = "Selects the texture",
					order = 3.2,
					type = "select",
					dialogControl = 'LSM30_Border',
					values = AceGUIWidgetLSMlists.border,
					get = function(info) return CooldownTimeline.db.profile.fIconHighlightBorder end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconHighlightBorder = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconHighlightBorderColor = {
					name = "Color",
					desc = "Selects the border color",
					order = 3.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fIconHighlightBorderColor["r"]
							local g = CooldownTimeline.db.profile.fIconHighlightBorderColor["g"]
							local b = CooldownTimeline.db.profile.fIconHighlightBorderColor["b"]
							local a = CooldownTimeline.db.profile.fIconHighlightBorderColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fIconHighlightBorderColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer4 = {
					name = "",
					type = "description",
					order = 4.1,
				},
				fIconHighlightBorderSize = {
					name = "Size",
					desc = "Sets the size of the border",
					order = 4.2,
					type = "range",
					softMin = 1,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fIconHighlightBorderSize end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconHighlightBorderSize = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				fIconHighlightBorderPadding = {
					name = "Padding",
					desc = "Sets the size of the border",
					order = 4.3,
					type = "range",
					softMin = 0,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fIconHighlightBorderPadding end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconHighlightBorderPadding = val
							CooldownTimeline:RefreshIcons()
						end,
				},
				spacer5 = {
					name = "\n\n\n",
					type = "description",
					order = 5.1,
				},
				fIconReadyHighlightSound = {
					name = "Ready Sound",
					desc = "Selects a sound to play when a highlighted icon is 'ready' (overrides any existing sound for a non-highlighted icon)",
					order = 5.2,
					type = "select",
					dialogControl = 'LSM30_Sound',
					values = AceGUIWidgetLSMlists.sound,
					get = function(info) return CooldownTimeline.db.profile.fIconReadyHighlightSound end,
					set = function(info, val)
							CooldownTimeline.db.profile.fIconReadyHighlightSound = val			
						end,
				},
			}
		},
		optionsTooltip = {
			name = "Tooltip",
			type = "group",
			args = {
				enableTooltips = {
					name = "Enable Icon Tooltips",
					desc = "Will show information about the icon on mouseover",
					order = 1.2,
					type = "toggle",
					hidden = false,
					get = function(info) return CooldownTimeline.db.profile.enableTooltips end,
					set = function(info, val)
							CooldownTimeline.db.profile.enableTooltips = val
							
							if not CooldownTimeline.fTooltip then
								CooldownTimeline:CreateTooltipFrame()
							end
							
							for _, child in ipairs(CooldownTimeline.iconTable) do
								local currentParent = child:GetParent():GetName()
								if currentParent == "CooldownTimeline_Timeline" or currentParent == "CooldownTimeline_Fastlane" or currentParent == "CooldownTimeline_Ready" then
									child:EnableMouse(val)
								end
							end
						end,
					width = "full",
				},
				spacer2 = {
					name = "",
					type = "description",
					order = 2.1,
				},
				fTooltipTextTextFont = {
					name = "Font",
					desc = "Selects the font",
					order = 2.2,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fTooltipText["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTooltipText["font"] = val
							
							local t = CooldownTimeline.db.profile.fTooltipText
							CooldownTimeline.fTooltip.text:SetFont(CooldownTimeline.SharedMedia:Fetch("font", val), t["size"], t["outline"])
						end,
				},
				fTooltipTextTextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 2.3,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fTooltipText["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTooltipText["outline"] = val
							
							local t = CooldownTimeline.db.profile.fTooltipText
							CooldownTimeline.fTooltip.text:SetFont(CooldownTimeline.SharedMedia:Fetch("font", t["font"]), t["size"], val)
						end,
				},
				spacer3 = {
					name = "",
					type = "description",
					order = 3.1,
				},
				fTooltipTextTextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 3.2,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fTooltipText["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTooltipText["size"] = val
							
							local t = CooldownTimeline.db.profile.fTooltipText
							CooldownTimeline.fTooltip.text:SetFont(CooldownTimeline.SharedMedia:Fetch("font", t["font"]), val, t["outline"])
						end,
				},
				fTooltipTextTextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 3.3,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTooltipText
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTooltipText["color"] = { r = red, g = green, b = blue, a = alpha }
							
							local t = CooldownTimeline.db.profile.fTooltipText
							CooldownTimeline.fTooltip.text:SetTextColor(
								t["color"]["r"],
								t["color"]["g"],
								t["color"]["b"],
								t["color"]["a"]
							)
						end,
				},
				fTooltipTextShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 3.4,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTooltipText
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTooltipText["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							
							local t = CooldownTimeline.db.profile.fTooltipText
							CooldownTimeline.fTooltip.text:SetShadowColor(
								t["shadowColor"]["r"],
								t["shadowColor"]["g"],
								t["shadowColor"]["b"],
								t["shadowColor"]["a"]
							)
						end,
				},
				spacer4 = {
					name = "",
					type = "description",
					order = 4.1,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
				},
				fTooltipTextShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 4.2,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTooltipText["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTooltipText["shadowXOffset"] = val
							
							local t = CooldownTimeline.db.profile.fTooltipText
							CooldownTimeline.fTooltip.text:SetShadowOffset(val, t["shadowYOffset"])
						end,
				},
				fTooltipTextShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 4.3,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTooltipText["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTooltipText["shadowYOffset"] = val
							
							local t = CooldownTimeline.db.profile.fTooltipText
							CooldownTimeline.fTooltip.text:SetShadowOffset(t["shadowXOffset"], val)
						end,
				},
				spacer5  = {
					name = "\n\n\n",
					type = "description",
					order = 5.1,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
				},
				fTooltipPadding = {
					name = "Padding",
					desc = "Sets the amount of padding around the text in the tooltip",
					order = 5.2,
					hidden = function(info) return not CooldownTimeline.db.profile.enableTooltips end,
					type = "range",
					softMin = -20,
					softMax = 50,
					get = function(info) return CooldownTimeline.db.profile.fTooltipPadding end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTooltipPadding = val
						end,
				},
				spacer6 = {
					name = "\n\n\n",
					type = "description",
					order = 6.1,
				},
				fTooltipBorder = {
					name = "                    Border Texture",
					desc = "Selects the texture",
					order = 6.2,
					type = "select",
					dialogControl = 'LSM30_Border',
					values = AceGUIWidgetLSMlists.border,
					get = function(info) return CooldownTimeline.db.profile.fTooltipBorder end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTooltipBorder = val

							local fTooltipBorderSize = CooldownTimeline.db.profile.fTooltipBorderSize
							local fTooltipBorderInset = CooldownTimeline.db.profile.fTooltipBorderInset
							local fTooltipBorderPadding = CooldownTimeline.db.profile.fTooltipBorderPadding
							local fTooltipBorderColor = CooldownTimeline.db.profile.fTooltipBorderColor
							
							CooldownTimeline:SetBorder(CooldownTimeline.fTooltip, val, fTooltipBorderSize, fTooltipBorderInset)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fTooltip, fTooltipBorderColor)
							CooldownTimeline:SetBorderPoint(CooldownTimeline.fTooltip, fTooltipBorderPadding)
						end,
				},
				fTooltipBorderColor = {
					name = "Color",
					desc = "Selects the border color",
					order = 6.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fTooltipBorderColor["r"]
							local g = CooldownTimeline.db.profile.fTooltipBorderColor["g"]
							local b = CooldownTimeline.db.profile.fTooltipBorderColor["b"]
							local a = CooldownTimeline.db.profile.fTooltipBorderColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTooltipBorderColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline.fTooltip.border:SetBackdropBorderColor(red, green, blue, alpha)
						end,
				},
				spacer7 = {
					name = "",
					type = "description",
					order = 7.1,
				},
				fTooltipBorderSize = {
					name = "Size",
					desc = "Sets the size of the border",
					order = 7.2,
					type = "range",
					softMin = 1,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fTooltipBorderSize end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTooltipBorderSize = val
							local fTooltipBorder = CooldownTimeline.db.profile.fTooltipBorder
							local fTooltipBorderInset = CooldownTimeline.db.profile.fTooltipBorderInset
							local fTooltipBorderColor = CooldownTimeline.db.profile.fTooltipBorderColor
							
							CooldownTimeline:SetBorder(CooldownTimeline.fTooltip, fTooltipBorder, val, fTooltipBorderInset)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fTooltip, fTooltipBorderColor)
						end,
				},
				fTooltipBorderPadding = {
					name = "Padding",
					desc = "Sets the size of the border",
					order = 7.3,
					type = "range",
					softMin = 0,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fTooltipBorderPadding end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTooltipBorderPadding = val
							local fTooltipBorderColor = CooldownTimeline.db.profile.fTooltipBorderColor
							
							CooldownTimeline:SetBorderPoint(CooldownTimeline.fTooltip, val)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fTooltip, fTooltipBorderColor)
						end,
				},
				
			}
		},
	}
}
	
local optionsTimeline = {
	name = "Timeline",
	handler = CooldownTimeline,
	type = 'group',
	childGroups  = "tab",
	width = 'full',
	args = {
		optionsMode = {
			name = "Mode",
			type = "group",
			order = 2,
			args = {
				fTimelineMode = {
					name = "Timeline Mode",
					desc = "This will change how an icon moves along the timeline",
					order = 1.2,
					type = "select",
					values = { ["LINEAR"] = "Linear (%)", ["SPLIT_ABS"] = "Split (Time)", ["LINEAR_ABS"] = "Linear (Time)", ["SPLIT"] = "Split (%)" },
					get = function(info) return CooldownTimeline.db.profile.fTimelineMode end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineMode = val
							
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:DrawTimelineText()
						end,
				},
				fTimelineIconReverseDirection = {
					name = "Reverse Travel Direction",
					desc = "Changes the icon travel direction from 'Right->Left' to 'Left->Right'",
					type = "toggle",
					order = 1.3,
					set = function(info,val) CooldownTimeline.db.profile.fTimelineIconReverseDirection = val end,
					get = function(info) return CooldownTimeline.db.profile.fTimelineIconReverseDirection end,
				},
				spacer2 = {
					name = "\n\n\n",
					type = "description",
					order = 2.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "LINEAR_ABS" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineModeAbsLimit = {
					name = "Linear (Time) Max",
					desc = "Sets the max time (in seconds) that the bar will show",
					order = 2.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "LINEAR_ABS" then
								return false
							else
								return true
							end
						end,
					type = "range",
					softMin = 0,
					softMax = 600,
					bigStep = 10,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeAbsLimit end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeAbsLimit = val
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer3 = {
					name = "\n\n\n",
					type = "description",
					order = 3.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineModeSplitAbsCount = {
					name = "Split Count",
					desc = "Sets how many splits are in the timeline",
					order = 3.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								return false
							else
								return true
							end
						end,
					type = "range",
					min = 1,
					max = 3,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplitAbsCount end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplitAbsCount = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer31 = {
					name = "\n\n\n",
					type = "description",
					order = 31.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineModeSplitAbs1 = {
					name = "Split 1",
					desc = "Sets the time at which the first split occurs",
					order = 31.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								return false
							else
								return true
							end
						end,
					type = "range",
					softMin = 0,
					softMax = 600,
					bigStep = 10,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplitAbs1 end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplitAbs1 = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer32 = {
					name = "",
					type = "description",
					order = 32.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								if CooldownTimeline.db.profile.fTimelineModeSplitAbsCount >= 2 then
									return false
								end
							end
							return true
						end,
				},
				fTimelineModeSplitAbs2 = {
					name = "Split 2",
					desc = "Sets the time at which the second split occurs",
					order = 32.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								if CooldownTimeline.db.profile.fTimelineModeSplitAbsCount >= 2 then
									return false
								end
							end
							return true
						end,
					type = "range",
					softMin = 0,
					softMax = 600,
					bigStep = 10,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplitAbs2 end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplitAbs2 = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer33 = {
					name = "",
					type = "description",
					order = 33.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								if CooldownTimeline.db.profile.fTimelineModeSplitAbsCount >= 3 then
									return false
								end
							end
							return true
						end,
				},
				fTimelineModeSplitAbs3 = {
					name = "Split 3",
					desc = "Sets the time at which the third split occurs",
					order = 33.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								if CooldownTimeline.db.profile.fTimelineModeSplitAbsCount >= 3 then
									return false
								end
							end
							return true
						end,
					type = "range",
					softMin = 0,
					softMax = 600,
					bigStep = 10,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplitAbs3 end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplitAbs3 = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer61 = {
					name = "\n\n\n",
					type = "description",
					order = 61.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineModeSplitAbsLimit = {
					name = "Split Max",
					desc = "Sets the max time (in seconds) that the bar will show",
					order = 61.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT_ABS" then
								return false
							else
								return true
							end
						end,
					type = "range",
					softMin = 0,
					softMax = 600,
					bigStep = 10,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplitAbsLimit end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplitAbsLimit = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer4 = {
					name = "\n\n\n",
					type = "description",
					order = 4.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineModeSplitCount = {
					name = "Split Count",
					desc = "Sets how many splits are in the timeline",
					order = 4.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								return false
							else
								return true
							end
						end,
					type = "range",
					min = 1,
					max = 3,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplitCount end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplitCount = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer41 = {
					name = "\n\n\n",
					type = "description",
					order = 41.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineModeSplit1 = {
					name = "Split 1",
					desc = "Sets the percent at which the first split occurs",
					order = 41.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								return false
							else
								return true
							end
						end,
					type = "range",
					softMin = 0,
					softMax = 100,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplit1 end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplit1 = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer42 = {
					name = "",
					type = "description",
					order = 42.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								if CooldownTimeline.db.profile.fTimelineModeSplitCount >= 2 then
									return false
								end
							end
							return true
						end,
				},
				fTimelineModeSplit2 = {
					name = "Split 2",
					desc = "Sets the percent at which the second split occurs",
					order = 42.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								if CooldownTimeline.db.profile.fTimelineModeSplitCount >= 2 then
									return false
								end
							end
							return true
						end,
					type = "range",
					softMin = 0,
					softMax = 100,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplit2 end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplit2 = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer43 = {
					name = "",
					type = "description",
					order = 43.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								if CooldownTimeline.db.profile.fTimelineModeSplitCount >= 3 then
									return false
								end
							end
							return true
						end,
				},
				fTimelineModeSplit3 = {
					name = "Split 3",
					desc = "Sets the percent at which the third split occurs",
					order = 43.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								if CooldownTimeline.db.profile.fTimelineModeSplitCount >= 3 then
									return false
								end
							end
							return true
						end,
					type = "range",
					softMin = 0,
					softMax = 100,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplit3 end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplit3 = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer71 = {
					name = "\n\n\n",
					type = "description",
					order = 71.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineModeSplitLimit = {
					name = "Split Max",
					desc = "Sets the max percent that the bar will show",
					order = 71.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineMode == "SPLIT" then
								return false
							else
								return true
							end
						end,
					type = "range",
					softMin = 0,
					softMax = 100,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineModeSplitLimit end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineModeSplitLimit = val
							CooldownTimeline:UpdateTimelineText(true)
							CooldownTimeline:SetTimelineText()
						end,
				},
			}
		},
		optionsTimeline = {
			name = "General",
			type = "group",
			order = 1,
			args = {
				fTimelineWidth = {
					name = "Width",
					desc = "Sets the width for the Timeline frame",
					order = 2.2,
					type = "range",
					softMin = 0,
					softMax = 600,
					get = function(info) return CooldownTimeline.db.profile.fTimelineWidth end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineWidth = val
							CooldownTimeline.fTimeline:SetWidth(val)
	 				end,
				},
				fTimelineHeight = {
					name = "Height",
					desc = "Sets the height for the Timeline frame",
					order = 2.3,
					type = "range",
					softMin = 0,
					softMax = 600,
					get = function(info) return CooldownTimeline.db.profile.fTimelineHeight end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineHeight = val
							CooldownTimeline.fTimeline:SetHeight(val)
						end,
				},
				spacer3 = {
					name = "",
					type = "description",
					order = 3.1,
				},
				fTimelineX = {
					name = "x Pos",
					desc = "Sets the x co-rd for the Timeline frame",
					order = 3.2,
					type = "range",
					softMin = -500,
					softMax = 500,
					get = function(info) return CooldownTimeline.db.profile.fTimelinePosX end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelinePosX = val
							CooldownTimeline.fTimeline:SetPoint(CooldownTimeline.db.profile.fTimelineRelativeTo, val, CooldownTimeline.db.profile.fTimelinePosY)
						end,
				},
				fTimelineY = {
					name = "y Pos",
					desc = "Sets the y co-rd for the Timeline frame",
					order = 3.3,
					type = "range",
					softMin = -500,
					softMax = 500,
					get = function(info) return CooldownTimeline.db.profile.fTimelinePosY end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelinePosY = val
							CooldownTimeline.fTimeline:SetPoint(CooldownTimeline.db.profile.fTimelineRelativeTo, CooldownTimeline.db.profile.fTimelinePosX, val)
						end,
				},
				spacer4 = {
					name = "",
					type = "description",
					order = 4.1,
				},
				fTimelineRelativeTo = {
					name = "Anchor Point",
					desc = "X/Y position is relative to this point of the screen",
					order = 4.2,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineRelativeTo end,
					set = function(info, val)
							CooldownTimeline.fTimeline:ClearAllPoints()
							CooldownTimeline.db.profile.fTimelineRelativeTo = val
							CooldownTimeline.fTimeline:SetPoint(val, CooldownTimeline.db.profile.fTimelinePosX, CooldownTimeline.db.profile.fTimelinePosY)
						end,
				},
				spacer5 = {
					name = "\n\n\n",
					type = "description",
					order = 5.1,
				},
				fTimelineBackground = {
					name = "Background Texture",
					desc = "Selects the texture",
					order = 5.2,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fTimelineBackground end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineBackground = val
							CooldownTimeline.fTimeline.bg:SetTexture(SharedMedia:Fetch("statusbar", val))

							local r = CooldownTimeline.db.profile.fTimelineBackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fTimelineBackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fTimelineBackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fTimelineBackgroundColor["a"]
							CooldownTimeline.fTimeline.bg:SetVertexColor(r, g, b, a)
						end,
				},
				fTimelineBackgroundColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 5.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fTimelineBackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fTimelineBackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fTimelineBackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fTimelineBackgroundColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineBackgroundColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline.fTimeline.bg:SetVertexColor(red, green, blue, alpha)
						end,
				},
				spacer6 = {
					name = "",
					type = "description",
					order = 6.1,
				},
				fTimelineTexture = {
					name = "Foreground Texture",
					desc = "Selects the texture",
					order = 6.2,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTexture end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTexture = val
							CooldownTimeline.fTimeline:SetStatusBarTexture(SharedMedia:Fetch("statusbar", val))

							local r = CooldownTimeline.db.profile.fTimelineTextureColor["r"]
							local g = CooldownTimeline.db.profile.fTimelineTextureColor["g"]
							local b = CooldownTimeline.db.profile.fTimelineTextureColor["b"]
							local a = CooldownTimeline.db.profile.fTimelineTextureColor["a"]
							CooldownTimeline.fTimeline:SetStatusBarColor(r, g, b, a)
						end,
				},
				fTimelineTextureColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 6.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fTimelineTextureColor["r"]
							local g = CooldownTimeline.db.profile.fTimelineTextureColor["g"]
							local b = CooldownTimeline.db.profile.fTimelineTextureColor["b"]
							local a = CooldownTimeline.db.profile.fTimelineTextureColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextureColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline.fTimeline:SetStatusBarColor(red, green, blue, alpha)
						end,
				},
				spacer8 = {
					name = "\n\n\n",
					type = "description",
					order = 8.1,
				},
				fTimelineFonts = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 8.2,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fTimelineFonts["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineFonts["font"] = val
							CooldownTimeline:SetTimelineText()
						end,
				},
				fTimelineFontOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 8.3,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineFonts["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineFonts["outline"] = val
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer9 = {
					name = "",
					type = "description",
					order = 9.1,
				},
				fTimelineFontSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 9.2,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fTimelineFonts["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineFonts["size"] = val
							CooldownTimeline:SetTimelineText()
						end,
				},
				fTimelineFontColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 9.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineFonts
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineFonts["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:SetTimelineText()
						end,
				},
				fTimelineFontShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 9.4,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineFonts
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineFonts["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer10 = {
					name = "",
					type = "description",
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineFonts["enabled"] end,
				},
				fTimelineFontShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 10.2,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineFonts["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineFonts["shadowXOffset"] = val
							CooldownTimeline:SetTimelineText()
						end,
				},
				fTimelineFontShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 10.3,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineFonts["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineFonts["shadowYOffset"] = val
							CooldownTimeline:SetTimelineText()
						end,
				},
				spacer12 = {
					name = "",
					type = "description",
					order = 12.1,
				},
				fTimelineFontYOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 12.2,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineFonts["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineFonts["yOffset"] = val
							
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer13 = {
					name = "\n\n\n",
					type = "description",
					order = 13.1,
				},
				fTimelineBorder = {
					name = "                    Border Texture",
					desc = "Selects the texture",
					order = 13.2,
					type = "select",
					dialogControl = 'LSM30_Border',
					values = AceGUIWidgetLSMlists.border,
					get = function(info) return CooldownTimeline.db.profile.fTimelineBorder end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineBorder = val

							local fTimelineBorderSize = CooldownTimeline.db.profile.fTimelineBorderSize
							local fTimelineBorderInset = CooldownTimeline.db.profile.fTimelineBorderInset
							local fTimelineBorderPadding = CooldownTimeline.db.profile.fTimelineBorderPadding
							local fTimelineBorderColor = CooldownTimeline.db.profile.fTimelineBorderColor
							
							CooldownTimeline:SetBorder(CooldownTimeline.fTimeline, val, fTimelineBorderSize, fTimelineBorderInset)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fTimeline, fTimelineBorderColor)
							CooldownTimeline:SetBorderPoint(CooldownTimeline.fTimeline, fTimelineBorderPadding)
						end,
				},
				fTimelineBorderColor = {
					name = "Color",
					desc = "Selects the border color",
					order = 13.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fTimelineBorderColor["r"]
							local g = CooldownTimeline.db.profile.fTimelineBorderColor["g"]
							local b = CooldownTimeline.db.profile.fTimelineBorderColor["b"]
							local a = CooldownTimeline.db.profile.fTimelineBorderColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineBorderColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline.fTimeline.border:SetBackdropBorderColor(red, green, blue, alpha)
						end,
				},
				spacer14 = {
					name = "",
					type = "description",
					order = 14.1,
				},
				fTimelineBorderSize = {
					name = "Size",
					desc = "Sets the size of the border",
					order = 14.2,
					type = "range",
					softMin = 1,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fTimelineBorderSize end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineBorderSize = val
							local fTimelineBorder = CooldownTimeline.db.profile.fTimelineBorder
							local fTimelineBorderInset = CooldownTimeline.db.profile.fTimelineBorderInset
							local fTimelineBorderColor = CooldownTimeline.db.profile.fTimelineBorderColor
							
							CooldownTimeline:SetBorder(CooldownTimeline.fTimeline, fTimelineBorder, val, fTimelineBorderInset)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fTimeline, fTimelineBorderColor)
						end,
				},
				fTimelineBorderPadding = {
					name = "Padding",
					desc = "Sets the size of the border",
					order = 14.3,
					type = "range",
					softMin = 0,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fTimelineBorderPadding end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineBorderPadding = val
							local fTimelineBorderColor = CooldownTimeline.db.profile.fTimelineBorderColor
							
							CooldownTimeline:SetBorderPoint(CooldownTimeline.fTimeline, val)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fTimeline, fTimelineBorderColor)
						end,
				},
				spacer16 = {
					name = "\n\n\n",
					type = "description",
					order = 16.1,
				},
				fTimelineAnimateInNewType = {
					name = "On show animation",
					desc = "Select the animation played on show",
					order = 16.2,
					type = "select",
					values = { ["NONE"] = "None", ["FADE"] = "Fade" },
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateInNew["type"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateInNew["type"] = val
						end,
				},
				spacer17 = {
					name = "",
					type = "description",
					order = 17.1,
				},
				fTimelineAnimateInNewStartValue = {
					name = "Start value",
					desc = "Value to start the animation at",
					order = 17.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateInNew["startValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateInNew["startValue"] = val
						end,
				},
				fTimelineAnimateInNewEndValue = {
					name = "End value",
					desc = "Value to end the animation at",
					order = 17.3,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateInNew["endValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateInNew["endValue"] = val
						end,
				},
				spacer18 = {
					name = "",
					type = "description",
					order = 18.1,
				},
				fTimelineAnimateInNewFinishValue = {
					name = "Finish value",
					desc = "Value to start the animation at",
					order = 18.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateInNew["finishValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateInNew["finishValue"] = val
						end,
				},
				fTimelineAnimateInNewDuration = {
					name = "Duration",
					desc = "How long should the animation last",
					order = 18.3,
					type = "range",
					softMin = 0.1,
					softMax = 10,
					bigStep = 0.1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateInNew["duration"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateInNew["duration"] = val
						end,
				},
				spacer19 = {
					name = "",
					type = "description",
					order = 19.1,
				},
				fTimelineAnimateInNewLoop = {
					name = "Number of loops (-1 will loop infinitely)",
					desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
					order = 19.2,
					type = "range",
					softMin = -1,
					softMax = 5,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateInNew["loop"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateInNew["loop"] = val
						end,
				},
				fTimelineAnimateInNewBounce = {
					name = "Bounce animation",
					desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
					type = "toggle",
					order = 19.3,
					set = function(info,val) CooldownTimeline.db.profile.fTimelineAnimateInNew["bounce"] = val end,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateInNew["bounce"] end,
				},
				spacer20 = {
					name = "\n\n",
					type = "description",
					order = 20.1,
				},
				fTimelineAnimateOutNewType = {
					name = "On show animation",
					desc = "Select the animation played on show",
					order = 20.2,
					type = "select",
					values = { ["NONE"] = "None", ["FADE"] = "Fade" },
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateOutNew["type"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateOutNew["type"] = val
						end,
				},
				spacer21 = {
					name = "",
					type = "description",
					order = 21.1,
				},
				fTimelineAnimateOutNewStartValue = {
					name = "Start value",
					desc = "Value to start the animation at",
					order = 21.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateOutNew["startValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateOutNew["startValue"] = val
						end,
				},
				fTimelineAnimateOutNewEndValue = {
					name = "End value",
					desc = "Value to end the animation at",
					order = 21.3,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateOutNew["endValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateOutNew["endValue"] = val
						end,
				},
				spacer22 = {
					name = "",
					type = "description",
					order = 22.1,
				},
				fTimelineAnimateOutNewFinishValue = {
					name = "Finish value",
					desc = "Value to start the animation at",
					order = 22.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateOutNew["finishValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateOutNew["finishValue"] = val
						end,
				},
				fTimelineAnimateOutNewDuration = {
					name = "Duration",
					desc = "How long should the animation last",
					order = 22.3,
					type = "range",
					softMin = 0.1,
					softMax = 10,
					bigStep = 0.1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateOutNew["duration"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateOutNew["duration"] = val
						end,
				},
				spacer23 = {
					name = "",
					type = "description",
					order = 23.1,
				},
				fTimelineAnimateOutNewLoop = {
					name = "Number of loops (-1 will loop infinitely)",
					desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
					order = 23.2,
					type = "range",
					softMin = -1,
					softMax = 5,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateOutNew["loop"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineAnimateOutNew["loop"] = val
						end,
				},
				fTimelineAnimateOutNewBounce = {
					name = "Bounce animation",
					desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
					type = "toggle",
					order = 23.3,
					set = function(info,val) CooldownTimeline.db.profile.fTimelineAnimateOutNew["bounce"] = val end,
					get = function(info) return CooldownTimeline.db.profile.fTimelineAnimateOutNew["bounce"] end,
				},
			}
		},
		optionsText = {
			name = "Text",
			type = "group",
			order = 4,
			args = {
				fTimelineTextHeader = {
					name = "Default Text",
					type = "header",
					order = 1.0,
				},
				fTimelineText1Text = {
					name = "",
					type = "input",
					order = 1.2,
					disabled = true,
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[1]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[1] then
								return CooldownTimeline.db.profile.fTimelineText[1]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[1] then
								CooldownTimeline.db.profile.fTimelineText[1]["text"] = val
							end
						end,
				},
				fTimelineText1Enabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 1.4,
					type = "toggle",
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[1]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[1] then
								return CooldownTimeline.db.profile.fTimelineText[1]["enabled"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[1] then
								CooldownTimeline.db.profile.fTimelineText[1]["enabled"] = val
								CooldownTimeline:DrawTimelineText()
							end
						end,
				},
				spacer2 = {
					name = "",
					type = "description",
					order = 2.1,
				},
				fTimelineText2Text = {
					name = "",
					type = "input",
					order = 2.2,
					disabled = true,
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[2]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[2] then
								return CooldownTimeline.db.profile.fTimelineText[2]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[2] then
								CooldownTimeline.db.profile.fTimelineText[2]["text"] = val
							end
						end,
				},
				fTimelineText2Enabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 2.3,
					type = "toggle",
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[2]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[2] then
								return CooldownTimeline.db.profile.fTimelineText[2]["enabled"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[2] then
								CooldownTimeline.db.profile.fTimelineText[2]["enabled"] = val
								CooldownTimeline:DrawTimelineText()
							end
						end,
				},
				spacer3 = {
					name = "",
					type = "description",
					order = 3.1,
				},
				fTimelineText3Text = {
					name = "",
					type = "input",
					order = 3.2,
					disabled = true,
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[3]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[3] then
								return CooldownTimeline.db.profile.fTimelineText[3]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[3] then
								CooldownTimeline.db.profile.fTimelineText[3]["text"] = val
							end
						end,
				},
				fTimelineText3Enabled = {
					name = "Enabled",
					desc = "Show this text",
					type = "toggle",
					order = 3.3,
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[3]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[3] then
								return CooldownTimeline.db.profile.fTimelineText[3]["enabled"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[3] then
								CooldownTimeline.db.profile.fTimelineText[3]["enabled"] = val
								CooldownTimeline:DrawTimelineText()
							end
						end,
				},
				spacer4 = {
					name = "",
					type = "description",
					order = 4.1,
				},
				fTimelineText4Text = {
					name = "",
					type = "input",
					order = 4.2,
					disabled = true,
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[4]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[4] then
								return CooldownTimeline.db.profile.fTimelineText[4]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[4] then
								CooldownTimeline.db.profile.fTimelineText[4]["text"] = val
							end
						end,
				},
				fTimelineText4Enabled = {
					name = "Enabled",
					desc = "Show this text",
					type = "toggle",
					order = 4.3,
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[4]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[4] then
								return CooldownTimeline.db.profile.fTimelineText[4]["enabled"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[4] then
								CooldownTimeline.db.profile.fTimelineText[4]["enabled"] = val
								CooldownTimeline:DrawTimelineText()
							end
						end,
				},
				spacer5 = {
					name = "",
					type = "description",
					order = 5.1,
				},
				fTimelineText5Text = {
					name = "",
					type = "input",
					order = 5.2,
					disabled = true,
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[5]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[5] then
								return CooldownTimeline.db.profile.fTimelineText[5]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[5] then
								CooldownTimeline.db.profile.fTimelineText[5]["text"] = val
							end
						end,
				},
				fTimelineText5Enabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 5.3,
					type = "toggle",
					hidden = function(info)
							return not CooldownTimeline.db.profile.fTimelineText[5]["used"]
						end,
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineText[5] then
								return CooldownTimeline.db.profile.fTimelineText[5]["enabled"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineText[5] then
								CooldownTimeline.db.profile.fTimelineText[5]["enabled"] = val
								CooldownTimeline:DrawTimelineText()
							end
						end,
				},
				fTimelineTextCustomHeader = {
					name = "Custom Text",
					type = "header",
					order = 6.0,
				},
				spacer6 = {
					name = "\nYou can use custom text tags to display 'useful' dynamic information.\nAll tags currently supported can be viewed at the following link:\n\nhttps://www.curseforge.com/wow/addons/cooldown-timeline/pages/custom-text-tags\n\n",
					type = "description",
					order = 6.01,
				},
				fTimelineText6Text = {
					name = "Custom Text 1",
					desc = function(info) return CooldownTimeline:GetCustomTextTagDescription() end,
					type = "input",
					disabled = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					order = 6.02,
					width = "double",
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineTextCustom[1] then
								return CooldownTimeline.db.profile.fTimelineTextCustom[1]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineTextCustom[1] then
								CooldownTimeline.db.profile.fTimelineTextCustom[1]["text"] = val
							end
						end,
				},
				fTimelineText6TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 6.03,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer61 = {
					name = "",
					type = "description",
					order = 6.04,
				},
				fTimelineText6TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 6.05,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["font"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText6TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 6.06,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["outline"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer62 = {
					name = "",
					type = "description",
					order = 6.07,
				},
				fTimelineText6TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 6.08,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["size"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText6TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 6.09,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[1]
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText6ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 6.10,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[1]
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer63 = {
					name = "",
					type = "description",
					order = 6.11,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
				},
				fTimelineText6ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 6.12,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["shadowXOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText6ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 6.13,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["shadowYOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer64 = {
					name = "",
					type = "description",
					order = 6.14,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
				},
				fTimelineText6Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 6.15,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["anchor"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText6Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 6.16,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["align"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer65 = {
					name = "",
					type = "description",
					order = 6.17,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
				},
				fTimelineText6XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 6.18,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["xOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText6YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 6.19,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[1]["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[1]["yOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer66 = {
					name = "\n\n",
					type = "description",
					hidden = function(info)	return not CooldownTimeline.db.profile.fTimelineTextCustom[1]["enabled"] end,
					order = 6.20,
				},
				spacer7 = {
					name = "",
					type = "description",
					order = 7.01,
				},
				fTimelineText7Text = {
					name = "Custom Text 2",
					desc = function(info) return CooldownTimeline:GetCustomTextTagDescription() end,
					type = "input",
					disabled = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					order = 7.02,
					width = "double",
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineTextCustom[2] then
								return CooldownTimeline.db.profile.fTimelineTextCustom[2]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineTextCustom[2] then
								CooldownTimeline.db.profile.fTimelineTextCustom[2]["text"] = val
							end
						end,
				},
				fTimelineText7TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 7.03,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer71 = {
					name = "",
					type = "description",
					order = 7.04,
				},
				fTimelineText7TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 7.05,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["font"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText7TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 7.06,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["outline"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer72 = {
					name = "",
					type = "description",
					order = 7.07,
				},
				fTimelineText7TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 7.08,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["size"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText7TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 7.09,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[2]
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText7ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 7.10,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[2]
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer73 = {
					name = "",
					type = "description",
					order = 7.11,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
				},
				fTimelineText7ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 7.12,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["shadowXOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText7ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 7.13,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["shadowYOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer74 = {
					name = "",
					type = "description",
					order = 7.14,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
				},
				fTimelineText7Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 7.15,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["anchor"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText7Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 7.16,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["align"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer75 = {
					name = "",
					type = "description",
					order = 7.17,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
				},
				fTimelineText7XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 7.18,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["xOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText7YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 7.19,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[2]["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[2]["yOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer76 = {
					name = "\n\n",
					type = "description",
					hidden = function(info)	return not CooldownTimeline.db.profile.fTimelineTextCustom[2]["enabled"] end,
					order = 7.20,
				},
				spacer8 = {
					name = "",
					type = "description",
					order = 8.01,
				},
				fTimelineText8Text = {
					name = "Custom Text 3",
					desc = function(info) return CooldownTimeline:GetCustomTextTagDescription() end,
					type = "input",
					disabled = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					order = 8.02,
					width = "double",
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineTextCustom[3] then
								return CooldownTimeline.db.profile.fTimelineTextCustom[3]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineTextCustom[3] then
								CooldownTimeline.db.profile.fTimelineTextCustom[3]["text"] = val
							end
						end,
				},
				fTimelineText8TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 8.03,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer81 = {
					name = "",
					type = "description",
					order = 8.04,
				},
				fTimelineText8TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 8.05,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["font"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText8TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 8.06,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["outline"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer82 = {
					name = "",
					type = "description",
					order = 8.07,
				},
				fTimelineText8TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 8.08,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["size"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText8TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 8.09,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[3]
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText8ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 8.10,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[3]
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer83 = {
					name = "",
					type = "description",
					order = 8.11,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
				},
				fTimelineText8ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 8.12,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["shadowXOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText8ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 8.13,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["shadowYOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer84 = {
					name = "",
					type = "description",
					order = 8.14,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
				},
				fTimelineText8Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 8.15,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["anchor"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText8Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 8.16,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["align"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer85 = {
					name = "",
					type = "description",
					order = 8.17,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
				},
				fTimelineText8XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 8.18,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["xOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText8YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 8.19,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[3]["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[3]["yOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer86 = {
					name = "\n\n",
					type = "description",
					hidden = function(info)	return not CooldownTimeline.db.profile.fTimelineTextCustom[3]["enabled"] end,
					order = 8.20,
				},
				spacer9 = {
					name = "",
					type = "description",
					order = 9.01,
				},
				fTimelineText9Text = {
					name = "Custom Text 4",
					desc = function(info) return CooldownTimeline:GetCustomTextTagDescription() end,
					type = "input",
					disabled = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					order = 9.02,
					width = "double",
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineTextCustom[4] then
								return CooldownTimeline.db.profile.fTimelineTextCustom[4]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineTextCustom[4] then
								CooldownTimeline.db.profile.fTimelineTextCustom[4]["text"] = val
							end
						end,
				},
				fTimelineText9TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 9.03,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer91 = {
					name = "",
					type = "description",
					order = 9.04,
				},
				fTimelineText9TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 9.05,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["font"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText9TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 9.06,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["outline"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer92 = {
					name = "",
					type = "description",
					order = 9.07,
				},
				fTimelineText9TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 9.08,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["size"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText9TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 9.09,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[4]
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText9ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 9.10,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[4]
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer93 = {
					name = "",
					type = "description",
					order = 9.11,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
				},
				fTimelineText9ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 9.12,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["shadowXOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText9ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 9.13,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["shadowYOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer94 = {
					name = "",
					type = "description",
					order = 9.14,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
				},
				fTimelineText9Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 9.15,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["anchor"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText9Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 9.16,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["align"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer95 = {
					name = "",
					type = "description",
					order = 9.17,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
				},
				fTimelineText9XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 9.18,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["xOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText9YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 9.19,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[4]["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[4]["yOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer96 = {
					name = "\n\n",
					type = "description",
					hidden = function(info)	return not CooldownTimeline.db.profile.fTimelineTextCustom[4]["enabled"] end,
					order = 9.20,
				},
				spacer10 = {
					name = "",
					type = "description",
					order = 10.01,
				},
				fTimelineText10Text = {
					name = "Custom Text 5",
					desc = function(info) return CooldownTimeline:GetCustomTextTagDescription() end,
					type = "input",
					disabled = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					order = 10.02,
					width = "double",
					get = function(info)
							if CooldownTimeline.db.profile.fTimelineTextCustom[5] then
								return CooldownTimeline.db.profile.fTimelineTextCustom[5]["text"]
							end
						end,
					set = function(info, val)
							if CooldownTimeline.db.profile.fTimelineTextCustom[5] then
								CooldownTimeline.db.profile.fTimelineTextCustom[5]["text"] = val
							end
						end,
				},
				fTimelineText10TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 10.03,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer101 = {
					name = "",
					type = "description",
					order = 10.04,
				},
				fTimelineText10TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 10.05,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["font"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText10TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 10.06,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["outline"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer102 = {
					name = "",
					type = "description",
					order = 10.07,
				},
				fTimelineText10TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 10.08,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["size"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText10TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 10.09,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[5]
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText10ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 10.10,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fTimelineTextCustom[5]
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer103 = {
					name = "",
					type = "description",
					order = 10.11,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
				},
				fTimelineText10ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 10.12,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["shadowXOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText10ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 10.13,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["shadowYOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer104 = {
					name = "",
					type = "description",
					order = 10.14,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
				},
				fTimelineText10Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 10.15,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["anchor"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText10Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 10.16,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["align"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer105 = {
					name = "",
					type = "description",
					order = 10.17,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
				},
				fTimelineText10XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 10.18,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["xOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				fTimelineText10YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 10.19,
					hidden = function(info) return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTextCustom[5]["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTextCustom[5]["yOffset"] = val
							CooldownTimeline:DrawTimelineTextCustom()
						end,
				},
				spacer106 = {
					name = "\n\n",
					type = "description",
					hidden = function(info)	return not CooldownTimeline.db.profile.fTimelineTextCustom[5]["enabled"] end,
					order = 10.20,
				},
			}
		},
		optionsTracking = {
			name = "Tracking",
			type = "group",
			order = 5,
			args = {
				fTimelineTracking = {
					name = "Timeline Tracking",
					desc = "The timeline will act as a status bar and track whatever is selected",
					order = 1.2,
					type = "select",
					values = {
								["NONE"] = "None",
								["GCD"] = "GCD",
								["ENERGY_TICK"] = "Energy Tick",
								["MANA_TICK"] = "Mana Tick",
								["CLASS_POWER"] = "Class Power",
								["HEALTH"] = "Health",
								["COMBO_POINTS"] = "Combo Points",
								["MH_SWING"] = "Main-hand Swing",
								["AUTO_SHOT"] = "Auto Shot",
							},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTracking end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTracking = val
						end,
				},
				spacer2 = {
					name = "",
					type = "description",
					order = 2.1,
				},
				fTimelineTrackingInvert = {
					name = "Invert",
					desc = "The bar will appear empty and fill up instead of being full and empty out",
					order = 2.2,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fTimelineTrackingInvert end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTrackingInvert = val 
						end,
				},
				fTimelineTrackingReverse = {
					name = "Reverse",
					desc = "Changes the fill direction",
					order = 2.3,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fTimelineTrackingReverse end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTrackingReverse = val
							CooldownTimeline.fTimeline:SetReverseFill(val)
						end,
				},
				spacer3 = {
					name = "\n\n\n",
					type = "description",
					order = 3.1,
				},
				fTimelineTrackingSecondary = {
					name = "Secondary Tracking",
					desc = "Tracks a second thing in the form of a spark",
					order = 3.2,
					type = "select",
					values = {
								["NONE"] = "None",
								["GCD"] = "GCD",
								["ENERGY_TICK"] = "Energy Tick",
								["MANA_TICK"] = "Mana Tick",
								["CLASS_POWER"] = "Class Power",
								["HEALTH"] = "Health",
								["COMBO_POINTS"] = "Combo Points",
								["MH_SWING"] = "Main-hand Swing",
								["AUTO_SHOT"] = "Auto Shot",
							},
					get = function(info) return CooldownTimeline.db.profile.fTimelineTrackingSecondary end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTrackingSecondary = val
						end,
				},
				spacer4 = {
					name = "",
					type = "description",
					order = 4.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineTrackingSecondary ~= "NONE" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineTrackingInvertSecondary = {
					name = "Invert",
					desc = "The bar will appear empty and fill up instead of being full and empty out",
					order = 4.2,
					type = "toggle",
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineTrackingSecondary ~= "NONE" then
								return false
							else
								return true
							end
						end,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTrackingInvertSecondary end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTrackingInvertSecondary = val 
						end,
				},
				fTimelineTrackingReverseSecondary = {
					name = "Reverse",
					desc = "Changes the fill direction",
					order = 4.3,
					type = "toggle",
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineTrackingSecondary ~= "NONE" then
								return false
							else
								return true
							end
						end,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTrackingReverseSecondary end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTrackingReverseSecondary = val
						end,
				},
				spacer5 = {
					name = "",
					type = "description",
					order = 5.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineTrackingSecondary ~= "NONE" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineTrackingSecondaryTexture = {
					name = "Spark Texture",
					desc = "Selects the spark texture",
					order = 5.2,
					type = "select",
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineTrackingSecondary ~= "NONE" then
								return false
							else
								return true
							end
						end,
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTrackingSecondaryTexture end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTrackingSecondaryTexture = val
							CooldownTimeline.fTimeline.secondaryTracker.bg:SetTexture(SharedMedia:Fetch("statusbar", val))

							local r = CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["r"]
							local g = CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["g"]
							local b = CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["b"]
							local a = CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["a"]
							CooldownTimeline.fTimeline.secondaryTracker.bg:SetVertexColor(r, g, b, a)
						end,
				},
				fTimelineTrackingSecondaryTextureColor = {
					name = "Color",
					desc = "Selects the spark color",
					order = 5.3,
					type = "color",
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineTrackingSecondary ~= "NONE" then
								return false
							else
								return true
							end
						end,
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["r"]
							local g = CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["g"]
							local b = CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["b"]
							local a = CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fTimelineTrackingSecondaryTextureColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline.fTimeline.secondaryTracker.bg:SetVertexColor(red, green, blue, alpha)
						end,
				},
				spacer6 = {
					name = "",
					type = "description",
					order = 6.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineTrackingSecondary ~= "NONE" then
								return false
							else
								return true
							end
						end,
				},
				fTimelineTrackingSecondaryWidth = {
					name = "Spark Width",
					desc = "Sets the width for the secondary tracking spark",
					order = 6.2,
					type = "range",
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineTrackingSecondary ~= "NONE" then
								return false
							else
								return true
							end
						end,
					softMin = 0,
					softMax = 20,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTrackingSecondaryWidth end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTrackingSecondaryWidth = val
							CooldownTimeline.fTimeline.secondaryTracker:SetWidth(val)
						end,
				},
				fTimelineTrackingSecondaryHeight = {
					name = "Spark Height",
					desc = "Sets the height for the secondary tracking spark",
					order = 6.3,
					type = "range",
					hidden = function(info)
							if CooldownTimeline.db.profile.fTimelineTrackingSecondary ~= "NONE" then
								return false
							else
								return true
							end
						end,
					softMin = 0,
					softMax = 50,
					get = function(info) return CooldownTimeline.db.profile.fTimelineTrackingSecondaryHeight end,
					set = function(info, val)
							CooldownTimeline.db.profile.fTimelineTrackingSecondaryHeight = val
							CooldownTimeline.fTimeline.secondaryTracker:SetHeight(val)
						end,
				},
			}
		},
	}
}
	
local optionsReady = {
	name = "Ready",
	handler = CooldownTimeline,
	type = 'group',
	childGroups  = "tab",
	args = {
		fReadyIconGrow = {
			name = "Grow direction",
			desc = "Grow Left/Up, Center, or Right/Down",
			order = 1.2,
			type = "select",
			values = { ["LEFT"] = "Left/Up", ["CENTER"] = "Center", ["RIGHT"] = "Right/Down" },
			get = function(info) return CooldownTimeline.db.profile.fReadyIconGrow end,
			set = function(info, val) CooldownTimeline.db.profile.fReadyIconGrow = val end,
		},
		fReadyVertical = {
			name = "Vertical",
			desc = "Changes the orientation from horizontal to vertical",
			type = "toggle",
			order = 1.3,
			set = function(info,val) CooldownTimeline.db.profile.fReadyVertical = val end,
			get = function(info) return CooldownTimeline.db.profile.fReadyVertical end,
		},
		fReadyIgnoreUnequipped = {
			name = "Ignore item cooldowns if the item is unequipped",
			desc = "",
			order = 1.4,
			type = "toggle",
			hidden = false,
			get = function(info) return CooldownTimeline.db.profile.fReadyIgnoreUnequipped end,
			set = function(info, val) CooldownTimeline.db.profile.fReadyIgnoreUnequipped = val end,
			width = "full",
		},
		spacer2 = {
			name = "\n\n\n",
			type = "description",
			order = 2.1,
		},
		fReadyX = {
			name = "x Pos",
			desc = "Sets the x co-rd for the Ready frame",
			order = 2.2,
			type = "range",
			softMin = -500,
			softMax = 500,
			get = function(info) return CooldownTimeline.db.profile.fReadyPosX end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyPosX = val
					CooldownTimeline.fReady:SetPoint(CooldownTimeline.db.profile.fReadyRelativeTo, val, CooldownTimeline.db.profile.fReadyPosY)
				end,
		},
		fReadyY = {
			name = "y Pos",
			desc = "Sets the y co-rd for the Ready frame",
			order = 2.3,
			type = "range",
			softMin = -500,
			softMax = 500,
			get = function(info) return CooldownTimeline.db.profile.fReadyPosY end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyPosY = val
					CooldownTimeline.fReady:SetPoint(CooldownTimeline.db.profile.fReadyRelativeTo, CooldownTimeline.db.profile.fReadyPosX, val)
				end,
		},		
		spacer3 = {
			name = "",
			type = "description",
			order = 3.1,
		},
		fReadyRelativeTo = {
			name = "Anchor Point",
			desc = "X/Y position is relative to this point of the screen",
			order = 3.2,
			type = "select",
			values = {
				["TOPLEFT"] = "TOPLEFT",
				["TOP"] = "TOP",
				["TOPRIGHT"] = "TOPRIGHT",
				["LEFT"] = "LEFT",
				["CENTER"] = "CENTER",
				["RIGHT"] = "RIGHT",
				["BOTTOMLEFT"] = "BOTTOMLEFT",
				["BOTTOM"] = "BOTTOM",
				["BOTTOMRIGHT"] = "BOTTOMRIGHT",
				},
			get = function(info) return CooldownTimeline.db.profile.fReadyRelativeTo end,
			set = function(info, val)
					CooldownTimeline.fReady:ClearAllPoints()
					
					CooldownTimeline.db.profile.fReadyRelativeTo = val
					
					CooldownTimeline.fReady:SetPoint(val, CooldownTimeline.db.profile.fReadyPosX, CooldownTimeline.db.profile.fReadyPosY)
				end,
		},
		spacer31 = {
			name = "\n\n\n",
			type = "description",
			order = 3.3,
		},
		fReadyFramePadding = {
			name = "Frame Padding",
			desc = "Sets the overall frame padding",
			order = 3.4,
			type = "range",
			softMin = 0,
			softMax = 20,
			get = function(info) return CooldownTimeline.db.profile.fReadyFramePadding end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyFramePadding = val
				end,
		},		
		spacer4 = {
			name = "\n\n\n",
			type = "description",
			order = 4.1,
		},
		fReadyTexture = {
			name = "Background Texture",
			desc = "Selects the texture",
			order = 4.2,
			type = "select",
			dialogControl = 'LSM30_Statusbar',
			values = AceGUIWidgetLSMlists.statusbar,
			get = function(info) return CooldownTimeline.db.profile.fReadyTexture end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyTexture = val
					CooldownTimeline.fReady.bg:SetTexture(SharedMedia:Fetch("statusbar", CooldownTimeline.db.profile.fReadyTexture))

					local r = CooldownTimeline.db.profile.fReadyTextureColor["r"]
					local g = CooldownTimeline.db.profile.fReadyTextureColor["g"]
					local b = CooldownTimeline.db.profile.fReadyTextureColor["b"]
					local a = CooldownTimeline.db.profile.fReadyTextureColor["a"]
					CooldownTimeline.fReady.bg:SetVertexColor(r, g, b, a)
				end,
		},
		fReadyTextureColor = {
			name = "Color",
			desc = "Selects the background color",
			order = 4.3,
			type = "color",
			hasAlpha = true,
			get = function(info)
					local r = CooldownTimeline.db.profile.fReadyTextureColor["r"]
					local g = CooldownTimeline.db.profile.fReadyTextureColor["g"]
					local b = CooldownTimeline.db.profile.fReadyTextureColor["b"]
					local a = CooldownTimeline.db.profile.fReadyTextureColor["a"]
					return r, g, b, a
				end,
			set = function(info, red, green, blue, alpha)
					CooldownTimeline.db.profile.fReadyTextureColor = { r = red, g = green, b = blue, a = alpha }
					CooldownTimeline.fReady.bg:SetVertexColor(red, green, blue, alpha)
				end,
		},
		spacer5 = {
			name = "\n\n\n",
			type = "description",
			order = 5.1,
		},
		fReadyIconSize = {
			name = "Icon Size",
			desc = "Sets the size of the icon on the timeline",
			order = 5.2,
			type = "range",
			softMin = 0,
			softMax = 64,
			get = function(info) return CooldownTimeline.db.profile.fReadyIconSize end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyIconSize = val
					for _, child in ipairs(CooldownTimeline.iconTable) do
						if Masque then
							-- Kill masque for this icon(button)
							CooldownTimeline.masqueGroup:RemoveButton(child)
							
							-- Change the settings
							child:SetSize(val, val)
							child:SetPoint("CENTER",0,0)
							child.tex:SetAllPoints(child)
							
							-- Reapply masque
							CooldownTimeline.masqueGroup = Masque:Group("CooldownTimeline")
							CooldownTimeline.masqueGroup:AddButton(child, { Icon = child.tex })	
						else
							child:SetSize(val, val)
							child:SetPoint("CENTER",0,0)
						end
					end
				end,
		},
		fReadyIconPadding = {
			name = "Icon Padding",
			desc = "Sets the padding between icons",
			order = 5.3,
			type = "range",
			softMin = 0,
			softMax = 20,
			get = function(info) return CooldownTimeline.db.profile.fReadyIconPadding end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyIconPadding = val
				end,
		},
		spacer6 = {
			name = "\n\n\n",
			type = "description",
			order = 6.1,
		},
		fReadyIconDuration = {
			name = "Icon Duration",
			desc = "Sets the duration an icon will display as ready",
			order = 6.2,
			type = "range",
			softMin = 0,
			softMax = 10,
			get = function(info) return CooldownTimeline.db.profile.fReadyIconDuration end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyIconDuration = val
				end,
		},
		spacer7 = {
			name = "\n\n\n",
			type = "description",
			order = 7.1,
		},
		fIconReadyText = {
			name = "Ready Text",
			desc = function(info) return CooldownTimeline:GetCustomIconTagDescription() end,
			type = "input",
			order = 7.2,
			width = "double",
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["text"] end,
			set = function(info, val) CooldownTimeline.db.profile.fIconReadyText["text"] = val end,
		},
		spacer8 = {
			name = "",
			type = "description",
			order = 8.1,
		},
		fIconReadyTextFont = {
			name = "Font",
			desc = "Selects the font for text on the bars",
			order = 8.2,
			type = "select",
			dialogControl = 'LSM30_Font',
			values = AceGUIWidgetLSMlists.font,
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["font"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconReadyText["font"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconReadyTextOutline = {
			name = "Outline",
			desc = "Sets the text outline",
			order = 8.3,
			type = "select",
			values = {
					["NONE"] = "None",
					["OUTLINE"] = "Outline",
					["THICKOUTLINE"] = "Thick Outline",
					["MONOCHROME"] = "Monochrome"
				},
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["outline"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconReadyText["outline"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer9 = {
			name = "",
			type = "description",
			order = 9.1,
		},
		fIconReadyTextSize = {
			name = "Font Size",
			desc = "Sets the size of the font",
			order = 9.2,
			type = "range",
			softMin = 0,
			softMax = 64,
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["size"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconReadyText["size"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconReadyTextColor = {
			name = "Color",
			desc = "Selects the font color",
			order = 9.3,
			type = "color",
			hasAlpha = true,
			get = function(info)
					local t = CooldownTimeline.db.profile.fIconReadyText
					
					local r = t["color"]["r"]
					local g = t["color"]["g"]
					local b = t["color"]["b"]
					local a = t["color"]["a"]
					return r, g, b, a
				end,
			set = function(info, red, green, blue, alpha)
					CooldownTimeline.db.profile.fIconReadyText["color"] = { r = red, g = green, b = blue, a = alpha }
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconReadyTextShadowColor = {
			name = "Shadow Color",
			desc = "Selects the shadow color",
			order = 9.4,
			type = "color",
			hasAlpha = true,
			get = function(info)
					local t = CooldownTimeline.db.profile.fIconReadyText
					
					local r = t["shadowColor"]["r"]
					local g = t["shadowColor"]["g"]
					local b = t["shadowColor"]["b"]
					local a = t["shadowColor"]["a"]
					return r, g, b, a
				end,
			set = function(info, red, green, blue, alpha)
					CooldownTimeline.db.profile.fIconReadyText["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer10 = {
			name = "",
			type = "description",
			order = 10.1,
		},
		fIconReadyTextShadowXOffset = {
			name = "Shadow x Offset",
			desc = "Sets the text shadow x offset",
			order = 10.2,
			type = "range",
			softMin = -5,
			softMax = 5,
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["shadowXOffset"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconReadyText["shadowXOffset"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconReadyTextShadowYOffset = {
			name = "Shadow y Offset",
			desc = "Sets the text shadow y offset",
			order = 10.3,
			type = "range",
			softMin = -5,
			softMax = 5,
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["shadowYOffset"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconReadyText["shadowYOffset"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer11 = {
			name = "",
			type = "description",
			order = 11.1,
		},
		fIconReadyTextAnchor = {
			name = "Anchor",
			desc = "Sets the text anchor point",
			order = 11.2,
			type = "select",
			values = {
					["TOPLEFT"] = "TOPLEFT",
					["TOP"] = "TOP",
					["TOPRIGHT"] = "TOPRIGHT",
					["LEFT"] = "LEFT",
					["CENTER"] = "CENTER",
					["RIGHT"] = "RIGHT",
					["BOTTOMLEFT"] = "BOTTOMLEFT",
					["BOTTOM"] = "BOTTOM",
					["BOTTOMRIGHT"] = "BOTTOMRIGHT",
				},
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["anchor"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconReadyText["anchor"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconReadyTextAlign = {
			name = "Align",
			desc = "Sets the text alignment",
			order = 11.3,
			type = "select",
			values = {
					["LEFT"] = "LEFT",
					["CENTER"] = "CENTER",
					["RIGHT"] = "RIGHT",
				},
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["align"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconReadyText["align"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer12 = {
			name = "",
			type = "description",
			order = 12.1,
		},
		fIconReadyTextXOffset = {
			name = "x Offset",
			desc = "Sets text x offset",
			order = 12.2,
			type = "range",
			softMin = -5,
			softMax = 5,
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["xOffset"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconReadyText["xOffset"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconReadyTextYOffset = {
			name = "y Offset",
			desc = "Sets text y offset",
			order = 12.3,
			type = "range",
			softMin = -5,
			softMax = 5,
			get = function(info) return CooldownTimeline.db.profile.fIconReadyText["yOffset"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconReadyText["yOffset"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer13 = {
			name = "\n\n\n",
			type = "description",
			order = 13.1,
		},
		fReadyBorder = {
			name = "                    Border Texture",
			desc = "Selects the texture",
			order = 13.2,
			type = "select",
			dialogControl = 'LSM30_Border',
			values = AceGUIWidgetLSMlists.border,
			get = function(info) return CooldownTimeline.db.profile.fReadyBorder end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyBorder = val
					local fReadyBorderSize = CooldownTimeline.db.profile.fReadyBorderSize
					local fReadyBorderInset = CooldownTimeline.db.profile.fReadyBorderInset
					local fReadyBorderPadding = CooldownTimeline.db.profile.fReadyBorderPadding
					local fReadyBorderColor = CooldownTimeline.db.profile.fReadyBorderColor
					
					CooldownTimeline:SetBorder(CooldownTimeline.fReady, val, fReadyBorderSize, fReadyBorderInset)
					CooldownTimeline:SetBorderColor(CooldownTimeline.fReady, fReadyBorderColor)
					CooldownTimeline:SetBorderPoint(CooldownTimeline.fReady, fReadyBorderPadding)
				end,
		},
		fReadyBorderColor = {
			name = "Color",
			desc = "Selects the border color",
			order = 13.3,
			type = "color",
			hasAlpha = true,
			get = function(info)
					local r = CooldownTimeline.db.profile.fReadyBorderColor["r"]
					local g = CooldownTimeline.db.profile.fReadyBorderColor["g"]
					local b = CooldownTimeline.db.profile.fReadyBorderColor["b"]
					local a = CooldownTimeline.db.profile.fReadyBorderColor["a"]
					return r, g, b, a
				end,
			set = function(info, red, green, blue, alpha)
					CooldownTimeline.db.profile.fReadyBorderColor = { r = red, g = green, b = blue, a = alpha }
					CooldownTimeline.fReady.border:SetBackdropBorderColor(red, green, blue, alpha)
				end,
		},
		spacer14 = {
			name = "",
			type = "description",
			order = 14.1,
		},
		fReadyBorderSize = {
			name = "Size",
			desc = "Sets the size of the border",
			order = 14.2,
			type = "range",
			softMin = 1,
			softMax = 40,
			get = function(info) return CooldownTimeline.db.profile.fReadyBorderSize end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyBorderSize = val
					local fReadyBorder = CooldownTimeline.db.profile.fReadyBorder
					local fReadyBorderInset = CooldownTimeline.db.profile.fReadyBorderInset
					local fReadyBorderPadding = CooldownTimeline.db.profile.fReadyBorderPadding
					local fReadyBorderColor = CooldownTimeline.db.profile.fReadyBorderColor
					
					CooldownTimeline:SetBorder(CooldownTimeline.fReady, fReadyBorder, val, fReadyBorderInset)
					CooldownTimeline:SetBorderColor(CooldownTimeline.fReady, fReadyBorderColor)
				end,
		},
		fReadyBorderPadding = {
			name = "Padding",
			desc = "Sets the size of the border",
			order = 14.3,
			type = "range",
			softMin = 0,
			softMax = 40,
			get = function(info) return CooldownTimeline.db.profile.fReadyBorderPadding end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyBorderPadding = val
					local fReadyBorderColor = CooldownTimeline.db.profile.fReadyBorderColor
					
					CooldownTimeline:SetBorderPoint(CooldownTimeline.fReady, val)
					CooldownTimeline:SetBorderColor(CooldownTimeline.fReady, fReadyBorderColor)
				end,
		},
		spacer16 = {
			name = "\n\n\n",
			type = "description",
			order = 16.1,
		},
		fReadyAnimateInNewType = {
			name = "On show animation",
			desc = "Select the animation played on show",
			order = 16.2,
			type = "select",
			values = { ["NONE"] = "None", ["FADE"] = "Fade" },
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateInNew["type"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateInNew["type"] = val
				end,
		},
		spacer17 = {
			name = "",
			type = "description",
			order = 17.1,
		},
		fReadyAnimateInNewStartValue = {
			name = "Start value",
			desc = "Value to start the animation at",
			order = 17.2,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateInNew["startValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateInNew["startValue"] = val
				end,
		},
		fReadyAnimateInNewEndValue = {
			name = "End value",
			desc = "Value to end the animation at",
			order = 17.3,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateInNew["endValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateInNew["endValue"] = val
				end,
		},
		spacer18 = {
			name = "",
			type = "description",
			order = 18.1,
		},
		fReadyAnimateInNewFinishValue = {
			name = "Finish value",
			desc = "Value to start the animation at",
			order = 18.2,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateInNew["finishValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateInNew["finishValue"] = val
				end,
		},
		fReadyAnimateInNewDuration = {
			name = "Duration",
			desc = "How long should the animation last",
			order = 18.3,
			type = "range",
			softMin = 0.1,
			softMax = 10,
			bigStep = 0.1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateInNew["duration"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateInNew["duration"] = val
				end,
		},
		spacer19 = {
			name = "",
			type = "description",
			order = 19.1,
		},
		fReadyAnimateInNewLoop = {
			name = "Number of loops (-1 will loop infinitely)",
			desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
			order = 19.2,
			type = "range",
			softMin = -1,
			softMax = 5,
			bigStep = 1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateInNew["loop"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateInNew["loop"] = val
				end,
		},
		fReadyAnimateInNewBounce = {
			name = "Bounce animation",
			desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
			type = "toggle",
			order = 19.3,
			set = function(info,val) CooldownTimeline.db.profile.fReadyAnimateInNew["bounce"] = val end,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateInNew["bounce"] end,
		},
		spacer20 = {
			name = "\n\n",
			type = "description",
			order = 20.1,
		},
		fReadyAnimateOutNewType = {
			name = "On show animation",
			desc = "Select the animation played on show",
			order = 20.2,
			type = "select",
			values = { ["NONE"] = "None", ["FADE"] = "Fade" },
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateOutNew["type"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateOutNew["type"] = val
				end,
		},
		spacer21 = {
			name = "",
			type = "description",
			order = 21.1,
		},
		fReadyAnimateOutNewStartValue = {
			name = "Start value",
			desc = "Value to start the animation at",
			order = 21.2,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateOutNew["startValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateOutNew["startValue"] = val
				end,
		},
		fReadyAnimateOutNewEndValue = {
			name = "End value",
			desc = "Value to end the animation at",
			order = 21.3,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateOutNew["endValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateOutNew["endValue"] = val
				end,
		},
		spacer22 = {
			name = "",
			type = "description",
			order = 22.1,
		},
		fReadyAnimateOutNewFinishValue = {
			name = "Finish value",
			desc = "Value to start the animation at",
			order = 22.2,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateOutNew["finishValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateOutNew["finishValue"] = val
				end,
		},
		fReadyAnimateOutNewDuration = {
			name = "Duration",
			desc = "How long should the animation last",
			order = 22.3,
			type = "range",
			softMin = 0.1,
			softMax = 10,
			bigStep = 0.1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateOutNew["duration"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateOutNew["duration"] = val
				end,
		},
		spacer23 = {
			name = "",
			type = "description",
			order = 23.1,
		},
		fReadyAnimateOutNewLoop = {
			name = "Number of loops (-1 will loop infinitely)",
			desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
			order = 23.2,
			type = "range",
			softMin = -1,
			softMax = 5,
			bigStep = 1,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateOutNew["loop"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fReadyAnimateOutNew["loop"] = val
				end,
		},
		fReadyAnimateOutNewBounce = {
			name = "Bounce animation",
			desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
			type = "toggle",
			order = 23.3,
			set = function(info,val) CooldownTimeline.db.profile.fReadyAnimateOutNew["bounce"] = val end,
			get = function(info) return CooldownTimeline.db.profile.fReadyAnimateOutNew["bounce"] end,
		},
	}
}

local optionsFastlane = {
	name = "Fast Lane",
	handler = CooldownTimeline,
	type = "group",
	childGroups  = "tab",
	width = 'full',
	args = {
		spacer1 = {
			name = "The Fast Lane allows icons to be placed in a separate 'lane' to the other icons\n\n",
			type = "description",
			order = 1.0,
		},
		fFastlaneWidth = {
			name = "Width",
			desc = "Sets the width for the Fastlane frame",
			order = 2.2,
			type = "range",
			softMin = 0,
			softMax = 600,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneWidth end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneWidth = val
					CooldownTimeline.fFastlane:SetWidth(val)
			end,
		},
		fFastlaneHeight = {
			name = "Height",
			desc = "Sets the height for the Timeline frame",
			order = 2.3,
			type = "range",
			softMin = 0,
			softMax = 600,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneHeight end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneHeight = val
					CooldownTimeline.fFastlane:SetHeight(val)
				end,
		},
		spacer3 = {
			name = "",
			type = "description",
			order = 3.1,
		},
		fFastlanePosX = {
			name = "x Pos",
			desc = "Sets the x co-rd for the Timeline frame",
			order = 3.2,
			type = "range",
			softMin = -500,
			softMax = 500,
			get = function(info) return CooldownTimeline.db.profile.fFastlanePosX end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlanePosX = val
					CooldownTimeline.fFastlane:SetPoint(CooldownTimeline.db.profile.fFastlaneRelativeTo, val, CooldownTimeline.db.profile.fFastlanePosY)
				end,
		},
		fFastlanePosY = {
			name = "y Pos",
			desc = "Sets the y co-rd for the Timeline frame",
			order = 3.3,
			type = "range",
			softMin = -500,
			softMax = 500,
			get = function(info) return CooldownTimeline.db.profile.fFastlanePosY end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlanePosY = val
					CooldownTimeline.fFastlane:SetPoint(CooldownTimeline.db.profile.fFastlaneRelativeTo, CooldownTimeline.db.profile.fFastlanePosX, val)
				end,
		},
		spacer4 = {
			name = "",
			type = "description",
			order = 4.1,
		},
		fFastlaneRelativeTo = {
			name = "Anchor Point",
			desc = "X/Y position is relative to this point of the screen",
			order = 4.2,
			type = "select",
			values = {
					["TOPLEFT"] = "TOPLEFT",
					["TOP"] = "TOP",
					["TOPRIGHT"] = "TOPRIGHT",
					["LEFT"] = "LEFT",
					["CENTER"] = "CENTER",
					["RIGHT"] = "RIGHT",
					["BOTTOMLEFT"] = "BOTTOMLEFT",
					["BOTTOM"] = "BOTTOM",
					["BOTTOMRIGHT"] = "BOTTOMRIGHT",
				},
			get = function(info) return CooldownTimeline.db.profile.fFastlaneRelativeTo end,
			set = function(info, val)
					CooldownTimeline.fFastlane:ClearAllPoints()
					CooldownTimeline.db.profile.fFastlaneRelativeTo = val
					CooldownTimeline.fFastlane:SetPoint(val, CooldownTimeline.db.profile.fFastlanePosX, CooldownTimeline.db.profile.fFastlanePosY)
				end,
		},
		spacer5 = {
			name = "\n\n\n",
			type = "description",
			order = 5.1,
		},
		fFastlaneBackground = {
			name = "Background Texture",
			desc = "Selects the texture",
			order = 5.2,
			type = "select",
			dialogControl = 'LSM30_Statusbar',
			values = AceGUIWidgetLSMlists.statusbar,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneBackground end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneBackground = val
					CooldownTimeline.fFastlane.bg:SetTexture(SharedMedia:Fetch("statusbar", CooldownTimeline.db.profile.fFastlaneBackground))

					local r = CooldownTimeline.db.profile.fFastlaneBackgroundColor["r"]
					local g = CooldownTimeline.db.profile.fFastlaneBackgroundColor["g"]
					local b = CooldownTimeline.db.profile.fFastlaneBackgroundColor["b"]
					local a = CooldownTimeline.db.profile.fFastlaneBackgroundColor["a"]
					CooldownTimeline.fFastlane.bg:SetVertexColor(r, g, b, a)
				end,
		},
		fFastlaneBackgroundColor = {
			name = "Color",
			desc = "Selects the background color",
			order = 5.3,
			type = "color",
			hasAlpha = true,
			get = function(info)
					local r = CooldownTimeline.db.profile.fFastlaneBackgroundColor["r"]
					local g = CooldownTimeline.db.profile.fFastlaneBackgroundColor["g"]
					local b = CooldownTimeline.db.profile.fFastlaneBackgroundColor["b"]
					local a = CooldownTimeline.db.profile.fFastlaneBackgroundColor["a"]
					return r, g, b, a
				end,
			set = function(info, red, green, blue, alpha)
					CooldownTimeline.db.profile.fFastlaneBackgroundColor = { r = red, g = green, b = blue, a = alpha }
					CooldownTimeline.fFastlane.bg:SetVertexColor(red, green, blue, alpha)
				end,
		},
		
		
		
		
		
		spacer6 = {
			name = "\n\n\n",
			type = "description",
			order = 6.1,
		},
		fFastlaneBorder = {
			name = "                    Border Texture",
			desc = "Selects the texture",
			order = 6.2,
			type = "select",
			dialogControl = 'LSM30_Border',
			values = AceGUIWidgetLSMlists.border,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneBorder end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneBorder = val
					local fFastlaneBorderSize = CooldownTimeline.db.profile.fFastlaneBorderSize
					local fFastlaneBorderInset = CooldownTimeline.db.profile.fFastlaneBorderInset
					local fFastlaneBorderPadding = CooldownTimeline.db.profile.fFastlaneBorderPadding
					local fFastlaneBorderColor = CooldownTimeline.db.profile.fFastlaneBorderColor
					
					CooldownTimeline:SetBorder(CooldownTimeline.fFastlane, val, fFastlaneBorderSize, fFastlaneBorderInset)
					CooldownTimeline:SetBorderColor(CooldownTimeline.fFastlane, fFastlaneBorderColor)
					CooldownTimeline:SetBorderPoint(CooldownTimeline.fFastlane, fFastlaneBorderPadding)
				end,
		},
		fFastlaneBorderColor = {
			name = "Color",
			desc = "Selects the border color",
			order = 6.3,
			type = "color",
			hasAlpha = true,
			get = function(info)
					local r = CooldownTimeline.db.profile.fFastlaneBorderColor["r"]
					local g = CooldownTimeline.db.profile.fFastlaneBorderColor["g"]
					local b = CooldownTimeline.db.profile.fFastlaneBorderColor["b"]
					local a = CooldownTimeline.db.profile.fFastlaneBorderColor["a"]
					return r, g, b, a
				end,
			set = function(info, red, green, blue, alpha)
					CooldownTimeline.db.profile.fFastlaneBorderColor = { r = red, g = green, b = blue, a = alpha }
					CooldownTimeline.fFastlane.border:SetBackdropBorderColor(red, green, blue, alpha)
				end,
		},
		spacer7 = {
			name = "",
			type = "description",
			order = 7.1,
		},
		fFastlaneBorderSize = {
			name = "Size",
			desc = "Sets the size of the border",
			order = 7.2,
			type = "range",
			softMin = 1,
			softMax = 40,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneBorderSize end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneBorderSize = val
					local fFastlaneBorder = CooldownTimeline.db.profile.fFastlaneBorder
					local fFastlaneBorderInset = CooldownTimeline.db.profile.fFastlaneBorderInset
					local fFastlaneBorderPadding = CooldownTimeline.db.profile.fFastlaneBorderPadding
					local fFastlaneBorderColor = CooldownTimeline.db.profile.fFastlaneBorderColor
					
					CooldownTimeline:SetBorder(CooldownTimeline.fFastlane, fFastlaneBorder, val, fFastlaneBorderInset)
					CooldownTimeline:SetBorderColor(CooldownTimeline.fFastlane, fFastlaneBorderColor)
				end,
		},
		fFastlaneBorderPadding = {
			name = "Padding",
			desc = "Sets the size of the border",
			order = 7.3,
			type = "range",
			softMin = 0,
			softMax = 40,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneBorderPadding end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneBorderPadding = val
					local fFastlaneBorderColor = CooldownTimeline.db.profile.fFastlaneBorderColor
					
					CooldownTimeline:SetBorderPoint(CooldownTimeline.fFastlane, val)
					CooldownTimeline:SetBorderColor(CooldownTimeline.fFastlane, fFastlaneBorderColor)
				end,
		},
		
		
		spacer8 = {
			name = "\n\n\n",
			type = "description",
			order = 8.1,
		},
		fFastlaneIconSize = {
			name = "Icon Size",
			desc = "Sets the size of the icon on the fast lane",
			order = 8.2,
			type = "range",
			softMin = 0,
			softMax = 64,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneIconSize end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneIconSize = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer9 = {
			name = "\n",
			type = "description",
			order = 9.1,
		},
		fFastlaneIconOffset = {
			name = "Icon Offset",
			desc = "Sets the vertical offset of the icons on the timeline",
			order = 9.2,
			type = "range",
			softMin = -50,
			softMax = 50,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneIconOffset end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneIconOffset = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer10 = {
			name = "\n\n\n",
			type = "description",
			order = 10.1,
		},
		fIconFastlaneText = {
			name = "Text 1",
			desc = function(info) return CooldownTimeline:GetCustomIconTagDescription() end,
			type = "input",
			order = 10.2,
			width = "double",
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["text"] end,
			set = function(info, val) CooldownTimeline.db.profile.fIconFastlaneText["text"] = val end,
		},
		spacer11 = {
			name = "",
			type = "description",
			order = 11.1,
		},
		fIconFastlaneTextFont = {
			name = "Font",
			desc = "Selects the font for text on the bars",
			order = 11.2,
			type = "select",
			dialogControl = 'LSM30_Font',
			values = AceGUIWidgetLSMlists.font,
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["font"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconFastlaneText["font"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconFastlaneTextOutline = {
			name = "Outline",
			desc = "Sets the text outline",
			order = 11.3,
			type = "select",
			values = {
					["NONE"] = "None",
					["OUTLINE"] = "Outline",
					["THICKOUTLINE"] = "Thick Outline",
					["MONOCHROME"] = "Monochrome"
				},
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["outline"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconFastlaneText["outline"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer12 = {
			name = "",
			type = "description",
			order = 12.1,
		},
		fIconFastlaneTextSize = {
			name = "Font Size",
			desc = "Sets the size of the font",
			order = 12.2,
			type = "range",
			softMin = 0,
			softMax = 64,
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["size"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconFastlaneText["size"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconFastlaneTextColor = {
			name = "Color",
			desc = "Selects the font color",
			order = 12.3,
			type = "color",
			hasAlpha = true,
			get = function(info)
					local t = CooldownTimeline.db.profile.fIconFastlaneText
					
					local r = t["color"]["r"]
					local g = t["color"]["g"]
					local b = t["color"]["b"]
					local a = t["color"]["a"]
					return r, g, b, a
				end,
			set = function(info, red, green, blue, alpha)
					CooldownTimeline.db.profile.fIconFastlaneText["color"] = { r = red, g = green, b = blue, a = alpha }
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconFastlaneTextShadowColor = {
			name = "Shadow Color",
			desc = "Selects the shadow color",
			order = 12.4,
			type = "color",
			hasAlpha = true,
			get = function(info)
					local t = CooldownTimeline.db.profile.fIconFastlaneText
					
					local r = t["shadowColor"]["r"]
					local g = t["shadowColor"]["g"]
					local b = t["shadowColor"]["b"]
					local a = t["shadowColor"]["a"]
					return r, g, b, a
				end,
			set = function(info, red, green, blue, alpha)
					CooldownTimeline.db.profile.fIconFastlaneText["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer13 = {
			name = "",
			type = "description",
			order = 13.1,
		},
		fIconFastlaneTextShadowXOffset = {
			name = "Shadow x Offset",
			desc = "Sets the text shadow x offset",
			order = 13.2,
			type = "range",
			softMin = -5,
			softMax = 5,
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["shadowXOffset"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconFastlaneText["shadowXOffset"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconFastlaneTextShadowYOffset = {
			name = "Shadow y Offset",
			desc = "Sets the text shadow y offset",
			order = 13.3,
			type = "range",
			softMin = -5,
			softMax = 5,
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["shadowYOffset"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconFastlaneText["shadowYOffset"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer14 = {
			name = "",
			type = "description",
			order = 14.1,
		},
		fIconFastlaneTextAnchor = {
			name = "Anchor",
			desc = "Sets the text anchor point",
			order = 14.2,
			type = "select",
			values = {
					["TOPLEFT"] = "TOPLEFT",
					["TOP"] = "TOP",
					["TOPRIGHT"] = "TOPRIGHT",
					["LEFT"] = "LEFT",
					["CENTER"] = "CENTER",
					["RIGHT"] = "RIGHT",
					["BOTTOMLEFT"] = "BOTTOMLEFT",
					["BOTTOM"] = "BOTTOM",
					["BOTTOMRIGHT"] = "BOTTOMRIGHT",
				},
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["anchor"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconFastlaneText["anchor"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconFastlaneTextAlign = {
			name = "Align",
			desc = "Sets the text alignment",
			order = 14.3,
			type = "select",
			values = {
					["LEFT"] = "LEFT",
					["CENTER"] = "CENTER",
					["RIGHT"] = "RIGHT",
				},
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["align"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconFastlaneText["align"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer15 = {
			name = "",
			type = "description",
			order = 15.1,
		},
		fIconFastlaneTextXOffset = {
			name = "x Offset",
			desc = "Sets text x offset",
			order = 15.2,
			type = "range",
			softMin = -5,
			softMax = 5,
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["xOffset"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconFastlaneText["xOffset"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		fIconFastlaneTextYOffset = {
			name = "y Offset",
			desc = "Sets text y offset",
			order = 15.3,
			type = "range",
			softMin = -5,
			softMax = 5,
			get = function(info) return CooldownTimeline.db.profile.fIconFastlaneText["yOffset"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fIconFastlaneText["yOffset"] = val
					CooldownTimeline:RefreshIcons()
				end,
		},
		spacer16 = {
			name = "\n\n\n",
			type = "description",
			order = 16.1,
		},
		fFastlaneAnimateInType = {
			name = "On show animation",
			desc = "Select the animation played on show",
			order = 16.2,
			type = "select",
			values = { ["NONE"] = "None", ["FADE"] = "Fade" },
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateIn["type"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateIn["type"] = val
				end,
		},
		spacer17 = {
			name = "",
			type = "description",
			order = 17.1,
		},
		fFastlaneAnimateInStartValue = {
			name = "Start value",
			desc = "Value to start the animation at",
			order = 17.2,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateIn["startValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateIn["startValue"] = val
				end,
		},
		fFastlaneAnimateInEndValue = {
			name = "End value",
			desc = "Value to end the animation at",
			order = 17.3,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateIn["endValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateIn["endValue"] = val
				end,
		},
		spacer18 = {
			name = "",
			type = "description",
			order = 18.1,
		},
		fFastlaneAnimateInFinishValue = {
			name = "Finish value",
			desc = "Value to start the animation at",
			order = 18.2,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateIn["finishValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateIn["finishValue"] = val
				end,
		},
		fFastlaneAnimateInDuration = {
			name = "Duration",
			desc = "How long should the animation last",
			order = 18.3,
			type = "range",
			softMin = 0.1,
			softMax = 10,
			bigStep = 0.1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateIn["duration"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateIn["duration"] = val
				end,
		},
		spacer19 = {
			name = "",
			type = "description",
			order = 19.1,
		},
		fFastlaneAnimateInLoop = {
			name = "Number of loops (-1 will loop infinitely)",
			desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
			order = 19.2,
			type = "range",
			softMin = -1,
			softMax = 5,
			bigStep = 1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateIn["loop"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateIn["loop"] = val
				end,
		},
		fFastlaneAnimateInBounce = {
			name = "Bounce animation",
			desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
			type = "toggle",
			order = 19.3,
			set = function(info,val) CooldownTimeline.db.profile.fFastlaneAnimateIn["bounce"] = val end,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateIn["bounce"] end,
		},
		spacer20 = {
			name = "\n\n",
			type = "description",
			order = 20.1,
		},
		fFastlaneAnimateOutType = {
			name = "On show animation",
			desc = "Select the animation played on show",
			order = 20.2,
			type = "select",
			values = { ["NONE"] = "None", ["FADE"] = "Fade" },
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateOut["type"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateOut["type"] = val
				end,
		},
		spacer21 = {
			name = "",
			type = "description",
			order = 21.1,
		},
		fFastlaneAnimateOutStartValue = {
			name = "Start value",
			desc = "Value to start the animation at",
			order = 21.2,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateOut["startValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateOut["startValue"] = val
				end,
		},
		fFastlaneAnimateOutEndValue = {
			name = "End value",
			desc = "Value to end the animation at",
			order = 21.3,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateOut["endValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateOut["endValue"] = val
				end,
		},
		spacer22 = {
			name = "",
			type = "description",
			order = 22.1,
		},
		fFastlaneAnimateOutFinishValue = {
			name = "Finish value",
			desc = "Value to start the animation at",
			order = 22.2,
			type = "range",
			softMin = 0,
			softMax = 1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateOut["finishValue"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateOut["finishValue"] = val
				end,
		},
		fFastlaneAnimateOutDuration = {
			name = "Duration",
			desc = "How long should the animation last",
			order = 22.3,
			type = "range",
			softMin = 0.1,
			softMax = 10,
			bigStep = 0.1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateOut["duration"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateOut["duration"] = val
				end,
		},
		spacer23 = {
			name = "",
			type = "description",
			order = 23.1,
		},
		fFastlaneAnimateOutLoop = {
			name = "Number of loops (-1 will loop infinitely)",
			desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
			order = 23.2,
			type = "range",
			softMin = -1,
			softMax = 5,
			bigStep = 1,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateOut["loop"] end,
			set = function(info, val)
					CooldownTimeline.db.profile.fFastlaneAnimateOut["loop"] = val
				end,
		},
		fFastlaneAnimateOutBounce = {
			name = "Bounce animation",
			desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
			type = "toggle",
			order = 23.3,
			set = function(info,val) CooldownTimeline.db.profile.fFastlaneAnimateOut["bounce"] = val end,
			get = function(info) return CooldownTimeline.db.profile.fFastlaneAnimateOut["bounce"] end,
		},
	}
}

local optionsBars = {
	name = "Bars",
	handler = CooldownTimeline,
	type = 'group',
	width = 'full',
	childGroups  = "tab",
	args = {
		optionsBarsFrame = {
			name = "Frame",
			type = "group",
			order = 1.0,
			args = {
				spacer3 = {
					name = "\n",
					type = "description",
					order = 3.1,
				},
				fBarFramePosX = {
					name = "x Pos",
					desc = "Sets the x co-rd for the bars frame",
					order = 3.2,
					type = "range",
					softMin = -500,
					softMax = 500,
					get = function(info) return CooldownTimeline.db.profile.fBarFramePosX end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFramePosX = val
							CooldownTimeline.fBar:SetPoint(CooldownTimeline.db.profile.fBarFrameRelativeTo, val, CooldownTimeline.db.profile.fBarFramePosY)
						end,
				},
				fBarFramePosY = {
					name = "y Pos",
					desc = "Sets the y co-rd for the bars frame",
					order = 3.3,
					type = "range",
					softMin = -500,
					softMax = 500,
					get = function(info) return CooldownTimeline.db.profile.fBarFramePosY end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFramePosY = val
							CooldownTimeline.fBar:SetPoint(CooldownTimeline.db.profile.fBarFrameRelativeTo, CooldownTimeline.db.profile.fBarFramePosX, val)
						end,
				},
				spacer4 = {
					name = "",
					type = "description",
					order = 4.1,
				},
				fBarFrameRelativeTo = {
					name = "Anchor Point",
					desc = "X/Y position is relative to this point of the screen",
					order = 4.2,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBarFrameRelativeTo end,
					set = function(info, val)
							CooldownTimeline.fBar:ClearAllPoints()
							CooldownTimeline.db.profile.fBarFrameRelativeTo = val
							CooldownTimeline.fBar:SetPoint(val, CooldownTimeline.db.profile.fBarFramePosX, CooldownTimeline.db.profile.fBarFramePosY)
						end,
				},
				spacer41 = {
					name = "\n\n\n",
					type = "description",
					order = 4.3,
				},
				fBarFramePadding = {
					name = "Frame Padding",
					desc = "Sets the overall frame padding",
					order = 4.4,
					type = "range",
					softMin = 0,
					softMax = 20,
					get = function(info) return CooldownTimeline.db.profile.fBarFramePadding end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFramePadding = val
						end,
				},
				spacer5 = {
					name = "\n\n\n",
					type = "description",
					order = 5.1,
				},
				fBarFrameBackground = {
					name = "Background Texture",
					desc = "Selects the texture",
					order = 5.2,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameBackground end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameBackground = val
							CooldownTimeline.fBar.bg:SetTexture(SharedMedia:Fetch("statusbar", val))

							local r = CooldownTimeline.db.profile.fBarFrameBackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fBarFrameBackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fBarFrameBackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fBarFrameBackgroundColor["a"]
							CooldownTimeline.fBar.bg:SetVertexColor(r, g, b, a)
						end,
				},
				fBarFrameBackgroundColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 5.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBarFrameBackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fBarFrameBackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fBarFrameBackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fBarFrameBackgroundColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarFrameBackgroundColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline.fBar.bg:SetVertexColor(red, green, blue, alpha)							
						end,
				},
				
				spacer6 = {
					name = "\n\n\n",
					type = "description",
					order = 6.1,
				},
				fBarBorder = {
					name = "                    Border Texture",
					desc = "Selects the texture",
					order = 6.2,
					type = "select",
					dialogControl = 'LSM30_Border',
					values = AceGUIWidgetLSMlists.border,
					get = function(info) return CooldownTimeline.db.profile.fBarBorder end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarBorder = val
							local fBarBorderSize = CooldownTimeline.db.profile.fBarBorderSize
							local fBarBorderInset = CooldownTimeline.db.profile.fBarBorderInset
							local fBarBorderPadding = CooldownTimeline.db.profile.fBarBorderPadding
							local fBarBorderColor = CooldownTimeline.db.profile.fBarBorderColor
							
							CooldownTimeline:SetBorder(CooldownTimeline.fBar, val, fBarBorderSize, fBarBorderInset)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fBar, fBarBorderColor)
							CooldownTimeline:SetBorderPoint(CooldownTimeline.fBar, fBarBorderPadding)
						end,
				},
				fBarBorderColor = {
					name = "Color",
					desc = "Selects the border color",
					order = 6.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBarBorderColor["r"]
							local g = CooldownTimeline.db.profile.fBarBorderColor["g"]
							local b = CooldownTimeline.db.profile.fBarBorderColor["b"]
							local a = CooldownTimeline.db.profile.fBarBorderColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarBorderColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline.fBar.border:SetBackdropBorderColor(red, green, blue, alpha)
						end,
				},
				spacer7 = {
					name = "",
					type = "description",
					order = 7.1,
				},
				fBarBorderSize = {
					name = "Size",
					desc = "Sets the size of the border",
					order = 7.2,
					type = "range",
					softMin = 1,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fBarBorderSize end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarBorderSize = val
							local fBarBorder = CooldownTimeline.db.profile.fBarBorder
							local fBarBorderInset = CooldownTimeline.db.profile.fBarBorderInset
							local fBarBorderPadding = CooldownTimeline.db.profile.fBarBorderPadding
							local fBarBorderColor = CooldownTimeline.db.profile.fBarBorderColor
							
							CooldownTimeline:SetBorder(CooldownTimeline.fBar, fBarBorder, val, fBarBorderInset)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fBar, fBarBorderColor)
						end,
				},
				fBarBorderPadding = {
					name = "Padding",
					desc = "Sets the size of the border",
					order = 7.3,
					type = "range",
					softMin = 0,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fBarBorderPadding end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarBorderPadding = val
							local fBarBorderColor = CooldownTimeline.db.profile.fBarBorderColor
							
							CooldownTimeline:SetBorderPoint(CooldownTimeline.fBar, val)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fBar, fBarBorderColor)
						end,
				},
				spacer8 = {
					name = "\n\n\n",
					type = "description",
					order = 8.1,
				},
				fBarXPadding = {
					name = "x Padding",
					desc = "Each bar will be staggered horizontally by this amount",
					order = 8.2,
					type = "range",
					softMin = 0,
					softMax = 10,
					get = function(info) return CooldownTimeline.db.profile.fBarXPadding end,
					set = function(info, val) CooldownTimeline.db.profile.fBarXPadding = val end,
				},
				fBarYPadding = {
					name = "y Padding",
					desc = "Each bar will be staggered vertically by this amount",
					order = 8.3,
					type = "range",
					softMin = 0,
					softMax = 10,
					get = function(info) return CooldownTimeline.db.profile.fBarYPadding end,
					set = function(info, val) CooldownTimeline.db.profile.fBarYPadding = val end,
				},
				spacer9 = {
					name = "\n\n\n",
					type = "description",
					order = 9.1,
				},
				fBarFrameGrow = {
					name = "Grow direction",
					desc = "Grow Up or Down",
					order = 9.2,
					type = "select",
					values = { ["UP"] = "Up", ["CENTERED"] = "Centered", ["DOWN"] = "Down" },
					get = function(info) return CooldownTimeline.db.profile.fBarFrameGrow end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameGrow = val
							
							local fBarHeight = CooldownTimeline.db.profile.fBarHeight
							local fBarFramePosX = CooldownTimeline.db.profile.fBarFramePosX
							local fBarFramePosY = CooldownTimeline.db.profile.fBarFramePosY
							local fBarFrameRelativeTo = CooldownTimeline.db.profile.fBarFrameRelativeTo
							local fBarFrameGrow = CooldownTimeline.db.profile.fBarFrameGrow
							
							local anchorPoint = "CENTER"
							if fBarFrameGrow == "UP" then
								anchorPoint = "BOTTOM"
								fBarFramePosY = fBarFramePosY - (fBarHeight / 2)
							elseif fBarFrameGrow == "DOWN" then
								anchorPoint = "TOP"
								fBarFramePosY = fBarFramePosY + (fBarHeight / 2)
							end
							
							CooldownTimeline.fBar:ClearAllPoints()
							CooldownTimeline.fBar:SetPoint(anchorPoint, UIParent, fBarFrameRelativeTo, fBarFramePosX, fBarFramePosY)
						end,
				},
				fBarFrameSort = {
					name = "Sort",
					desc = "Grow Up or Down",
					order = 9.3,
					type = "select",
					values = { ["NONE"] = "None", ["ASCENDING"] = "Ascending", ["DESCENDING"] = "Descending" },
					get = function(info) return CooldownTimeline.db.profile.fBarFrameSort end,
					set = function(info, val) CooldownTimeline.db.profile.fBarFrameSort = val end,
				},
				spacer10 = {
					name = "\n\n\n",
					type = "description",
					order = 10.1,
				},				
				fBarOnlyShowOverThreshold = {
					name = "Only show over threshold",
					desc = "Will only show a bar if the cooldown is active and is longer than the ignore threshold\nOnce the cooldown passes below the threshold it will disappear and the related icon will appear on the timeline",
					order = 10.2,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBarOnlyShowOverThreshold end,
					set = function(info, val) CooldownTimeline.db.profile.fBarOnlyShowOverThreshold = val end,
					width = "full",
				},
				fBarShowTimeToTransition = {
					name = "Transition indicator",
					desc = "You can show how long until the bar disappears and the related icon will appear on the timeline",
					order = 10.3,
					type = "select",
					hidden = function(info) return not CooldownTimeline.db.profile.fBarOnlyShowOverThreshold end,
					values = { ["NONE"] = "None",["SHORTEN"] = "Shorten", ["REGION"] = "Region", ["LINE"] = "Line" },
					get = function(info) return CooldownTimeline.db.profile.fBarShowTimeToTransition end,
					set = function(info, val) CooldownTimeline.db.profile.fBarShowTimeToTransition = val end,
				},
				fBarAlwaysShowOffensiveAuras = {
					name = "Always show offensive auras",
					desc = "Will always show offensive auras as a bar regardless of duration",
					order = 10.3,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBarAlwaysShowOffensiveAuras end,
					set = function(info, val) CooldownTimeline.db.profile.fBarAlwaysShowOffensiveAuras = val end,
					width = "full",
				},
				spacer11 = {
					name = "",
					type = "description",
					order = 11.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBarOnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBarShowTimeToTransition ~= "NONE" and CooldownTimeline.db.profile.fBarShowTimeToTransition ~= "SHORTEN" then
									return false
								end
							end
							
							return true
						end,
				},
				fBarTransitionTexture = {
					name = "Foreground Texture",
					desc = "Selects the texture",
					order = 11.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBarOnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBarShowTimeToTransition ~= "NONE" and CooldownTimeline.db.profile.fBarShowTimeToTransition ~= "SHORTEN" then
									return false
								end
							end
							
							return true
						end,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fBarTransitionTexture end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarTransitionTexture = val
							
							local r = CooldownTimeline.db.profile.fBarTransitionTextureColor["r"]
							local g = CooldownTimeline.db.profile.fBarTransitionTextureColor["g"]
							local b = CooldownTimeline.db.profile.fBarTransitionTextureColor["b"]
							local a = CooldownTimeline.db.profile.fBarTransitionTextureColor["a"]

							CooldownTimeline:RefreshBars()
						end,
				},
				fBarTransitionTextureColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 11.3,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBarOnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBarShowTimeToTransition ~= "NONE" and CooldownTimeline.db.profile.fBarShowTimeToTransition ~= "SHORTEN" then
									return false
								end
							end
							
							return true
						end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBarTransitionTextureColor["r"]
							local g = CooldownTimeline.db.profile.fBarTransitionTextureColor["g"]
							local b = CooldownTimeline.db.profile.fBarTransitionTextureColor["b"]
							local a = CooldownTimeline.db.profile.fBarTransitionTextureColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarTransitionTextureColor = { r = red, g = green, b = blue, a = alpha }
							
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer12 = {
					name = "",
					type = "description",
					order = 12.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBarOnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBarShowTimeToTransition == "LINE" then
									return false
								end
							end
							
							return true
						end,
				},
				fBarTransitionTextureWidth = {
					name = "Width",
					desc = "Sets the width of the bar",
					order = 12.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBarOnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBarShowTimeToTransition == "LINE" then
									return false
								end
							end
							
							return true
						end,
					type = "range",
					softMin = 0,
					softMax = 10,
					get = function(info) return CooldownTimeline.db.profile.fBarTransitionTextureWidth end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarTransitionTextureWidth = val
							local fBarTransitionTexture = CooldownTimeline.db.profile.fBarTransitionTexture
							
							CooldownTimeline:RefreshBars()
					end,
				},
				spacer16 = {
					name = "\n\n\n",
					type = "description",
					order = 16.1,
				},
				fBarFrameAnimateInType = {
					name = "On show animation",
					desc = "Select the animation played on show",
					order = 16.2,
					type = "select",
					values = { ["NONE"] = "None", ["FADE"] = "Fade" },
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateIn["type"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateIn["type"] = val
						end,
				},
				spacer17 = {
					name = "",
					type = "description",
					order = 17.1,
				},
				fBarFrameAnimateInStartValue = {
					name = "Start value",
					desc = "Value to start the animation at",
					order = 17.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateIn["startValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateIn["startValue"] = val
						end,
				},
				fBarFrameAnimateInEndValue = {
					name = "End value",
					desc = "Value to end the animation at",
					order = 17.3,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateIn["endValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateIn["endValue"] = val
						end,
				},
				spacer18 = {
					name = "",
					type = "description",
					order = 18.1,
				},
				fBarFrameAnimateInFinishValue = {
					name = "Finish value",
					desc = "Value to start the animation at",
					order = 18.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateIn["finishValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateIn["finishValue"] = val
						end,
				},
				fBarFrameAnimateInDuration = {
					name = "Duration",
					desc = "How long should the animation last",
					order = 18.3,
					type = "range",
					softMin = 0.1,
					softMax = 10,
					bigStep = 0.1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateIn["duration"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateIn["duration"] = val
						end,
				},
				spacer19 = {
					name = "",
					type = "description",
					order = 19.1,
				},
				fBarFrameAnimateInLoop = {
					name = "Number of loops (-1 will loop infinitely)",
					desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
					order = 19.2,
					type = "range",
					softMin = -1,
					softMax = 5,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateIn["loop"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateIn["loop"] = val
						end,
				},
				fBarFrameAnimateInBounce = {
					name = "Bounce animation",
					desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
					type = "toggle",
					order = 19.3,
					set = function(info,val) CooldownTimeline.db.profile.fBarFrameAnimateIn["bounce"] = val end,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateIn["bounce"] end,
				},
				spacer20 = {
					name = "\n\n",
					type = "description",
					order = 20.1,
				},
				fBarFrameAnimateOutType = {
					name = "On show animation",
					desc = "Select the animation played on show",
					order = 20.2,
					type = "select",
					values = { ["NONE"] = "None", ["FADE"] = "Fade" },
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateOut["type"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateOut["type"] = val
						end,
				},
				spacer21 = {
					name = "",
					type = "description",
					order = 21.1,
				},
				fBarFrameAnimateOutStartValue = {
					name = "Start value",
					desc = "Value to start the animation at",
					order = 21.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateOut["startValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateOut["startValue"] = val
						end,
				},
				fBarFrameAnimateOutEndValue = {
					name = "End value",
					desc = "Value to end the animation at",
					order = 21.3,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateOut["endValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateOut["endValue"] = val
						end,
				},
				spacer22 = {
					name = "",
					type = "description",
					order = 22.1,
				},
				fBarFrameAnimateOutFinishValue = {
					name = "Finish value",
					desc = "Value to start the animation at",
					order = 22.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateOut["finishValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateOut["finishValue"] = val
						end,
				},
				fBarFrameAnimateOutDuration = {
					name = "Duration",
					desc = "How long should the animation last",
					order = 22.3,
					type = "range",
					softMin = 0.1,
					softMax = 10,
					bigStep = 0.1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateOut["duration"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateOut["duration"] = val
						end,
				},
				spacer23 = {
					name = "",
					type = "description",
					order = 23.1,
				},
				fBarFrameAnimateOutLoop = {
					name = "Number of loops (-1 will loop infinitely)",
					desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
					order = 23.2,
					type = "range",
					softMin = -1,
					softMax = 5,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateOut["loop"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarFrameAnimateOut["loop"] = val
						end,
				},
				fBarFrameAnimateOutBounce = {
					name = "Bounce animation",
					desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
					type = "toggle",
					order = 23.3,
					set = function(info,val) CooldownTimeline.db.profile.fBarFrameAnimateOut["bounce"] = val end,
					get = function(info) return CooldownTimeline.db.profile.fBarFrameAnimateOut["bounce"] end,
				},
			}
		},
		optionsBarsBars = {
			name = "Bars",
			type = "group",
			order = 2.0,
			args = {
				fBarWidth = {
					name = "Width",
					desc = "Sets the width of the bar",
					order = 2.2,
					type = "range",
					softMin = 0,
					softMax = 600,
					get = function(info) return CooldownTimeline.db.profile.fBarWidth end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarWidth = val
							CooldownTimeline:RefreshBars()
					end,
				},
				fBarHeight = {
					name = "Height",
					desc = "Sets the height of the bar",
					order = 2.3,
					type = "range",
					softMin = 0,
					softMax = 100,
					get = function(info) return CooldownTimeline.db.profile.fBarHeight end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarHeight = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer5 = {
					name = "\n\n\n",
					type = "description",
					order = 5.1,
				},
				fBarBackground = {
					name = "Background Texture",
					desc = "Selects the texture",
					order = 5.2,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fBarBackground end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarBackground = val
							
							local r = CooldownTimeline.db.profile.fBarBackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fBarBackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fBarBackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fBarBackgroundColor["a"]
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarBackgroundColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 5.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBarBackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fBarBackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fBarBackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fBarBackgroundColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarBackgroundColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer6 = {
					name = "",
					type = "description",
					order = 6.1,
				},
				fBarTexture = {
					name = "Foreground Texture",
					desc = "Selects the texture",
					order = 6.2,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fBarTexture end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarTexture = val
							
							local r = CooldownTimeline.db.profile.fBarTextureColor["r"]
							local g = CooldownTimeline.db.profile.fBarTextureColor["g"]
							local b = CooldownTimeline.db.profile.fBarTextureColor["b"]
							local a = CooldownTimeline.db.profile.fBarTextureColor["a"]
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarTextureColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 6.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBarTextureColor["r"]
							local g = CooldownTimeline.db.profile.fBarTextureColor["g"]
							local b = CooldownTimeline.db.profile.fBarTextureColor["b"]
							local a = CooldownTimeline.db.profile.fBarTextureColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarTextureColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer60 = {
					name = "\n\n",
					type = "description",
					order = 6.4,
				},
				fBarShowIcon = {
					name = "Show Spell Icon",
					desc = "Turn spell icons on/off on the bar",
					type = "toggle",
					order = 6.5,
					set = function(info,val)
							CooldownTimeline.db.profile.fBarShowIcon = val
							CooldownTimeline:RefreshBars()
						end,
					get = function(info) return CooldownTimeline.db.profile.fBarShowIcon end,
				},
				fBarIconPosition = {
					name = "Icon Position",
					desc = "Where to show the icon",
					order = 6.6,
					type = "select",
					values = { ["LEFT"] = "Left", ["RIGHT"] = "Right" },
					get = function(info) return CooldownTimeline.db.profile.fBarIconPosition end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarIconPosition = val
							CooldownTimeline:RefreshBars()
						end,
				},
				--[[fBarUseIconAsTexture = {
					name = "Use Icon as Textures",
					desc = "Set the foreground/background bar textures to the icon",
					type = "toggle",
					order = 6.7,
					set = function(info,val)
							CooldownTimeline.db.profile.fBarUseIconAsTexture = val
							CooldownTimeline:RefreshBars()
						end,
					get = function(info) return CooldownTimeline.db.profile.fBarUseIconAsTexture end,
				},]]--
				spacer7 = {
					name = "\n\n",
					type = "description",
					order = 7.1,
				},
				fBarText1Text = {
					name = "Text 1",
					desc = function(info) return CooldownTimeline:GetCustomIconTagDescription() end,
					type = "input",
					order = 7.2,
					disabled = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					width = "double",
					get = function(info) return CooldownTimeline.db.profile.fBarText1["text"] end,
					set = function(info, val) CooldownTimeline.db.profile.fBarText1["text"] = val end,
				},
				fBarText1TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 7.3,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBarText1["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["enabled"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer8 = {
					name = "",
					type = "description",
					order = 8.1,
				},
				fBarText1TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 8.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fBarText1["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["font"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText1TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 8.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fBarText1["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["outline"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer9 = {
					name = "",
					type = "description",
					order = 9.1,
				},
				fBarText1TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 9.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fBarText1["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["size"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText1TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 9.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBarText1
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarText1["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText1ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 9.4,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBarText1
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarText1["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer10 = {
					name = "",
					type = "description",
					order = 10.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
				},
				fBarText1ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 10.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText1["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["shadowXOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText1ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 10.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText1["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["shadowYOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer11 = {
					name = "",
					type = "description",
					order = 11.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
				},
				fBarText1Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 11.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBarText1["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["anchor"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText1Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 11.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBarText1["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["align"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer12 = {
					name = "",
					type = "description",
					order = 12.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
				},
				fBarText1XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 12.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText1["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["xOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText1YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 12.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText1["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText1["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText1["yOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer13 = {
					name = "\n\n\n",
					type = "description",
					order = 13.1,
				},
				fBarText2Text = {
					name = "Text 2",
					desc = function(info) return CooldownTimeline:GetCustomIconTagDescription() end,
					type = "input",
					order = 13.2,
					disabled = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					width = "double",
					get = function(info) return CooldownTimeline.db.profile.fBarText2["text"] end,
					set = function(info, val) CooldownTimeline.db.profile.fBarText2["text"] = val end,
				},
				fBarText2TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 13.3,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBarText2["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["enabled"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer14 = {
					name = "",
					type = "description",
					order = 14.1,
				},
				fBarText2TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 14.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fBarText2["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["font"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText2TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 14.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fBarText2["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["outline"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer15 = {
					name = "",
					type = "description",
					order = 15.1,
				},
				fBarText2TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 15.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fBarText2["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["size"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText2TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 15.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBarText2
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarText2["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText2ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 15.4,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBarText2
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarText2["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer16 = {
					name = "",
					type = "description",
					order = 16.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
				},
				fBarText2ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 16.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText2["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["shadowXOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText2ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 16.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText2["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["shadowYOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer17  = {
					name = "",
					type = "description",
					order = 17.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
				},
				fBarText2Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 17.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBarText2["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["anchor"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText2Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 17.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBarText2["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["align"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer18 = {
					name = "",
					type = "description",
					order = 18.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
				},
				fBarText2XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 18.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText2["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["xOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText2YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 18.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText2["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText2["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText2["yOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer19 = {
					name = "\n\n\n",
					type = "description",
					order = 19.1,
				},
				fBarText3Text = {
					name = "Text 3",
					desc = function(info) return CooldownTimeline:GetCustomIconTagDescription() end,
					type = "input",
					order = 19.2,
					disabled = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					width = "double",
					get = function(info) return CooldownTimeline.db.profile.fBarText3["text"] end,
					set = function(info, val) CooldownTimeline.db.profile.fBarText3["text"] = val end,
				},
				fBarText3TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 19.3,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBarText3["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["enabled"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer20 = {
					name = "",
					type = "description",
					order = 20.1,
				},
				fBarText3TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 20.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fBarText3["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["font"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText3TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 20.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fBarText3["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["outline"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer21 = {
					name = "",
					type = "description",
					order = 21.1,
				},
				fBarText3TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 21.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fBarText3["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["size"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText3TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 21.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBarText3
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarText3["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText3ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 21.4,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBarText3
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBarText3["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer22 = {
					name = "",
					type = "description",
					order = 22.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
				},
				fBarText3ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 22.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText3["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["shadowXOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText3ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 22.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText3["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["shadowYOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer23  = {
					name = "",
					type = "description",
					order = 23.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
				},
				fBarText3Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 23.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBarText3["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["anchor"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText3Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 23.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBarText3["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["align"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer24 = {
					name = "",
					type = "description",
					order = 24.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
				},
				fBarText3XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 24.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText3["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["xOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBarText3YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 24.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBarText3["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBarText3["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBarText3["yOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
			}
		},
		optionsBars2Frame = {
			name = "OAURA Frame",
			type = "group",
			order = 3.0,
			args = {
				enableBar2 = {
					name = "Enabled",
					desc = "Enable a second set of bars for Offensive Auras",
					order = 1.1,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.enableBar2 end,
					set = function(info, val)
							CooldownTimeline.db.profile.enableBar2 = val
							
							if not CooldownTimeline_Bar2 then
								CooldownTimeline:CreateBar2Frame()
							end
						end,
				},
				--[[spacer2 = {
					name = "\n",
					type = "description",
					order = 2.1,
				},
				fBar2FrameWidth = {
					name = "Width",
					desc = "Sets the width of the bars frame",
					order = 2.2,
					type = "range",
					softMin = 0,
					softMax = 600,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameWidth end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameWidth = val
							CooldownTimeline.fBar2:SetWidth(val)
					end,
				},
				fBar2FrameHeight = {
					name = "Height",
					desc = "Sets the height of the bars frame",
					order = 2.3,
					type = "range",
					softMin = 0,
					softMax = 100,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameHeight end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameHeight = val
							CooldownTimeline.fBar2:SetHeight(val)
						end,
				},]]--
				spacer3 = {
					name = "\n",
					type = "description",
					order = 3.1,
				},
				fBar2FramePosX = {
					name = "x Pos",
					desc = "Sets the x co-rd for the OAURAs bars frame",
					order = 3.2,
					type = "range",
					softMin = -500,
					softMax = 500,
					get = function(info) return CooldownTimeline.db.profile.fBar2FramePosX end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FramePosX = val
							CooldownTimeline.fBar2:SetPoint(CooldownTimeline.db.profile.fBar2FrameRelativeTo, val, CooldownTimeline.db.profile.fBar2FramePosY)
						end,
				},
				fBar2FramePosY = {
					name = "y Pos",
					desc = "Sets the y co-rd for the OAURAs bars frame",
					order = 3.3,
					type = "range",
					softMin = -500,
					softMax = 500,
					get = function(info) return CooldownTimeline.db.profile.fBar2FramePosY end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FramePosY = val
							CooldownTimeline.fBar2:SetPoint(CooldownTimeline.db.profile.fBar2FrameRelativeTo, CooldownTimeline.db.profile.fBar2FramePosX, val)
						end,
				},
				spacer4 = {
					name = "",
					type = "description",
					order = 4.1,
				},
				fBar2FrameRelativeTo = {
					name = "Anchor Point",
					desc = "X/Y position is relative to this point of the screen",
					order = 4.2,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameRelativeTo end,
					set = function(info, val)
							CooldownTimeline.fBar2:ClearAllPoints()
							CooldownTimeline.db.profile.fBar2FrameRelativeTo = val
							CooldownTimeline.fBar2:SetPoint(val, CooldownTimeline.db.profile.fBar2FramePosX, CooldownTimeline.db.profile.fBar2FramePosY)
						end,
				},
				spacer41 = {
					name = "\n\n\n",
					type = "description",
					order = 4.3,
				},
				fBar2FramePadding = {
					name = "Frame Padding",
					desc = "Sets the overall frame padding",
					order = 4.4,
					type = "range",
					softMin = 0,
					softMax = 20,
					get = function(info) return CooldownTimeline.db.profile.fBar2FramePadding end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FramePadding = val
						end,
				},
				spacer5 = {
					name = "\n\n\n",
					type = "description",
					order = 5.1,
				},
				fBar2FrameBackground = {
					name = "Background Texture",
					desc = "Selects the texture",
					order = 5.2,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameBackground end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameBackground = val
							CooldownTimeline.fBar2.bg:SetTexture(SharedMedia:Fetch("statusbar", val))

							local r = CooldownTimeline.db.profile.fBar2FrameBackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fBar2FrameBackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fBar2FrameBackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fBar2FrameBackgroundColor["a"]
							CooldownTimeline.fBar2.bg:SetVertexColor(r, g, b, a)
						end,
				},
				fBar2FrameBackgroundColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 5.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBar2FrameBackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fBar2FrameBackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fBar2FrameBackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fBar2FrameBackgroundColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2FrameBackgroundColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline.fBar2.bg:SetVertexColor(red, green, blue, alpha)							
						end,
				},
				
				spacer6 = {
					name = "\n\n\n",
					type = "description",
					order = 6.1,
				},
				fBar2Border = {
					name = "                    Border Texture",
					desc = "Selects the texture",
					order = 6.2,
					type = "select",
					dialogControl = 'LSM30_Border',
					values = AceGUIWidgetLSMlists.border,
					get = function(info) return CooldownTimeline.db.profile.fBar2Border end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Border = val
							local fBar2BorderSize = CooldownTimeline.db.profile.fBar2BorderSize
							local fBar2BorderInset = CooldownTimeline.db.profile.fBar2BorderInset
							local fBar2BorderPadding = CooldownTimeline.db.profile.fBar2BorderPadding
							local fBar2BorderColor = CooldownTimeline.db.profile.fBar2BorderColor
							
							CooldownTimeline:SetBorder(CooldownTimeline.fBar2, val, fBar2BorderSize, fBar2BorderInset)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fBar2, fBar2BorderColor)
							CooldownTimeline:SetBorderPoint(CooldownTimeline.fBar2, fBar2BorderPadding)
						end,
				},
				fBar2BorderColor = {
					name = "Color",
					desc = "Selects the border color",
					order = 6.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBar2BorderColor["r"]
							local g = CooldownTimeline.db.profile.fBar2BorderColor["g"]
							local b = CooldownTimeline.db.profile.fBar2BorderColor["b"]
							local a = CooldownTimeline.db.profile.fBar2BorderColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2BorderColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline.fBar2.border:SetBackdropBorderColor(red, green, blue, alpha)
						end,
				},
				spacer7 = {
					name = "",
					type = "description",
					order = 7.1,
				},
				fBar2BorderSize = {
					name = "Size",
					desc = "Sets the size of the border",
					order = 7.2,
					type = "range",
					softMin = 1,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fBar2BorderSize end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2BorderSize = val
							local fBar2Border = CooldownTimeline.db.profile.fBar2Border
							local fBar2BorderInset = CooldownTimeline.db.profile.fBar2BorderInset
							local fBar2BorderPadding = CooldownTimeline.db.profile.fBar2BorderPadding
							local fBar2BorderColor = CooldownTimeline.db.profile.fBar2BorderColor
							
							CooldownTimeline:SetBorder(CooldownTimeline.fBar2, fBar2Border, val, fBar2BorderInset)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fBar2, fBar2BorderColor)
						end,
				},
				fBar2BorderPadding = {
					name = "Padding",
					desc = "Sets the size of the border",
					order = 7.3,
					type = "range",
					softMin = 0,
					softMax = 40,
					get = function(info) return CooldownTimeline.db.profile.fBar2BorderPadding end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2BorderPadding = val
							local fBar2BorderColor = CooldownTimeline.db.profile.fBar2BorderColor
							
							CooldownTimeline:SetBorderPoint(CooldownTimeline.fBar2, val)
							CooldownTimeline:SetBorderColor(CooldownTimeline.fBar2, fBar2BorderColor)
						end,
				},
				spacer8 = {
					name = "\n\n\n",
					type = "description",
					order = 8.1,
				},
				fBar2XPadding = {
					name = "x Padding",
					desc = "Each bar will be staggered horizontally by this amount",
					order = 8.2,
					type = "range",
					softMin = 0,
					softMax = 10,
					get = function(info) return CooldownTimeline.db.profile.fBar2XPadding end,
					set = function(info, val) CooldownTimeline.db.profile.fBar2XPadding = val end,
				},
				fBar2YPadding = {
					name = "y Padding",
					desc = "Each bar will be staggered vertically by this amount",
					order = 8.3,
					type = "range",
					softMin = 0,
					softMax = 10,
					get = function(info) return CooldownTimeline.db.profile.fBar2YPadding end,
					set = function(info, val) CooldownTimeline.db.profile.fBar2YPadding = val end,
				},
				spacer9 = {
					name = "\n\n\n",
					type = "description",
					order = 9.1,
				},
				fBar2FrameGrow = {
					name = "Grow direction",
					desc = "Grow Up or Down",
					order = 9.2,
					type = "select",
					values = { ["UP"] = "Up", ["CENTERED"] = "Centered", ["DOWN"] = "Down" },
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameGrow end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameGrow = val
							
							local fBarHeight = CooldownTimeline.db.profile.fBar2Height
							local fBarFramePosX = CooldownTimeline.db.profile.fBar2FramePosX
							local fBarFramePosY = CooldownTimeline.db.profile.fBar2FramePosY
							local fBarFrameRelativeTo = CooldownTimeline.db.profile.fBar2FrameRelativeTo
							local fBarFrameGrow = CooldownTimeline.db.profile.fBar2FrameGrow
							
							local anchorPoint = "CENTER"
							if fBarFrameGrow == "UP" then
								anchorPoint = "BOTTOM"
								fBarFramePosY = fBarFramePosY - (fBarHeight / 2)
							elseif fBarFrameGrow == "DOWN" then
								anchorPoint = "TOP"
								fBarFramePosY = fBarFramePosY + (fBarHeight / 2)
							end
							
							CooldownTimeline.fBar2:ClearAllPoints()
							CooldownTimeline.fBar2:SetPoint(anchorPoint, UIParent, fBarFrameRelativeTo, fBarFramePosX, fBarFramePosY)
						end,
				},
				fBar2FrameSort = {
					name = "Sort",
					desc = "Grow Up or Down",
					order = 9.3,
					type = "select",
					values = { ["NONE"] = "None", ["ASCENDING"] = "Ascending", ["DESCENDING"] = "Descending" },
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameSort end,
					set = function(info, val) CooldownTimeline.db.profile.fBar2FrameSort = val end,
				},
				spacer10 = {
					name = "\n\n\n",
					type = "description",
					order = 10.1,
				},				
				fBar2OnlyShowOverThreshold = {
					name = "Only show over threshold",
					desc = "Will only show a bar if the cooldown is active and is longer than the ignore threshold\nOnce the cooldown passes below the threshold it will disappear and the related icon will appear on the timeline",
					order = 10.2,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold end,
					set = function(info, val) CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold = val end,
					width = "full",
				},
				fBar2ShowTimeToTransition = {
					name = "Transition indicator",
					desc = "You can show how long until the bar disappears and the related icon will appear on the timeline",
					order = 10.3,
					type = "select",
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold end,
					values = { ["NONE"] = "None",["SHORTEN"] = "Shorten", ["REGION"] = "Region", ["LINE"] = "Line" },
					get = function(info) return CooldownTimeline.db.profile.fBar2ShowTimeToTransition end,
					set = function(info, val) CooldownTimeline.db.profile.fBar2ShowTimeToTransition = val end,
				},
				fBar2AlwaysShowOffensiveAuras = {
					name = "Always show offensive auras",
					desc = "Will always show offensive auras as a bar regardless of duration",
					order = 10.3,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBar2AlwaysShowOffensiveAuras end,
					set = function(info, val) CooldownTimeline.db.profile.fBar2AlwaysShowOffensiveAuras = val end,
					width = "full",
				},
				spacer11 = {
					name = "",
					type = "description",
					order = 11.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBar2ShowTimeToTransition ~= "NONE" and CooldownTimeline.db.profile.fBar2ShowTimeToTransition ~= "SHORTEN" then
									return false
								end
							end
							
							return true
						end,
				},
				fBar2TransitionTexture = {
					name = "Foreground Texture",
					desc = "Selects the texture",
					order = 11.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBar2ShowTimeToTransition ~= "NONE" and CooldownTimeline.db.profile.fBar2ShowTimeToTransition ~= "SHORTEN" then
									return false
								end
							end
							
							return true
						end,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fBar2TransitionTexture end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2TransitionTexture = val
							
							local r = CooldownTimeline.db.profile.fBar2TransitionTextureColor["r"]
							local g = CooldownTimeline.db.profile.fBar2TransitionTextureColor["g"]
							local b = CooldownTimeline.db.profile.fBar2TransitionTextureColor["b"]
							local a = CooldownTimeline.db.profile.fBar2TransitionTextureColor["a"]

							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2TransitionTextureColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 11.3,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBar2ShowTimeToTransition ~= "NONE" and CooldownTimeline.db.profile.fBar2ShowTimeToTransition ~= "SHORTEN" then
									return false
								end
							end
							
							return true
						end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBar2TransitionTextureColor["r"]
							local g = CooldownTimeline.db.profile.fBar2TransitionTextureColor["g"]
							local b = CooldownTimeline.db.profile.fBar2TransitionTextureColor["b"]
							local a = CooldownTimeline.db.profile.fBar2TransitionTextureColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2TransitionTextureColor = { r = red, g = green, b = blue, a = alpha }
							
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer12 = {
					name = "",
					type = "description",
					order = 12.1,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBar2ShowTimeToTransition == "LINE" then
									return false
								end
							end
							
							return true
						end,
				},
				fBar2TransitionTextureWidth = {
					name = "Width",
					desc = "Sets the width of the bar",
					order = 12.2,
					hidden = function(info)
							if CooldownTimeline.db.profile.fBar2OnlyShowOverThreshold then
								if CooldownTimeline.db.profile.fBar2ShowTimeToTransition == "LINE" then
									return false
								end
							end
							
							return true
						end,
					type = "range",
					softMin = 0,
					softMax = 10,
					get = function(info) return CooldownTimeline.db.profile.fBar2TransitionTextureWidth end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2TransitionTextureWidth = val
							local fBar2TransitionTexture = CooldownTimeline.db.profile.fBar2TransitionTexture
							
							CooldownTimeline:RefreshBars()
					end,
				},
				spacer16 = {
					name = "\n\n\n",
					type = "description",
					order = 16.1,
				},
				fBar2FrameAnimateInType = {
					name = "On show animation",
					desc = "Select the animation played on show",
					order = 16.2,
					type = "select",
					values = { ["NONE"] = "None", ["FADE"] = "Fade" },
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateIn["type"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateIn["type"] = val
						end,
				},
				spacer17 = {
					name = "",
					type = "description",
					order = 17.1,
				},
				fBar2FrameAnimateInStartValue = {
					name = "Start value",
					desc = "Value to start the animation at",
					order = 17.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateIn["startValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateIn["startValue"] = val
						end,
				},
				fBar2FrameAnimateInEndValue = {
					name = "End value",
					desc = "Value to end the animation at",
					order = 17.3,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateIn["endValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateIn["endValue"] = val
						end,
				},
				spacer18 = {
					name = "",
					type = "description",
					order = 18.1,
				},
				fBar2FrameAnimateInFinishValue = {
					name = "Finish value",
					desc = "Value to start the animation at",
					order = 18.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateIn["finishValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateIn["finishValue"] = val
						end,
				},
				fBar2FrameAnimateInDuration = {
					name = "Duration",
					desc = "How long should the animation last",
					order = 18.3,
					type = "range",
					softMin = 0.1,
					softMax = 10,
					bigStep = 0.1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateIn["duration"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateIn["duration"] = val
						end,
				},
				spacer19 = {
					name = "",
					type = "description",
					order = 19.1,
				},
				fBar2FrameAnimateInLoop = {
					name = "Number of loops (-1 will loop infinitely)",
					desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
					order = 19.2,
					type = "range",
					softMin = -1,
					softMax = 5,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateIn["loop"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateIn["loop"] = val
						end,
				},
				fBar2FrameAnimateInBounce = {
					name = "Bounce animation",
					desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
					type = "toggle",
					order = 19.3,
					set = function(info,val) CooldownTimeline.db.profile.fBar2FrameAnimateIn["bounce"] = val end,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateIn["bounce"] end,
				},
				spacer20 = {
					name = "\n\n",
					type = "description",
					order = 20.1,
				},
				fBar2FrameAnimateOutType = {
					name = "On show animation",
					desc = "Select the animation played on show",
					order = 20.2,
					type = "select",
					values = { ["NONE"] = "None", ["FADE"] = "Fade" },
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateOut["type"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateOut["type"] = val
						end,
				},
				spacer21 = {
					name = "",
					type = "description",
					order = 21.1,
				},
				fBar2FrameAnimateOutStartValue = {
					name = "Start value",
					desc = "Value to start the animation at",
					order = 21.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateOut["startValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateOut["startValue"] = val
						end,
				},
				fBar2FrameAnimateOutEndValue = {
					name = "End value",
					desc = "Value to end the animation at",
					order = 21.3,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateOut["endValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateOut["endValue"] = val
						end,
				},
				spacer22 = {
					name = "",
					type = "description",
					order = 22.1,
				},
				fBar2FrameAnimateOutFinishValue = {
					name = "Finish value",
					desc = "Value to start the animation at",
					order = 22.2,
					type = "range",
					softMin = 0,
					softMax = 1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateOut["finishValue"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateOut["finishValue"] = val
						end,
				},
				fBar2FrameAnimateOutDuration = {
					name = "Duration",
					desc = "How long should the animation last",
					order = 22.3,
					type = "range",
					softMin = 0.1,
					softMax = 10,
					bigStep = 0.1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateOut["duration"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateOut["duration"] = val
						end,
				},
				spacer23 = {
					name = "",
					type = "description",
					order = 23.1,
				},
				fBar2FrameAnimateOutLoop = {
					name = "Number of loops (-1 will loop infinitely)",
					desc = "Value to start the animation at (a value of -1 will loop the animation infinitely, and a value of 0 will not play the animation at all)",
					order = 23.2,
					type = "range",
					softMin = -1,
					softMax = 5,
					bigStep = 1,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateOut["loop"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2FrameAnimateOut["loop"] = val
						end,
				},
				fBar2FrameAnimateOutBounce = {
					name = "Bounce animation",
					desc = "If selected the animation will progress forward for a loop, and the backwards on the next loop",
					type = "toggle",
					order = 23.3,
					set = function(info,val) CooldownTimeline.db.profile.fBar2FrameAnimateOut["bounce"] = val end,
					get = function(info) return CooldownTimeline.db.profile.fBar2FrameAnimateOut["bounce"] end,
				},
			}
		},
		optionsBars2Bars = {
			name = "OAURA Bars",
			type = "group",
			order = 4.0,
			args = {
				fBar2Width = {
					name = "Width",
					desc = "Sets the width of the bar",
					order = 2.2,
					type = "range",
					softMin = 0,
					softMax = 600,
					get = function(info) return CooldownTimeline.db.profile.fBar2Width end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Width = val
							CooldownTimeline:RefreshBars()
					end,
				},
				fBar2Height = {
					name = "Height",
					desc = "Sets the height of the bar",
					order = 2.3,
					type = "range",
					softMin = 0,
					softMax = 100,
					get = function(info) return CooldownTimeline.db.profile.fBar2Height end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Height = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer5 = {
					name = "\n\n\n",
					type = "description",
					order = 5.1,
				},
				fBar2Background = {
					name = "Background Texture",
					desc = "Selects the texture",
					order = 5.2,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fBar2Background end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Background = val
							
							local r = CooldownTimeline.db.profile.fBar2BackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fBar2BackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fBar2BackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fBar2BackgroundColor["a"]
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2BackgroundColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 5.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBar2BackgroundColor["r"]
							local g = CooldownTimeline.db.profile.fBar2BackgroundColor["g"]
							local b = CooldownTimeline.db.profile.fBar2BackgroundColor["b"]
							local a = CooldownTimeline.db.profile.fBar2BackgroundColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2BackgroundColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer6 = {
					name = "",
					type = "description",
					order = 6.1,
				},
				fBar2Texture = {
					name = "Foreground Texture",
					desc = "Selects the texture",
					order = 6.2,
					type = "select",
					dialogControl = 'LSM30_Statusbar',
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return CooldownTimeline.db.profile.fBar2Texture end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Texture = val
							
							local r = CooldownTimeline.db.profile.fBar2TextureColor["r"]
							local g = CooldownTimeline.db.profile.fBar2TextureColor["g"]
							local b = CooldownTimeline.db.profile.fBar2TextureColor["b"]
							local a = CooldownTimeline.db.profile.fBar2TextureColor["a"]
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2TextureColor = {
					name = "Color",
					desc = "Selects the background color",
					order = 6.3,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local r = CooldownTimeline.db.profile.fBar2TextureColor["r"]
							local g = CooldownTimeline.db.profile.fBar2TextureColor["g"]
							local b = CooldownTimeline.db.profile.fBar2TextureColor["b"]
							local a = CooldownTimeline.db.profile.fBar2TextureColor["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2TextureColor = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer64 = {
					name = "\n\n",
					type = "description",
					order = 6.4,
				},
				fBar2ShowIcon = {
					name = "Show Spell Icon",
					desc = "Turn spell icons on/off on the bar",
					type = "toggle",
					order = 6.5,
					set = function(info,val)
							CooldownTimeline.db.profile.fBar2ShowIcon = val
							CooldownTimeline:RefreshBars()
						end,
					get = function(info) return CooldownTimeline.db.profile.fBar2ShowIcon end,
				},
				--[[fBar2UseIconAsTexture = {
					name = "Use Icon as Textures",
					desc = "Set the foreground/background bar textures to the icon",
					type = "toggle",
					order = 6.6,
					set = function(info,val)
							CooldownTimeline.db.profile.fBar2UseIconAsTexture = val
							CooldownTimeline:RefreshBars()
						end,
					get = function(info) return CooldownTimeline.db.profile.fBar2UseIconAsTexture end,
				},]]--
				fBar2IconPosition = {
					name = "Icon Position",
					desc = "Where to show the icon",
					order = 6.7,
					type = "select",
					values = { ["LEFT"] = "Left", ["RIGHT"] = "Right" },
					get = function(info) return CooldownTimeline.db.profile.fBar2IconPosition end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2IconPosition = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer7 = {
					name = "\n\n",
					type = "description",
					order = 7.1,
				},
				fBar2Text1Text = {
					name = "Text 1",
					desc = function(info) return CooldownTimeline:GetCustomIconTagDescription() end,
					type = "input",
					order = 7.2,
					disabled = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					width = "double",
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["text"] end,
					set = function(info, val) CooldownTimeline.db.profile.fBar2Text1["text"] = val end,
				},
				fBar2Text1TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 7.3,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["enabled"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer8 = {
					name = "",
					type = "description",
					order = 8.1,
				},
				fBar2Text1TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 8.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["font"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text1TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 8.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["outline"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer9 = {
					name = "",
					type = "description",
					order = 9.1,
				},
				fBar2Text1TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 9.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["size"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text1TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 9.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBar2Text1
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2Text1["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text1ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 9.4,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBar2Text1
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2Text1["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer10 = {
					name = "",
					type = "description",
					order = 10.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
				},
				fBar2Text1ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 10.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["shadowXOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text1ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 10.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["shadowYOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer11 = {
					name = "",
					type = "description",
					order = 11.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
				},
				fBar2Text1Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 11.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["anchor"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text1Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 11.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["align"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer12 = {
					name = "",
					type = "description",
					order = 12.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
				},
				fBar2Text1XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 12.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["xOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text1YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 12.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text1["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text1["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text1["yOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer13 = {
					name = "\n\n\n",
					type = "description",
					order = 13.1,
				},
				fBar2Text2Text = {
					name = "Text 2",
					desc = function(info) return CooldownTimeline:GetCustomIconTagDescription() end,
					type = "input",
					order = 13.2,
					disabled = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					width = "double",
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["text"] end,
					set = function(info, val) CooldownTimeline.db.profile.fBar2Text2["text"] = val end,
				},
				fBar2Text2TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 13.3,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["enabled"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer14 = {
					name = "",
					type = "description",
					order = 14.1,
				},
				fBar2Text2TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 14.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["font"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text2TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 14.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["outline"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer15 = {
					name = "",
					type = "description",
					order = 15.1,
				},
				fBar2Text2TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 15.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["size"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text2TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 15.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBar2Text2
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2Text2["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text2ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 15.4,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBar2Text2
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2Text2["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer16 = {
					name = "",
					type = "description",
					order = 16.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
				},
				fBar2Text2ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 16.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["shadowXOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text2ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 16.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["shadowYOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer17  = {
					name = "",
					type = "description",
					order = 17.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
				},
				fBar2Text2Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 17.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["anchor"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text2Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 17.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["align"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer18 = {
					name = "",
					type = "description",
					order = 18.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
				},
				fBar2Text2XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 18.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["xOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text2YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 18.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text2["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text2["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text2["yOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer19 = {
					name = "\n\n\n",
					type = "description",
					order = 19.1,
				},
				fBar2Text3Text = {
					name = "Text 3",
					desc = function(info) return CooldownTimeline:GetCustomIconTagDescription() end,
					type = "input",
					order = 19.2,
					disabled = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					width = "double",
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["text"] end,
					set = function(info, val) CooldownTimeline.db.profile.fBar2Text3["text"] = val end,
				},
				fBar2Text3TextEnabled = {
					name = "Enabled",
					desc = "Show this text",
					order = 19.3,
					type = "toggle",
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["enabled"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer20 = {
					name = "",
					type = "description",
					order = 20.1,
				},
				fBar2Text3TextFont = {
					name = "Font",
					desc = "Selects the font for text on the bars",
					order = 20.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "select",
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["font"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["font"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text3TextOutline = {
					name = "Outline",
					desc = "Sets the text outline",
					order = 20.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "select",
					values = {
							["NONE"] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome"
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["outline"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["outline"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer21 = {
					name = "",
					type = "description",
					order = 21.1,
				},
				fBar2Text3TextSize = {
					name = "Font Size",
					desc = "Sets the size of the font",
					order = 21.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "range",
					softMin = 0,
					softMax = 64,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["size"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["size"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text3TextColor = {
					name = "Color",
					desc = "Selects the font color",
					order = 21.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBar2Text3
							
							local r = t["color"]["r"]
							local g = t["color"]["g"]
							local b = t["color"]["b"]
							local a = t["color"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2Text3["color"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text3ShadowColor = {
					name = "Shadow Color",
					desc = "Selects the shadow color",
					order = 21.4,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local t = CooldownTimeline.db.profile.fBar2Text3
							
							local r = t["shadowColor"]["r"]
							local g = t["shadowColor"]["g"]
							local b = t["shadowColor"]["b"]
							local a = t["shadowColor"]["a"]
							return r, g, b, a
						end,
					set = function(info, red, green, blue, alpha)
							CooldownTimeline.db.profile.fBar2Text3["shadowColor"] = { r = red, g = green, b = blue, a = alpha }
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer22 = {
					name = "",
					type = "description",
					order = 22.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
				},
				fBar2Text3ShadowXOffset = {
					name = "Shadow x Offset",
					desc = "Sets the text shadow x offset",
					order = 22.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["shadowXOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["shadowXOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text3ShadowYOffset = {
					name = "Shadow y Offset",
					desc = "Sets the text shadow y offset",
					order = 22.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["shadowYOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["shadowYOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer23  = {
					name = "",
					type = "description",
					order = 23.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
				},
				fBar2Text3Anchor = {
					name = "Anchor",
					desc = "Sets the text anchor point",
					order = 23.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "select",
					values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOP"] = "TOP",
							["TOPRIGHT"] = "TOPRIGHT",
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOM"] = "BOTTOM",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["anchor"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["anchor"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text3Align = {
					name = "Align",
					desc = "Sets the text alignment",
					order = 23.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "select",
					values = {
							["LEFT"] = "LEFT",
							["CENTER"] = "CENTER",
							["RIGHT"] = "RIGHT",
						},
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["align"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["align"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				spacer24 = {
					name = "",
					type = "description",
					order = 24.1,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
				},
				fBar2Text3XOffset = {
					name = "x Offset",
					desc = "Sets text x offset",
					order = 24.2,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["xOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["xOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
				fBar2Text3YOffset = {
					name = "y Offset",
					desc = "Sets text y offset",
					order = 24.3,
					hidden = function(info) return not CooldownTimeline.db.profile.fBar2Text3["enabled"] end,
					type = "range",
					softMin = -5,
					softMax = 5,
					get = function(info) return CooldownTimeline.db.profile.fBar2Text3["yOffset"] end,
					set = function(info, val)
							CooldownTimeline.db.profile.fBar2Text3["yOffset"] = val
							CooldownTimeline:RefreshBars()
						end,
				},
			}
		},
		optionsBarsFilter = {
			name = "Filter",
			type = "group",
			order = 5.0,
			args = {
				filterDescription = {
					name = "Select the cooldowns you which to show a cooldown bar for\n\n",
					type = "description",
					order = 1.,
				},
				filterHeadingSpells = {
					name = "Spells",
					type = "header",
					order = 2.1,
				},
				filterSpellSelectAll = {
					name = "Select All",
					desc = "",
					order = 2.2,
					type = "execute",
					confirm = false,
					func = function(info)
							for key, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								spell["bar"] = true
							end
						end
				},
				filterSpellSelectNone = {
					name = "Select None",
					desc = "",
					order = 2.3,
					type = "execute",
					confirm = false,
					func = function(info)
							for key, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								spell["bar"] = false
							end
						end
				},
				filter = {
					name = "",
					desc = "",
					order = 2.4,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterFilterSpell = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterFilterSpell, displayName)
										break
									end
								end
							end

							return CooldownTimeline.characterFilterSpell
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFilterSpell[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								if spell["name"] == displayName then
									return spell["bar"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFilterSpell[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								if spell["name"] == displayName then
									spell["bar"] = val
									break
								end
							end
						end,
				},
				filterHeadingItems = {
					name = "Items",
					type = "header",
					order = 3.1,
				},
				filterItemsDescription1 = {
					name = "\nItems are listed below by the name of the spell cast on use, and many items wont actually generate an item\n",
					type = "description",
					order = 3.2,
				},
				filterItemsDescription2 = {
					name = "\nYou can remove old and unwanted item spells from the filters options panel\n\n",
					type = "description",
					order = 3.3,
				},
				filterItemsSelectAll = {
					name = "Select All",
					desc = "",
					order = 3.4,
					type = "execute",
					confirm = false,
					func = function(info)
							for key, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								spell["bar"] = true
							end
						end
				},
				filterItemsSelectNone = {
					name = "Select None",
					desc = "",
					order = 3.5,
					type = "execute",
					confirm = false,
					func = function(info)
							for key, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								spell["bar"] = false
							end
						end
				},
				filterItems = {
					name = "",
					desc = "",
					order = 3.6,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterFilterItems = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterFilterItems, displayName)
										break
									end
								end
							end

							return CooldownTimeline.characterFilterItems
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFilterItems[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								if spell["name"] == displayName then
									return spell["bar"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFilterItems[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								if spell["name"] == displayName then
									spell["bar"] = val
									break
								end
							end
						end,
				},
				filterHeadingAuras = {
					name = "Auras",
					type = "header",
					order = 4.1,
				},
				filterAurasSelectAll = {
					name = "Select All",
					desc = "",
					order = 4.2,
					type = "execute",
					confirm = false,
					func = function(info)
							for key, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								spell["bar"] = true
							end
						end
				},
				filterAurasSelectNone = {
					name = "Select None",
					desc = "",
					order = 4.3,
					type = "execute",
					confirm = false,
					func = function(info)
							for key, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								spell["bar"] = false
							end
						end
				},
				filterAuras = {
					name = "",
					desc = "",
					order = 4.4,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterFilterAuras = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["type"] == "BUFF" or spell["type"] == "DEBUFF" then
									table.insert(CooldownTimeline.characterFilterAuras, spell["name"])
								end
							end
							
							table.sort(CooldownTimeline.characterFilterAuras, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterFilterAuras
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFilterAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									return spell["bar"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFilterAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									spell["bar"] = val
									break
								end
							end
						end,
				},
				filterHeadingPetSpells = {
					name = "Pet Spells",
					type = "header",
					order = 5.1,
				},
				filterPetSpellSelectAll = {
					name = "Select All",
					desc = "",
					order = 5.2,
					type = "execute",
					confirm = false,
					func = function(info)
							for key, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								spell["bar"] = true
							end
						end
				},
				filterPetSpellSelectNone = {
					name = "Select None",
					desc = "",
					order = 5.3,
					type = "execute",
					confirm = false,
					func = function(info)
							for key, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								spell["bar"] = false
							end
						end
				},
				filterPetSpell = {
					name = "",
					desc = "",
					order = 5.4,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterFilterPet = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterFilterPet, displayName)
										break
									end
								end
							end

							return CooldownTimeline.characterFilterPet
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFilterPet[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								if spell["name"] == displayName then
									return spell["bar"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFilterPet[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								if spell["name"] == displayName then
									spell["bar"] = val
									break
								end
							end
						end,
				},
				fastlaneHeadingOffensiveAuras = {
					name = "Offensive Auras",
					type = "header",
					order = 6.1,
				},
				fastlaneOffensiveAuras = {
					name = "",
					desc = "",
					order = 6.2,
					type = "multiselect",
					--disabled = true,
					values = function(info)
							CooldownTimeline.characterFastLaneOAuras = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["type"] == "OAURA" then
									table.insert(CooldownTimeline.characterFastLaneOAuras, spell["name"])
								end
							end
							
							table.sort(CooldownTimeline.characterFastLaneOAuras, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterFastLaneOAuras
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFastLaneOAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									return spell["bar"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFastLaneOAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									spell["bar"] = val
									break
								end
							end
						end,
					
				},
			}
		},
	}
}

--[[local optionsHighlight = {
	name = "Highlights",
	handler = CooldownTimeline,
	type = 'group',
	args = {
		
	}
}]]--

local optionsFilter = {
	name = "",
	handler = CooldownTimeline,
	type = "group",
	childGroups  = "tab",
	args = {
		filtersWhitelist = {
			name = "Whitelist",
			type = "group",
			order = 1.1,
			args = {
				whitelistDescription = {
					name = "Unselect the tickbox to hide the respective icon on the timeline (and ready area)\n\n",
					type = "description",
					order = 1.2,
				},
				whitelistHeadingSpells = {
					name = "Spells",
					type = "header",
					order = 2.1,
				},
				whitelist = {
					name = "",
					desc = "",
					order = 2.2,
					type = "multiselect",
					--disabled = true,
					values = function(info)
							CooldownTimeline.characterFilterList = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterFilterList, displayName)
										break
									end
								end
							end

							return CooldownTimeline.characterFilterList
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFilterList[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								if spell["name"] == displayName then
									return spell["tracked"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFilterList[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								if spell["name"] == displayName then
									spell["tracked"] = val
									break
								end
							end
						end,
				},
				whitelistHeadingItems = {
					name = "Items",
					type = "header",
					order = 3.1,
				},
				whitelistItemsDescription1 = {
					name = "\nItems are listed below by the name of the spell cast on use, and many items wont actually generate an item\n",
					type = "description",
					order = 3.2,
				},
				whitelistItemsDescription2 = {
					name = "\nOver time you may gather items that are not longer required(quest items), or should not be listed(recipes).\n\nClicking the 'Clean Item Table' button will remove them - REQUIRES UI RELOAD\n\n",
					type = "description",
					order = 3.3,
				},
				whitelistItemsCleanButton = {
					name = "Clean Item Table",
					desc = "This will remove quest items, and any items clearly not meant to be tracked (such as recipes)\n\nRequires UI Reload",
					order = 3.4,
					type = "execute",
					confirm = true,
					func = function(info)
							CooldownTimeline.db.profile.needToCleanTable = true
							
							for key, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								local _, itemType, itemSubType, _, _, itemClassID, itemSubClassID = GetItemInfoInstant(spell["id"])
								
								if CooldownTimeline:IsValidItemType(itemType) then
									if not CooldownTimeline:IsBlacklisted("ITEM", spell["name"]) then
										table.insert(CooldownTimeline.db.profile.cleanTable, spell)
									end
								end
							end
							
							for key, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								CooldownTimeline.db.profile.whitelistItems[key] = nil
							end
							
							ReloadUI()
						end
				},
				whitelistItems = {
					name = "",
					desc = "",
					order = 3.5,
					type = "multiselect",
					--disabled = true,
					values = function(info)
							CooldownTimeline.characterFilterListItems = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterFilterListItems, displayName)
										break
									end
								end
							end

							return CooldownTimeline.characterFilterListItems
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFilterListItems[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								if spell["name"] == displayName then
									return spell["tracked"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFilterListItems[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								if spell["name"] == displayName then
									spell["tracked"] = val
									break
								end
							end
						end,
				},
				whitelistHeadingAuras = {
					name = "Auras",
					type = "header",
					order = 4.1,
				},
				whitelistAuras = {
					name = "",
					desc = "",
					order = 4.2,
					type = "multiselect",
					--disabled = true,
					values = function(info)
							CooldownTimeline.characterFilterListAuras = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["type"] == "BUFF" or spell["type"] == "DEBUFF" then
									table.insert(CooldownTimeline.characterFilterListAuras, spell["name"])
								end
							end
							
							table.sort(CooldownTimeline.characterFilterListAuras, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterFilterListAuras
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFilterListAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									return spell["tracked"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFilterListAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									spell["tracked"] = val
									break
								end
							end
						end,
				},
				whitelistHeadingPetSpells = {
					name = "Pet Spells",
					type = "header",
					order = 5.1,
				},
				whitelistPet = {
					name = "",
					desc = "",
					order = 5.2,
					type = "multiselect",
					--disabled = true,
					values = function(info)
							CooldownTimeline.characterFilterListPet = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterFilterListPet, displayName)
										break
									end
								end
							end

							return CooldownTimeline.characterFilterListPet
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFilterListPet[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								if spell["name"] == displayName then
									return spell["tracked"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFilterListPet[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								if spell["name"] == displayName then
									spell["tracked"] = val
									break
								end
							end
						end,
				},
				whitelistHeadingOffensiveAuras = {
					name = "Offensive Auras",
					type = "header",
					order = 6.1,
				},
				whitelistOffensiveAuras = {
					name = "",
					desc = "",
					order = 6.2,
					type = "multiselect",
					--disabled = true,
					values = function(info)
							CooldownTimeline.characterFilterListOAuras = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["type"] == "OAURA" then
									table.insert(CooldownTimeline.characterFilterListOAuras, spell["name"])
								end
							end
							
							table.sort(CooldownTimeline.characterFilterListOAuras, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterFilterListOAuras
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFilterListOAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									return spell["tracked"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFilterListOAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									spell["tracked"] = val
									break
								end
							end
						end,
				},
			}
		},
		filtersHighlight = {
			name = "Higlight",
			type = "group",
			order = 2,
			args = {
				highlightDescription = {
					name = "Select the cooldowns you which to highlight as importnant \n\n",
					type = "description",
					order = 1.,
				},
				highlightHeadingSpells = {
					name = "Spells",
					type = "header",
					order = 2.1,
				},
				highlight = {
					name = "",
					desc = "",
					order = 2.2,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterHighlightList = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterHighlightList, displayName)
										break
									end
								end
							end

							return CooldownTimeline.characterHighlightList
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterHighlightList[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								if spell["name"] == displayName then
									return spell["highlight"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterHighlightList[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								if spell["name"] == displayName then
									spell["highlight"] = val
									break
								end
							end
						end,
				},
				highlightHeadingItems = {
					name = "Items",
					type = "header",
					order = 3.1,
				},
				highlightItemsDescription1 = {
					name = "\nItems are listed below by the name of the spell cast on use, and many items wont actually generate an item\n",
					type = "description",
					order = 3.2,
				},
				highlightItemsDescription2 = {
					name = "\nYou can remove old and unwanted item spells from the filters options panel\n\n",
					type = "description",
					order = 3.3,
				},
				highlightItems = {
					name = "",
					desc = "",
					order = 3.5,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterHighlightItems = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterHighlightItems, displayName)
										break
									end
								end
							end

							return CooldownTimeline.characterHighlightItems
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterHighlightItems[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								if spell["name"] == displayName then
									return spell["highlight"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterHighlightItems[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								if spell["name"] == displayName then
									spell["highlight"] = val
									break
								end
							end
						end,
				},
				highlightHeadingAuras = {
					name = "Auras",
					type = "header",
					order = 4.1,
				},
				highlightAuras = {
					name = "",
					desc = "",
					order = 4.2,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterHighlightAuras = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["type"] == "BUFF" or spell["type"] == "DEBUFF" then
									table.insert(CooldownTimeline.characterHighlightAuras, spell["name"])
								end
							end
							
							table.sort(CooldownTimeline.characterHighlightAuras, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterHighlightAuras
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterHighlightAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									return spell["highlight"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterHighlightAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									spell["highlight"] = val
									break
								end
							end
						end,
				},
				highlightHeadingPetSpells = {
					name = "Pet Spells",
					type = "header",
					order = 5.1,
				},
				highlightPet = {
					name = "",
					desc = "",
					order = 5.2,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterHighlightPet = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterHighlightPet, displayName)
										break
									end
								end
							end

							return CooldownTimeline.characterHighlightPet
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterHighlightPet[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								if spell["name"] == displayName then
									return spell["highlight"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterHighlightPet[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								if spell["name"] == displayName then
									spell["highlight"] = val
									break
								end
							end
						end,
				},
				fastlaneHeadingOffensiveAuras = {
					name = "Offensive Auras",
					type = "header",
					order = 6.1,
				},
				fastlaneOffensiveAuras = {
					name = "",
					desc = "",
					order = 6.2,
					type = "multiselect",
					--disabled = true,
					values = function(info)
							CooldownTimeline.characterFastLaneOAuras = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["type"] == "OAURA" then
									table.insert(CooldownTimeline.characterFastLaneOAuras, spell["name"])
								end
							end
							
							table.sort(CooldownTimeline.characterFastLaneOAuras, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterFastLaneOAuras
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFastLaneOAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									return spell["highlight"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFastLaneOAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									spell["highlight"] = val
									break
								end
							end
						end,
					
				},
			}
		},
		filtersFastLane = {
			name = "Fast Lane",
			type = "group",
			order = 3,
			args = {
				fastlaneDescription = {
					name = "Select the cooldowns you which to show in the fastlane\n\n",
					type = "description",
					order = 1.,
				},
				fastlaneHeadingSpells = {
					name = "Spells",
					type = "header",
					order = 2.1,
				},
				fastlane = {
					name = "",
					desc = "",
					order = 2.2,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterFastLaneList = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterFastLaneList, displayName)
										break
									end
								end
							end
							
							table.sort(CooldownTimeline.characterFastLaneList, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterFastLaneList
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFastLaneList[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								if spell["name"] == displayName then
									return spell["fastlane"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFastLaneList[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelist) do
								if spell["name"] == displayName then
									spell["fastlane"] = val
									
									for _, icon in pairs(CooldownTimeline.iconTable) do
										if spell["name"] == icon.cdName then
											icon.fastlane = CooldownTimeline:SpellIsInFastLane(icon.cdName, icon.cdType)
											CooldownTimeline:SendToTimeline(icon)
											break
										end
									end
									
									break
								end
							end
						end,
				},
				fastlaneHeadingItems = {
					name = "Items",
					type = "header",
					order = 3.1,
				},
				fastlaneItemsDescription1 = {
					name = "\nItems are listed below by the name of the spell cast on use, and many items wont actually generate an item\n",
					type = "description",
					order = 3.2,
				},
				fastlaneItemsDescription2 = {
					name = "\nYou can remove old and unwanted item spells from the filters options panel\n\n",
					type = "description",
					order = 3.3,
				},
				fastlaneItems = {
					name = "",
					desc = "",
					order = 3.5,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterHighlightItems = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterHighlightItems, displayName)
										break
									end
								end
							end
							
							table.sort(CooldownTimeline.characterHighlightItems, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterHighlightItems
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterHighlightItems[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								if spell["name"] == displayName then
									return spell["fastlane"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterHighlightItems[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistItems) do
								if spell["name"] == displayName then
									spell["fastlane"] = val
									
									for _, icon in pairs(CooldownTimeline.iconTable) do
										if spell["name"] == icon.cdName then
											icon.fastlane = CooldownTimeline:SpellIsInFastLane(icon.cdName, icon.cdType)
											CooldownTimeline:SendToTimeline(icon)
											break
										end
									end
									
									break
								end
							end
						end,
				},
				fastlaneHeadingAuras = {
					name = "Auras",
					type = "header",
					order = 4.1,
				},
				fastlaneAuras = {
					name = "",
					desc = "",
					order = 4.2,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterFastLaneAuras = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["type"] == "BUFF" or spell["type"] == "DEBUFF" then
									table.insert(CooldownTimeline.characterFastLaneAuras, spell["name"])
								end
							end
							
							table.sort(CooldownTimeline.characterFastLaneAuras, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterFastLaneAuras
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFastLaneAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									return spell["fastlane"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFastLaneAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									spell["fastlane"] = val
									
									for _, icon in pairs(CooldownTimeline.iconTable) do
										if spell["name"] == icon.cdName then
											icon.fastlane = CooldownTimeline:SpellIsInFastLane(icon.cdName, icon.cdType)
											CooldownTimeline:SendToTimeline(icon)
											break
										end
									end
									
									break
								end
							end
						end,
				},
				fastlaneHeadingPetSpells = {
					name = "Pet Spells",
					type = "header",
					order = 5.1,
				},
				fastlanePet = {
					name = "",
					desc = "",
					order = 5.2,
					type = "multiselect",
					values = function(info)
							CooldownTimeline.characterHighlightPet = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								local displayName = spell["name"]
								for _, tSpell in pairs(CooldownTimeline.spellTable) do
									if displayName == tSpell["name"] then
										table.insert(CooldownTimeline.characterHighlightPet, displayName)
										break
									end
								end
							end
							
							table.sort(CooldownTimeline.characterHighlightPet, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterHighlightPet
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterHighlightPet[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								if spell["name"] == displayName then
									return spell["fastlane"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterHighlightPet[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistPet) do
								if spell["name"] == displayName then
									spell["fastlane"] = val
									
									for _, icon in pairs(CooldownTimeline.iconTable) do
										if spell["name"] == icon.cdName then
											icon.fastlane = CooldownTimeline:SpellIsInFastLane(icon.cdName, icon.cdType)
											CooldownTimeline:SendToTimeline(icon)
											break
										end
									end
									
									break
								end
							end
						end,
				},
				fastlaneHeadingOffensiveAuras = {
					name = "Offensive Auras",
					type = "header",
					order = 6.1,
				},
				fastlaneOffensiveAuras = {
					name = "",
					desc = "",
					order = 6.2,
					type = "multiselect",
					--disabled = true,
					values = function(info)
							CooldownTimeline.characterFastLaneOAuras = {}
							
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["type"] == "OAURA" then
									table.insert(CooldownTimeline.characterFastLaneOAuras, spell["name"])
								end
							end
							
							table.sort(CooldownTimeline.characterFastLaneOAuras, function(a, b)
								return a < b
							end)

							return CooldownTimeline.characterFastLaneOAuras
						end,
					get = function(info, index)
							local displayName = CooldownTimeline.characterFastLaneOAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									return spell["fastlane"]
								end
							end
						end,
					set = function(info, index, val)
							local displayName = CooldownTimeline.characterFastLaneOAuras[index]
							for _, spell in pairs(CooldownTimeline.db.profile.whitelistAuras) do
								if spell["name"] == displayName then
									spell["fastlane"] = val
									break
								end
							end
						end,
					
				},
			}
		},
	}
}

local defaults = {
    profile = {
		-- Default general values
		previousVersion = "2.5.2-20",
		debugFrame = false,
		showGCD = true,
		hideOutsideCombat = false,
		onlyShowWhenCoolingDown = false,
		unlockFrames = false,
		stringImportExport = "",
		
		trackSpellCooldowns = true,
		trackItemCooldowns = true,
		trackPetSpells = true,
		trackDebuffs = true,
		trackShortBuffs = true,
		trackOffensiveAuras = true,
		
		enableTimeline = true,
		enableReady = true,
		enableFastlane = true,
		enableBars = true,
		enableTooltips = true,
		
		attemptSharedCooldownDetection = true,
		sharedCooldownDetectionThreshold = 0.05,
		
		longIgnoreThreshold = 600,
		buffCaptureThreshold = 120,
		
		-- Default values for the Cooldown Icons
		fIconSize = 36,
		fIconFont = "",
		fIconFontSize = 13,
		fIconFontColor = { r = 1, g = 1, b = 1, a = 1 },
		fIconGlow = false,
		fIconTextOffset = 0,
		
		fIconText = {
			--enabled = true,
			text = "[cd.time]",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			align = "CENTER",
			--width = "",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
		},
		
		fIconFastlaneText = {
			--enabled = true,
			text = "[cd.time]",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			align = "CENTER",
			--width = "",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
		},
		
		fIconReadyText = {
			--enabled = true,
			text = "Ready",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			align = "CENTER",
			--width = "",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
		},
		
		fIconNotUsableOverride = true,
		fIconNotUsableDesaturate = false,
		fIconNotUsableColor = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
		
		fIconReadySound = "None",
		fIconReadyHighlightSound = "None",
		
		fIconBorder = "None",
		fIconBorderColor = { r = 1, g = 1, b = 1, a = 1 },
		fIconBorderSize = 5,
		fIconBorderPadding = 2,
		fIconBorderInset = 0,
		
		fIconHighlightBorder = "",
		fIconHighlightBorderColor = { r = 1, g = 1, b = 1, a = 1 },
		fIconHighlightBorderSize = 5,
		fIconHighlightBorderPadding = 2,
		fIconHighlightBorderInset = 0,

		fIconHighlightPin = false;
		fIconHighlightEffect = "NONE";

		fIconAnimateIn = false,
		fIconAnimateOut = false,
		fIconAnimateInType = "FADE",
		fIconAnimateOutType = "FADE",
	
		-- Default values for the Ready Frame
		fReadyRelativeTo = "CENTER",
		fReadyPosX = 0,
        fReadyPosY = 50,
		fReadyTexture = "",
		fReadyTextureColor = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
		fReadyIconSize = 48,
		fReadyFramePadding = 10,
		fReadyIconPadding = 0,
		fReadyIconDuration = 5,
		fReadyIconHighlightDuration = 10,
		fReadyIconGrow = "CENTER",
		fReadyVertical = true,
		fReadyIgnoreUnequipped = false,
		
		fReadyBorder = "None",
		fReadyBorderColor = { r = 1, g = 1, b = 1, a = 1 },
		fReadyBorderSize = 5,
		fReadyBorderPadding = 2,
		fReadyBorderInset = 0,
		
		fReadyAnimateIn = false,
		fReadyAnimateOut = false,
		fReadyAnimateInType = "FADE",
		fReadyAnimateOutType = "FADE",
		
		fReadyAnimateInNew = {
			type = "FADE",
			duration = 0.3,
			startValue = 0,
			endValue = 1,
			finishValue = 1,
			loop = 1,
			bounce = false,
		},
		fReadyAnimateOutNew = {
			type = "FADE",
			duration = 0.3,
			startValue = 1,
			endValue = 0,
			finishValue = 0,
			loop = 1,
			bounce = false,
		},
		
		-- Default values for the Timeline Frame
		fTimelineTracking = "NONE",
		fTimelineTrackingReverse = false;
		fTimelineTrackingInvert = false;
		fTimelineMode = "SPLIT_ABS",
		fTimelineIconReverseDirection = false;
		fTimelineStack = true,
		fTimelineStackOverlap = true,
		fTimelineStackMaxSize = 36,
		fTimelineIconOffset = 0,
		
		fTimelineModeAbsLimit = 180,
		
		fTimelineModeSplitAbsCount = 3,
		fTimelineModeSplitAbs1 = 10,
		fTimelineModeSplitAbs2 = 60,
		fTimelineModeSplitAbs3 = 180,
		fTimelineModeSplitAbsLimit = 600,
		
		fTimelineModeSplitCount = 3,
		fTimelineModeSplit1 = 5,
		fTimelineModeSplit2 = 20,
		fTimelineModeSplit3 = 50,
		fTimelineModeSplitLimit = 100,
		
		fTimelineTrackingSecondary = "NONE",
		fTimelineTrackingReverseSecondary = false;
		fTimelineTrackingInvertSecondary = false;
		fTimelineTrackingSecondaryTexture = "",
		fTimelineTrackingSecondaryTextureColor = { r = 1, g = 1, b = 1, a = 1 },
		fTimelineTrackingSecondaryHeight = 50;
		fTimelineTrackingSecondaryWidth = 5;
		
		fTimelineAnimateIn = false,
		fTimelineAnimateOut = false,
		fTimelineAnimateInType = "FADE",
		fTimelineAnimateOutType = "FADE",
		
		fTimelineAnimateInNew = {
			type = "FADE",
			duration = 0.3,
			startValue = 0,
			endValue = 1,
			finishValue = 1,
			loop = 1,
			bounce = false,
		},
		fTimelineAnimateOutNew = {
			type = "FADE",
			duration = 0.3,
			startValue = 1,
			endValue = 0,
			finishValue = 0,
			loop = 1,
			bounce = false,
		},
		
		fTimelineFonts = {
			--enabled = true,
			--text = "",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			--align = "LEFT",
			--width = "",
			--anchor = "LEFT",
			--xOffset = 0,
			yOffset = 0,
		},
		
		fTimelineText = {},
		fTimelineTextCustom = {},
		
		fTimelineRelativeTo = "CENTER",
		fTimelinePosX = 0,
        fTimelinePosY = -100,
        fTimelineWidth = 400,
        fTimelineHeight = 50,
		
		fTimelineBackground = "",
		fTimelineBackgroundColor = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
		fTimelineTexture = "",
		fTimelineTextureColor = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
		
		fTimelineBorder = "None",
		fTimelineBorderColor = { r = 1, g = 1, b = 1, a = 1 },
		fTimelineBorderSize = 5,
		fTimelineBorderPadding = 2,
		fTimelineBorderInset = 0,
				
		-- Default values for the Tooltip
		fTooltipText = {
			enabled = true,
			text = "",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			--align = "LEFT",
			--width = "",
			--anchor = "LEFT",
			--xOffset = 0,
			--yOffset = 0,
		},
		
		fTooltipPadding = 10,
		fTooltipTexture = "",
		fTooltipTextureColor = { r = 1, g = 1, b = 1, a = 1 },
		fTooltipRelativeTo = "BOTTOMLEFT",
		
		fTooltipBorder = "None",
		fTooltipBorderColor = { r = 1, g = 1, b = 1, a = 1 },
		fTooltipBorderSize = 5,
		fTooltipBorderPadding = 2,
		fTooltipBorderInset = 0,
		
		-- Default values for the Fast Lane Frame
		fFastlaneIconSize = 24;
		fFastlaneFont = "",
		fFastlaneFontSize = 13,
		fFastlaneFontColor = { r = 1, g = 1, b = 1, a = 1 },
		fFastlaneRelativeTo = "CENTER",
		fFastlanePosX = 0,
        fFastlanePosY = -50,
        fFastlaneWidth = 400,
        fFastlaneHeight = 24,
		fFastlaneBackground = "",
		fFastlaneBackgroundColor = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
		fFastlaneBorder = "None",
		fFastlaneBorderColor = { r = 1, g = 1, b = 1, a = 1 },
		fFastlaneBorderSize = 5,
		fFastlaneBorderPadding = 2,
		fFastlaneBorderInset = 0,
		fFastlaneSkipReady = true,
		fFastlaneIconOffset = 0,
		
		fFastlaneAnimateIn = {
			type = "FADE",
			duration = 0.3,
			startValue = 0,
			endValue = 1,
			finishValue = 1,
			loop = 1,
			bounce = false,
		},
		fFastlaneAnimateOut = {
			type = "FADE",
			duration = 0.3,
			startValue = 1,
			endValue = 0,
			finishValue = 0,
			loop = 1,
			bounce = false,
		},
		
		-- Default values for the Bar/Cooldown Bar Frame
		fBarFramePosX = -300,
		fBarFramePosY = 0,
		fBarFrameRelativeTo = "CENTER",
		fBarFrameWidth = 150,
		fBarFrameHeight = 30,
		fBarFrameBackground = "",
		fBarFrameBackgroundColor = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
		fBarFrameGrow = "DOWN",
		fBarFrameSort = "NONE",
		fBarFramePadding = 10;
		
		fBarFrameAnimateIn = {
			type = "FADE",
			duration = 1,
			startValue = 0,
			endValue = 1,
			finishValue = 1,
			loop = 1,
			bounce = false,
		},
		fBarFrameAnimateOut = {
			type = "FADE",
			duration = 1,
			startValue = 1,
			endValue = 0,
			finishValue = 0,
			loop = 1,
			bounce = false,
		},
		
		fBarBorder = "None",
		fBarBorderColor = { r = 1, g = 1, b = 1, a = 1 },
		fBarBorderSize = 5,
		fBarBorderPadding = 2,
		fBarBorderInset = 0,
		
		fBarOnlyShowOverThreshold = true,
		fBarShowTimeToTransition = "NONE",
		fBarAlwaysShowOffensiveAuras = true,
		
		fBarXPadding = 0,
		fBarYPadding = 0,
		fBarDirectionReverse = false,
		
		fBarWidth = 150,
		fBarHeight = 30,
		fBarTexture = "",
		fBarTextureColor = { r = 1, g = 1, b = 1, a = 1 },
		fBarBackground = "",
		fBarBackgroundColor = { r = 1, g = 1, b = 1, a = 1 },
		fBarUseIconAsTexture = false,
		
		fBarText1 = {
			enabled = true,
			text = "",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			align = "LEFT",
			width = "",
			anchor = "LEFT",
			xOffset = 0,
			yOffset = 0,
		},
		fBarText2 = {
			enabled = true,
			text = "",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			align = "CENTER",
			width = "",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
		},
		fBarText3 = {
			enabled = true,
			text = "",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			align = "RIGHT",
			width = "",
			anchor = "RIGHT",
			xOffset = 0,
			yOffset = 0,
		},
		
		fBarFontXOffset = 0,
		fBarFontYOffset = 0,
		fBarFontOutline = "OUTLINE",
		fBarFontShadowColor = { r = 1, g = 1, b = 1, a = 1 },
		fBarFontShadowXOffset = 1,
		fBarFontShadowYOffset = -1,
		fBarFontAnchor = "",
		
		fBarShowIcon = true,
		fBarIconPosition = "LEFT",
		
		fBarTransitionIndicator = true,
		fBarTransitionTexture = "Solid",
		fBarTransitionTextureColor = { r = 1, g = 0, b = 0, a = 0.1 },
		fBarTransitionTextureWidth = 5,
		fBarTransitionTextureHeight = 15,
		
		enableBar2 = true,
		fBar2FramePosX = -300,
		fBar2FramePosY = 0,
		fBar2FrameRelativeTo = "CENTER",
		fBar2FrameWidth = 150,
		fBar2FrameHeight = 30,
		fBar2FrameBackground = "",
		fBar2FrameBackgroundColor = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
		fBar2FrameGrow = "DOWN",
		fBar2FrameSort = "NONE",
		fBar2FramePadding = 10;
		
		fBar2FrameAnimateIn = {
			type = "FADE",
			duration = 1,
			startValue = 0,
			endValue = 1,
			finishValue = 1,
			loop = 1,
			bounce = false,
		},
		fBar2FrameAnimateOut = {
			type = "FADE",
			duration = 1,
			startValue = 1,
			endValue = 0,
			finishValue = 0,
			loop = 1,
			bounce = false,
		},
		
		fBar2Border = "None",
		fBar2BorderColor = { r = 1, g = 1, b = 1, a = 1 },
		fBar2BorderSize = 5,
		fBar2BorderPadding = 2,
		fBar2BorderInset = 0,
		
		fBar2OnlyShowOverThreshold = true,
		fBar2ShowTimeToTransition = "NONE",
		fBar2AlwaysShowOffensiveAuras = true,
		
		fBar2XPadding = 0,
		fBar2YPadding = 0,
		fBar2DirectionReverse = false,
		
		fBar2Width = 150,
		fBar2Height = 30,
		fBar2Texture = "",
		fBar2TextureColor = { r = 1, g = 1, b = 1, a = 1 },
		fBar2Background = "",
		fBar2BackgroundColor = { r = 1, g = 1, b = 1, a = 1 },
		fBar2UseIconAsTexture = false,
		
		fBar2Text1 = {
			enabled = true,
			text = "",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			align = "LEFT",
			width = "",
			anchor = "LEFT",
			xOffset = 0,
			yOffset = 0,
		},
		fBar2Text2 = {
			enabled = true,
			text = "",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			align = "CENTER",
			width = "",
			anchor = "CENTER",
			xOffset = 0,
			yOffset = 0,
		},
		fBar2Text3 = {
			enabled = true,
			text = "",
			font = "",
			size = 12,
			color = { r = 1, g = 1, b = 1, a = 1 },
			outline = "NONE",
			shadowColor = { r = 0, g = 0, b = 0, a = 1 },
			shadowXOffset = 0,
			shadowYOffset = 0,
			align = "RIGHT",
			width = "",
			anchor = "RIGHT",
			xOffset = 0,
			yOffset = 0,
		},
		
		fBar2FontXOffset = 0,
		fBar2FontYOffset = 0,
		fBar2FontOutline = "OUTLINE",
		fBar2FontShadowColor = { r = 1, g = 1, b = 1, a = 1 },
		fBar2FontShadowXOffset = 1,
		fBar2FontShadowYOffset = -1,
		fBar2FontAnchor = "",
		
		fBar2ShowIcon = true,
		fBar2IconPosition = "LEFT",
		
		fBar2TransitionIndicator = true,
		fBar2TransitionTexture = "Solid",
		fBar2TransitionTextureColor = { r = 1, g = 0, b = 0, a = 0.1 },
		fBar2TransitionTextureWidth = 5,
		fBar2TransitionTextureHeight = 15,
		
		whitelist = {},
		whitelistPet = {},
		whitelistItems = {},
		whitelistAuras = {},
		
		needToCleanTable = false,
		cleanTable = {},
		
		cleanSpells = false,
		cleanPetSpells = false,
		cleanItems = false,
		cleanAuras = false,
    }
}

function CooldownTimeline:OnInitialize()
    -- Called when the addon is loaded
	self.db = LibStub("AceDB-3.0"):New("CooldownTimelineDB", defaults, true)
	self.registry = LibStub("AceConfigRegistry-3.0")
	self.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CooldownTimeline", options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CooldownTimelineReady", optionsReady)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CooldownTimelineTimeline", optionsTimeline)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CooldownTimelineIcons", optionsIcons)
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CooldownTimelineFastlane", optionsFastlane)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CooldownTimelineBars", optionsBars)
	
	--LibStub("AceConfig-3.0"):RegisterOptionsTable("CooldownTimelineHighlight", optionsHighlight)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CooldownTimelineFilters", optionsFilter)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CooldownTimelineProfiles", self.profile)
	
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CooldownTimeline", "Cooldown Timeline")
	self.optionsFrame.oIcons = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CooldownTimelineIcons", "Icons", "Cooldown Timeline")
	self.optionsFrame.oReady = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CooldownTimelineReady", "Ready", "Cooldown Timeline")
	self.optionsFrame.oTimeline = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CooldownTimelineTimeline", "Timeline", "Cooldown Timeline")
	
	self.optionsFrame.oFastlane = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CooldownTimelineFastlane", "Fast Lane", "Cooldown Timeline")
	self.optionsFrame.oBars = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CooldownTimelineBars", "Bars", "Cooldown Timeline")
	
	--self.optionsFrame.oHighlight = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CooldownTimelineHighlight", "Highlight", "Cooldown Timeline")
	self.optionsFrame.oFilter = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CooldownTimelineFilters", "Filters", "Cooldown Timeline")
	self.optionsFrame.profile = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CooldownTimelineProfiles", "Profiles", "Cooldown Timeline")
	
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	
    self:RegisterChatCommand("cdtl", "ChatCommand")
    self:RegisterChatCommand("cooldowntimeline", "ChatCommand")
end

function CooldownTimeline:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("LEARNED_SPELL_IN_TAB")
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("UNIT_POWER_FREQUENT")
	self:RegisterEvent("UNIT_POWER_UPDATE")
	
	if self.db.profile.debugFrame then
		self:CreateDebugFrame()
	end
	
	local _
	self.playerClass, _, _ = UnitClass("player")
	
	-- Create the frames
	if CooldownTimeline.db.profile.enableTimeline then
		self:CreateTimelineFrame()
	end	
	
	if CooldownTimeline.db.profile.enableReady then
		self:CreateReadyFrame()
	end	
	
	if CooldownTimeline.db.profile.enableFastlane then
		self:CreateFastlaneFrame()
	end
	
	if CooldownTimeline.db.profile.enableBars then
		self:CreateBarFrame()
		self:CreateBarHoldingFrame()
		
		if CooldownTimeline.db.profile.enableBar2 then
			self:CreateBar2Frame()
		end
	end
	
	if CooldownTimeline.db.profile.enableTooltips then
		self:CreateTooltipFrame()
	end
	
	-- Finish the table clean as needed
	if CooldownTimeline.db.profile.needToCleanTable then
		-- Add all the cleaned values back in
		for _, item in pairs(CooldownTimeline.db.profile.cleanTable) do
			table.insert(CooldownTimeline.db.profile.whitelistItems, item)
		end
		
		-- Clear the cleanTable
		CooldownTimeline.db.profile.cleanTable = {}
		CooldownTimeline.db.profile.needToCleanTable = false
	end
	
	self:CreateHoldingFrame()
	self:CreateInactiveFrame()
	self:CreateActiveFrame()
	self:CreateAnimationFrame()
	
	-- Called when the addon is enabled
	self:ScanSpellbook()
	self:ScanInventory()
	self:ScanAuraTable()

	self:ScanCurrentCooldowns()
	
	self:Print("Loaded version: "..version)
	self:Print("Type /cdtl or /cooldowntimeline for options ")
end

function CooldownTimeline:OnDisable()
    -- Called when the addon is disabled
end

function CooldownTimeline:COMBAT_LOG_EVENT_UNFILTERED()
	local _, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _ = CombatLogGetCurrentEventInfo()
	local playerID = UnitGUID("player")
	local targetID = UnitGUID("target")
	local petID
	
	local petExists = UnitExists("pet")
	if petExists then
		CooldownTimeline:ScanPetSpellbook()
		petID = UnitGUID("pet")
	end
	
	if sourceGUID == playerID or destGUID == playerID or sourceGUID == petID then
		-- SPELL_CAST_SUCCESS --
		if subevent == "SPELL_CAST_SUCCESS" then
			local _, spellName, _, _, _, _, _, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())

			for k, v in pairs(CooldownTimeline.spellTable) do
				if v["name"] == spellName then
					--CooldownTimeline:Print(spellName)
					local matchFound, matchFrame = self:CheckExistingIcons(v["name"])
					
					if matchFound then
						if matchFrame.hasCooldown then
							CooldownTimeline:SendToTimeline(matchFrame)
						end
					else
						if v["type"] == "PETSPELL" then
							local baseDuration, _ = GetSpellBaseCooldown(v["id"])
							local _,_,spellIcon,_,_,_,_ = GetSpellInfo(v["id"])
							
							local data = {}
							data["name"] = spellName
							data["type"] = v["type"]
							data["id"] = v["id"]
							
							-- Stop searching as we have a match
							self:CreateCooldownIcon(data)
							break
						end
					end
				end
			end
			
		-- SPELL_AURA_APPLIED --
		elseif subevent == "SPELL_AURA_APPLIED" then
				local _, spellName, _, _, _, _, _, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
				
				if self.db.profile.debugFrame then
					if destGUID == targetID then
						local name, realm = UnitName("target")
						CooldownTimeline:Print("aura applied - "..spellName.." - to "..name)
					else
						CooldownTimeline:Print("aura applied - "..spellName.." - to player")
					end
				end
				
				if destGUID == playerID then
					-- Scan through buffs to determin if we should track it
					if self.db.profile.trackShortBuffs then
						for i = 1, 40, 1 do
							local name, _, _, _, duration, expirationTime, _, _,  _, spellId, _, _, _, _, _ = UnitBuff("player", i)
							if name then
								if name == spellName then
									if duration <= self.db.profile.buffCaptureThreshold and duration > 1.5 then
										local auraType = "BUFF"
										
										-- If we havent seen this yet, then we need to add it to our database
										if not CooldownTimeline:CheckWhitelistForDoubles(spellName, "AURA") then
											table.insert(self.db.profile.whitelistAuras, { type = auraType, id = spellId, tracked = true, highlight = false, name = spellName })
										end
									
										local matchFound, matchFrame = self:CheckExistingIcons(auraType.."_"..spellName)
										
										if matchFound then
											if matchFrame.hasCooldown then
												CooldownTimeline:SendToTimeline(matchFrame)
											end
										else
											local data = {}
											data["name"] = auraType.."_"..spellName
											data["type"] = auraType
											data["id"] = spellId
											
											self:CreateCooldownIcon(data)
										end
										
										break
									end
								end
							end
						end
					end
					
					-- Tackle specific known auras
					if self.db.profile.trackDebuffs then
						for _, aura in pairs(CooldownTimeline.aurasToTrack) do
							if spellName == aura["name"] and destGUID == playerID then
								--CooldownTimeline:Print(spellName)
								local matchFound, matchFrame = self:CheckExistingIcons(spellName)
								
								if matchFound then
									if matchFrame.hasCooldown then
										CooldownTimeline:SendToTimeline(matchFrame)
									end
								else
									local data = {}
									data["name"] = aura["name"]
									data["type"] = aura["type"]
									data["id"] = aura["id"]
									
									self:CreateCooldownIcon(data)
								end
								
								break
							end
						end
					end
				elseif destGUID == targetID then
					if self.db.profile.trackOffensiveAuras then
						for i = 1, 40, 1 do
							local name, _, _, _, duration, expirationTime, _, _,  _, spellId, _, _, _, _, _ = UnitDebuff("target", i)
							if name then
								if name == spellName then
									local auraType = "OAURA"
									
									-- If we havent seen this yet, then we need to add it to our database
									if not CooldownTimeline:CheckWhitelistForDoubles(spellName, "OAURA") then
										table.insert(self.db.profile.whitelistAuras, { type = auraType, id = spellId, tracked = true, highlight = false, name = spellName })
									end
								
									local matchFound, matchFrame = self:CheckExistingIcons(auraType.."_"..spellName)
									
									if matchFound then
										if matchFrame.hasCooldown then
											CooldownTimeline:SendToTimeline(matchFrame)
											matchFrame.target = destGUID
										end
									else
										local data = {}
										data["name"] = auraType.."_"..spellName
										data["type"] = auraType
										data["id"] = spellId
										data["target"] = destGUID
										
										self:CreateCooldownIcon(data)
									end
									
									break
								end
							end
						end
					end
				end
				
			
		-- SWING_DAMAGE --
		elseif subevent == "SWING_DAMAGE" then
			local amount, _, _, _, _, _, _, _, _, isOffHand = select(12, CombatLogGetCurrentEventInfo())
			local mhSpeed, ohSpeed = UnitAttackSpeed("player")
			
			if not isOffHand then
				--CooldownTimeline:Print("SWING_DAMAGE - MH - "..tostring(amount))
				CooldownTimeline.fTimeline.mhSwingTime = mhSpeed
				CooldownTimeline.fTimeline.mhSwinging = true
			end
		
		-- SWING_MISSED --
		elseif subevent == "SWING_MISSED" then
			local _, isOffHand, _, _ = select(12, CombatLogGetCurrentEventInfo())
			local mhSpeed, ohSpeed = UnitAttackSpeed("player")
			
			if not isOffHand then
				--CooldownTimeline:Print("SWING_MISSED - MH - "..tostring(amount))
				CooldownTimeline.fTimeline.mhSwingTime = mhSpeed
				CooldownTimeline.fTimeline.mhSwinging = true
			end
		end
	end
	
	-- SPELL_AURA_REMOVED --
	if self.db.profile.trackOffensiveAuras then
		--CooldownTimeline:Print("Found target aura removal - 1")
		if sourceGUID == playerID then
			if subevent == "SPELL_AURA_REMOVED" then
				local _, spellName, _, _, _, _, _, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
				
				--CooldownTimeline:Print(spellName.." - "..sourceGUID.."("..tostring(targetID)..")")
				
				--local matchFound, matchFrame = self:CheckExistingIcons("OAURA_"..spellName)
				
				for k, v in pairs(CooldownTimeline.iconTable) do
					if v ~= nil then
						--CooldownTimeline:Print("   - "..v:GetName():gsub("CooldownTimeline_", ""))
						if v.cdType == "OAURA" then
							if destGUID == v.target then
								--CooldownTimeline:Print(spellName.." fades from target")
								v.cdRemaining = 0
							end
						end
					end
				end
			end
		end
	end
end

function CooldownTimeline:PLAYER_REGEN_DISABLED()
	--CooldownTimeline:Print("Combat")
	CooldownTimeline.inCombat = true
end

function CooldownTimeline:PLAYER_REGEN_ENABLED()
	--CooldownTimeline:Print("No Combat")
	self.inCombat = false
	
	if self.db.profile.fIconHighlightPin then
		self.fReady.outOfCombatTimer = self.db.profile.fReadyIconHighlightDuration
	end
end

function CooldownTimeline:BAG_UPDATE()
	CooldownTimeline:ScanInventory()
	--CooldownTimeline:Print("BAG_UPDATE")
end

function CooldownTimeline:LEARNED_SPELL_IN_TAB()
	CooldownTimeline:ScanSpellbook()
	--CooldownTimeline:Print("LEARNED_SPELL_IN_TAB")
end

function CooldownTimeline:SPELL_UPDATE_COOLDOWN()
	if self.db.profile.enableTimeline then
		CooldownTimeline.fTimeline.onGCD = true
		--CooldownTimeline:Print("SPELL_UPDATE_COOLDOWN")
	end
end

function CooldownTimeline:UNIT_POWER_FREQUENT(...)
	local _, unitTarget, powerType = ...
	
	if unitTarget == "player" and self.db.profile.enableTimeline then
		if powerType == "MANA" then
			self.fTimeline.manaMax = UnitPowerMax("player", Enum.PowerType.Mana)
			
			local currentTime = GetTime()
			local currentMana = UnitPower("player", Enum.PowerType.Mana)
			local maxMana = UnitPowerMax("player", Enum.PowerType.Mana)
			local difference = currentMana - self.fTimeline.manaPrevious
			local timeDifference = 0
			
			if self.fTimeline.manaPreviousTickTime then
				timeDifference = currentTime - self.fTimeline.manaPreviousTickTime
			end
			
			-- Start the five second rule
			if difference < 0 then
				self.fTimeline.fiveSecondRule = true
				self.fTimeline.manaTickTime = 6
				self.fTimeline.manaTickInterval = 6
				self.fTimeline.manaPreviousTickTime = currentTime
			end			
			
			-- Check for normal ticks and re-sync
			if difference > 0 then
				local low = 0.1
				local high = 1.9
				
				if self.fTimeline.fiveSecondRule then
					high = 4.9
				end
				
				if timeDifference < low or  timeDifference > high then
					self.fTimeline.manaTickTime = 2
					self.fTimeline.manaTickInterval = 2
					self.fTimeline.manaPreviousTickTime = currentTime
				end
			end
			
			self.fTimeline.manaPrevious = currentMana
		end
	end
end

function CooldownTimeline:UNIT_POWER_UPDATE(...)
	local _, unitTarget, powerType = ...
	--CooldownTimeline:Print("UNIT_POWER_UPDATE - "..GetTime())
	--CooldownTimeline:Print(unitTarget.." - "..powerType)
	
	if unitTarget == "player" and self.db.profile.enableTimeline  then
		if powerType == "ENERGY" then
			self.fTimeline.energyMax = UnitPowerMax("player", Enum.PowerType.Energy)
			
			local current = UnitPower("player", Enum.PowerType.Energy)
			local difference = current - self.fTimeline.energyPrevious
			
			if current < self.fTimeline.energyMax then
				local difference = current - self.fTimeline.energyPrevious
				if (difference > 18 and difference < 22) or (difference > 38 and difference < 42) then
					self.fTimeline.energyLastTickTime = GetTime()
				end
			end
			
			self.fTimeline.energyPrevious = current
		end
	end
end

function CooldownTimeline:ITEM_LOCK_CHANGED(...)
	-- Detect item lock cooldowns
	-- Most commonly trinkets being equipped, that will begin a 30 second cooldown
	local _, bagOrSlotIndex, slotIndex = ...
	
	if slotIndex == nil then
		--CooldownTimeline:Print("Inventory: "..bagOrSlotIndex)
		local itemId = GetInventoryItemID("player", bagOrSlotIndex)
		local itemName = C_Item.GetItemNameByID(itemId)
		local spellName, spellID = GetItemSpell(itemId)
		local start, duration, enabled = GetItemCooldown(itemId)
		
		if duration ~= 0 then
			local matchFound, matchFrame = self:CheckExistingIcons(spellName)
			
			if matchFound then
				if matchFrame.hasCooldown then
					CooldownTimeline:SendToTimeline(matchFrame)
				end
			else
				local data = {}
				data["name"] = spellName
				data["type"] = "ITEM"
				data["id"] = itemId
				
				self:CreateCooldownIcon(data)
			end
		end
	end
	--CooldownTimeline:Print("ITEM_LOCK_CHANGED")
end

function CooldownTimeline:UNIT_SPELLCAST_SUCCEEDED(...)
	local _, unitTarget, castGUID, spellID = ...
	
	-- Lets find a matched spell in our collection
	if unitTarget == "player" then
		if self.db.profile.debugFrame then
			CooldownTimeline:Print("SUCCEEDED - "..unitTarget.." - "..castGUID.." - "..spellID)
		end
		
		-- Special case for autoshot
		if spellID == 75 then
			local rSwingTime, _, _, _, _, _ = UnitRangedDamage("player");
			
			CooldownTimeline.fTimeline.rSwingTime = rSwingTime
			CooldownTimeline.fTimeline.rSwinging = true
		end
	
		for _, spell in pairs(CooldownTimeline.spellTable) do
			--if spell["type"] == "SPELL" or spell["type"] == "PETSPELL" then
			if spell["type"] == "SPELL" then
				if self.db.profile.trackSpellCooldowns then
					if spell["id"] == spellID then
						local matchFound, matchFrame = self:CheckExistingIcons(spell["name"])
						--CooldownTimeline:Print("spell name: "..spell["name"])
						
						if matchFound then
							CooldownTimeline:SendToTimeline(matchFrame)
							CooldownTimeline:CheckEdgeCases(spell["name"])
							
							break
						else
							--local baseDuration, _ = GetSpellBaseCooldown(spellID)
							--local _,_,spellIcon,_,_,_,_ = GetSpellInfo(spellID)
							
							local data = {}
							data["name"] = spell["name"]
							data["type"] = spell["type"]
							data["id"] = spell["id"]
							
							-- Stop searching as we have a match
							self:CreateCooldownIcon(data)
							CooldownTimeline:CheckEdgeCases(spell["name"])
							
							break
						end
					end
				end
			elseif spell["type"] == "ITEM" then
				if self.db.profile.trackItemCooldowns then
					--CooldownTimeline:Print("ITEM - "..spell["sid"].." - "..spellID)
					if spell["sid"] == spellID then
						
						local matchFound, matchFrame = self:CheckExistingIcons(spell["name"])
						
						if matchFound then
							-- Some item spell names are common, but had different spell ids
							-- Lets update the icon to the currently used item (eg. different health potions with different icons)
							for _, spell in pairs(CooldownTimeline.spellTable) do
								if spell["type"] == "ITEM" then
									local _, existingSpellID = GetItemSpell(spell["id"])
									
									if spellID == existingSpellID then
										matchFrame.cdID = spell["id"]
										matchFrame.cdIcon = GetItemIcon(matchFrame.cdID)
										matchFrame.tex:SetTexture(matchFrame.cdIcon)
										break
									end
								end
							end
							
							CooldownTimeline:SendToTimeline(matchFrame)
						else
							local data = {}
							data["name"] = spell["name"]
							data["type"] = spell["type"]
							data["id"] = spell["id"]
							
							-- Stop searching as we have a match
							self:CreateCooldownIcon(data)
							break
						end
					end
				end
			end
			
			-- Attempt to track offensive abilities on a target such as DoTs
			if self.db.profile.trackOffensiveAuras then
				
			end
		end
	end
end

function CooldownTimeline:UNIT_SPELLCAST_FAILED(...)
	local _, unitTarget, castGUID, spellID = ...
	
	if self.db.profile.debugFrame then
		local name, _, _, _, _, _ = GetSpellInfo(spellID)
		
		CooldownTimeline:Print("FAILED - "..unitTarget.." - "..castGUID.." - "..name)
	end
end

function CooldownTimeline:CreateTestCooldownIcon(name, icon, cooldown)
	local frameName = name.."_"..cooldown
	
	
	local matchFound, matchFrame = self:CheckExistingIcons(frameName)
	if matchFound then
		matchFrame.start = GetTime()
		CooldownTimeline:SendToTimeline(matchFrame)
	else
		local f
		local fIconSize = self.db.profile.fIconSize
		
		if Masque then
			f = CreateFrame("Button", "CooldownTimeline_"..name, CooldownTimeline_Timeline, BackdropTemplateMixin and "BackdropTemplate" or nil)
			f:EnableMouse(false)
			f:SetSize(fIconSize, fIconSize)
			f:SetPoint("CENTER",0,0)
			
			f.tex = f:CreateTexture()
			f.tex:SetAllPoints(f)
			f.tex:SetTexture(132386)
			
			CooldownTimeline.masqueGroup = Masque:Group("CooldownTimeline")
			CooldownTimeline.masqueGroup:AddButton(f, { Icon = f.tex })		
		else
			f = CreateFrame("Frame", "CooldownTimeline_"..name, CooldownTimeline_Timeline, BackdropTemplateMixin and "BackdropTemplate" or nil)
			f:SetPoint("CENTER", self.db.profile.fTimelineWidth, 0)
			f:SetSize(fIconSize, fIconSize)
		
			f.tex = f:CreateTexture()
			f.tex:SetAllPoints(f)
			f.tex:SetTexture(icon)
		end
		
		f.cdUniqueID = CooldownTimeline:AssignUniqueID()
		if self.db.profile.debugFrame then
			f.textID = f:CreateFontString(nil,"ARTWORK")
			f.textID:SetFont("Fonts\\ARIALN.ttf", 10, "OUTLINE")
			f.textID:SetPoint("TOPLEFT",2,-2)
			f.textID:SetText(f.cdUniqueID)
		end
		
		f.hasCooldown = true
		f.updateCount = 0
		f.readyStart = 0
		
		f.text = f:CreateFontString(nil,"ARTWORK")
		f.text:SetFont(SharedMedia:Fetch("font", self.db.profile.fIconFont), self.db.profile.fIconFontSize, "OUTLINE")
		f.text:SetPoint("CENTER",0,0)
		f.text:SetText("0.0")
		
		f.iconIsHolding = false
		f.readyTimerRunning = false
		f.readyTimerStart = 0
		
		f.start = GetTime()
		f.duration = cooldown
		f.cdRemaining = 0
		
		f.yOffset = 0
		
		-- Set the icon border
		local fIconBorderInset = self.db.profile.fIconBorderInset
		local fIconBorderPadding = self.db.profile.fIconBorderPadding
		
		f.border = CreateFrame("Frame", frameName.."_Border",f , BackdropTemplateMixin and "BackdropTemplate" or nil)
		f.border:SetParent(f)
		f.border:SetPoint("TOPLEFT", f, "TOPLEFT", -fIconBorderPadding, fIconBorderPadding)
		f.border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", fIconBorderPadding, -fIconBorderPadding)
		
		f.border:SetBackdrop({
			bgFile = SharedMedia:Fetch("background", "None"),
			edgeFile = SharedMedia:Fetch("border", self.db.profile.fIconBorder),
			tile = false,
			tileSize = 0,
			edgeSize = CooldownTimeline.db.profile.fIconBorderSize,
			insets = { left = fIconBorderInset, right = fIconBorderInset, top = fIconBorderInset, bottom = fIconBorderInset }
		})
		
		local r = CooldownTimeline.db.profile.fIconBorderColor["r"]
		local g = CooldownTimeline.db.profile.fIconBorderColor["g"]
		local b = CooldownTimeline.db.profile.fIconBorderColor["b"]
		local a = CooldownTimeline.db.profile.fIconBorderColor["a"]
		f.border:SetBackdropBorderColor(r, g, b, a)
		
		-- Set the icon hightlight border
		local fIconHighlightBorderInset = self.db.profile.fIconHighlightBorderInset
		local fIconHighlightBorderPadding = self.db.profile.fIconHighlightBorderPadding
		
		f.highlightBorder = CreateFrame("Frame", frameName.."_HL_Border", f, BackdropTemplateMixin and "BackdropTemplate" or nil)
		f.highlightBorder:SetParent(f)
		f.highlightBorder:SetPoint("TOPLEFT", f, "TOPLEFT", -fIconHighlightBorderPadding, fIconHighlightBorderPadding)
		f.highlightBorder:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", fIconHighlightBorderPadding, -fIconHighlightBorderPadding)
		
		f.highlightBorder:SetBackdrop({
			bgFile = SharedMedia:Fetch("background", "None"),
			edgeFile = SharedMedia:Fetch("border", self.db.profile.fIconHighlightBorder),
			tile = false,
			tileSize = 0,
			edgeSize = CooldownTimeline.db.profile.fIconHighlightBorderSize,
			insets = { left = fIconHighlightBorderInset, right = fIconHighlightBorderInset, top = fIconHighlightBorderInset, bottom = fIconHighlightBorderInset }
		})
		
		local r = CooldownTimeline.db.profile.fIconHighlightBorderColor["r"]
		local g = CooldownTimeline.db.profile.fIconHighlightBorderColor["g"]
		local b = CooldownTimeline.db.profile.fIconHighlightBorderColor["b"]
		local a = CooldownTimeline.db.profile.fIconHighlightBorderColor["a"]
		f.highlightBorder:SetBackdropBorderColor(r, g, b, a)
		
		f.highlightBorder:SetAlpha(0)
		
		f:HookScript("OnUpdate", function(self,elapsed)
			f.readyTimerDuration = CooldownTimeline.db.profile.fReadyIconDuration
			if not f.iconIsHolding then
				self.cdRemaining = (f.start + f.duration) - GetTime()
				local timeLeftDisplay = CooldownTimeline:ConvertToReadableTime(self.cdRemaining)
				
				if self.cdRemaining >= 0 then
					if f:GetParent():GetName() == "CooldownTimeline_Timeline" then
						f.text:SetText(timeLeftDisplay)
						
						local fIconSize = CooldownTimeline.db.profile.fIconSize
						
						local mode = CooldownTimeline.db.profile.fTimelineMode
						local position
						if mode == "LINEAR" then
							position = CooldownTimeline:CalcLinearPercentPosition(self.cdRemaining, cooldown, fIconSize)
						elseif mode == "LINEAR_ABS" then
							position = CooldownTimeline:CalcLinearAbsolutePosition(self.cdRemaining, nil)
						elseif mode == "SPLIT" then
							position = CooldownTimeline:CalcSplitAbsolutePosition(self.cdRemaining)
						end
						
						local iconRelativeTo = "RIGHT"
				
						if CooldownTimeline.db.profile.fTimelineIconReverseDirection then
							iconRelativeTo = "LEFT"
						end
						
						f:SetPoint(iconRelativeTo, position - CooldownTimeline.db.profile.fTimelineWidth, self.yOffset)
					end
				elseif f.readyTimerRunning then
					if (f.readyTimerStart + f.readyTimerDuration) - GetTime() < 0 then
						CooldownTimeline:SendToHolding(f)
					end
				else
					CooldownTimeline:SendToReady(f)
					f.readyTimerRunning = true
					f.readyTimerStart = GetTime()
				end
			end
		end)
		
		table.insert(CooldownTimeline.iconTable, f)
	end
end

function CooldownTimeline:CreateInactiveFrame()
	self.fInactive = CreateFrame("Frame", "CooldownTimeline_Inactive", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.fInactive:SetPoint("CENTER", UIParent, "CENTER", 0, 400)
	self.fInactive:SetSize(50, 50)

	self.fInactive:HookScript("OnUpdate", function(self,elapsed)
		-- Show frame and its contents for debug purposes
		if CooldownTimeline.db.profile.debugFrame then
			CooldownTimeline.fInactive:SetAlpha(1)
			
			-- Count the children
			local children = { CooldownTimeline.fInactive:GetChildren() }
			
			local childCount = 0
			
			-- Count and position them
			for _, child in ipairs(children) do
				-- A positive value will grow to the right
				local position = CooldownTimeline.db.profile.fReadyIconSize * childCount
				
				child:ClearAllPoints()
				child:SetPoint("CENTER", position, 0)
								
				childCount = childCount + 1
			end
			
			-- Make the frame appear nice
			local xOffset = 0
			if childCount > 0 then
				xOffset = (CooldownTimeline.db.profile.fReadyIconSize * (childCount - 1)) / 2
			end
			self:ClearAllPoints()
			self:SetPoint("CENTER", -xOffset, 400)
			
			self.text:ClearAllPoints()
			self.text:SetPoint("CENTER", xOffset, CooldownTimeline.db.profile.fReadyIconSize)
			self.text:SetText("*** Inactive ("..childCount..") ***")
		else
			CooldownTimeline.fInactive:SetAlpha(0)
		end
	end)
	
	self.fInactive.text = self.fInactive:CreateFontString(nil,"ARTWORK")
	self.fInactive.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fInactive.text:SetPoint("CENTER", 0, (CooldownTimeline.db.profile.fReadyIconSize / 2) + 5)
	self.fInactive.text:SetText("*** Inactive ***")
end

function CooldownTimeline:CreateHoldingFrame()
	self.fHolding = CreateFrame("Frame", "CooldownTimeline_Holding", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.fHolding:SetPoint("CENTER", 0, 300)
	self.fHolding:SetSize(50, 50)
	
	self.fHolding:HookScript("OnUpdate", function(self,elapsed)
		-- Show frame and its contents for debug purposes
		if CooldownTimeline.db.profile.debugFrame then
			CooldownTimeline.fHolding:SetAlpha(1)
			
			-- Count the children
			local children = { CooldownTimeline.fHolding:GetChildren() }
			
			local childCount = 0
			
			-- Count and position them
			for _, child in ipairs(children) do
				-- A positive value will grow to the right
				local position = CooldownTimeline.db.profile.fReadyIconSize * childCount
				
				child:ClearAllPoints()
				child:SetPoint("CENTER", position, 0)
				
				childCount = childCount + 1
			end
			
			-- Make the frame appear nice
			local xOffset = 0
			if childCount > 0 then
				xOffset = (CooldownTimeline.db.profile.fReadyIconSize * (childCount - 1)) / 2
			end
			self:ClearAllPoints()
			self:SetPoint("CENTER", -xOffset, 300)
			
			self.text:ClearAllPoints()
			self.text:SetPoint("CENTER", xOffset, CooldownTimeline.db.profile.fReadyIconSize)
			self.text:SetText("*** Holding ("..childCount..") ***")
			
		else
			CooldownTimeline.fHolding:SetAlpha(0)
		end
	end)
	
	self.fHolding.text = self.fHolding:CreateFontString(nil,"ARTWORK")
	self.fHolding.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fHolding.text:SetPoint("CENTER", 0, (CooldownTimeline.db.profile.fReadyIconSize / 2) + 5)
	self.fHolding.text:SetText("*** Holding ***")
end

function CooldownTimeline:CreateBarHoldingFrame()
	self.fBarHolding = CreateFrame("Frame", "CooldownTimeline_BarHolding", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.fBarHolding:SetPoint("CENTER", -600, 0)
	self.fBarHolding:SetWidth(self.db.profile.fBarWidth)
	self.fBarHolding:SetHeight(self.db.profile.fBarHeight)
	
	self.fBarHolding:HookScript("OnUpdate", function(self,elapsed)
		-- Show frame and its contents for debug purposes
		if CooldownTimeline.db.profile.debugFrame then
			CooldownTimeline.fBarHolding:SetAlpha(1)
			
			-- Count the children
			local children = { CooldownTimeline.fBarHolding:GetChildren() }
			local childCount = 0
			
			-- Count and position them
			for _, child in ipairs(children) do
				local xPosition = 0
				local yPosition = CooldownTimeline.db.profile.fBarHeight * childCount
				
				local xPadding = CooldownTimeline.db.profile.fBarXPadding * childCount
				local yPadding = CooldownTimeline.db.profile.fBarYPadding * childCount
				
				child:ClearAllPoints()
				child:SetPoint("CENTER", xPosition + xPadding, -yPosition + -yPadding)
				
				childCount = childCount + 1
			end
			
			self.text:ClearAllPoints()
			self.text:SetPoint("TOPLEFT", 0, 15)
			self.text:SetText("*** Bar Holding ("..childCount..") ***")
			
		else
			CooldownTimeline.fBarHolding:SetAlpha(0)
		end
	end)
	
	self.fBarHolding.text = self.fBarHolding:CreateFontString(nil,"ARTWORK")
	self.fBarHolding.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fBarHolding.text:SetPoint("TOPLEFT", 0, 15)
	self.fBarHolding.text:SetText("*** Bar Holding ***")
end

function CooldownTimeline:CreateActiveFrame()
	self.fActive = CreateFrame("Frame", "CooldownTimeline_Active", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.fActive:SetPoint("CENTER", 0, 200)
	self.fActive:SetSize(50, 50)

	self.fActive:HookScript("OnUpdate", function(self,elapsed)
		-- Show frame and its contents for debug purposes
		if CooldownTimeline.db.profile.debugFrame then
			CooldownTimeline.fActive:SetAlpha(1)
			
			-- Count the children
			local children = { CooldownTimeline.fActive:GetChildren() }
			
			local childCount = 0
			for _, child in ipairs(children) do
				-- A positive value will grow to the right
				local position = CooldownTimeline.db.profile.fReadyIconSize * childCount
				
				child:ClearAllPoints()
				child:SetPoint("CENTER", position, 0)
				
				childCount = childCount + 1
			end
			
			-- Make the frame appear nice
			local xOffset = 0
			if childCount > 0 then
				xOffset = (CooldownTimeline.db.profile.fReadyIconSize * (childCount - 1)) / 2
			end
			self:ClearAllPoints()
			self:SetPoint("CENTER", -xOffset, 200)
			
			self.text:ClearAllPoints()
			self.text:SetPoint("CENTER", xOffset, CooldownTimeline.db.profile.fReadyIconSize)
			self.text:SetText("*** Active ("..childCount..") ***")
			
		else
			CooldownTimeline.fActive:SetAlpha(0)
		end
	end)
	
	self.fActive.text = self.fActive:CreateFontString(nil,"ARTWORK")
	self.fActive.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fActive.text:SetPoint("CENTER", 0, (CooldownTimeline.db.profile.fReadyIconSize / 2) + 5)
	self.fActive.text:SetText("*** Active ***")
end

function CooldownTimeline:CreateTooltipFrame()
	self.fTooltip = CreateFrame("Frame", "CooldownTimeline_Tooltip", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.fTooltip:SetPoint("CENTER", 0, 100)
	self.fTooltip:SetSize(50, 50)
	self.fTooltip:SetFrameStrata("TOOLTIP")
	
	self.fTooltip.cdUniqueID = 904
	
	self.fTooltip:SetBackdrop({
		bgFile = "Interface/DialogFrame/UI-DialogBox-Background", 
		edgeFile = nil, tile = true, tileSize = 32, edgeSize = 0, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	
	local t =  self.db.profile.fTooltipText
	self.fTooltip.text = self.fTooltip:CreateFontString(nil,"ARTWORK")
	self.fTooltip.text:SetFont(CooldownTimeline.SharedMedia:Fetch("font", t["font"]), t["size"], t["outline"])
	self.fTooltip.text:SetTextColor(
		t["color"]["r"],
		t["color"]["g"],
		t["color"]["b"],
		t["color"]["a"]
	)
	self.fTooltip.text:SetShadowColor(
		t["shadowColor"]["r"],
		t["shadowColor"]["g"],
		t["shadowColor"]["b"],
		t["shadowColor"]["a"]
	)
	self.fTooltip.text:SetShadowOffset(t["shadowXOffset"], t["shadowYOffset"])
	self.fTooltip.text:SetPoint("CENTER", 0, 0)
	self.fTooltip.text:SetText("Tooltip")
	
	self.fTooltip.border = CreateFrame("Frame", "CooldownTimeline_Tooltip_Border", CooldownTimeline_Tooltip, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	local fTooltipBorder = CooldownTimeline.db.profile.fTooltipBorder
	local fTooltipBorderSize = CooldownTimeline.db.profile.fTooltipBorderSize
	local fTooltipBorderInset = CooldownTimeline.db.profile.fTooltipBorderInset
	local fTooltipBorderPadding = CooldownTimeline.db.profile.fTooltipBorderPadding
	local fTooltipBorderColor = CooldownTimeline.db.profile.fTooltipBorderColor
	
	CooldownTimeline:SetBorder(self.fTooltip, fTooltipBorder, fTooltipBorderSize, fTooltipBorderInset)
	CooldownTimeline:SetBorderColor(self.fTooltip, fTooltipBorderColor)
	CooldownTimeline:SetBorderPoint(self.fTooltip, fTooltipBorderPadding)
	self.fTooltip.border:SetFrameLevel(CooldownTimeline_Tooltip:GetFrameLevel() + 1)
	
	self.fTooltip:Hide()
end

function CooldownTimeline:CalcLinearPercentPosition(timeLeft, cooldown, iconWidth)
	local percent = ( timeLeft / cooldown ) * 100
	
	local timelineWidthAdjusted = CooldownTimeline.db.profile.fTimelineWidth - iconWidth
	
	local position = ( timelineWidthAdjusted / 100 ) * percent
	position = position + iconWidth
	
	return position
end

function CooldownTimeline:CalcLinearAbsolutePosition(timeLeft, id)
	local absolute = CooldownTimeline.db.profile.fTimelineModeAbsLimit
	
	local fIconSize = CooldownTimeline.db.profile.fIconSize
	
	local timelineWidthAdjusted = CooldownTimeline.db.profile.fTimelineWidth - fIconSize
	
	local percent = ( timeLeft / absolute ) * 100
	local position = ( timelineWidthAdjusted / 100 ) * percent
	position = position + fIconSize
	
	if timeLeft > absolute then
		position = timelineWidthAdjusted + fIconSize
	end
	
	return position
end

function CooldownTimeline:CalcSplitPercentPosition(timeLeft, cooldown)
	local fTimelineModeSplitCount = CooldownTimeline.db.profile.fTimelineModeSplitCount
	local split1 = CooldownTimeline.db.profile.fTimelineModeSplit1
	local split2 = CooldownTimeline.db.profile.fTimelineModeSplit2
	local split3 = CooldownTimeline.db.profile.fTimelineModeSplit3
	local absolute = CooldownTimeline.db.profile.fTimelineModeSplitLimit
	
	local percent = ( timeLeft / cooldown ) * 100
	
	local fIconSize = CooldownTimeline.db.profile.fIconSize
	local timelineWidthAdjusted = CooldownTimeline.db.profile.fTimelineWidth - fIconSize
	
	local position = 0
	local regionSize = timelineWidthAdjusted / (fTimelineModeSplitCount + 1)
	local regionAdjustment = 0
	
	if percent > absolute then
		position = CooldownTimeline.db.profile.fTimelineWidth
	else
		if fTimelineModeSplitCount == 1 then
			if percent > split1 then
				regionAdjustment = regionSize
				
				local adjustedTimeLeft = percent - split1
				percent = adjustedTimeLeft / (absolute - split1)
			else
				percent = percent / split1
			end
		elseif fTimelineModeSplitCount == 2 then
			if percent > split2 then
				regionAdjustment = regionSize * 2
				
				local adjustedTimeLeft = percent - split2
				percent = adjustedTimeLeft / (absolute - split2)
			elseif percent > split1 then
				regionAdjustment = regionSize
				
				local adjustedTimeLeft = percent - split1
				percent = adjustedTimeLeft / (split2 - split1)
			else
				percent = percent / split1
			end
		elseif fTimelineModeSplitCount == 3 then
			if percent > split3 then
				regionAdjustment = regionSize * 3
				
				local adjustedTimeLeft = percent - split3
				percent = adjustedTimeLeft / (absolute - split3)
			elseif percent > split2 then
				regionAdjustment = regionSize * 2
				
				local adjustedTimeLeft = percent - split2
				percent = adjustedTimeLeft / (split3 - split2)
			elseif percent > split1 then
				regionAdjustment = regionSize
				
				local adjustedTimeLeft = percent - split1
				percent = adjustedTimeLeft / (split2 - split1)
			else
				percent = percent / split1
			end
		end
		
		position = position + regionAdjustment
		position = position + (regionSize * percent)
		position = position + fIconSize
	end
	
	return position
end

function CooldownTimeline:CalcSplitAbsolutePosition(timeLeft, id)
	local fTimelineModeSplitCount = CooldownTimeline.db.profile.fTimelineModeSplitAbsCount
	local splitTime1 = CooldownTimeline.db.profile.fTimelineModeSplitAbs1
	local splitTime2 = CooldownTimeline.db.profile.fTimelineModeSplitAbs2
	local splitTime3 = CooldownTimeline.db.profile.fTimelineModeSplitAbs3
	local absolute = CooldownTimeline.db.profile.fTimelineModeSplitAbsLimit
	
	local fIconSize = CooldownTimeline.db.profile.fIconSize
	local timelineWidthAdjusted = CooldownTimeline.db.profile.fTimelineWidth - fIconSize
	
	local position = 0
	local regionSize = timelineWidthAdjusted / (fTimelineModeSplitCount + 1)
	local regionAdjustment = 0
	local percent = 0
	
	if timeLeft > absolute then
		position = CooldownTimeline.db.profile.fTimelineWidth
	else
		if fTimelineModeSplitCount == 1 then
			if timeLeft > splitTime1 then
				regionAdjustment = regionSize
				
				local adjustedTimeLeft = timeLeft - splitTime1
				percent = adjustedTimeLeft / (absolute - splitTime1)
			else
				percent = timeLeft / splitTime1
			end
		elseif fTimelineModeSplitCount == 2 then
			if timeLeft > splitTime2 then
				regionAdjustment = regionSize * 2
				
				local adjustedTimeLeft = timeLeft - splitTime2
				percent = adjustedTimeLeft / (absolute - splitTime2)
			elseif timeLeft > splitTime1 then
				regionAdjustment = regionSize
				
				local adjustedTimeLeft = timeLeft - splitTime1
				percent = adjustedTimeLeft / (splitTime2 - splitTime1)
			else
				percent = timeLeft / splitTime1
			end
		elseif fTimelineModeSplitCount == 3 then
			if timeLeft > splitTime3 then
				regionAdjustment = regionSize * 3
				
				local adjustedTimeLeft = timeLeft - splitTime3
				percent = adjustedTimeLeft / (absolute - splitTime3)
			elseif timeLeft > splitTime2 then
				regionAdjustment = regionSize * 2
				
				local adjustedTimeLeft = timeLeft - splitTime2
				percent = adjustedTimeLeft / (splitTime3 - splitTime2)
			elseif timeLeft > splitTime1 then
				regionAdjustment = regionSize
				
				local adjustedTimeLeft = timeLeft - splitTime1
				percent = adjustedTimeLeft / (splitTime2 - splitTime1)
			else
				percent = timeLeft / splitTime1
			end
		end
		
		position = position + regionAdjustment
		position = position + (regionSize * percent)
		position = position + fIconSize
	end
	
	return position
end

function CooldownTimeline:CalcLogAbsolutePosition(timeLeft, id)
	local position = 0
	
	for x = 0, 10, 1 do
		local a = 25
		local y = math.log(x) * a
	end
	
	return position
end

function CooldownTimeline:CalcCurveLinearPosition(timeLeft, cooldown)
	local position = 0
	
	local percent = ( timeLeft / (cooldown / 1000)) * 100
	
	local percentCalc = math.sqrt(10000 - ((100 -percent) * (100 -percent)))
	
	percent = 100 - percentCalc
	
	position = ( CooldownTimeline.db.profile.fTimelineWidth / 100 ) * -percent
	position = position + CooldownTimeline.db.profile.fTimelineWidth
	position = position + (CooldownTimeline.db.profile.fIconSize / 2)
	
	return position
end

function CooldownTimeline:CreateDebugFrame()
	self.fDebug = CreateFrame("Frame", "CooldownTimeline_Debug", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.fDebug:SetPoint("CENTER", 400, 200)
	self.fDebug:SetSize(400, 200)

	self.fDebug:SetBackdrop({
		bgFile = "Interface/DialogFrame/UI-DialogBox-Background", 
		edgeFile = nil, tile = true, tileSize = 32, edgeSize = 0, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	
	self.fDebug.text = self.fDebug:CreateFontString(nil,"ARTWORK")
	self.fDebug.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
	self.fDebug.text:SetPoint("TOPLEFT",0,15)
	self.fDebug.text:SetText("*** Debug ***")
	
	self.fDebug.text1 = self.fDebug:CreateFontString(nil,"ARTWORK")
	self.fDebug.text1:SetFont("Fonts\\ARIALN.ttf", 10, "OUTLINE")
	self.fDebug.text1:SetPoint("RIGHT",0,0)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_Reload", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Reload")
	b:SetPoint("TOPLEFT", 10, -10)
	b:SetScript("OnClick", function()
		ReloadUI()
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_Options", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Options")
	b:SetPoint("TOPLEFT", 10, -35)
	b:SetScript("OnClick", function()
		InterfaceOptionsFrame_OpenToCategory(CooldownTimeline.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(CooldownTimeline.optionsFrame.oTimeline)
		InterfaceOptionsFrame_OpenToCategory(CooldownTimeline.optionsFrame)
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_RunTest", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Run Test1")
	b:SetPoint("TOPLEFT", 10, -60)
	b:SetScript("OnClick", function()
		CooldownTimeline:TestCode1()
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_RunTest", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Run Test2")
	b:SetPoint("TOPLEFT", 10, -85)
	b:SetScript("OnClick", function()
		CooldownTimeline:TestCode2()
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_TestIcon1", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Test Icon 5")
	b:SetPoint("TOPLEFT", 100, -10)
	b:SetScript("OnClick", function()
		CooldownTimeline:CreateTestCooldownIcon("Test", 1, 5)
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_TestIcon2", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Test Icon 10")
	b:SetPoint("TOPLEFT", 100, -35)
	b:SetScript("OnClick", function()
		CooldownTimeline:CreateTestCooldownIcon("Test", 1, 10)
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_TestIcon3", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Test Icon 30")
	b:SetPoint("TOPLEFT", 100, -60)
	b:SetScript("OnClick", function()
		CooldownTimeline:CreateTestCooldownIcon("Test", 1, 30)
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_TestIcon4", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Test Icon 60")
	b:SetPoint("TOPLEFT", 100, -85)
	b:SetScript("OnClick", function()
		CooldownTimeline:CreateTestCooldownIcon("Test", 1, 60)
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_TestIcon5", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Test Icon 70")
	b:SetPoint("TOPLEFT", 100, -110)
	b:SetScript("OnClick", function()
		CooldownTimeline:CreateTestCooldownIcon("Test", 1, 70)
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_TestIcon6", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Test Icon 180")
	b:SetPoint("TOPLEFT", 100, -135)
	b:SetScript("OnClick", function()
		CooldownTimeline:CreateTestCooldownIcon("Test", 1, 180)
	end)
	
	local b = CreateFrame("Button", "CooldownTimeline_Debug_TestIcon7", CooldownTimeline_Debug, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Test Icon 360")
	b:SetPoint("TOPLEFT", 100, -160)
	b:SetScript("OnClick", function()
		CooldownTimeline:CreateTestCooldownIcon("Test", 1, 360)
	end)
	
	self.fDebug:HookScript("OnUpdate", function(self,elapsed)
		-- Show frame and its contents for debug purposes
		if CooldownTimeline.db.profile.debugFrame then
			CooldownTimeline.fDebug:SetAlpha(1)
		else
			CooldownTimeline.fDebug:SetAlpha(0)
		end
	end)		
	
	self.fDebug:RegisterForDrag("LeftButton")
	self.fDebug:SetScript("OnDragStart", self.fDebug.StartMoving)
	self.fDebug:SetScript("OnDragStop", self.fDebug.StopMovingOrSizing)
	self.fDebug:EnableMouse(true)
	self.fDebug:SetMovable(true)
end

function CooldownTimeline:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(CooldownTimeline.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(CooldownTimeline.optionsFrame.oTimeline)
        InterfaceOptionsFrame_OpenToCategory(CooldownTimeline.optionsFrame)
    else
        --LibStub("AceConfigCmd-3.0"):HandleCommand("wh", "WelcomeHome", input)
    end
end