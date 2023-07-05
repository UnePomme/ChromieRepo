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
local BT = SUF:NewModule("BarTexture")
local LSM = LibStub("LibSharedMedia-3.0")

SUF.defaults.global.bartexture = {
	texture = "Blizzard",
}

SUF.options.args.general.args.texture = {
	type = 'select',
	name = L["Bar Textures"],
	desc = L["Health & Mana Bar Textures"],
	get = function(info) return info.handler.db.global.bartexture.texture end,
	set = function(info, val)
		info.handler.db.global.bartexture.texture = val
		BT:UpdateTexture()
	end,
	dialogControl = 'LSM30_Statusbar',
	values = AceGUIWidgetLSMlists.statusbar,
	order = 120,
}

BT.bars = {}

function BT:OnInitialize()
	SUF.db.RegisterCallback(self, "OnProfileChanged", function() self:UpdateTexture() end)
	SUF.db.RegisterCallback(self, "OnProfileCopied", function() self:UpdateTexture() end)
	SUF.db.RegisterCallback(self, "OnProfileReset", function() self:UpdateTexture() end)
	
	LSM.RegisterCallback(self, "LibSharedMedia_Registered", function(event, type, key) 
		if type == "statusbar" and key == SUF.db.global.bartexture.texture then self:UpdateTexture() end
	end)
	LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", function(event, type) 
		if type == "statusbar" then self:UpdateTexture() end
	end)
end

function BT:OnEnable()
	self:UpdateTexture()
end

function BT:OnDisable()
end

function BT:UpdateTexture(bar)
	if bar then
		bar:GetStatusBarTexture():SetTexture(LSM:Fetch("statusbar", SUF.db.global.bartexture.texture))
	else
		for bar, _ in pairs(self.bars) do
			self:UpdateTexture(bar)
		end
	end
end

