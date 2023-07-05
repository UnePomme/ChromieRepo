--[[ ---------------------------------------------------------------------------
Name:	SimpleUnitFrames
Author:	Pneumatus
About:	An extension to the default WoW Unit Frames. Rather than a complete 
		unitframe replacement, this addon adds further information and features
		to the existing frames and allows a greater degree of customization to 
		enhance their usability.
----------------------------------------------------------------------------- ]]

local SUF = LibStub("AceAddon-3.0"):GetAddon("SimpleUnitFrames")
local L = LibStub("AceLocale-3.0"):GetLocale("SimpleUnitFrames")
local TO = SUF:NewModule("TextOverlay", "AceEvent-3.0", "AceHook-3.0")
local DT = LibStub("LibDogTag-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- Static FontString display styles
local STATIC_STYLES = {
	-- Health Styles
	["HPcurrent"] = {
		type = "HP",
		desc = L["Current HP"],
		dt = '[HP]',
	},
	["HPdeficit"] = {
		type = "HP",
		desc = L["HP Defecit"],
		dt = '[0-MissingHP]',
	},
	["HPpercent"] = {
		type = "HP",
		desc = L["Percent HP"],
		dt = '[PercentHP:Percent]',
	},
	["HPcurrmax"] = {
		type = "HP",
		desc = L["Fractional HP"],
		dt = '[FractionalHP:Short]',
	},
	["HPcomplete"] = {
		type = "HP",
		desc = L["Complete HP"],
		dt = '[FractionalHP:Short " " PercentHP:Percent:Paren]',
	},
	["HPnone"] = {
		type = "HP",
		desc = L["Blank"],
		dt = '',
	},
	-- Mana Styles
	["MPcurrent"] = {
		type = "MP",
		desc = L["Current MP"],
		dt = '[HasMP ? MP ! "-"]',
	},
	["MPdeficit"] = {
		type = "MP",
		desc = L["MP Defecit"],
		dt = '[HasMP ? 0-MissingMP]',
	},
	["MPpercent"] = {
		type = "MP",
		desc = L["Percent MP"],
		dt = '[HasMP ? PercentMP:Percent ! "-"]',
	},
	["MPcurrmax"] = {
		type = "MP",
		desc = L["Fractional MP"],
		dt = '[HasMP ? FractionalMP:Short ! "-"]',
	},
	["MPcomplete"] = {
		type = "MP",
		desc = L["Complete MP"],
		dt = '[HasMP ? FractionalMP:Short " " PercentMP:Percent:Paren ! "-"]',
	},
	["MPnone"] = {
		type = "MP",
		desc = L["Blank"],
		dt = '',
	},
	-- Druid Mana Styles
	["MPDcurrent"] = {
		type = "MPD",
		desc = L["Current Druid MP"],
		dt = '[DruidMP]',
	},
	["MPDdeficit"] = {
		type = "MPD",
		desc = L["Druid MP Defecit"],
		dt = '[0-MissingDruidMP]',
	},
	["MPDpercent"] = {
		type = "MPD",
		desc = L["Percent Druid MP"],
		dt = '[PercentDruidMP:Percent]',
	},
	["MPDcurrmax"] = {
		type = "MPD",
		desc = L["Fractional Druid MP"],
		dt = '[FractionalDruidMP:Short]',
	},
	["MPDcomplete"] = {
		type = "MPD",
		desc = L["Complete Druid MP"],
		dt = '[FractionalDruidMP:Short " " PercentDruidMP:Percent:Paren]',
	},
	["MPDnone"] = {
		type = "MPD",
		desc = L["Blank"],
		dt = '',
	},
}

SUF.defaults.global.overlayfont = {
	fontface = "Friz Quadrata TT",
	fontsize = 10,
}

SUF.options.args.general.args.fontface = {
	type = 'select',
	name = L["Overlay Font"],
	desc = L["Text Overlay Font"],
	get = function(info) return info.handler.db.global.overlayfont.fontface end,
	set = function(info, val)
		info.handler.db.global.overlayfont.fontface = val
		TO:RefreshFontStrings()
	end,
	dialogControl = 'LSM30_Font',
	values = AceGUIWidgetLSMlists.font,
	order = 100,
}
SUF.options.args.general.args.fontsize = {
	type = 'range',
	name = L["Overlay Font Size"],
	desc = L["Text Overlay Font Size"],
	get = function(info) return info.handler.db.global.overlayfont.fontsize end,
	set = function(info, value)
		info.handler.db.global.overlayfont.fontsize = value
		TO:RefreshFontStrings()
	end,
	min = 7,
	max = 14,
	step = 1,
	order = 110,
}

local frames = {}
local inVehicle = {}

TO.frameSettings = {}
TO.activeStyles = {}
TO.formatList = { HP = {}, MP = {}, MPD = {} }

function TO:OnInitialize()
	-- Copy STATIC_STYLES into self.formatList and self.activeStyles
	for name, style in pairs(STATIC_STYLES) do
		self.formatList[style.type][name] = style.desc
		self.activeStyles[name] = style.dt
	end
	
	for unit, args in pairs(self.frameSettings) do
		self:CreateNewFrame(unit, args)
	end
	
	SUF.db.RegisterCallback(self, "OnProfileChanged", function() self:RefreshFontStrings() end)
	SUF.db.RegisterCallback(self, "OnProfileCopied", function() self:RefreshFontStrings() end)
	SUF.db.RegisterCallback(self, "OnProfileReset", function() self:RefreshFontStrings() end)
	
	LSM.RegisterCallback(self, "LibSharedMedia_Registered", function(event, type, key) 
		if type == "font" and key == SUF.db.global.overlayfont.fontface then self:RefreshFontStrings() end
	end)
	LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", function(event, type) 
		if type == "font" then self:RefreshFontStrings() end
	end)
end

function TO:OnEnable()
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "VehicleSwitch")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "VehicleSwitch")
	self:RefreshFontStrings()
end

function TO:OnDisable()
end

function TO:CreateNewFrame(unit, args)
	local parent = args.parent
	
	local frame = CreateFrame("Frame", nil, parent)
	frames[unit] = frame
	frame:SetFrameLevel(parent:GetFrameLevel()+3)
	frame.fontStrings = {}
	
	for text, points in pairs(args.text) do
		local fontString = frame:CreateFontString(nil, "OVERLAY")
		frame.fontStrings[text] = fontString
		fontString:SetPoint(unpack(points))
		fontString:SetShadowOffset(1, -1)
		fontString.parent = points[2]
	end
end

function TO:RefreshFontStrings(unit)
	if unit then
		local mappedUnit = SUF.unitMap[unit] or unit
		if mappedUnit and frames[unit] then
			for text, fontString in pairs(frames[unit].fontStrings) do
				fontString:SetFont(LSM:Fetch("font", SUF.db.global.overlayfont.fontface), SUF.db.global.overlayfont.fontsize)
				local style = SUF.db.profile[mappedUnit][text]
				local dtString = self.activeStyles[style] or "ERROR"
				DT:AddFontString(fontString, fontString.parent, dtString, "Unit", {["unit"] = unit})
			end
		end
	else
		for unit, _ in pairs(frames) do
			self:RefreshFontStrings(unit)
		end
	end
end

function TO:ToggleOverlay(unit, fs)
	-- Sanity that the FontString exists
	if not frames[unit].fontStrings[fs] then return end
	
	-- Toggle depending on the parent frame's visibility
	if frames[unit].fontStrings[fs].parent:IsShown() then
		frames[unit].fontStrings[fs]:Show()
	else
		frames[unit].fontStrings[fs]:Hide()
	end
end

function TO:VehicleSwitch(event, unit)
	-- Drop out if the unit is not player/party[1-4]
	if unit ~= "player" and not unit:match("^party[1-4]") then return end
	
	-- Drop out if we are in a vehicle and not exiting
	if inVehicle[unit] and UnitHasVehicleUI(unit) then return end
	
	-- Work out the name of the unit's pet
	local pet = unit:match("^party[1-4]") and unit:gsub("party", "partypet") or "pet"
	
	local unitMap = SUF.unitMap
	if UnitHasVehicleUI(unit) and not inVehicle[unit] and frames[unit] and frames[pet] then
		-- Has VehicleUI now but did not previously
		inVehicle[unit] = true
		frames[unit].fontStrings, frames[pet].fontStrings = frames[pet].fontStrings, frames[unit].fontStrings
		unitMap[unit], unitMap[pet] = unitMap[pet] or pet, unitMap[unit] or unit
	elseif inVehicle[unit] and not UnitHasVehicleUI(unit) and frames[unit] and frames[pet] then
		-- Had VehicleUI previously but does not now
		inVehicle[unit] = nil
		frames[unit].fontStrings, frames[pet].fontStrings = frames[pet].fontStrings, frames[unit].fontStrings
		unitMap[unit], unitMap[pet] = unitMap[pet] or pet, unitMap[unit] or unit
	end
	self:RefreshFontStrings()
end
