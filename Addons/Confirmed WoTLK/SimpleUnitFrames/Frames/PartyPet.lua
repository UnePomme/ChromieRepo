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

SUF.unitMap.partypet1 = "partypet"
SUF.unitMap.partypet2 = "partypet"
SUF.unitMap.partypet3 = "partypet"
SUF.unitMap.partypet4 = "partypet"

SUF.defaults.profile.partypet = {}
SUF.options.args.partypet = {
	type = 'group',
	name = L["PartyPet Frames"],
	args = {},
	order = 160,
}

if TO then
	for i = 1, 4 do
		local partyPetFrame = "PartyMemberFrame"..i.."PetFrame"
		TO.frameSettings["partypet"..i] = {
			parent = _G[partyPetFrame],
			text = {
				mhp = { "TOPLEFT", _G[partyPetFrame.."HealthBar"], "TOPLEFT", 37, 2 },
			},
		}
	end
	
	SUF.defaults.profile.partypet.mhp = "HPcurrmax"
	SUF.options.args.partypet.args.mhp = {
		type = 'select',
		name = L["Middle HP"],
		desc = L["Middle HP Style"],
		get = function(info) return info.handler.db.profile.partypet.mhp end,
		set = function(info, val)
			info.handler.db.profile.partypet.mhp = val
			for i = 1, 4 do
				TO:RefreshFontStrings("partypet"..i)
			end
		end,
		style = 'dropdown',
		values = TO.formatList.HP,
		order = 200,
	}
end

if PD then
	for i = 1, 4 do
		local partyPetFrame = "PartyMemberFrame"..i.."PetFrame"
		PD.frameSettings["partypet"..i] = { _G[partyPetFrame], 16, { "CENTER", _G[partyPetFrame].portrait, "CENTER" } }
	end
	
	SUF.defaults.profile.partypet.portraitdamage = true
	SUF.options.args.partypet.args.portraitdamage = {
		type = 'toggle',
		name = L["Display Portrait Damage"],
		desc = L["Display Portrait Damage on this frame"],
		get = function(info) return info.handler.db.profile.partypet.portraitdamage end,
		set = function(info, val)
			info.handler.db.profile.partypet.portraitdamage = val
			for i = 1, 4 do
				PD:RefreshSettings("partypet"..i)
			end
		end,
		order = 150,
	}
end

if BT then
	for i = 1, 4 do
		BT.bars[_G["PartyMemberFrame"..i.."PetFrameHealthBar"]] = true
	end
end
