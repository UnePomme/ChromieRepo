--[[ ---------------------------------------------------------------------------
Name:	SimpleUnitFrames
Author:	Pneumatus
About:	An extension to the default WoW Unit Frames. Rather than a complete 
		unitframe replacement, this addon adds further information and features
		to the existing frames and allows a greater degree of customization to 
		enhance their usability.
----------------------------------------------------------------------------- ]]

local SUF = LibStub("AceAddon-3.0"):GetAddon("SimpleUnitFrames")
local CI = SUF:NewModule("ClassIcon", "AceEvent-3.0")
local BCT = LibStub("LibBabble-CreatureType-3.0"):GetReverseLookupTable()

local CREATURE_TEXTURES = {
	["Beast"]			= "Interface\\Icons\\Ability_Tracking",
	["Critter"]			= "Interface\\Icons\\Spell_Nature_Polymorph",
	["Demon"]			= "Interface\\Icons\\Spell_Shadow_SummonFelhunter",
	["Dragonkin"]		= "Interface\\Icons\\INV_Misc_Head_Dragon_01",
	["Elemental"]		= "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
	["Giant"]			= "Interface\\Icons\\Ability_Racial_Avatar",
	["Gas Cloud"]		= "Interface\\Icons\\INV_Elemental_Mote_Air01",
	["Humanoid"]		= "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
	["Mechanical"]		= "Interface\\Icons\\Trade_Engineering",
	["Non-combat Pet"]	= "Interface\\Icons\\INV_Box_PetCarrier_01",
	["Not specified"]	= "Interface\\Icons\\INV_Misc_QuestionMark",
	["Totem"]			= "Interface\\Icons\\Spell_Totem_WardOfDraining",
	["Undead"]			= "Interface\\Icons\\Spell_Shadow_DarkSummoning",
	["Unknown"]			= "Interface\\Icons\\INV_Misc_QuestionMark",
}

local frames = {}

CI.frameSettings = {}

function CI:OnInitialize()
	for unit, args in pairs(self.frameSettings) do
		self:CreateNewFrame(unit, unpack(args))
	end
	SUF.db.RegisterCallback(self, "OnProfileChanged", function() self:UpdateClassIcon() end)
	SUF.db.RegisterCallback(self, "OnProfileCopied", function() self:UpdateClassIcon() end)
	SUF.db.RegisterCallback(self, "OnProfileReset", function() self:UpdateClassIcon() end)
end

function CI:OnEnable()
	self:UpdateClassIcon()
end

function CI:OnDisable()
end

function CI:CreateNewFrame(unit, parent, scale, points)
	local frame = CreateFrame("Frame", nil, parent)
	frames[unit] = frame
	frame:SetWidth(31*scale)
	frame:SetHeight(31*scale)
	frame:SetFrameLevel(parent:GetFrameLevel()+3)
	frame:SetPoint(unpack(points))
	
	local icon = frame:CreateTexture(nil, "BACKGROUND")
	frame.icon = icon
	icon:SetWidth(20*scale)
	icon:SetHeight(20*scale)
	icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 7*scale, -5*scale)
	
	local overlay = frame:CreateTexture(nil, "OVERLAY")
	frame.overlay = overlay
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetWidth(53*scale)
	overlay:SetHeight(53*scale)
	overlay:SetPoint("TOPLEFT", frame, "TOPLEFT")
end

function CI:UpdateClassIcon(unit)
	if unit then
		local frame = frames[unit]
		local icon = frame and frame.icon
		local mappedUnit = SUF.unitMap[unit] or unit
		if icon and UnitExists(unit) and SUF.db.profile[mappedUnit].icon then
			local coords = CLASS_BUTTONS[select(2, UnitClass(unit))]
			if UnitIsPlayer(unit) and coords then
				icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
				icon:SetTexCoord(unpack(coords))
			else
				local creatureType = BCT[UnitCreatureType(unit)] or "Unknown"
				local texture = CREATURE_TEXTURES[creatureType]
				icon:SetTexture(texture)
				icon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
			end
			if not frame:IsVisible() then
				frame:Show()
			end
		elseif frame then
			frame:Hide()
		end
	else
		for unit, _ in pairs(frames) do
			self:UpdateClassIcon(unit)
		end
	end
end
