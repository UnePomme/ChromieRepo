--[[ ---------------------------------------------------------------------------
Name:	SimpleUnitFrames
Author:	Pneumatus
About:	An extension to the default WoW Unit Frames. Rather than a complete 
		unitframe replacement, this addon adds further information and features
		to the existing frames and allows a greater degree of customization to 
		enhance their usability.
----------------------------------------------------------------------------- ]]

local SUF = LibStub("AceAddon-3.0"):NewAddon("SimpleUnitFrames", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SimpleUnitFrames")

SUF.unitMap = {}

SUF.defaults = {
	global = {},
	profile = {},
}

SUF.options = {
	type = 'group',
	name = "SimpleUnitFrames",
	handler = SUF,
	args = {
		general = {
			type = 'group',
			name = L["General"],
			args = {},
		},
	},
}

function SUF:OnInitialize()
	-- Set up the SavedVariables DB
	self.db = LibStub("AceDB-3.0"):New("SimpleUnitFramesDB", self.defaults)
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.options.args.profiles.order = 1000
	
	-- Set up the InterfaceOptions
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SimpleUnitFrames", self.options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SimpleUnitFrames", "SimpleUnitFrames")
	
	-- Register slash commands
	self:RegisterChatCommand("simpleunitframes", function() InterfaceOptionsFrame_OpenToCategory("SimpleUnitFrames") end)
	self:RegisterChatCommand("suf", function() InterfaceOptionsFrame_OpenToCategory("SimpleUnitFrames") end)
end

function SUF:OnEnable()
end

function SUF:OnDisable()
end
