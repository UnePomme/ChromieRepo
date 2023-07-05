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

SUF.defaults.profile.targettarget = {}
SUF.options.args.targettarget = {
	type = 'group',
	name = L["TargetOfTarget Frame"],
	args = {},
	order = 140,
}

if TO then
	TO.frameSettings.targettarget = {
		parent = TargetFrameToT,
		text = {
			mhp = { "TOP", TargetFrameToTHealthBar, "TOP", 0, 2 },
			rhp = { "TOPLEFT", TargetFrameToTHealthBar, "TOPRIGHT", 32, 2 },
			mmp = { "TOP", TargetFrameToTManaBar, "TOP", 0, 2 },
			rmp = { "TOPLEFT", TargetFrameToTManaBar, "TOPRIGHT", 32, 2 },
		},
	}
	
	SUF.defaults.profile.targettarget.mhp = "HPpercent"
	SUF.defaults.profile.targettarget.rhp = "HPcurrmax"
	SUF.defaults.profile.targettarget.mmp = "MPpercent"
	SUF.defaults.profile.targettarget.rmp = "MPcurrmax"
	SUF.options.args.targettarget.args.mhp = {
		type = 'select',
		name = L["Middle HP"],
		desc = L["Middle HP Style"],
		get = function(info) return info.handler.db.profile.targettarget.mhp end,
		set = function(info, val)
			info.handler.db.profile.targettarget.mhp = val
			TO:RefreshFontStrings("targettarget")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 200,
	}
	SUF.options.args.targettarget.args.rhp = {
		type = 'select',
		name = L["Right HP"],
		desc = L["Right HP Style"],
		get = function(info) return info.handler.db.profile.targettarget.rhp end,
		set = function(info, val)
			info.handler.db.profile.targettarget.rhp = val
			TO:RefreshFontStrings("targettarget")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 210,
	}
	SUF.options.args.targettarget.args.mmp = {
		type = 'select',
		name = L["Middle MP"],
		desc = L["Middle MP Style"],
		get = function(info) return info.handler.db.profile.targettarget.mmp end,
		set = function(info, val)
			info.handler.db.profile.targettarget.mmp = val
			TO:RefreshFontStrings("targettarget")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 220,
	}
	SUF.options.args.targettarget.args.rmp = {
		type = 'select',
		name = L["Right MP"],
		desc = L["Right MP Style"],
		get = function(info) return info.handler.db.profile.targettarget.rmp end,
		set = function(info, val)
			info.handler.db.profile.targettarget.rmp = val
			TO:RefreshFontStrings("targettarget")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 230,
	}
	
	-- Disable the "Dead" text
	TargetFrameToT.deadText:SetText()
end

if BT then
	BT.bars[TargetFrameToTHealthBar] = true
	BT.bars[TargetFrameToTManaBar] = true
end

