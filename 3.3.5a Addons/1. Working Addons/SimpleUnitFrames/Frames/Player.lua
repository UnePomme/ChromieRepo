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
local CI = SUF:GetModule("ClassIcon", true)
local TO = SUF:GetModule("TextOverlay", true)
local BT = SUF:GetModule("BarTexture", true)

SUF.defaults.profile.player = {}
SUF.options.args.player = {
	type = 'group',
	name = L["Player Frame"],
	args = {},
	order = 110,
}

if CI then
	CI.frameSettings.player = { PlayerFrame, 1.1, { "TOPLEFT", PlayerFrame, "TOPLEFT", 85, -5 } }
	
	SUF.defaults.profile.player.icon = true
	SUF.options.args.player.args.icon = {
		type = 'toggle',
		name = L["Display Class Icon"],
		desc = L["Display a Class Icon on this frame"],
		get = function(info) return info.handler.db.profile.player.icon end,
		set = function(info, val)
			info.handler.db.profile.player.icon = val
			CI:UpdateClassIcon("player")
		end,
		order = 100,
	}
end

if TO then
	TO.frameSettings.player = {
		parent = PlayerFrame,
		text = {
			mhp = { "TOP", PlayerFrameHealthBar, "TOP" },
			rhp = { "TOPLEFT", PlayerFrameHealthBar, "TOPRIGHT", 5, 0 },
			mmp = { "TOP", PlayerFrameManaBar, "TOP" },
			rmp = { "TOPLEFT", PlayerFrameManaBar, "TOPRIGHT", 5, 0 },
		},
	}
	
	SUF.defaults.profile.player.mhp = "HPcurrmax"
	SUF.defaults.profile.player.rhp = "HPpercent"
	SUF.defaults.profile.player.mmp = "MPcurrmax"
	SUF.defaults.profile.player.rmp = "MPpercent"
	SUF.options.args.player.args.mhp = {
		type = 'select',
		name = L["Middle HP"],
		desc = L["Middle HP Style"],
		get = function(info) return info.handler.db.profile.player.mhp end,
		set = function(info, val)
			info.handler.db.profile.player.mhp = val
			TO:RefreshFontStrings("player")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 200,
	}
	SUF.options.args.player.args.rhp = {
		type = 'select',
		name = L["Right HP"],
		desc = L["Right HP Style"],
		get = function(info) return info.handler.db.profile.player.rhp end,
		set = function(info, val)
			info.handler.db.profile.player.rhp = val
			TO:RefreshFontStrings("player")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 210,
	}
	SUF.options.args.player.args.mmp = {
		type = 'select',
		name = L["Middle MP"],
		desc = L["Middle MP Style"],
		get = function(info) return info.handler.db.profile.player.mmp end,
		set = function(info, val)
			info.handler.db.profile.player.mmp = val
			TO:RefreshFontStrings("player")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 220,
	}
	SUF.options.args.player.args.rmp = {
		type = 'select',
		name = L["Right MP"],
		desc = L["Right MP Style"],
		get = function(info) return info.handler.db.profile.player.rmp end,
		set = function(info, val)
			info.handler.db.profile.player.rmp = val
			TO:RefreshFontStrings("player")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 230,
	}
	
	-- Disable the default HP/MP text
	TO:SecureHook(PlayerFrameHealthBar.TextString, "Show", function(f) f:Hide() end)
	TO:SecureHook(PlayerFrameManaBar.TextString, "Show", function(f) f:Hide() end)
end

if BT then
	BT.bars[PlayerFrameHealthBar] = true
	BT.bars[PlayerFrameManaBar] = true
end
