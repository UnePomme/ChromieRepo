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

SUF.defaults.profile.focustarget = {}
SUF.options.args.focustarget = {
	type = 'group',
	name = L["FocusTarget Frame"],
	args = {},
	order = 180,
}

if TO then
	TO.frameSettings.focustarget = {
		parent = FocusFrameToT,
		text = {
			mhp = { "TOP", FocusFrameToTHealthBar, "TOP", 0, 2 },
			rhp = { "TOPLEFT", FocusFrameToTHealthBar, "TOPRIGHT", 32, 2 },
			mmp = { "TOP", FocusFrameToTManaBar, "TOP", 0, 2 },
			rmp = { "TOPLEFT", FocusFrameToTManaBar, "TOPRIGHT", 32, 2 },
		},
	}
	
	SUF.defaults.profile.focustarget.mhp = "HPpercent"
	SUF.defaults.profile.focustarget.rhp = "HPcurrmax"
	SUF.defaults.profile.focustarget.mmp = "MPpercent"
	SUF.defaults.profile.focustarget.rmp = "MPcurrmax"
	SUF.options.args.focustarget.args.mhp = {
		type = 'select',
		name = L["Middle HP"],
		desc = L["Middle HP Style"],
		get = function(info) return info.handler.db.profile.focustarget.mhp end,
		set = function(info, val)
			info.handler.db.profile.focustarget.mhp = val
			TO:RefreshFontStrings("focustarget")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 200,
	}
	SUF.options.args.focustarget.args.rhp = {
		type = 'select',
		name = L["Right HP"],
		desc = L["Right HP Style"],
		get = function(info) return info.handler.db.profile.focustarget.rhp end,
		set = function(info, val)
			info.handler.db.profile.focustarget.rhp = val
			TO:RefreshFontStrings("focustarget")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 210,
	}
	SUF.options.args.focustarget.args.mmp = {
		type = 'select',
		name = L["Middle MP"],
		desc = L["Middle MP Style"],
		get = function(info) return info.handler.db.profile.focustarget.mmp end,
		set = function(info, val)
			info.handler.db.profile.focustarget.mmp = val
			TO:RefreshFontStrings("focustarget")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 220,
	}
	SUF.options.args.focustarget.args.rmp = {
		type = 'select',
		name = L["Right MP"],
		desc = L["Right MP Style"],
		get = function(info) return info.handler.db.profile.focustarget.rmp end,
		set = function(info, val)
			info.handler.db.profile.focustarget.rmp = val
			TO:RefreshFontStrings("focustarget")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 230,
	}
	
	-- Disable the "Dead" text
	FocusFrameToT.deadText:SetText()
end

if BT then
	BT.bars[FocusFrameToTHealthBar] = true
	BT.bars[FocusFrameToTManaBar] = true
end
