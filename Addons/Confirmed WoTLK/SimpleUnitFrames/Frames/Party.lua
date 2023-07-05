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

SUF.unitMap.party1 = "party"
SUF.unitMap.party2 = "party"
SUF.unitMap.party3 = "party"
SUF.unitMap.party4 = "party"

SUF.defaults.profile.party = {}
SUF.options.args.party = {
	type = 'group',
	name = L["Party Frames"],
	args = {},
	order = 150,
}

if CI then
	for i = 1, 4 do
		local partyFrame = "PartyMemberFrame"..i
		CI.frameSettings["party"..i] = { _G[partyFrame], 0.7, { "TOPLEFT", _G[partyFrame], "TOPLEFT", 30, 0 } }
	end
	CI:RegisterEvent("PARTY_MEMBERS_CHANGED", function()
		for i = 1, GetNumPartyMembers() do
			CI:UpdateClassIcon("party"..i)
		end
	end)
	
	SUF.defaults.profile.party.icon = true
	SUF.options.args.party.args.icon = {
		type = 'toggle',
		name = L["Display Class Icon"],
		desc = L["Display a Class Icon on this frame"],
		get = function(info) return info.handler.db.profile.party.icon end,
		set = function(info, val)
			info.handler.db.profile.party.icon = val
			for i = 1, 4 do
				CI:UpdateClassIcon("party"..i)
			end
		end,
		order = 100,
	}
end

if TO then
	for i = 1, 4 do
		local partyFrame = "PartyMemberFrame"..i
		TO.frameSettings["party"..i] = {
			parent = _G[partyFrame],
			text = {
				mhp = { "TOP", _G[partyFrame.."HealthBar"], "TOP", 0, 1 },
				rhp = { "TOPLEFT", _G[partyFrame.."HealthBar"], "TOPRIGHT", 2, 1 },
				mmp = { "TOP", _G[partyFrame.."ManaBar"], "TOP", 0, 1 },
				rmp = { "TOPLEFT", _G[partyFrame.."ManaBar"], "TOPRIGHT", 2, 1 },
			},
		}
	end
	
	SUF.defaults.profile.party.mhp = "HPpercent"
	SUF.defaults.profile.party.rhp = "HPcurrmax"
	SUF.defaults.profile.party.mmp = "MPpercent"
	SUF.defaults.profile.party.rmp = "MPcurrmax"
	SUF.options.args.party.args.mhp = {
		type = 'select',
		name = L["Middle HP"],
		desc = L["Middle HP Style"],
		get = function(info) return info.handler.db.profile.party.mhp end,
		set = function(info, val)
			info.handler.db.profile.party.mhp = val
			for i = 1, 4 do
				TO:RefreshFontStrings("party"..i)
			end
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 200,
	}
	SUF.options.args.party.args.rhp = {
		type = 'select',
		name = L["Right HP"],
		desc = L["Right HP Style"],
		get = function(info) return info.handler.db.profile.party.rhp end,
		set = function(info, val)
			info.handler.db.profile.party.rhp = val
			for i = 1, 4 do
				TO:RefreshFontStrings("party"..i)
			end
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 210,
	}
	SUF.options.args.party.args.mmp = {
		type = 'select',
		name = L["Middle MP"],
		desc = L["Middle MP Style"],
		get = function(info) return info.handler.db.profile.party.mmp end,
		set = function(info, val)
			info.handler.db.profile.party.mmp = val
			for i = 1, 4 do
				TO:RefreshFontStrings("party"..i)
			end
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 220,
	}
	SUF.options.args.party.args.rmp = {
		type = 'select',
		name = L["Right MP"],
		desc = L["Right MP Style"],
		get = function(info) return info.handler.db.profile.party.rmp end,
		set = function(info, val)
			info.handler.db.profile.party.rmp = val
			for i = 1, 4 do
				TO:RefreshFontStrings("party"..i)
			end
		end,
		style = 'dropdown',
		values = TO.formatList.MP,
		order = 230,
	}
	
	-- Disable the default HP/MP text
	for i = 1, 4 do
		TO:SecureHook(_G["PartyMemberFrame"..i.."HealthBar"].TextString, "Show", function(f) f:Hide() end)
		TO:SecureHook(_G["PartyMemberFrame"..i.."ManaBar"].TextString, "Show", function(f) f:Hide() end)
	end
end

if PD then
	for i = 1, 4 do
		local partyFrame = "PartyMemberFrame"..i
		PD.frameSettings["party"..i] = { _G[partyFrame], 30, { "CENTER", _G[partyFrame].portrait, "CENTER" } }
	end
	
	SUF.defaults.profile.party.portraitdamage = true
	SUF.options.args.party.args.portraitdamage = {
		type = 'toggle',
		name = L["Display Portrait Damage"],
		desc = L["Display Portrait Damage on this frame"],
		get = function(info) return info.handler.db.profile.party.portraitdamage end,
		set = function(info, val)
			info.handler.db.profile.party.portraitdamage = val
			for i = 1, 4 do
				PD:RefreshSettings("party"..i)
			end
		end,
		order = 150,
	}
end

if BT then
	for i = 1, 4 do
		BT.bars[_G["PartyMemberFrame"..i.."HealthBar"]] = true
		BT.bars[_G["PartyMemberFrame"..i.."ManaBar"]] = true
	end
end
