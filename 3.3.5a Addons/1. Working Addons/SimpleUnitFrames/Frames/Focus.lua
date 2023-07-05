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
local PD = SUF:GetModule("PortraitDamage", true)
local BT = SUF:GetModule("BarTexture", true)

SUF.defaults.profile.focus = {}
SUF.options.args.focus = {
	type = 'group',
	name = L["Focus Frame"],
	args = {},
	order = 170,
}

if CI then
	CI.frameSettings.focus = { FocusFrame, 1.1, { "TOPRIGHT", FocusFrame, "TOPRIGHT", -85, -5 } }
	CI:RegisterEvent("PLAYER_FOCUS_CHANGED", function() CI:UpdateClassIcon("focus") end)
	
	SUF.defaults.profile.focus.icon = true
	SUF.options.args.focus.args.icon = {
		type = 'toggle',
		name = L["Display Class Icon"],
		desc = L["Display a Class Icon on this frame"],
		get = function(info) return info.handler.db.profile.focus.icon end,
		set = function(info, val) 
			info.handler.db.profile.focus.icon = val 
			CI:UpdateClassIcon("focus")
		end,
		order = 100,
	}
end

if TO then
	TO.frameSettings.focus = {
		parent = FocusFrame,
		text = {
			mhp = { "TOP", FocusFrameHealthBar, "TOP" },
			mmp = { "TOP", FocusFrameManaBar, "TOP" },
		},
	}
	
	SUF.defaults.profile.focus.mhp = "HPcomplete"
	SUF.defaults.profile.focus.mmp = "MPcomplete"
	SUF.options.args.focus.args.mhp = {
		type = 'select',
		name = L["Middle HP"],
		desc = L["Middle HP Style"],
		get = function(info) return info.handler.db.profile.focus.mhp end,
		set = function(info, val)
			info.handler.db.profile.focus.mhp = val
			TO:RefreshFontStrings("focus")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 200,
	}
	SUF.options.args.focus.args.mmp = {
		type = 'select',
		name = L["Middle MP"],
		desc = L["Middle MP Style"],
		get = function(info) return info.handler.db.profile.focus.mmp end,
		set = function(info, val)
			info.handler.db.profile.focus.mmp = val
			TO:RefreshFontStrings("focus")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 210,
	}
	
	-- Disable the default HP/MP text
	TO:SecureHook(FocusFrameHealthBar.TextString, "Show", function(f) f:Hide() end)
	TO:SecureHook(FocusFrameManaBar.TextString, "Show", function(f) f:Hide() end)
	
	-- Disable the "Dead" text
	FocusFrame.deadText:SetText()
end

if PD then
	PD.frameSettings.focus = { FocusFrame, 30, { "CENTER", FocusFrame.portrait, "CENTER" } }
	
	SUF.defaults.profile.focus.portraitdamage = true
	SUF.options.args.focus.args.portraitdamage = {
		type = 'toggle',
		name = L["Display Portrait Damage"],
		desc = L["Display Portrait Damage on this frame"],
		get = function(info) return info.handler.db.profile.focus.portraitdamage end,
		set = function(info, val)
			info.handler.db.profile.focus.portraitdamage = val
			PD:RefreshSettings("focus")
		end,
		order = 150,
	}
end

if BT then
	BT.bars[FocusFrameHealthBar] = true
	BT.bars[FocusFrameManaBar] = true
end
