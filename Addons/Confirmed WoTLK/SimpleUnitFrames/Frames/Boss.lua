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

for i = 1, MAX_BOSS_FRAMES do
	SUF.unitMap["boss"..i] = "boss"
end

SUF.defaults.profile.boss = {}
SUF.options.args.boss = {
	type = 'group',
	name = L["Boss Frames"],
	args = {},
	order = 190,
}

if TO then
	for i = 1, MAX_BOSS_FRAMES do
		local bossFrame = "Boss"..i.."TargetFrame"
		TO.frameSettings["boss"..i] = {
			parent = _G[bossFrame],
			text = {
				mhp = { "TOP", _G[bossFrame.."HealthBar"], "TOP", 0, 1 },
				mmp = { "TOP", _G[bossFrame.."ManaBar"], "TOP", 0, 1 },
				lhp = { "TOPRIGHT", _G[bossFrame.."HealthBar"], "TOPLEFT", -2, 1 },
				lmp = { "TOPRIGHT", _G[bossFrame.."ManaBar"], "TOPLEFT", -2, 1 },
			},
		}
	end
	
	SUF.defaults.profile.boss.mhp = "HPcurrmax"
	SUF.defaults.profile.boss.mmp = "MPcurrmax"
	SUF.defaults.profile.boss.lhp = "HPpercent"
	SUF.defaults.profile.boss.lmp = "MPpercent"
	SUF.options.args.boss.args.mhp = {
		type = 'select',
		name = L["Middle HP"],
		desc = L["Middle HP Style"],
		get = function(info) return info.handler.db.profile.boss.mhp end,
		set = function(info, val)
			info.handler.db.profile.boss.mhp = val
			for i = 1, MAX_BOSS_FRAMES do
				TO:RefreshFontStrings("boss"..i)
			end
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 200,
	}
	SUF.options.args.boss.args.mmp = {
		type = 'select',
		name = L["Middle MP"],
		desc = L["Middle MP Style"],
		get = function(info) return info.handler.db.profile.boss.mmp end,
		set = function(info, val)
			info.handler.db.profile.boss.mmp = val
			for i = 1, MAX_BOSS_FRAMES do
				TO:RefreshFontStrings("boss"..i)
			end
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 210,
	}
	SUF.options.args.boss.args.lhp = {
		type = 'select',
		name = L["Left HP"],
		desc = L["Left HP Style"],
		get = function(info) return info.handler.db.profile.boss.lhp end,
		set = function(info, val)
			info.handler.db.profile.boss.lhp = val
			for i = 1, MAX_BOSS_FRAMES do
				TO:RefreshFontStrings("boss"..i)
			end
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 220,
	}
	SUF.options.args.boss.args.lmp = {
		type = 'select',
		name = L["Left MP"],
		desc = L["Left MP Style"],
		get = function(info) return info.handler.db.profile.boss.lmp end,
		set = function(info, val)
			info.handler.db.profile.boss.lmp = val
			for i = 1, MAX_BOSS_FRAMES do
				TO:RefreshFontStrings("boss"..i)
			end
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 230,
	}
	
	-- Disable the default HP/MP text
	for i = 1, MAX_BOSS_FRAMES do
		TO:SecureHook(_G["Boss"..i.."TargetFrameHealthBar"].TextString, "Show", function(f) f:Hide() end)
		TO:SecureHook(_G["Boss"..i.."TargetFrameManaBar"].TextString, "Show", function(f) f:Hide() end)
	end
	
	-- Disable the "Dead" text
	for i = 1, MAX_BOSS_FRAMES do
		_G["Boss"..i.."TargetFrame"].deadText:SetText()
	end
end

if BT then
	for i = 1, MAX_BOSS_FRAMES do
		BT.bars[_G["Boss"..i.."TargetFrameHealthBar"]] = true
		BT.bars[_G["Boss"..i.."TargetFrameManaBar"]] = true
	end
end
