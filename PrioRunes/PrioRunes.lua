
local PrioRunes = LibStub( "AceAddon-3.0" ):NewAddon("PrioRunes","AceEvent-3.0", "AceConsole-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PrioRunes")

local GetRuneType, GetRuneCooldown, UnitClass, GetTime, UnitPower, UnitPowerMax, GetSpecialization
    = GetRuneType, GetRuneCooldown, UnitClass, GetTime, UnitPower, UnitPowerMax, GetSpecialization

local MAX_RUNES = 6	
	
local db
local _,class = UnitClass("player")
local initialized = false
local optionsinit = false

--local debug = true

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

function PrioRunes:SetterFunc(info, value)
	db[info[#info-1]][info[#info]] = value
	if debug then
		print( info[#info-1].."."..info[#info] .. " was set to: " .. tostring(value) )
	end
	self:UpdateFrames()
end

function PrioRunes:GetterFunc(info)
	return db[info[#info-1]][info[#info]]
end

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
						initialized = false
						if value then PrioRunes.background:Show()
						else PrioRunes.background:Hide() end
						PrioRunes:OnInitialize()
						PrioRunes:OnEnable()
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

function PrioRunes:UpdateFrames()
	
	self.background:SetHeight(db.runes.height)
	--self.border:SetHeight(2*db.borderoffset+db.height)
	for i=1,MAX_RUNES do
		self.runespacer[i]:SetHeight(db.runes.height-2)
		self.runeframe[i]:SetHeight(db.runes.height-2)
	end	
	
	self.background:SetWidth(db.runes.width*MAX_RUNES)
	--self.border:SetWidth(2*db.borderoffset+db.width*MAX_RUNES)
	for i=1,MAX_RUNES do
		self.runespacer[i]:SetWidth(db.runes.width-2)
		self.runeframe[i]:SetWidth(db.runes.width-2)
	end	
	
	--self.border:SetBackdrop( {edgeFile=LSM:Fetch("border",db.bordertexture),tile=true,tileSize=16,edgeSize=16,insets = { left = -4, right = -4, top = -4, bottom = -4 }})
	
	local set = 1	
	self.runespacer[1]:SetPoint("TOPLEFT",self.background,"TOPLEFT",set+(db.runes.bloodorder*2-2)*db.runes.width,-set)	 --0
	self.runespacer[2]:SetPoint("TOPLEFT",self.background,"TOPLEFT",set+(db.runes.bloodorder*2-1)*db.runes.width,-set) 	 --1
	self.runespacer[3]:SetPoint("TOPLEFT",self.background,"TOPLEFT",set+(db.runes.unholyorder*2-2)*db.runes.width,-set)	 --2
	self.runespacer[4]:SetPoint("TOPLEFT",self.background,"TOPLEFT",set+(db.runes.unholyorder*2-1)*db.runes.width,-set)	 --3
	self.runespacer[5]:SetPoint("TOPLEFT",self.background,"TOPLEFT",set+(db.runes.frostorder*2-2)*db.runes.width,-set)	 --4
	self.runespacer[6]:SetPoint("TOPLEFT",self.background,"TOPLEFT",set+(db.runes.frostorder*2-1)*db.runes.width,-set)	 --5
	
	self:UpdatePowerBar()
	
	self.background:ClearAllPoints()
	self.background:SetPoint("CENTER", UIParent, "CENTER", db.positions.runex, db.positions.runey)
	
	for i=1,MAX_RUNES do 
		self:SetBarTexture(i)
		self:ColorRuneBars(i)
		self:UpdateTimers(i)
	end
	
	if db.general.lock then self.background:EnableMouse(false)
	else self.background:EnableMouse(true) end
		
	--[[if db.showborder then self.border:Show() 
	else self.border:Hide() end]]
	
	if db.powerbar.showindicator then self.powerindicator:Show() 
	else self.powerindicator:Hide() end
	
	if db.general.hideblizz then RuneFrame:Hide()	
	else RuneFrame:Show() end

	if db.runes.enabled then 
		self.background:Show()
		if db.general.onlyCombat then 
			self.background:Hide() 
		end
	else self.background:Hide() end
	
	
	
	if debug then
		print("Updated Frames.")
	end
end

function PrioRunes:SetBarTexture(i)	
		self.runeframe[i]:SetStatusBarTexture(LSM:Fetch("statusbar",db.media.bartexture))	
end

function PrioRunes:ColorRuneBars(i)	
		info = GetRuneType(i)
		self.runeframe[i]:SetStatusBarColor(unpack(db.runes.colors[info]))
		self.runebackdrop[i]:SetTexture(db.runes.colors[info][1], db.runes.colors[info][2], db.runes.colors[info][3], db.media.backdropalpha)		--alphaoption
end

function PrioRunes:UpdateTimers(i)
	
		if db.media.fontoutline == true then
			self.barframeText[i]:SetFont(LSM:Fetch("font",db.media.font),db.media.textsize,"OUTLINE")
		else
			self.barframeText[i]:SetFont(LSM:Fetch("font",db.media.font),db.media.textsize)
		end
		if db.media.text == true then
			self.barframeText[i]:Show()
		else
			self.barframeText[i]:Hide()
		end
	
end

local function GetRunecost()
	local runecost
	local spec = GetSpecialization()
	if spec == 1 then runecost = 30
	elseif spec == 2 then runecost = 25
	elseif spec == 3 then runecost = 30
	else runecost = 0 end
	return runecost
end

function PrioRunes:UpdatePowerBar()

	local value = UnitPower("player", SPELL_POWER_RUNIC_POWER)
	local maxvalue = UnitPowerMax("player", SPELL_POWER_RUNIC_POWER)
	
	if db.powerbar.snappower then
		self.powerbarbackground:SetWidth(db.runes.width*MAX_RUNES)
		self.powerbarbackground:SetHeight(db.powerbar.height)
		self.powerbarbackground:ClearAllPoints()
		self.powerbarbackground:SetPoint("BOTTOM",self.background,"BOTTOM",0,-db.powerbar.height)
		self.powerbar:SetWidth(db.runes.width*MAX_RUNES-2)
		self.powerbar:SetHeight(db.powerbar.height-2)
	else  
		self.powerbarbackground:SetWidth(db.powerbar.width)
		self.powerbarbackground:SetHeight(db.powerbar.height)
		self.powerbarbackground:ClearAllPoints()
		self.powerbarbackground:SetPoint("CENTER",UIParent,"CENTER",db.positions.powerx,db.positions.powery)
		self.powerbar:SetWidth(db.powerbar.width-2)
		self.powerbar:SetHeight(db.powerbar.height-2)
	end
		
	self.powerbar:SetStatusBarTexture(LSM:Fetch("statusbar",db.media.bartexture))
	
	self.powerbar:SetStatusBarColor(unpack(db.powerbar.colors))
	self.powerbarbackdrop2:SetTexture(db.powerbar.colors[1],db.powerbar.colors[2],db.powerbar.colors[3],db.media.backdropalpha)
	
	self.powerbar:SetMinMaxValues(0,maxvalue)
	self.powerbar:SetValue(value)
	if db.powerbar.maxpower then	
		self.powerbartext:SetFormattedText("%d / %d", value, maxvalue)
	else self.powerbartext:SetFormattedText("%d",value) end
	
	if db.general.lock then self.powerbarbackground:EnableMouse(false)
	else self.powerbarbackground:EnableMouse(true) end
	
	if db.powerbar.powertext then self.powerbartext:Show()
	else self.powerbartext:Hide() end
	
	if db.media.fontoutline then
		self.powerbartext:SetFont(LSM:Fetch("font",db.media.font),db.media.textsize,"OUTLINE")
	else
		self.powerbartext:SetFont(LSM:Fetch("font",db.media.font),db.media.textsize)
	end
		
	self.powerindicator:SetHeight(db.powerbar.height)
	self.powerindicator:SetWidth(1)
	if not db.powerbar.snappower then
		self.powerindicator:SetPoint("RIGHT", self.powerbar, "LEFT", db.powerbar.width*GetRunecost()/maxvalue, 0)
	else self.powerindicator:SetPoint("RIGHT", self.powerbar, "LEFT", (db.runes.width*MAX_RUNES-2)*GetRunecost()/maxvalue, 0) end
	if db.powerbar.showindicator then self.powerindicator:Show()
	else self.powerindicator:Hide() end

	if db.powerbar.enabled then 
		self.powerbarbackground:Show()
		if db.general.onlyCombat then 
			self.powerbarbackground:Hide() 
		end
	else self.powerbarbackground:Hide() end
	
end

function PrioRunes:OnUpdateOptions(elapsed)

	self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed; 	
	
	local textformat
	
	if db.runes.decimal then textformat = "%.1f"
	else textformat = "%d" end
	
	local duration = {4,6,4.5,6.5,3.5,6.7}
	
	while (self.TimeSinceLastUpdate > db.general.throttle) do
	
		local now = GetTime()
		
		self.AnimTimeStart = self.AnimTimeStart or 0
		
		if self.AnimTimeStart + 4 <= now then
			self.AnimTimeStart = GetTime()
		end	
		
		for i=1,MAX_RUNES do
			--duration[i] = duration[i] or (random() * 10) -- 0 or timestamp(14000), 7.13
			PrioRunes.runeframe[i]:SetMinMaxValues(0, duration[i])
			PrioRunes.runeframe[i]:SetValue(now - self.AnimTimeStart)
			if self.AnimTimeStart ~= 0 and duration[i]-(now - self.AnimTimeStart) >= 0 then
				PrioRunes.barframeText[i]:SetFormattedText(textformat,duration[i]-(now - self.AnimTimeStart))
			else PrioRunes.barframeText[i]:SetFormattedText(" ") end
		end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - db.general.throttle
	end

end

function PrioRunes:OnUpdate(elapsed)

	self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed; 	
	
	local textformat
	
	if db.runes.decimal then textformat = "%.1f"
	else textformat = "%d" end
	
	while (self.TimeSinceLastUpdate > db.general.throttle) do
	
		local now = GetTime()
		for i=1,MAX_RUNES do
			local start, duration = GetRuneCooldown(i) -- 0 or timestamp(14000), 7.13
			PrioRunes.runeframe[i]:SetMinMaxValues(0, duration)
			PrioRunes.runeframe[i]:SetValue(now - start)
			if start ~= 0 and duration-(now - start) >= 0 then
				PrioRunes.barframeText[i]:SetFormattedText(textformat,duration-(now - start))
			else PrioRunes.barframeText[i]:SetFormattedText(" ") end
		end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - db.general.throttle
	end

end

function PrioRunes:CreateFrames()
	
	self.background = CreateFrame("Frame", "PrioRunesParent", UIParent)
	self.background:SetFrameStrata("LOW")
	self.background:ClearAllPoints()
	
	self.background:SetPoint("CENTER","UIParent")
	self.background:SetMovable(true)
	
	--[[self.border = CreateFrame("Frame", "PrioRunesBorder", self.background)
	self.border:SetFrameStrata("LOW")
	self.border:ClearAllPoints()]]
	
	self.backdrop = self.background:CreateTexture("PrioRunesBackdrop","BACKGROUND")
	self.backdrop:SetAllPoints(self.background)
	self.backdrop:SetTexture(.05,.05,.05,1)
	
	self.runeframe = {}
	self.runespacer = {}
	self.runebackdrop = {}
	self.barframeText = {}
	
	for i=1,MAX_RUNES do
	
		self.runespacer[i] = CreateFrame("Frame", nil,self.background)
		self.runespacer[i]:SetFrameStrata("LOW")
				
		self.runeframe[i] = CreateFrame("StatusBar", "RuneFrame"..i, self.background)		
		self.runeframe[i]:SetFrameStrata("MEDIUM")
		
		self:SetBarTexture(i)		
		
		self.runeframe[i]:SetOrientation("VERTICAL")
		self.runeframe[i]:SetRotatesTexture(true)
		self.runeframe[i]:SetPoint("CENTER",self.runespacer[i],"CENTER",0,0)
		
		self.runebackdrop[i] = self.runespacer[i]:CreateTexture("RuneBackdrop"..i,"BACKGROUND")
		self.runebackdrop[i]:SetAllPoints(self.runespacer[i])
		self.runebackdrop[i]:SetTexture(.7,.7,.7,0.5)
		self.runebackdrop[i]:SetBlendMode("ADD")
		
		self.barframeText[i] = self.runeframe[i]:CreateFontString("RuneCDTimer", "OVERLAY", "GameFontNormal")
		self.barframeText[i]:SetTextColor(1,1,1)
		self.barframeText[i]:SetJustifyH("CENTER")
		self.barframeText[i]:SetPoint("CENTER", self.runeframe[i], "CENTER", 0, -5)		
			
	end
	
	self.powerbarbackground = CreateFrame("Frame", nil, UIParent)
	self.powerbarbackground:SetFrameStrata("LOW")
	self.powerbarbackground:SetMovable(true)
	
	self.powerbarbackdrop = self.powerbarbackground:CreateTexture("RPBackdrop", "BACKGROUND")
	self.powerbarbackdrop:SetAllPoints(self.powerbarbackground)
	self.powerbarbackdrop:SetTexture(.05,.05,.05,1)
	
	self.powerbar = CreateFrame("StatusBar", "RPBar", self.powerbarbackground)
	self.powerbar:SetFrameStrata("MEDIUM")
	self.powerbar:SetOrientation("HORIZONTAL")
	self.powerbar:SetPoint("CENTER", self.powerbarbackground, "CENTER", 0,0)	
	
	self.powerbarbackdrop2 = self.powerbar:CreateTexture("RPBackdrop2", "BACKGROUND")
	self.powerbarbackdrop2:SetAllPoints(self.powerbar)

	
	self.powerbartext = self.powerbar:CreateFontString("RunicPowerText", "OVERLAY", "GameFontNormal")
	self.powerbartext:SetTextColor(1,1,1)
	self.powerbartext:SetJustifyH("CENTER")
	self.powerbartext:SetPoint("CENTER", self.powerbar, "CENTER", 0, 0)
	
	self.powerindicator = self.powerbar:CreateTexture("RPIndicator", "OVERLAY")
	self.powerindicator:SetTexture(0,0,0,1)	
	
	self.background:SetScript("OnMouseDown", function(frame, button)
        if (button == "LeftButton") and not db.general.lock then
            frame:StartMoving()
		end
		if debug then
			print("OnMouseDown")
		end			
    end)
	self.background:SetScript("OnMouseUp", function(frame, button)
        if (button == "LeftButton") and not db.general.lock then
            frame:StopMovingOrSizing()
			local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
			local x, y = frame:GetCenter()

			x, y = x * scale, y * scale
			x = x - _G.GetScreenWidth() / 2
			y = y - _G.GetScreenHeight() / 2
			x = x / frame:GetScale()
			y = y / frame:GetScale()
			db.positions.runex, db.positions.runey = x, y
			AceConfigRegistry:NotifyChange("PrioRunes")
		end
    end)
	
	self.powerbarbackground:SetScript("OnMouseDown", function(frame, button)
        if (button == "LeftButton") and not db.general.lock and not db.powerbar.snappower then
            frame:StartMoving()
		end
		if debug then
			print("OnMouseDown")
		end
    end)
	self.powerbarbackground:SetScript("OnMouseUp", function(frame, button)
        if (button == "LeftButton") and not db.general.lock and not db.powerbar.snappower then
            frame:StopMovingOrSizing()
			local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
			local x, y = frame:GetCenter()

			x, y = x * scale, y * scale
			x = x - _G.GetScreenWidth() / 2
			y = y - _G.GetScreenHeight() / 2
			x = x / frame:GetScale()
			y = y / frame:GetScale()
			db.positions.powerx, db.positions.powery = x, y
			AceConfigRegistry:NotifyChange("PrioRunes")
		end
    end)
	
	
end

function PrioRunes:UNIT_POWER(_,unit,type)
	if unit == "player" and type == "RUNIC_POWER" then
		local value = UnitPower("player",SPELL_POWER_RUNIC_POWER)
		local maxvalue = UnitPowerMax("player",SPELL_POWER_RUNIC_POWER)
		self.powerbar:SetMinMaxValues(0, maxvalue)
		self.powerbar:SetValue(value)
		
		if db.powerbar.maxpower then	
			self.powerbartext:SetFormattedText("%d / %d", value, maxvalue)
		else self.powerbartext:SetFormattedText("%d",value) end
				
	end
end

function PrioRunes:RUNE_TYPE_UPDATE(_,id)
	self:ColorRuneBars(id)
end

function PrioRunes:PLAYER_REGEN_ENABLED()
	if db.general.onlyCombat then
		self.background:Hide()
		self.powerbarbackground:Hide()
	end
end

function PrioRunes:PLAYER_REGEN_DISABLED()
	if db.general.onlyCombat then
		self.background:Show()
		self.powerbarbackground:Show()
	end	
end

function PrioRunes:PLAYER_ENTERING_WORLD()
	self:UpdateFrames()
end
	
function PrioRunes:PLAYER_TALENT_UPDATE()
	self:UpdatePowerBar()
end

function PrioRunes:OnEnable()

	self:UnregisterEvent("RUNE_TYPE_UPDATE")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("UNIT_POWER")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_TALENT_UPDATE")
	
	if self.background then
		self.background:SetScript("OnUpdate",nil)
	end
	
	
	
	if class == "DEATHKNIGHT" and not initialized and db.general.enabled then
		self:RegisterEvent("RUNE_TYPE_UPDATE")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("UNIT_POWER")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PLAYER_TALENT_UPDATE")		
		
		self.background:SetScript("OnUpdate",self.OnUpdate)
		initialized = true
	end
end

function PrioRunes:OnInitialize()
	
	self.db = LibStub("AceDB-3.0"):New("PrioRunesDB", defaults, true)	
	db = self.db.profile
	self.AnimTimeStart = GetTime()
	
	if not optionsinit then
		AceConfig:RegisterOptionsTable("PrioRunes", options, {"priorunes", "priorunesdummy"})
		AceConfigDialog:AddToBlizOptions("PrioRunes","Prio Runes")
		AceConfigDialog:SetDefaultSize("PrioRunes",580,500)
		optionsinit = true
	end
	
	
	if class == "DEATHKNIGHT" and db.general.enabled and not self.background then					
		self:CreateFrames()	
	end

end