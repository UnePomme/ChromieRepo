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
local TO = SUF:GetModule("TextOverlay", true)
local BT = SUF:GetModule("BarTexture", true)

SUF.defaults.profile.pet = {}
SUF.options.args.pet = {
	type = 'group',
	name = L["Pet Frame"],
	args = {},
	order = 120,
}

if TO then
	TO.frameSettings.pet = {
		parent = PetFrame,
		text = {
			mhp = { "TOP", PetFrameHealthBar, "TOP", 0, 2 },
			rhp = { "TOPLEFT", PetFrameHealthBar, "TOPRIGHT", 1, 2 },
			mmp = { "TOP", PetFrameManaBar, "TOP", 0, 0 },
			rmp = { "TOPLEFT", PetFrameManaBar, "TOPRIGHT", 1, 0 },
		},
	}
	
	SUF.defaults.profile.pet.mhp = "HPpercent"
	SUF.defaults.profile.pet.rhp = "HPcurrmax"
	SUF.defaults.profile.pet.mmp = "MPpercent"
	SUF.defaults.profile.pet.rmp = "MPcurrmax"
	SUF.options.args.pet.args.mhp = {
		type = 'select',
		name = L["Middle HP"],
		desc = L["Middle HP Style"],
		get = function(info) return info.handler.db.profile.pet.mhp end,
		set = function(info, val)
			info.handler.db.profile.pet.mhp = val
			TO:RefreshFontStrings("pet")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 200,
	}
	SUF.options.args.pet.args.rhp = {
		type = 'select',
		name = L["Right HP"],
		desc = L["Right HP Style"],
		get = function(info) return info.handler.db.profile.pet.rhp end,
		set = function(info, val)
			info.handler.db.profile.pet.rhp = val
			TO:RefreshFontStrings("pet")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 210,
	}
	SUF.options.args.pet.args.mmp = {
		type = 'select',
		name = L["Middle MP"],
		desc = L["Middle MP Style"],
		get = function(info) return info.handler.db.profile.pet.mmp end,
		set = function(info, val)
			info.handler.db.profile.pet.mmp = val
			TO:RefreshFontStrings("pet")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 220,
	}
	SUF.options.args.pet.args.rmp = {
		type = 'select',
		name = L["Right MP"],
		desc = L["Right MP Style"],
		get = function(info) return info.handler.db.profile.pet.rmp end,
		set = function(info, val)
			info.handler.db.profile.pet.rmp = val
			TO:RefreshFontStrings("pet")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 230,
	}
	
	-- Disable the default HP/MP text
	TO:SecureHook(PetFrameHealthBar.TextString, "Show", function(f) f:Hide() end)
	TO:SecureHook(PetFrameManaBar.TextString, "Show", function(f) f:Hide() end)
end

if BT then
	BT.bars[PetFrameHealthBar] = true
	BT.bars[PetFrameManaBar] = true
end
