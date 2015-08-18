local PrioRunes = LibStub("AceAddon-3.0"):GetAddon("PrioRunes")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PrioRunes")
local LSM = LibStub("LibSharedMedia-3.0")

local db

function PrioRunes:SetterFunc( info, value )
	if value == nil then return end
	db[info[#info-1]][info[#info]] = value
	self:Debug(info[#info-1].."."..info[#info] .. " was set to: " .. tostring(value))
	self:UpdateFrames()
end

function PrioRunes:GetterFunc( info )
	return db[info[#info-1]][info[#info]]
end

local defaults = {
	profile = {
		general = {
			enabled = true,
			hideblizz = true,
			lock = true,
			onlyCombat = false,
			throttle = 0.03,
		},
		media = {
			bartexture = LSM.DefaultMedia.statusbar,
			backdropalpha = 0.2,
			text = true,
			font = LSM.DefaultMedia.font,
			fontoutline = true,
			textsize = 14,		
		},
		runes = {
			enabled = true, --not in use
			height = 60,
			width = 35,
			decimal = false,
			bloodorder = 1,
			frostorder = 2,
			unholyorder = 3,
			--showborder = true,
			--borderoffset = 5,
			--bordertexture = "Blizzard Dialog",
			colors = {
				[1] = {1, 0, 0},
				[2] = {0, .5, 0},
				[3] = {0, 1, 1},
				[4] = {.9, .1, 1},
			},		
		},
		powerbar = {
			enabled = true, --not in use
			powertext = true,
			maxpower = true,
			snappower = true,
			colors = {0.2,.89,.93},
			height = 20,
			width = 210,		
			showindicator = true,
		},		
		positions = {
			runex = 0,
			runey = 0,	
			powerx = 0,
			powery = 0,
		},
	},
}

local options = {
	name = L["PrioRunes"],
	type = "group",
	handler = PrioRunes,
	args = {
		config = {
			type = "execute",
			order = 1,
			name = L["Config"],
			desc = L["Opens PrioRunes config."],
			guiHidden = true,
			func = function() 
				PrioRunes.background:SetScript("OnUpdate",PrioRunes.OnUpdateOptions)
				AceConfigDialog:Open("PrioRunes") 
				AceConfigDialog.OpenFrames["PrioRunes"]:SetCallback("OnClose", function() 
					PrioRunes.background:SetScript("OnUpdate",PrioRunes.OnUpdate)
				end)
			end,
		},
		general = {
			type = "group",
			name = L["General"],
			order = 1,
			args = {
				enabled = {
					type = "toggle",
					name = L["Enable"],
					desc = L["Enables / Disables rune bar."],
					order = 10,
					set = function(info,value) 
						db.general.enabled = not db.general.enabled
						--initialized = false
						if value then PrioRunes.background:Show()
						else PrioRunes.background:Hide() end
						--PrioRunes:OnInitialize()
						--PrioRunes:OnEnable()
					end,
					get = "GetterFunc",			
				},
				hideblizz = {
					type = "toggle",
					name = L["Hide Blizzard Runes"],
					desc = L["Enables / Disables default Rune Frames."],
					order = 10,
					set = "SetterFunc",
					get = "GetterFunc",			
				},
				
				lock = {
					type = "toggle",
					name = L["Lock Frame"],
					desc = L["Locks / Unlocks the Frames."],
					order = 11,
					set = "SetterFunc",
					get = "GetterFunc",			
				},
				onlyCombat = {
					type = "toggle",
					name = L["Only in Combat"],
					desc = L["Disables the bar while not in combat."],
					order = 12,
					set = "SetterFunc",
					get = "GetterFunc",	
				},
				throttle = {
					type = "range",
					name = L["Update Sequence"],
					desc = L["Lower for smoother updating bars. WARNING: Your framerate could be drastically decreased if you enter too small numbers. If you can't start the game because of this, delete PrioRunes.lua, located in your SavedVariables."],
					order = 13,
					min = 0.01,
					max = 1,
					softMin = 0.03,
					softMax = 0.5,
					step = 0.01,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				reset = {
					type = "execute",
					name = L["Reset Settings"],
					desc = L["Resets all user given settings."],
					order = 14,
					confirm = true,
					confirmText = L["Are you sure you want to reset ALL the settings you've made?"],
					func = function(info) 
						PrioRunes.db:ResetProfile()
						PrioRunes:UpdateFrames()
					end,
				},
			},
		},
		media = {
			type = "group",
			name = L["Media Settings"],
			order = 2,
			args = {
				bartexture = {
					name = L["Texture"],
					desc = L["Select a bar texture."],
					type = "select",
					order = 22,
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				backdropalpha = {
					name = L["Backdrop Alpha"],
					desc = L["Set the Backdrop Alpha of the Runes and the Powerbar."],
					type = "range",
					order = 23,
					min = 0,
					max = 1,
					softMin = 0,
					softMax = 1,
					--step = 0.02,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				--[[showborder = {
					type = "toggle",
					name = "Show Border",
					desc = "Shows / Hides Border.",
					order = 23,
					set = "SetterFunc",
					get = "GetterFunc",	
				},				
				bordertexture = {
					name = "Border",
					desc = "Select a border texture",
					type = "select",
					order = 24,
					dialogControl = "LSM30_Border",
					values = AceGUIWidgetLSMlists.border ,
					set = "SetterFunc",	
					get = "GetterFunc",
				},
				borderoffset = {
					type = "range",
					order = 24,
					name = "Border Offset",
					desc = "Set border offset.",
					min = 1,
					max = 50,
					softMin = 1,
					softMax = 15,
					step = 1,
					set = "SetterFunc",
					get = "GetterFunc",
				},]]
				textheader = {
					type = "header",
					order = 25,
					name = L["Font Settings"],
				},
				text = {
					type = "toggle",
					name = L["Show Text"],
					desc = L["Shows / Hides the Cooldown Timer."],
					order = 35,
					set = "SetterFunc",
					get = "GetterFunc",	
				},
				font = {
					name = L["Font"],
					desc = L["Select a font"],
					type = "select",
					order = 36,
					dialogControl = "LSM30_Font",
					values = AceGUIWidgetLSMlists.font,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				fontoutline = {
					type = "toggle",
					name = L["Font Outline"],
					desc = L["Enables / Disables Font Outline."],
					order = 37,
					set = "SetterFunc",
					get = "GetterFunc",	},
				textsize = {
					type = "range",
					order = 38,
					name = L["Font Size"],
					desc = L["Set font size."],
					min = 1,
					max = 25,
					softMin = 8,
					softMax = 25,
					step = 1,
					set = "SetterFunc",
					get = "GetterFunc",
				},
			},
		},
		runes = {
			type = "group",
			name = L["Rune Settings"],
			order = 3,
			args = {
				enabled = {
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable / Disable Rune Bars."],
					order = 10,
					width = "full",
					set = "SetterFunc",
					get = "GetterFunc",
				},
				height = {
					type = "range",
					order = 21,
					name = L["Height"],
					desc =  L["Set Height of the rune bars."],
					min = 1,
					max = 200,
					softMin = 20,
					softMax = 100,
					step = 1,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				width = {
					type = "range",
					order = 22,
					name = L["Width"],
					desc =  L["Set Width of each rune bar."],
					min = 1,
					max = 200,
					softMin = 5,
					softMax = 150,
					step = 1,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				decimal = {
					type = "toggle",
					name = L["Show Decimal"],
					order = 23,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				colorSettingsHeader = {
					type = "header",
					order = 30,
					name = L["Color Settings"],
					width = "full",		
				},
				colorblood = {
					type = "color",
					order = 31,
					name = L["Blood Rune Color"],
					desc = L["Customize rune colors."],
					set = function(info, r, g, b, a) 
						db.runes.colors[1] = {r,g,b}
						--db.runes.colors[1][2] = g
						--db.runes.colors[1][3] = b
						PrioRunes:UpdateFrames()
					end,
					get = function(info) 
						return unpack(db.runes.colors[1])
					end,
				},
				colorunholy = {
					type = "color",
					order = 32,
					name = L["Unholy Rune Color"],
					desc = L["Customize rune colors."],
					set = function(info, r, g, b, a) 
						db.runes.colors[2] = {r,g,b}
						--db.runes.colors[2][2] = g
						--db.runes.colors[2][3] = b
						PrioRunes:UpdateFrames()
					end,
					get = function(info) 
						return unpack(db.runes.colors[2])
					end,
				},
				colorfrost = {
					type = "color",
					order = 33,
					name = L["Frost Rune Color"],
					desc = L["Customize rune colors."],
					set = function(info, r, g, b, a) 
						db.runes.colors[3] = {r,g,b}
						--db.runes.colors[3][2] = g
						--db.runes.colors[3][3] = b
						PrioRunes:UpdateFrames()
					end,
					get = function(info) 
						return unpack(db.runes.colors[3])
					end,
				},
				colordeath = {
					type = "color",
					order = 34,
					name = L["Death Rune Color"],
					desc = L["Customize rune colors."],
					set = function(info, r, g, b, a) 
						db.runes.colors[4] = {r,g,b}
						--db.runes.colors[4][2] = g
						--db.runes.colors[4][3] = b
						PrioRunes:UpdateFrames()
					end,
					get = function(info) 
						return unpack(db.runes.colors[4])
					end,
				},
				resetcolors = {
					type = "execute",
					name = L["Reset Colors"],
					desc = L["Resets colors to their defaults."],
					confirm = true,
					order = 35,
					func = function(info) 
						db.runes.colors = {
						[1] = {1, 0, 0},
						[2] = {0, .5, 0},
						[3] = {0, 1, 1},
						[4] = {.9, .1, 1}}
						PrioRunes:UpdateFrames()			
					end,
				},
				orderheader = {
					type = "header",
					order = 40,
					name = L["Order Settings"],
				},
				bloodorder = {
					type = "range",
					name = L["Blood Runes"],
					desc = L["1 = Left, 2 = Middle, 3 = Right."],
					order = 41,
					min = 1,
					max = 3,
					softMin = 1,
					softMax = 3,
					step = 1,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				frostorder = {
					type = "range",
					name = L["Frost Runes"],
					desc = L["1 = Left, 2 = Middle, 3 = Right."],
					order = 42,
					min = 1,
					max = 3,
					softMin = 1,
					softMax = 3,
					step = 1,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				unholyorder = {
					type = "range",
					name = L["Unholy Runes"],
					desc = L["1 = Left, 2 = Middle, 3 = Right."],
					order = 43,
					min = 1,
					max = 3,
					softMin = 1,
					softMax = 3,
					step = 1,
					set = "SetterFunc",
					get = "GetterFunc",			
				},
			},
		},
		powerbar = {
			type = "group",
			order = 4,
			name = L["Power Bar"],
			args = {
				enabled = {
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable / Disable Runic Power Bar."],
					order = 10,
					width = "full",
					set = "SetterFunc",
					get = "GetterFunc",
				},
				height = {
					type = "range",
					order = 12,
					name = L["Height"],
					desc = L["Set Height of the Runic Power bar."],
					min = 1,
					max = 200,
					softMin = 5,
					softMax = 80,
					step = 1,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				width = {
					type = "range",
					order = 13,
					name = L["Width"],
					desc = L["Set Width of the Runic Power bar."],
					min = 1,
					max = 500,
					softMin = 20,
					softMax = 350,
					step = 1,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				snappower = {
					type = "toggle",
					name = L["Snap to Runes"],
					desc = L["Snap powerbar to runeframe."],
					order = 14,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				powertext = {
					type = "toggle",
					name = L["Rune Power Text"],
					desc = L["Enables / Disables Rune Power Text."],
					order = 15,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				maxpower = {
					type = "toggle",
					name = L["Show Max Runic Power"],
					desc = L["Enables / Disables Max Runic Power."],
					order = 16,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				showindicator = {
					type = "toggle",
					name = L["Show Indicators"],
					desc = L["Toggle an indicator for Rune Strike, Frost Strike and Deathcoil."],
					order = 17,
					set = "SetterFunc",
					get = "GetterFunc",
				},
				orderheader = {
					type = "header",
					order = 30,
					name = L["Order Settings"],					
				},
				colors = {
					type = "color",
					order = 34,
					name = L["Runic Power Bar"],
					desc = L["Customize Runic Power colors."],
					set = function(info, r, g, b, a) 
						db.powerbar.colors = {r,g,b}
						PrioRunes:UpdateFrames()
					end,
					get = function(info) 
						return unpack(db.powerbar.colors)
					end,
				},
				resetcolors = {
					type = "execute",
					name = L["Reset Colors"],
					desc = L["Resets colors to their defaults."],
					confirm = true,
					order = 35,
					func = function(info) 
						db.powerbar.colors = {0.2,.89,.93}
						PrioRunes:UpdateFrames()			
					end,
				},
			},
		},
		positions = {
			type = "group",
			order = 5,
			name = L["Positioning"],
			args = {
				desc = {
					type = "description",
					name = L["Manually change the frame positions"],
					order = 1,
				},
				runex = {					
					type = "range",
					name = L["Main Frame x"],
					order = 10,
					min = -1000,
					max = 1000,
					softMin = -700,
					softMax = 700,
					step = 1,
					bigStep = 10,
					set = "SetterFunc",
					get = "GetterFunc",							
				},
				powerx = {					
					type = "range",
					name = L["Power Frame x"],
					order = 20,
					min = -1000,
					max = 1000,
					softMin = -700,
					softMax = 700,
					step = 1,
					bigStep = 10,
					set = "SetterFunc",
					get = "GetterFunc",							
				},
				runey = {					
					type = "range",
					name = L["Main Frame y"],
					order = 11,
					min = -500,
					max = 500,
					softMin = -350,
					softMax = 350,
					step = 1,
					bigStep = 10,
					set = "SetterFunc",
					get = "GetterFunc",							
				},
				powery = {					
					type = "range",
					name = L["Rune Frame y"],
					order = 21,
					min = -500,
					max = 500,
					softMin = -350,
					softMax = 350,
					step = 1,
					bigStep = 10,
					set = "SetterFunc",
					get = "GetterFunc",							
				},
			},
		},
	}
}

function PrioRunes:InitializeOptions()
	self.db = LibStub("AceDB-3.0"):New("PrioRunesDB", defaults, true)
	db = self.db.profile
	AceConfig:RegisterOptionsTable("PrioRunes", options, {"priorunes", "priorunesdummy"})
	AceConfigDialog:AddToBlizOptions("PrioRunes","Prio Runes")
	AceConfigDialog:SetDefaultSize("PrioRunes",580,500)
end