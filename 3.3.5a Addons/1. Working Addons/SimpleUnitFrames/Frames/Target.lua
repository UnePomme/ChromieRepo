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

SUF.defaults.profile.target = {}
SUF.options.args.target = {
	type = 'group',
	name = L["Target Frame"],
	args = {},
	order = 130,
}

if CI then
	CI.frameSettings.target = { TargetFrame, 1.1, { "TOPRIGHT", TargetFrame, "TOPRIGHT", -85, -5 } }
	CI:RegisterEvent("PLAYER_TARGET_CHANGED", function() CI:UpdateClassIcon("target") end)
	
	SUF.defaults.profile.target.icon = true
	SUF.options.args.target.args.icon = {
		type = 'toggle',
		name = L["Display Class Icon"],
		desc = L["Display a Class Icon on this frame"],
		get = function(info) return info.handler.db.profile.target.icon end,
		set = function(info, val)
			info.handler.db.profile.target.icon = val
			CI:UpdateClassIcon("target")
		end,
		order = 100,
	}
end

if TO then
	TO.frameSettings.target = {
		parent = TargetFrame,
		text = {
			mhp = { "TOP", TargetFrameHealthBar, "TOP" },
			mmp = { "TOP", TargetFrameManaBar, "TOP" },
		},
	}
	
	SUF.defaults.profile.target.mhp = "HPcomplete"
	SUF.defaults.profile.target.mmp = "MPcomplete"
	SUF.options.args.target.args.mhp = {
		type = 'select',
		name = L["Middle HP"],
		desc = L["Middle HP Style"],
		get = function(info) return info.handler.db.profile.target.mhp end,
		set = function(info, val)
			info.handler.db.profile.target.mhp = val
			TO:RefreshFontStrings("target")
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 200,
	}
	SUF.options.args.target.args.mmp = {
		type = 'select',
		name = L["Middle MP"],
		desc = L["Middle MP Style"],
		get = function(info) return info.handler.db.profile.target.mmp end,
		set = function(info, val)
			info.handler.db.profile.target.mmp = val
			TO:RefreshFontStrings("target")
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 210,
	}
	
	-- Disable the default HP/MP text
	TO:SecureHook(TargetFrameHealthBar.TextString, "Show", function(f) f:Hide() end)
	TO:SecureHook(TargetFrameManaBar.TextString, "Show", function(f) f:Hide() end)
	
	-- Disable the "Dead" text
	TargetFrame.deadText:SetText()
end

if PD then
	PD.frameSettings.target = { TargetFrame, 30, { "CENTER", TargetFrame.portrait, "CENTER" } }
	
	SUF.defaults.profile.target.portraitdamage = true
	SUF.options.args.target.args.portraitdamage = {
		type = 'toggle',
		name = L["Display Portrait Damage"],
		desc = L["Display Portrait Damage on this frame"],
		get = function(info) return info.handler.db.profile.target.portraitdamage end,
		set = function(info, val)
			info.handler.db.profile.target.portraitdamage = val
			PD:RefreshSettings("target")
		end,
		order = 150,
	}
end

if BT then
	BT.bars[TargetFrameHealthBar] = true
	BT.bars[TargetFrameManaBar] = true
end
