--[[ ---------------------------------------------------------------------------
Name:	SimpleUnitFrames
Author:	Pneumatus
About:	An extension to the default WoW Unit Frames. Rather than a complete 
		unitframe replacement, this addon adds further information and features
		to the existing frames and allows a greater degree of customization to 
		enhance their usability.
----------------------------------------------------------------------------- ]]

if select(2, UnitClass("player")) ~= "DRUID" then return end

local SUF = LibStub("AceAddon-3.0"):GetAddon("SimpleUnitFrames")
local L = LibStub("AceLocale-3.0"):GetLocale("SimpleUnitFrames")
local TO = SUF:GetModule("TextOverlay", true)
local BT = SUF:GetModule("BarTexture", true)

if TO then
	TO.frameSettings.player.text.amp = { "TOP", PlayerFrameAlternateManaBar, "TOP" }
	
	SUF.defaults.profile.player.amp = "MPDcurrmax"
	SUF.options.args.player.args.amp = {
		type = 'select',
		name = L["Alternate MP"],
		desc = L["Alternate MP Style"],
		get = function(info) return info.handler.db.profile.player.amp end,
		set = function(info, val)
			info.handler.db.profile.player.amp = val
			TO:RefreshFontStrings("player")
		end,
		style = 'dropdown',
		values = TO.formatList.MPD,
		order = 240,
	}
	
	-- Disable the default MP text
	TO:SecureHook(PlayerFrameAlternateManaBar.TextString, "Show", function(f) f:Hide() end)
	
	-- Show/Hide the text overlay when PlayerFrameAlternateManaBar is shown/hidden
	TO:RegisterEvent("PLAYER_ENTERING_WORLD", function() TO:ToggleOverlay("player", "amp") end)
	TO:RegisterEvent("UNIT_DISPLAYPOWER", function() TO:ToggleOverlay("player", "amp") end)
end

if BT then
	BT.bars[PlayerFrameAlternateManaBar] = true
end
